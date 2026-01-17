-- Update PIN_DECOY dedupe trigger to preserve encrypted location fields
-- and wipe plaintext lat/lng once encrypted fields exist.

create or replace function public.trg_dedupe_pin_decoy_alerts()
returns trigger
language plpgsql
as $function$
declare
  ts timestamptz;
  existing_id uuid;
begin
  ts := coalesce(new.created_at, now());
  new.created_at := ts;

  if new.trigger_type = 'PIN_DECOY' then
    perform pg_advisory_xact_lock(hashtext(new.user_id::text || ':PIN_DECOY'));

    select a.id
      into existing_id
    from public.alert_logs a
    where a.user_id = new.user_id
      and a.trigger_type = 'PIN_DECOY'
      and a.created_at >= (ts - interval '10 seconds')
    order by a.created_at desc
    limit 1;

    if existing_id is not null then
      update public.alert_logs
      set
        location_ciphertext = coalesce(location_ciphertext, new.location_ciphertext),
        location_nonce = coalesce(location_nonce, new.location_nonce),
        location_wrapped_datakey = coalesce(location_wrapped_datakey, new.location_wrapped_datakey),
        location_version = coalesce(location_version, new.location_version),

        lat = case
                when coalesce(location_ciphertext, new.location_ciphertext) is not null
                 and coalesce(location_nonce, new.location_nonce) is not null
                 and coalesce(location_wrapped_datakey, new.location_wrapped_datakey) is not null
                then null
                else lat
              end,
        lng = case
                when coalesce(location_ciphertext, new.location_ciphertext) is not null
                 and coalesce(location_nonce, new.location_nonce) is not null
                 and coalesce(location_wrapped_datakey, new.location_wrapped_datakey) is not null
                then null
                else lng
              end
      where id = existing_id;

      return null;
    end if;
  end if;

  return new;
end;
$function$;
