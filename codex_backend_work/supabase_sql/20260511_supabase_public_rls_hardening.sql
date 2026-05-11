begin;

-- Keep alert enqueue working after sms_queue direct client access is removed.
-- These trigger functions keep their existing bodies/gates; this only changes
-- the execution privilege context used by Postgres when a trigger fires.
alter function public.create_alert_from_decoy_trigger() security definer;
alter function public.create_alert_from_decoy_trigger() set search_path = public;

alter function public.fn_alert_logs_to_sms_queue() security definer;
alter function public.fn_alert_logs_to_sms_queue() set search_path = public;

-- These are trigger functions, not public RPC endpoints.
revoke execute on function public.create_alert_from_decoy_trigger() from public, anon, authenticated;
revoke execute on function public.fn_alert_logs_to_sms_queue() from public, anon, authenticated;
revoke execute on function public.enqueue_sms_on_alert() from public, anon, authenticated;

-- Backend/system tables should not be directly readable or writable through
-- the public PostgREST API. Cloud Run and Edge Function service-role clients
-- keep access through service_role.
alter table public.btcpay_webhook_events enable row level security;
alter table public.emergency_contact_consents enable row level security;
alter table public.emergency_contact_consent_requests enable row level security;
alter table public.emergency_contact_sms_suppressions enable row level security;
alter table public.sms_queue enable row level security;
alter table public.decoy_seen_txs enable row level security;
alter table public.emergency_contact_opt_out_tokens enable row level security;
alter table public.decoy_seed_baselines enable row level security;
alter table public.decoy_seed_scan_state enable row level security;

revoke all privileges on table public.btcpay_webhook_events from anon, authenticated;
revoke all privileges on table public.emergency_contact_consents from anon, authenticated;
revoke all privileges on table public.emergency_contact_consent_requests from anon, authenticated;
revoke all privileges on table public.emergency_contact_sms_suppressions from anon, authenticated;
revoke all privileges on table public.sms_queue from anon, authenticated;
revoke all privileges on table public.decoy_seen_txs from anon, authenticated;
revoke all privileges on table public.emergency_contact_opt_out_tokens from anon, authenticated;
revoke all privileges on table public.decoy_seed_baselines from anon, authenticated;
revoke all privileges on table public.decoy_seed_scan_state from anon, authenticated;

-- The seed watcher view is backend-only. Make it obey the caller's privileges
-- when possible, and remove direct app/browser access.
alter view public.armed_decoy_seeds set (security_invoker = true);
revoke all privileges on table public.armed_decoy_seeds from anon, authenticated;

commit;
