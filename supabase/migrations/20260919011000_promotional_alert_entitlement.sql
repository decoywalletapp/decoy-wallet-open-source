begin;

create or replace function public.create_alert_from_decoy_trigger()
returns trigger
language plpgsql
as $function$
declare
  v_alert_id uuid;
  v_txid text;
  v_txid_hmac text;
  v_pin_contacts_enabled boolean := false;
  v_seed_armed boolean := false;
begin
  v_txid := NEW.txid;
  v_txid_hmac := NEW.txid_hmac;

  if public.has_active_decoy_wallet_access(NEW.user_id) is not true then
    return NEW;
  end if;

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

  insert into public.alert_logs (
    user_id,
    trigger_type,
    success,
    error_message,
    lat,
    lng,
    txid,
    txid_hmac,
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

create or replace function public.fn_alert_logs_to_sms_queue()
returns trigger
language plpgsql
as $function$
begin
  if public.has_active_decoy_wallet_access(NEW.user_id) is not true then
    return NEW;
  end if;

  insert into public.sms_queue (alert_id, user_id, created_at, processed)
  values (NEW.id, NEW.user_id, NEW.created_at, false)
  on conflict (alert_id) do nothing;

  return NEW;
end;
$function$;

commit;
