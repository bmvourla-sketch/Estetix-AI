-- Wardrobe: the user's photographed clothing / self photos for the
-- "Gardırop" fashion mode.
create table if not exists public.wardrobe_items (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users(id) on delete cascade,
  category    text not null,
  image_url   text not null,
  created_at  timestamptz not null default now()
);

alter table public.wardrobe_items enable row level security;

drop policy if exists "wardrobe_select_own" on public.wardrobe_items;
create policy "wardrobe_select_own" on public.wardrobe_items
  for select using (auth.uid() = user_id);

drop policy if exists "wardrobe_insert_own" on public.wardrobe_items;
create policy "wardrobe_insert_own" on public.wardrobe_items
  for insert with check (auth.uid() = user_id);

drop policy if exists "wardrobe_delete_own" on public.wardrobe_items;
create policy "wardrobe_delete_own" on public.wardrobe_items
  for delete using (auth.uid() = user_id);
