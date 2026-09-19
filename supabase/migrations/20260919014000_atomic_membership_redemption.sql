begin;

alter table public.promo_codes
  add column if not exists reservation_session_id uuid
    references public.promo_redemption_sessions(id) on delete set null,
  add column if not exists reserved_access_started_at timestamptz,
  add column if not exists reserved_access_ends_at timestamptz,
  add column if not exists reserved_billing_sync_status text
    check (reserved_billing_sync_status in ('not_required', 'pending', 'complete'));

create or replace function public.reserve_membership_code(
  p_session_hash text,
  p_code_hash text
)
returns table (
  reservation_id uuid,
  user_id uuid,
  access_started_at timestamptz,
  access_ends_at timestamptz,
  billing_sync_status text,
  return_to text
)
language plpgsql
security definer
set search_path = public
as $$
#variable_conflict use_column
declare
  v_code public.promo_codes%rowtype;
  v_campaign public.promo_campaigns%rowtype;
  v_session public.promo_redemption_sessions%rowtype;
  v_entitlement public.user_entitlements%rowtype;
  v_start timestamptz;
  v_end timestamptz;
  v_billing_status text;
begin
  if auth.role() <> 'service_role' then
    raise exception 'service_role_required';
  end if;

  select * into v_session
  from public.promo_redemption_sessions
  where token_hash = p_session_hash
  for update;

  if not found or v_session.consumed_at is not null then
    raise exception 'invalid_or_expired_session';
  end if;

  select * into v_code
  from public.promo_codes
  where code_hash = p_code_hash
  for update;

  if not found then
    raise exception 'invalid_or_used_code';
  end if;

  if v_code.status = 'reserved'
      and v_code.reserved_by = v_session.user_id
      and v_code.reservation_session_id = v_session.id then
    return query select
      v_code.id,
      v_session.user_id,
      v_code.reserved_access_started_at,
      v_code.reserved_access_ends_at,
      coalesce(v_code.reserved_billing_sync_status, 'not_required'),
      v_session.return_to;
    return;
  end if;

  if v_session.expires_at <= now() then
    raise exception 'invalid_or_expired_session';
  end if;

  if v_code.status <> 'available' then
    raise exception 'invalid_or_used_code';
  end if;

  select * into v_campaign
  from public.promo_campaigns
  where id = v_code.campaign_id and is_active = true;
  if not found then raise exception 'campaign_unavailable'; end if;

  select * into v_entitlement
  from public.user_entitlements
  where user_id = v_session.user_id and entitlement = 'decoy_wallet'
  for update;

  v_start := greatest(
    now(),
    coalesce(v_entitlement.current_period_end, now()),
    coalesce(v_entitlement.promotional_access_until, now()),
    coalesce(v_entitlement.teardown_grace_until, now())
  );
  v_end := v_start + make_interval(days => v_campaign.duration_days);
  v_billing_status := case
    when v_entitlement.provider = 'stripe'
      and v_entitlement.provider_subscription_id is not null
      and coalesce(v_entitlement.cancel_at_period_end, false) = false
    then 'pending'
    else 'not_required'
  end;

  update public.promo_codes
  set status = 'reserved',
      reserved_by = v_session.user_id,
      reserved_at = now(),
      reservation_session_id = v_session.id,
      reserved_access_started_at = v_start,
      reserved_access_ends_at = v_end,
      reserved_billing_sync_status = v_billing_status
  where id = v_code.id;

  return query select
    v_code.id, v_session.user_id, v_start, v_end,
    v_billing_status, v_session.return_to;
end;
$$;

create or replace function public.finalize_membership_code(
  p_session_hash text,
  p_code_hash text,
  p_billing_sync_complete boolean default false
)
returns table (
  redemption_id uuid,
  user_id uuid,
  access_ends_at timestamptz,
  return_to text
)
language plpgsql
security definer
set search_path = public
as $$
#variable_conflict use_column
declare
  v_code public.promo_codes%rowtype;
  v_campaign public.promo_campaigns%rowtype;
  v_session public.promo_redemption_sessions%rowtype;
  v_redemption_id uuid;
begin
  if auth.role() <> 'service_role' then
    raise exception 'service_role_required';
  end if;

  select * into v_session
  from public.promo_redemption_sessions
  where token_hash = p_session_hash
  for update;
  if not found or v_session.consumed_at is not null then
    raise exception 'invalid_or_consumed_session';
  end if;

  select * into v_code
  from public.promo_codes
  where code_hash = p_code_hash
  for update;
  if not found or v_code.status <> 'reserved'
      or v_code.reserved_by is distinct from v_session.user_id
      or v_code.reservation_session_id is distinct from v_session.id then
    raise exception 'reservation_mismatch';
  end if;
  if v_code.reserved_billing_sync_status = 'pending'
      and p_billing_sync_complete is not true then
    raise exception 'billing_sync_incomplete';
  end if;

  select * into v_campaign from public.promo_campaigns where id = v_code.campaign_id;

  insert into public.user_entitlements (
    user_id, entitlement, is_active, promotional_access_until, updated_at
  ) values (
    v_session.user_id, 'decoy_wallet', true,
    v_code.reserved_access_ends_at, now()
  )
  on conflict (user_id, entitlement) do update
    set promotional_access_until = greatest(
          coalesce(public.user_entitlements.promotional_access_until, '-infinity'::timestamptz),
          excluded.promotional_access_until
        ),
        updated_at = now();

  insert into public.promo_redemptions (
    promo_code_id, campaign_id, user_id, duration_days,
    access_started_at, access_ends_at, billing_sync_status
  ) values (
    v_code.id, v_campaign.id, v_session.user_id, v_campaign.duration_days,
    v_code.reserved_access_started_at, v_code.reserved_access_ends_at,
    case when v_code.reserved_billing_sync_status = 'pending' then 'complete' else 'not_required' end
  ) returning id into v_redemption_id;

  update public.promo_codes
  set status = 'redeemed', redeemed_by = v_session.user_id, redeemed_at = now(),
      reserved_billing_sync_status = case
        when reserved_billing_sync_status = 'pending' then 'complete'
        else reserved_billing_sync_status end
  where id = v_code.id;
  update public.promo_redemption_sessions set consumed_at = now() where id = v_session.id;

  return query select
    v_redemption_id, v_session.user_id,
    v_code.reserved_access_ends_at, v_session.return_to;
end;
$$;

create or replace function public.completed_membership_redemption(
  p_session_hash text,
  p_code_hash text
)
returns table (
  redemption_id uuid,
  user_id uuid,
  access_ends_at timestamptz,
  return_to text
)
language sql
stable
security definer
set search_path = public
as $$
  select r.id, r.user_id, r.access_ends_at, s.return_to
  from public.promo_redemption_sessions s
  join public.promo_codes c
    on c.reservation_session_id = s.id
   and c.code_hash = p_code_hash
   and c.status = 'redeemed'
   and c.redeemed_by = s.user_id
  join public.promo_redemptions r on r.promo_code_id = c.id
  where s.token_hash = p_session_hash
    and s.consumed_at is not null
  limit 1;
$$;

revoke all on function public.reserve_membership_code(text, text)
  from public, anon, authenticated;
revoke all on function public.finalize_membership_code(text, text, boolean)
  from public, anon, authenticated;
revoke all on function public.completed_membership_redemption(text, text)
  from public, anon, authenticated;
grant execute on function public.reserve_membership_code(text, text) to service_role;
grant execute on function public.finalize_membership_code(text, text, boolean) to service_role;
grant execute on function public.completed_membership_redemption(text, text) to service_role;

commit;
