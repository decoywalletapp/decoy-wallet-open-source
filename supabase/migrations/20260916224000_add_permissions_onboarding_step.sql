alter table public.decoy_wallet
  add column if not exists permissions_onboarding_step text;

alter table public.decoy_wallet
  drop constraint if exists decoy_wallet_permissions_onboarding_step_check;

alter table public.decoy_wallet
  add constraint decoy_wallet_permissions_onboarding_step_check
  check (
    permissions_onboarding_step is null
    or permissions_onboarding_step in (
      'biometrics',
      'notifications',
      'location',
      'complete'
    )
  );
