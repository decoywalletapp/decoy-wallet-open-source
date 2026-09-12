begin;

create table if not exists public.decoy_monitor_activation_resets (
  decoy_id uuid primary key references public.decoys(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  reset_at timestamptz not null default now(),
  processed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists decoy_monitor_activation_resets_pending_idx
  on public.decoy_monitor_activation_resets (processed_at, reset_at)
  where processed_at is null;

alter table public.decoy_monitor_activation_resets enable row level security;

revoke all on table public.decoy_monitor_activation_resets from anon, authenticated;

comment on table public.decoy_monitor_activation_resets is
  'Backend-only reset markers used to baseline individual Decoy Keys monitors when they are re-enabled, preventing retroactive alerts for spends made while a monitor was off.';

commit;
