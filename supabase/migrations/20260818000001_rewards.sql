-- Reward tracking: one-time "rate the app" bonus flag.
alter table public.profiles
  add column if not exists has_rated boolean not null default false;
