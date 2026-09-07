begin;

-- Decoy Keys now supports multiple active wallet-activity monitors per user.
-- The master decoy_wallet.decoy_seed_armed switch remains the global gate.
drop index if exists public.one_active_decoy_per_user;

create or replace view public.armed_decoy_seeds as
  select
    dw.user_id,
    d.id as decoy_id,
    null::text as first_name,
    null::text as last_name,
    to_jsonb(d.addresses) as addresses
  from public.decoy_wallet dw
  join public.decoys d
    on d.user_id = dw.user_id
  where coalesce(dw.decoy_seed_armed, false) is true
    and coalesce(d.active, false) is true
    and d.archived_at is null;

comment on view public.armed_decoy_seeds is
  'Backend-only watcher view. Returns all active, unarchived Decoy Keys monitors for users whose master Decoy Keys switch is armed.';

alter view public.armed_decoy_seeds set (security_invoker = true);
revoke all privileges on table public.armed_decoy_seeds from anon, authenticated;

commit;
