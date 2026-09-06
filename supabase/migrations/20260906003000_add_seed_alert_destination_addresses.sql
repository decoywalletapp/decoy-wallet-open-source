begin;

alter table public.decoy_triggers
  add column if not exists destination_addresses jsonb,
  add column if not exists destination_address_count integer not null default 0;

alter table public.alert_logs
  add column if not exists destination_addresses jsonb,
  add column if not exists destination_address_count integer not null default 0;

comment on column public.decoy_triggers.destination_addresses is
  'Optional SEED_DECOY transaction output address candidates. Does not contain watched input addresses or full raw transaction payloads.';

comment on column public.alert_logs.destination_addresses is
  'Optional SEED_DECOY transaction output address candidates copied from decoy_triggers for emergency-contact SMS context.';

create or replace function public.create_alert_from_decoy_trigger()
returns trigger
language plpgsql
security definer
set search_path = public
as $function$
declare
  v_alert_id uuid;
  v_txid text;
  v_txid_hmac text;
  v_destination_addresses jsonb := null;
  v_destination_address_count integer := 0;

  v_pin_contacts_enabled boolean := false;
  v_seed_armed boolean := false;
  v_entitlement_usable boolean := false;
begin
  v_txid := NEW.txid;
  v_txid_hmac := NEW.txid_hmac;

  if NEW.trigger_type = 'SEED_DECOY'
    and NEW.destination_addresses is not null
    and jsonb_typeof(NEW.destination_addresses) = 'array'
    and jsonb_array_length(NEW.destination_addresses) > 0
  then
    v_destination_addresses := NEW.destination_addresses;
    v_destination_address_count := jsonb_array_length(NEW.destination_addresses);
  end if;

  select exists (
    select 1
    from public.user_entitlements ue
    where ue.user_id = NEW.user_id
      and ue.entitlement = 'decoy_wallet'
      and ue.is_active is true
      and (
        ue.current_period_end is null
        or ue.current_period_end > now()
        or ue.teardown_grace_until > now()
        or (
          lower(coalesce(ue.pending_provider, '')) in ('stripe', 'btcpay')
          and ue.pending_starts_at is not null
          and coalesce(ue.pending_provider_subscription_id, '') <> ''
        )
      )
  )
  into v_entitlement_usable;

  if v_entitlement_usable is not true then
    return NEW;
  end if;

  -- ---------- GATING ----------
  if NEW.trigger_type = 'PIN_DECOY' then
    select coalesce(dw.decoy_pin_contacts_enabled, false)
      into v_pin_contacts_enabled
    from public.decoy_wallet dw
    where dw.user_id = NEW.user_id
    limit 1;

    if v_pin_contacts_enabled is not true then
      return NEW;
    end if;
  end if;

  if NEW.trigger_type = 'SEED_DECOY' then
    select coalesce(dw.decoy_seed_armed, false)
      into v_seed_armed
    from public.decoy_wallet dw
    where dw.user_id = NEW.user_id
    limit 1;

    if v_seed_armed is not true then
      return NEW;
    end if;
  end if;

  -- ---------- Idempotency ----------
  -- Seed watcher stores HMAC-only txids. Prefer HMAC dedupe and retain
  -- the legacy plaintext txid path only for older rows or non-seed triggers.
  if NEW.trigger_type = 'SEED_DECOY' and v_txid_hmac is not null then
    select id
      into v_alert_id
    from public.alert_logs
    where user_id = NEW.user_id
      and trigger_type = 'SEED_DECOY'
      and txid_hmac = v_txid_hmac
    limit 1;

    if v_alert_id is not null then
      return NEW;
    end if;
  elsif v_txid is not null then
    select id
      into v_alert_id
    from public.alert_logs
    where txid = v_txid
    limit 1;

    if v_alert_id is not null then
      return NEW;
    end if;
  end if;

  -- For SEED_DECOY, v_txid is expected to be null and v_txid_hmac populated.
  -- Do not store raw_event or plaintext txids here.
  insert into public.alert_logs (
    user_id,
    trigger_type,
    success,
    error_message,
    lat,
    lng,
    txid,
    txid_hmac,
    destination_addresses,
    destination_address_count,
    created_at
  )
  values (
    NEW.user_id,
    NEW.trigger_type,
    true,
    null,
    null,
    null,
    v_txid,
    v_txid_hmac,
    v_destination_addresses,
    v_destination_address_count,
    now()
  )
  returning id into v_alert_id;

  insert into public.sms_queue (
    alert_id,
    user_id,
    processed,
    created_at
  )
  values (
    v_alert_id,
    NEW.user_id,
    false,
    now()
  )
  on conflict (alert_id) do nothing;

  return NEW;
end;
$function$;

commit;
