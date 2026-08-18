-- Weight log for diet progress tracking.
create table if not exists public.weight_entries (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users(id) on delete cascade,
  weight_kg   numeric not null,
  created_at  timestamptz not null default now()
);

alter table public.weight_entries enable row level security;

drop policy if exists "weight_select_own" on public.weight_entries;
create policy "weight_select_own" on public.weight_entries
  for select using (auth.uid() = user_id);

drop policy if exists "weight_insert_own" on public.weight_entries;
create policy "weight_insert_own" on public.weight_entries
  for insert with check (auth.uid() = user_id);
