create extension if not exists pgcrypto;

alter table public.user_entitlements
  add column if not exists promotional_access_until timestamptz;

create table if not exists public.promo_campaigns (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  name text not null,
  duration_days integer not null check (duration_days > 0),
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.promo_codes (
  id uuid primary key default gen_random_uuid(),
  campaign_id uuid not null references public.promo_campaigns(id) on delete cascade,
  code_hash text not null unique,
  status text not null default 'available'
    check (status in ('available', 'reserved', 'redeemed', 'disabled')),
  reserved_by uuid references auth.users(id) on delete set null,
  reserved_at timestamptz,
  redeemed_by uuid references auth.users(id) on delete set null,
  redeemed_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.promo_redemptions (
  id uuid primary key default gen_random_uuid(),
  promo_code_id uuid not null unique references public.promo_codes(id),
  campaign_id uuid not null references public.promo_campaigns(id),
  user_id uuid not null references auth.users(id) on delete cascade,
  duration_days integer not null check (duration_days > 0),
  access_started_at timestamptz not null,
  access_ends_at timestamptz not null,
  billing_sync_status text not null default 'not_required'
    check (billing_sync_status in ('not_required', 'pending', 'complete', 'error')),
  billing_sync_error text,
  created_at timestamptz not null default now()
);

create table if not exists public.promo_redemption_sessions (
  id uuid primary key default gen_random_uuid(),
  token_hash text not null unique,
  user_id uuid not null references auth.users(id) on delete cascade,
  return_to text not null default 'home',
  expires_at timestamptz not null,
  consumed_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists promo_redemptions_user_id_idx
  on public.promo_redemptions(user_id, created_at desc);
create index if not exists promo_redemption_sessions_expiry_idx
  on public.promo_redemption_sessions(expires_at)
  where consumed_at is null;

alter table public.promo_campaigns enable row level security;
alter table public.promo_codes enable row level security;
alter table public.promo_redemptions enable row level security;
alter table public.promo_redemption_sessions enable row level security;

revoke all on public.promo_campaigns from anon, authenticated;
revoke all on public.promo_codes from anon, authenticated;
revoke all on public.promo_redemptions from anon, authenticated;
revoke all on public.promo_redemption_sessions from anon, authenticated;

grant select, insert, update, delete on public.promo_campaigns to service_role;
grant select, insert, update, delete on public.promo_codes to service_role;
grant select, insert, update, delete on public.promo_redemptions to service_role;
grant select, insert, update, delete on public.promo_redemption_sessions to service_role;

create or replace function public.redeem_membership_code(
  p_session_hash text,
  p_code_hash text
)
returns table (
  redemption_id uuid,
  user_id uuid,
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
  v_redemption_id uuid;
  v_billing_status text;
begin
  if auth.role() <> 'service_role' then
    raise exception 'service_role_required';
  end if;

  select * into v_session
  from public.promo_redemption_sessions
  where token_hash = p_session_hash
  for update;

  if not found or v_session.consumed_at is not null
      or v_session.expires_at <= now() then
    raise exception 'invalid_or_expired_session';
  end if;

  select * into v_code
  from public.promo_codes
  where code_hash = p_code_hash
  for update;

  if not found or v_code.status <> 'available' then
    raise exception 'invalid_or_used_code';
  end if;

  select * into v_campaign
  from public.promo_campaigns
  where id = v_code.campaign_id and is_active = true;

  if not found then
    raise exception 'campaign_unavailable';
  end if;

  select * into v_entitlement
  from public.user_entitlements
  where user_id = v_session.user_id and entitlement = 'decoy_wallet'
  for update;

  v_start := greatest(
    now(),
    coalesce(v_entitlement.current_period_end, now()),
    coalesce(v_entitlement.promotional_access_until, now())
  );
  v_end := v_start + make_interval(days => v_campaign.duration_days);
  v_billing_status := case
    when v_entitlement.provider = 'stripe'
      and v_entitlement.provider_subscription_id is not null
      and coalesce(v_entitlement.cancel_at_period_end, false) = false
    then 'pending'
    else 'not_required'
  end;

  insert into public.user_entitlements (
    user_id, entitlement, is_active, promotional_access_until, updated_at
  ) values (
    v_session.user_id, 'decoy_wallet', true, v_end, now()
  )
  on conflict (user_id, entitlement) do update
    set promotional_access_until = excluded.promotional_access_until,
        updated_at = now();

  insert into public.promo_redemptions (
    promo_code_id, campaign_id, user_id, duration_days,
    access_started_at, access_ends_at, billing_sync_status
  ) values (
    v_code.id, v_campaign.id, v_session.user_id, v_campaign.duration_days,
    v_start, v_end, v_billing_status
  ) returning id into v_redemption_id;

  update public.promo_codes
  set status = 'redeemed', redeemed_by = v_session.user_id, redeemed_at = now(),
      reserved_by = null, reserved_at = null
  where id = v_code.id;

  update public.promo_redemption_sessions
  set consumed_at = now()
  where id = v_session.id;

  return query select
    v_redemption_id,
    v_session.user_id,
    v_end,
    v_billing_status,
    v_session.return_to;
end;
$$;

revoke all on function public.redeem_membership_code(text, text)
  from public, anon, authenticated;
grant execute on function public.redeem_membership_code(text, text)
  to service_role;

create or replace function public.has_active_decoy_wallet_access(
  p_user_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.user_entitlements e
    where e.user_id = p_user_id
      and e.entitlement = 'decoy_wallet'
      and (
        e.promotional_access_until > now()
        or (
          e.is_active = true
          and e.current_period_end > now()
        )
        or e.teardown_grace_until > now()
      )
  );
$$;

revoke all on function public.has_active_decoy_wallet_access(uuid)
  from public, anon, authenticated;
grant execute on function public.has_active_decoy_wallet_access(uuid)
  to service_role;

insert into public.promo_campaigns (slug, name, duration_days)
values ('mwbs-2026', 'Midwest Bitcoin Summit 2026', 365)
on conflict (slug) do nothing;
