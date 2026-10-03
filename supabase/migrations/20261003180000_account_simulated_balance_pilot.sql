begin;

-- Empty by default. Populate only reviewed auth.users IDs during pilot rollout.
create table public.simulated_balance_pilot_users (
  user_id uuid primary key references auth.users(id) on delete cascade
);
create table public.account_simulated_balances (
  user_id uuid primary key references auth.users(id) on delete cascade,
  sats bigint not null default 0 check (sats between 0 and 2100000000000000),
  seeded_at timestamptz,
  epoch uuid,
  check ((seeded_at is null) = (epoch is null))
);
create table public.simulated_balance_operations (
  user_id uuid not null references auth.users(id) on delete cascade,
  operation_id uuid not null,
  applied_at timestamptz not null default now(),
  primary key (user_id, operation_id)
);

alter table public.simulated_balance_pilot_users enable row level security;
alter table public.account_simulated_balances enable row level security;
alter table public.simulated_balance_operations enable row level security;
revoke all on public.simulated_balance_pilot_users,
  public.account_simulated_balances, public.simulated_balance_operations
  from public, anon, authenticated;
grant all on public.simulated_balance_pilot_users,
  public.account_simulated_balances, public.simulated_balance_operations
  to service_role;

-- No direct client table access. All reads/writes derive ownership from auth.uid().
create function public.account_simulated_balance(
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
    if v_kind = 'configure' or (v_kind = 'seed' and
        (v_balance.seeded_at is null or
         v_balance.seeded_at <= now() - interval '24 hours')) then
      v_balance.sats := v_sats;
      v_balance.seeded_at := now();
      v_balance.epoch := v_id;
    elsif v_kind = 'spend' and v_balance.epoch is not null and
        v_expected_epoch = v_balance.epoch then
      v_balance.sats := greatest(0, v_balance.sats - v_sats);
      if v_balance.sats <= v_fee + 1 then v_balance.sats := 0; end if;
    end if;

    update public.account_simulated_balances set sats = v_balance.sats,
      seeded_at = v_balance.seeded_at, epoch = v_balance.epoch
      where user_id = v_uid;
    insert into public.simulated_balance_operations(user_id, operation_id)
      values (v_uid, v_id);
  end if;

  return jsonb_build_object('eligible', true, 'balance', jsonb_build_object(
    'sats', v_balance.sats, 'seeded_at', v_balance.seeded_at,
    'epoch', v_balance.epoch));
end;
$$;
revoke all on function public.account_simulated_balance(uuid, jsonb)
  from public, anon, authenticated;
grant execute on function public.account_simulated_balance(uuid, jsonb)
  to authenticated;

commit;
