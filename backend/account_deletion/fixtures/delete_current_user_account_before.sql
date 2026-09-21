CREATE OR REPLACE FUNCTION public.delete_current_user_account()
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'auth'
AS $function$
declare
  uid uuid;
  deleted_counts jsonb;
begin
  uid := auth.uid();

  if uid is null then
    raise exception 'Not authenticated';
  end if;

  select jsonb_build_object(
    'sms_queue', (
      select count(*)
      from public.sms_queue sq
      where sq.user_id = uid
         or sq.alert_id in (
           select al.id
           from public.alert_logs al
           where al.user_id = uid
         )
    ),
    'alert_logs', (
      select count(*)
      from public.alert_logs
      where user_id = uid
    ),
    'emergency_contact_opt_out_tokens', (
      select count(*)
      from public.emergency_contact_opt_out_tokens t
      where t.user_id = uid
         or t.consent_id in (
           select c.id
           from public.emergency_contact_consents c
           where c.user_id = uid
         )
    ),
    'emergency_contact_consent_requests', (
      select count(*)
      from public.emergency_contact_consent_requests r
      where r.user_id = uid
         or r.consent_id in (
           select c.id
           from public.emergency_contact_consents c
           where c.user_id = uid
         )
    ),
    'emergency_contact_consents', (
      select count(*)
      from public.emergency_contact_consents
      where user_id = uid
    ),
    'armed_decoy_seeds_view', (
      select count(*)
      from public.armed_decoy_seeds s
      where s.user_id = uid
         or s.decoy_id in (
           select d.id
           from public.decoys d
           where d.user_id = uid
         )
    ),
    'decoy_seed_baselines', (
      select count(*)
      from public.decoy_seed_baselines b
      where b.decoy_id in (
        select d.id
        from public.decoys d
        where d.user_id = uid
      )
    ),
    'decoy_seed_scan_state', (
      select count(*)
      from public.decoy_seed_scan_state s
      where s.decoy_id in (
        select d.id
        from public.decoys d
        where d.user_id = uid
      )
    ),
    'decoy_triggers', (
      select count(*)
      from public.decoy_triggers t
      where t.user_id = uid
         or t.decoy_id in (
           select d.id
           from public.decoys d
           where d.user_id = uid
         )
    ),
    'decoys', (
      select count(*)
      from public.decoys
      where user_id = uid
    ),
    'notification_jobs', (
      select count(*)
      from public.notification_jobs
      where user_id = uid
    ),
    'user_devices', (
      select count(*)
      from public.user_devices
      where user_id = uid
    ),
    'user_settings', (
      select count(*)
      from public.user_settings
      where user_id = uid
    ),
    'user_entitlements', (
      select count(*)
      from public.user_entitlements
      where user_id = uid
    ),
    'emergency_contacts', (
      select count(*)
      from public.emergency_contacts
      where user_id = uid
    ),
    'decoy_wallet', (
      select count(*)
      from public.decoy_wallet
      where user_id = uid
    )
  )
  into deleted_counts;

  insert into public.account_deletion_receipts (
    deleted_user_hash,
    deletion_scope_version,
    deleted_counts,
    note
  )
  values (
    md5(uid::text),
    '20260506_retention_aware_v1',
    deleted_counts,
    'Self-service account deletion completed. Operational app data was removed; global SMS suppression records and external payment-provider records are retained separately for compliance/legal/payment integrity.'
  );

  -- Alert delivery artifacts. Delete queue rows before alert rows because
  -- some live schemas do not cascade directly from auth.users.
  delete from public.sms_queue
  where user_id = uid
     or alert_id in (
       select id
       from public.alert_logs
       where user_id = uid
     );

  delete from public.alert_logs
  where user_id = uid;

  -- Emergency-contact consent artifacts. These include names, phone numbers,
  -- response statuses, and opt-out link tokens.
  delete from public.emergency_contact_opt_out_tokens
  where user_id = uid
     or consent_id in (
       select id
       from public.emergency_contact_consents
       where user_id = uid
     );

  delete from public.emergency_contact_consent_requests
  where user_id = uid
     or consent_id in (
       select id
       from public.emergency_contact_consents
       where user_id = uid
     );

  delete from public.emergency_contact_consents
  where user_id = uid;

  -- Decoy seed scanner state. armed_decoy_seeds is a read-only view in the
  -- live schema, so it is cleaned by deleting its source decoys/wallet rows.
  -- These tables are keyed by decoy_id and do not all have live foreign keys,
  -- so remove them before deleting decoys.

  delete from public.decoy_seed_baselines
  where decoy_id in (
    select id
    from public.decoys
    where user_id = uid
  );

  delete from public.decoy_seed_scan_state
  where decoy_id in (
    select id
    from public.decoys
    where user_id = uid
  );

  -- Decoy trigger history and owned decoys.
  delete from public.decoy_triggers
  where user_id = uid
     or decoy_id in (
       select id
       from public.decoys
       where user_id = uid
     );

  delete from public.decoys
  where user_id = uid;

  -- App/account rows. Most have auth.users cascades, but explicit deletion
  -- keeps the function correct even if constraints drift later.
  delete from public.notification_jobs
  where user_id = uid;

  delete from public.user_devices
  where user_id = uid;

  delete from public.user_settings
  where user_id = uid;

  delete from public.user_entitlements
  where user_id = uid;

  delete from public.emergency_contacts
  where user_id = uid;

  delete from public.decoy_wallet
  where user_id = uid;

  -- Global SMS suppressions are intentionally not deleted. They are keyed by
  -- phone number, not user id, and preserve STOP/opt-out compliance.
  --
  -- Stripe/BTCPay provider records and raw local payment webhook records are
  -- intentionally not deleted here. They support payment integrity, duplicate
  -- webhook handling, fraud review, tax/accounting, and legal defense. Keep
  -- this retention policy aligned with the public privacy policy.

  delete from auth.users
  where id = uid;
end;
$function$
