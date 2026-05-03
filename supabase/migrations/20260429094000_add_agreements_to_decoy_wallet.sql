alter table public.decoy_wallet
  add column if not exists agreements_complete boolean not null default false,
  add column if not exists agreements_completed_at timestamptz;
