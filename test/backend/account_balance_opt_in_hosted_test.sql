-- Run only in the staging SQL editor after applying the opt-in migration.
-- The fixture is new, has no password, and is rolled back with all its data.
begin;
do $$
declare
  v_id uuid := gen_random_uuid();
begin
  perform set_config('decoy.balance_test_user', v_id::text, true);
  insert into auth.users(id, email, aud, role, created_at, updated_at)
    values (v_id, 'balance-opt-in-' || v_id || '@example.invalid',
      'authenticated', 'authenticated', now(), now());
end;
$$;
select set_config('request.jwt.claim.sub', current_setting('decoy.balance_test_user'), true);
set local role authenticated;
do $$
declare
  v_id uuid := current_setting('decoy.balance_test_user')::uuid;
  v_first jsonb;
  v_next jsonb;
  v_epoch uuid;
begin
  if (public.account_simulated_balance_v2(v_id)->>'eligible')::boolean then
    raise exception 'Unenrolled account unexpectedly active';
  end if;
  begin
    perform public.adopt_account_simulated_balance(gen_random_uuid(), 1, gen_random_uuid());
    raise exception 'Cross-account adoption was not rejected';
  exception when insufficient_privilege then null;
  end;
  v_first := public.adopt_account_simulated_balance(v_id, 1234567891, gen_random_uuid());
  if (v_first->'balance'->>'sats')::bigint <> 1234567891 or
      (v_first->>'eligible')::boolean is not true then
    raise exception 'Initial adoption did not preserve the chosen amount';
  end if;
  v_next := public.adopt_account_simulated_balance(v_id, 9999999999, gen_random_uuid());
  if v_next is distinct from v_first then
    raise exception 'Retry overwrote the account balance';
  end if;
  v_epoch := (v_first->'balance'->>'epoch')::uuid;
  v_first := public.account_simulated_balance_v2(v_id, jsonb_build_object(
    'id', gen_random_uuid(), 'kind', 'spend', 'sats', 1234567891,
    'fee_sats', 0, 'expected_epoch', v_epoch));
  v_next := public.adopt_account_simulated_balance(v_id, 500000000, gen_random_uuid());
  if v_next is distinct from v_first or
      (v_next->'balance'->>'sats')::bigint <> 0 or
      v_next->'balance'->>'drained_at' is null then
    raise exception 'Adoption modified a drained balance or its timer';
  end if;
end;
$$;
reset role;
select 'PASS: authenticated adoption, ownership, retries, and drain preservation; fixture rolled back' as result;
rollback;
