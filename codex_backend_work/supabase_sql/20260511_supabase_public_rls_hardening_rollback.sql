begin;

-- Roll back the Supabase public RLS hardening from 2026-05-11.
-- This intentionally restores the broad pre-hardening API posture and should
-- only be used if the hardening patch causes a production issue.
alter function public.create_alert_from_decoy_trigger() security invoker;
alter function public.create_alert_from_decoy_trigger() reset search_path;

alter function public.fn_alert_logs_to_sms_queue() security invoker;
alter function public.fn_alert_logs_to_sms_queue() reset search_path;

grant execute on function public.create_alert_from_decoy_trigger() to public, anon, authenticated;
grant execute on function public.fn_alert_logs_to_sms_queue() to public, anon, authenticated;
grant execute on function public.enqueue_sms_on_alert() to public, anon, authenticated;

alter table public.btcpay_webhook_events disable row level security;
alter table public.emergency_contact_consents disable row level security;
alter table public.emergency_contact_consent_requests disable row level security;
alter table public.emergency_contact_sms_suppressions disable row level security;
alter table public.sms_queue disable row level security;
alter table public.decoy_seen_txs disable row level security;
alter table public.emergency_contact_opt_out_tokens disable row level security;
alter table public.decoy_seed_baselines disable row level security;
alter table public.decoy_seed_scan_state disable row level security;

grant all privileges on table public.btcpay_webhook_events to anon, authenticated;
grant all privileges on table public.emergency_contact_consents to anon, authenticated;
grant all privileges on table public.emergency_contact_consent_requests to anon, authenticated;
grant all privileges on table public.emergency_contact_sms_suppressions to anon, authenticated;
grant all privileges on table public.sms_queue to anon, authenticated;
grant all privileges on table public.decoy_seen_txs to anon, authenticated;
grant all privileges on table public.emergency_contact_opt_out_tokens to anon, authenticated;
grant all privileges on table public.decoy_seed_baselines to anon, authenticated;
grant all privileges on table public.decoy_seed_scan_state to anon, authenticated;

alter view public.armed_decoy_seeds reset (security_invoker);
grant all privileges on table public.armed_decoy_seeds to anon, authenticated;

commit;
