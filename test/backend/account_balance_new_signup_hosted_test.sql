-- Staging only, after the new-signup migration. Both synthetic users roll back.
begin;
do $$
declare
  v_old uuid := gen_random_uuid();
  v_new uuid := gen_random_uuid();
begin
  perform set_config('decoy.balance_old_fixture', v_old::text, true);
  perform set_config('decoy.balance_new_fixture', v_new::text, true);
  insert into auth.users(id, email, aud, role, raw_user_meta_data, created_at, updated_at)
    values
      (v_old, 'balance-old-' || v_old || '@example.invalid',
        'authenticated', 'authenticated', '{}', now(), now()),
      (v_new, 'balance-new-' || v_new || '@example.invalid',
        'authenticated', 'authenticated',
        '{"decoy_balance_storage":"account_v1"}', now(), now());
end;
$$;
select set_config('request.jwt.claim.sub', current_setting('decoy.balance_old_fixture'), true);
set local role authenticated;
do $$
declare
  v_old uuid := current_setting('decoy.balance_old_fixture')::uuid;
  v_result jsonb;
begin
  if (public.account_simulated_balance_v3(v_old)->>'eligible')::boolean then
    raise exception 'Existing account was automatically enrolled';
  end if;
  begin
    perform public.account_simulated_balance_v3(current_setting('decoy.balance_new_fixture')::uuid);
    raise exception 'Cross-account read was not rejected';
  exception when insufficient_privilege then null;
  end;
  v_result := public.adopt_account_simulated_balance(v_old, 452380952, gen_random_uuid());
  if (v_result->'balance'->>'sats')::bigint <> 452380952 then
    raise exception 'Set did not preserve the entered amount';
  end if;
end;
$$;
select set_config('request.jwt.claim.sub', current_setting('decoy.balance_new_fixture'), true);
do $$
declare
  v_new uuid := current_setting('decoy.balance_new_fixture')::uuid;
  v_first jsonb;
  v_partial jsonb;
begin
  if (public.account_simulated_balance_v3(v_new)->>'eligible')::boolean is not true then
    raise exception 'New signup did not start in account storage';
  end if;
  v_first := public.account_simulated_balance_v3(v_new, jsonb_build_object(
    'id', gen_random_uuid(), 'kind', 'seed', 'sats', 314159265));
  if (v_first->'balance'->>'sats')::bigint <> 314159265 or
      v_first->'balance'->>'configured_sats' is not null then
    raise exception 'New account default was not preserved as an unconfigured amount';
  end if;
  v_partial := public.account_simulated_balance_v3(v_new, jsonb_build_object(
    'id', gen_random_uuid(), 'kind', 'spend', 'sats', 100000000, 'fee_sats', 0,
    'expected_epoch', v_first->'balance'->>'epoch'));
  if (v_partial->'balance'->>'sats')::bigint <> 214159265 or
      v_partial->'balance'->>'drained_at' is not null or
      public.account_simulated_balance_v3(v_new) is distinct from v_partial then
    raise exception 'New account read changed the partially spent balance';
  end if;
end;
$$;
reset role;
select 'PASS: existing accounts preserved; Set and new signup defaults verified; fixtures rolled back' as result;
rollback;
