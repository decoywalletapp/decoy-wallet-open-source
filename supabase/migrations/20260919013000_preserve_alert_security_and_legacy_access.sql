begin;

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
          and (
            e.current_period_end is null
            or e.current_period_end > now()
            or e.teardown_grace_until > now()
            or (
              lower(coalesce(e.pending_provider, '')) in ('stripe', 'btcpay')
              and e.pending_starts_at is not null
              and coalesce(e.pending_provider_subscription_id, '') <> ''
            )
          )
        )
      )
  );
$$;

alter function public.create_alert_from_decoy_trigger() security definer;
alter function public.create_alert_from_decoy_trigger() set search_path = public;
alter function public.fn_alert_logs_to_sms_queue() security definer;
alter function public.fn_alert_logs_to_sms_queue() set search_path = public;

revoke execute on function public.create_alert_from_decoy_trigger()
  from public, anon, authenticated;
revoke execute on function public.fn_alert_logs_to_sms_queue()
  from public, anon, authenticated;
revoke all on function public.has_active_decoy_wallet_access(uuid)
  from public, anon, authenticated;
grant execute on function public.has_active_decoy_wallet_access(uuid)
  to service_role;

commit;
