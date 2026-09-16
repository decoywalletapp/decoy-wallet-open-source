alter table public.decoy_wallet
  add column if not exists phone_onboarding_skipped_at timestamptz;
