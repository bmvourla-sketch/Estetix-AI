-- Storage upgrade: spend tokens to increase the user's max storage quota.
create or replace function public.upgrade_storage(user_id uuid, amount_mb numeric, cost int)
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
     set token_balance = token_balance - cost,
         max_storage_mb = max_storage_mb + amount_mb
   where id = user_id and token_balance >= cost
   returning * into updated;

  if updated is null then
    raise exception 'INSUFFICIENT_TOKEN_BALANCE';
  end if;

  return updated;
end;
$$;

grant execute on function public.upgrade_storage(uuid, numeric, int) to authenticated;
