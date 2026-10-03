begin;

alter table public.account_simulated_balances
  add column configured_sats bigint
    check (configured_sats between 0 and 2100000000000000),
  add column drained_at timestamptz,
  add column refilled_from_epoch uuid,
  add constraint account_balance_drain_requires_zero check (
    drained_at is null or
    (sats = 0 and configured_sats is distinct from 0 and epoch is not null)
  );

-- The first pilot did not retain custom starting amounts. Preserve the current
-- amount (including intentional/unknown zero) rather than guessing or refilling.
-- Testers can save their desired custom amount once in the updated pilot.
update public.account_simulated_balances set configured_sats = sats
  where epoch is not null;

-- Update the original endpoint too so an older online pilot cannot overwrite
-- a nonzero balance with its former time-based seed operation.
create or replace function public.account_simulated_balance(
  p_expected_user_id uuid,
  p_operation jsonb default null
) returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_balance public.account_simulated_balances%rowtype;
  v_id uuid;
  v_kind text;
  v_sats bigint;
  v_fee bigint;
  v_expected_epoch uuid;
begin
  if v_uid is null or p_expected_user_id is distinct from v_uid then
    raise exception 'balance_owner_mismatch' using errcode = '42501';
  end if;
  if not exists (select 1 from public.simulated_balance_pilot_users
      where user_id = v_uid) then
    return jsonb_build_object('eligible', false, 'balance', null);
  end if;

  if p_operation is not null then
    v_id := (p_operation->>'id')::uuid;
    v_kind := p_operation->>'kind';
    v_sats := (p_operation->>'sats')::bigint;
    v_fee := coalesce((p_operation->>'fee_sats')::bigint, 0);
    v_expected_epoch := (p_operation->>'expected_epoch')::uuid;
    if v_id is null or v_kind is null or
        v_kind not in ('seed', 'configure', 'spend') or
        v_sats is null or v_sats not between 0 and 2100000000000000 or
        v_fee not between 0 and 2100000000000000 then
      raise exception 'invalid_balance_operation';
    end if;
    if v_kind = 'seed' and v_sats not between 100000000 and 500000000 then
      raise exception 'invalid_initial_balance';
    end if;
  end if;

  insert into public.account_simulated_balances(user_id) values (v_uid)
    on conflict (user_id) do nothing;
  select * into v_balance from public.account_simulated_balances
    where user_id = v_uid for update;

  if p_operation is not null and not exists (
      select 1 from public.simulated_balance_operations
      where user_id = v_uid and operation_id = v_id) then
    if v_kind = 'configure' then
      v_balance.sats := v_sats;
      v_balance.configured_sats := v_sats;
      v_balance.seeded_at := now();
      v_balance.drained_at := null;
      v_balance.refilled_from_epoch := null;
      v_balance.epoch := v_id;
    elsif v_kind = 'seed' and (
        v_balance.epoch is null or
        (v_expected_epoch = v_balance.epoch and
         v_balance.sats = 0 and
         v_balance.configured_sats is distinct from 0 and
         v_balance.drained_at <= now() - interval '24 hours')) then
      v_balance.sats := coalesce(v_balance.configured_sats, v_sats);
      v_balance.seeded_at := now();
      v_balance.drained_at := null;
      v_balance.refilled_from_epoch := v_balance.epoch;
      v_balance.epoch := v_id;
    elsif v_kind = 'spend' and v_sats > 0 and v_balance.sats > 0 and
        v_balance.epoch is not null and v_expected_epoch = v_balance.epoch then
      v_balance.sats := greatest(0, v_balance.sats - v_sats);
      if v_balance.sats <= v_fee + 1 then
        v_balance.sats := 0;
        -- Server receipt time is authoritative, including queued offline sends.
        v_balance.drained_at := now();
      end if;
    end if;

    update public.account_simulated_balances set sats = v_balance.sats,
      configured_sats = v_balance.configured_sats,
      drained_at = v_balance.drained_at,
      refilled_from_epoch = v_balance.refilled_from_epoch,
      seeded_at = v_balance.seeded_at, epoch = v_balance.epoch
      where user_id = v_uid;
    insert into public.simulated_balance_operations(user_id, operation_id)
      values (v_uid, v_id);
  end if;

  return jsonb_build_object('eligible', true, 'balance', jsonb_build_object(
    'sats', v_balance.sats, 'seeded_at', v_balance.seeded_at,
    'epoch', v_balance.epoch, 'configured_sats', v_balance.configured_sats,
    'drained_at', v_balance.drained_at,
    'refilled_from_epoch', v_balance.refilled_from_epoch));
end;
$$;

-- New clients require this endpoint so they cannot silently use old reset rules
-- if the database migration has not yet been deployed.
create function public.account_simulated_balance_v2(
  p_expected_user_id uuid,
  p_operation jsonb default null
) returns jsonb
language sql security invoker set search_path = ''
as $$
  select public.account_simulated_balance(p_expected_user_id, p_operation);
$$;

revoke all on function public.account_simulated_balance(uuid, jsonb),
  public.account_simulated_balance_v2(uuid, jsonb)
  from public, anon, authenticated;
grant execute on function public.account_simulated_balance(uuid, jsonb),
  public.account_simulated_balance_v2(uuid, jsonb)
  to authenticated;

commit;
