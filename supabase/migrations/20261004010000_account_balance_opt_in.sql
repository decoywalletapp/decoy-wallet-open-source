begin;

-- Explicit adoption only. Installing the migration enrolls or changes nobody.
create function public.adopt_account_simulated_balance(
  p_expected_user_id uuid,
  p_sats bigint,
  p_operation_id uuid
) returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_balance public.account_simulated_balances%rowtype;
begin
  if v_uid is null or p_expected_user_id is distinct from v_uid then
    raise exception 'balance_owner_mismatch' using errcode = '42501';
  end if;
  if p_sats is null or p_sats not between 0 and 2100000000000000
     or p_operation_id is null then
    raise exception 'invalid_balance_adoption';
  end if;

  insert into public.account_simulated_balances(user_id) values (v_uid)
    on conflict (user_id) do nothing;
  select * into v_balance from public.account_simulated_balances
    where user_id = v_uid for update;

  -- The first confirmed adoption wins, including zero. Retries and another
  -- device must never overwrite an existing account balance or its drain clock.
  if v_balance.epoch is null then
    update public.account_simulated_balances
      set sats = p_sats, configured_sats = p_sats, seeded_at = now(),
          epoch = p_operation_id, drained_at = null, refilled_from_epoch = null
      where user_id = v_uid;
    insert into public.simulated_balance_operations(user_id, operation_id)
      values (v_uid, p_operation_id) on conflict do nothing;
  end if;
  insert into public.simulated_balance_pilot_users(user_id) values (v_uid)
    on conflict (user_id) do nothing;
  return public.account_simulated_balance(v_uid);
end;
$$;

revoke all on function public.adopt_account_simulated_balance(uuid, bigint, uuid)
  from public, anon, authenticated;
grant execute on function public.adopt_account_simulated_balance(uuid, bigint, uuid)
  to authenticated;

commit;
