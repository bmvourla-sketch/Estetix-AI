-- Saved "looks": liked transformation results (e.g. favorite outfits) that
-- can be re-viewed / re-worn.
create table if not exists public.saved_looks (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users(id) on delete cascade,
  module      text not null,
  render_url  text not null,
  summary     text not null default '',
  created_at  timestamptz not null default now()
);

alter table public.saved_looks enable row level security;

drop policy if exists "saved_looks_select_own" on public.saved_looks;
create policy "saved_looks_select_own" on public.saved_looks
  for select using (auth.uid() = user_id);

drop policy if exists "saved_looks_insert_own" on public.saved_looks;
create policy "saved_looks_insert_own" on public.saved_looks
  for insert with check (auth.uid() = user_id);

drop policy if exists "saved_looks_delete_own" on public.saved_looks;
create policy "saved_looks_delete_own" on public.saved_looks
  for delete using (auth.uid() = user_id);
