-- ============================================================================
-- Estetix AI — Supabase schema
-- Run once in the Supabase SQL editor (Dashboard → SQL Editor → New query).
-- ============================================================================

-- 1) Profiles: one row per authenticated user.
--    Column defaults provision the free tier: 1 token, 0/50 MB storage.
create table if not exists public.profiles (
  id              uuid primary key references auth.users (id) on delete cascade,
  phone_number    text,
  device_uuid     text unique,
  token_balance   integer not null default 1,
  used_storage_mb numeric not null default 0.0,
  max_storage_mb  numeric not null default 50.0,
  created_at      timestamptz not null default now()
);

--    `pro_status` marks a paying subscriber (set by RevenueCat-backed RPCs).
alter table public.profiles
  add column if not exists pro_status boolean not null default false;

-- 2) Row Level Security: a user can only read/insert/update their own row.
alter table public.profiles enable row level security;

drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own" on public.profiles
  for select using (auth.uid() = id);

drop policy if exists "profiles_insert_own" on public.profiles;
create policy "profiles_insert_own" on public.profiles
  for insert with check (auth.uid() = id);

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own" on public.profiles
  for update using (auth.uid() = id);

-- 3) Realtime: enables WalletService.watchWallet(...).stream(...).
alter publication supabase_realtime add table public.profiles;

-- 4) Atomic wallet mutations, called via supabase.rpc(...).
--    security definer runs them as the owner; the `user_id <> auth.uid()`
--    guard prevents one client from mutating another user's row.
--    NOTE (security): `add_token` lets callers grant themselves tokens. In
--    production, revoke it from `authenticated` and call it only from a
--    service-role Edge Function after purchase verification:
--      revoke execute on function public.add_token(uuid, int) from authenticated;
create or replace function public.deduct_token(user_id uuid, amount int)
returns public.profiles
language plpgsql
security definer
set search_path = public
as $$
declare
  updated public.profiles;
begin
  if user_id <> auth.uid() then
    raise exception 'NOT_AUTHORIZED';
  end if;

  update public.profiles
     set token_balance = token_balance - amount
   where id = user_id and token_balance >= amount
  returning * into updated;

  if updated is null then
    raise exception 'INSUFFICIENT_TOKEN_BALANCE';
  end if;

  return updated;
end;
$$;

create or replace function public.add_token(user_id uuid, amount int)
returns public.profiles
language plpgsql
security definer
set search_path = public
as $$
declare
  updated public.profiles;
begin
  if user_id <> auth.uid() then
    raise exception 'NOT_AUTHORIZED';
  end if;

  update public.profiles
     set token_balance = token_balance + amount
   where id = user_id
  returning * into updated;

  if updated is null then
    raise exception 'PROFILE_NOT_FOUND';
  end if;

  return updated;
end;
$$;

create or replace function public.update_storage_usage(user_id uuid, used_storage_mb numeric)
returns public.profiles
language plpgsql
security definer
set search_path = public
as $$
declare
  updated public.profiles;
begin
  if user_id <> auth.uid() then
    raise exception 'NOT_AUTHORIZED';
  end if;

  update public.profiles
     set used_storage_mb = used_storage_mb
   where id = user_id
  returning * into updated;

  if updated is null then
    raise exception 'PROFILE_NOT_FOUND';
  end if;

  return updated;
end;
$$;

--    NOTE (security): like `add_token`, these grant-self RPCs should be
--    revoked from `authenticated` in production and invoked from a service-role
--    Edge Function after server-side purchase verification (RevenueCat webhook).
create or replace function public.update_user_credits(user_id uuid, delta int)
returns public.profiles
language plpgsql
security definer
set search_path = public
as $$
declare
  updated public.profiles;
begin
  if user_id <> auth.uid() then
    raise exception 'NOT_AUTHORIZED';
  end if;

  update public.profiles
     set token_balance = token_balance + delta
   where id = user_id
  returning * into updated;

  if updated is null then
    raise exception 'PROFILE_NOT_FOUND';
  end if;

  return updated;
end;
$$;

create or replace function public.set_pro_status(user_id uuid, is_pro boolean)
returns public.profiles
language plpgsql
security definer
set search_path = public
as $$
declare
  updated public.profiles;
begin
  if user_id <> auth.uid() then
    raise exception 'NOT_AUTHORIZED';
  end if;

  update public.profiles
     set pro_status = is_pro
   where id = user_id
  returning * into updated;

  if updated is null then
    raise exception 'PROFILE_NOT_FOUND';
  end if;

  return updated;
end;
$$;

--    Atomic balance pre-check for the transform-engine (runs before any AI
--    call). Does NOT deduct; the final `deduct_token` remains the authority.
create or replace function public.precheck_transform(user_id uuid, amount int)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
begin
  if user_id <> auth.uid() then
    raise exception 'NOT_AUTHORIZED';
  end if;

  if not exists (
    select 1 from public.profiles
    where id = user_id and token_balance >= amount
  ) then
    raise exception 'INSUFFICIENT_TOKEN_BALANCE';
  end if;

  return true;
end;
$$;

-- 5) Grants. Deduction + storage + precheck stay client-callable (the
--    transform-engine and Drive use the user's JWT). Balance/status *granting*
--    is revoked from PUBLIC and granted only to `service_role`, so only the
--    `paywall-webhook` Edge Function can grant credits / pro status.
grant execute on function public.deduct_token(uuid, int) to authenticated;
grant execute on function public.update_storage_usage(uuid, numeric) to authenticated;
grant execute on function public.precheck_transform(uuid, int) to authenticated;

revoke execute on function public.add_token(uuid, int) from public;
grant execute on function public.add_token(uuid, int) to service_role;

revoke execute on function public.update_user_credits(uuid, int) from public;
grant execute on function public.update_user_credits(uuid, int) to service_role;

revoke execute on function public.set_pro_status(uuid, boolean) from public;
grant execute on function public.set_pro_status(uuid, boolean) to service_role;

-- 6) Storage buckets for the AI transform pipeline.
--    `input-images`: client uploads the source photo (public read).
--    `renders`: the transform-engine Edge Function stores generated images.
insert into storage.buckets (id, name, public)
values ('input-images', 'input-images', true)
on conflict (id) do nothing;

insert into storage.buckets (id, name, public)
values ('renders', 'renders', true)
on conflict (id) do nothing;

drop policy if exists "input_images_public_read" on storage.objects;
create policy "input_images_public_read" on storage.objects
  for select using (bucket_id = 'input-images');

drop policy if exists "input_images_auth_insert" on storage.objects;
create policy "input_images_auth_insert" on storage.objects
  for insert with check (bucket_id = 'input-images' and auth.role() = 'authenticated');

drop policy if exists "renders_public_read" on storage.objects;
create policy "renders_public_read" on storage.objects
  for select using (bucket_id = 'renders');

drop policy if exists "renders_auth_insert" on storage.objects;
create policy "renders_auth_insert" on storage.objects
  for insert with check (bucket_id = 'renders' and auth.role() = 'authenticated');

-- 7) `user-drive`: per-user saved projects (PDF report + preview images).
--    Layout: user-drive/{user_id}/{category}/{project_id}/...
insert into storage.buckets (id, name, public)
values ('user-drive', 'user-drive', false)
on conflict (id) do nothing;

-- Private bucket: reads/writes are scoped to the owner's own folder
-- (user-drive/{user_id}/...). The client generates short-lived signed URLs
-- via createSignedUrl() for previews and downloads.
drop policy if exists "user_drive_select_own" on storage.objects;
create policy "user_drive_select_own" on storage.objects
  for select using (
    bucket_id = 'user-drive'
    and auth.role() = 'authenticated'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "user_drive_auth_insert" on storage.objects;
create policy "user_drive_auth_insert" on storage.objects
  for insert with check (
    bucket_id = 'user-drive'
    and auth.role() = 'authenticated'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
