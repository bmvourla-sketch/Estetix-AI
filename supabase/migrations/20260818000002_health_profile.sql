-- Health profile columns for personalized diet programs.
alter table public.profiles
  add column if not exists age int,
  add column if not exists height_cm int,
  add column if not exists weight_kg numeric,
  add column if not exists health_conditions text,
  add column if not exists goal text;
