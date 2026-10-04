begin;

-- Only signup requests from an enabled new client carry this preference.
-- Existing accounts remain local until Set explicitly saves an account balance.
-- This is not an entitlement or security role; owners can already adopt via RPC.
create function public.account_simulated_balance_v3(
  p_expected_user_id uuid,
  p_operation jsonb default null
) returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null or p_expected_user_id is distinct from v_uid then
    raise exception 'balance_owner_mismatch' using errcode = '42501';
  end if;

  if exists (
    select 1 from auth.users
      where id = v_uid
        and raw_user_meta_data->>'decoy_balance_storage' = 'account_v1'
  ) then
    insert into public.simulated_balance_pilot_users(user_id) values (v_uid)
      on conflict (user_id) do nothing;
  end if;

  -- Reuse the tested spending, default, idempotency, and drain-only refill rules.
  return public.account_simulated_balance_v2(v_uid, p_operation);
end;
$$;

revoke all on function public.account_simulated_balance_v3(uuid, jsonb)
  from public, anon, authenticated;
grant execute on function public.account_simulated_balance_v3(uuid, jsonb)
  to authenticated;

commit;
