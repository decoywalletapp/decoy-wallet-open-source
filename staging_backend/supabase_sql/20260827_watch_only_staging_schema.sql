create extension if not exists pgcrypto;

create table if not exists public.decoys (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  decoy_name text,
  addresses text[] not null default '{}',
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  network text not null default 'mainnet',
  last_checked_height integer,
  last_activity_at timestamptz,
  derivation_path text,
  xpub text,
  zpub text,
  watch_public_key text,
  watch_public_key_type text
);

alter table public.decoys add column if not exists decoy_name text;
alter table public.decoys add column if not exists addresses text[] not null default '{}';
alter table public.decoys add column if not exists active boolean not null default true;
alter table public.decoys add column if not exists created_at timestamptz not null default now();
alter table public.decoys add column if not exists updated_at timestamptz not null default now();
alter table public.decoys add column if not exists network text not null default 'mainnet';
alter table public.decoys add column if not exists last_checked_height integer;
alter table public.decoys add column if not exists last_activity_at timestamptz;
alter table public.decoys add column if not exists derivation_path text;
alter table public.decoys add column if not exists xpub text;
alter table public.decoys add column if not exists zpub text;
alter table public.decoys add column if not exists watch_public_key text;
alter table public.decoys add column if not exists watch_public_key_type text;

create index if not exists decoys_user_id_idx on public.decoys(user_id);
create index if not exists decoys_active_idx on public.decoys(active);

create table if not exists public.decoy_wallet (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  wallet_name text,
  is_triggered boolean not null default false,
  metadata jsonb,
  triggered_at timestamptz,
  decoy_type text,
  encrypted_pin text,
  is_phone_verified boolean not null default false,
  verified_at timestamptz,
  decoy_pin_hash text,
  decoy_pin_salt text,
  decoy_pin_set_at timestamptz,
  decoy_mode_enabled boolean,
  account_pin_hash text,
  account_pin_salt text,
  account_pin_algo text,
  decoy_pin_algo text,
  decoy_encrypted_pin text,
  setup_complete boolean not null default false,
  setup_completed_at timestamptz,
  agreements_complete boolean not null default false,
  agreements_completed_at timestamptz,
  decoy_seed_armed boolean not null default false,
  decoy_seed_contacts_enabled boolean not null default false,
  decoy_seed_decoy_id text,
  decoy_seed_armed_at timestamptz,
  decoy_seed_last_triggered_at timestamptz,
  decoy_pin_911_enabled boolean,
  decoy_pin_contacts_enabled boolean,
  last_teardown_at timestamptz,
  current_wallet_balance numeric,
  passcode_hash text,
  passcode_salt text,
  decoy_passcode_hash text,
  decoy_passcode_salt text,
  contacts_ciphertext text,
  contacts_nonce text,
  contacts_version integer,
  first_name_ciphertext text,
  first_name_nonce text,
  last_name_ciphertext text,
  last_name_nonce text,
  phone_number_ciphertext text,
  phone_number_nonce text,
  email_ciphertext text,
  email_nonce text,
  email_verified boolean not null default false,
  email_verified_at timestamptz,
  pending_email text,
  pending_email_hash text,
  phone_e164_hash text,
  email_hash text,
  address_ciphertext text,
  address_nonce text,
  address_version integer,
  city_ciphertext text,
  city_nonce text,
  state_ciphertext text,
  state_nonce text,
  zip_code_ciphertext text,
  zip_code_nonce text,
  personal_ciphertext text,
  personal_nonce text,
  personal_version integer,
  use_current_location boolean,
  personal_complete boolean,
  address_complete boolean,
  contacts_complete boolean,
  has_decoy_seed_ack boolean,
  has_decoy_pin_ack boolean,
  wrapped_datakey text,
  key_id text
);

alter table public.decoy_wallet add column if not exists wallet_name text;
alter table public.decoy_wallet add column if not exists is_triggered boolean not null default false;
alter table public.decoy_wallet add column if not exists metadata jsonb;
alter table public.decoy_wallet add column if not exists triggered_at timestamptz;
alter table public.decoy_wallet add column if not exists decoy_type text;
alter table public.decoy_wallet add column if not exists encrypted_pin text;
alter table public.decoy_wallet add column if not exists is_phone_verified boolean not null default false;
alter table public.decoy_wallet add column if not exists verified_at timestamptz;
alter table public.decoy_wallet add column if not exists decoy_pin_hash text;
alter table public.decoy_wallet add column if not exists decoy_pin_salt text;
alter table public.decoy_wallet add column if not exists decoy_pin_set_at timestamptz;
alter table public.decoy_wallet add column if not exists decoy_mode_enabled boolean;
alter table public.decoy_wallet add column if not exists account_pin_hash text;
alter table public.decoy_wallet add column if not exists account_pin_salt text;
alter table public.decoy_wallet add column if not exists account_pin_algo text;
alter table public.decoy_wallet add column if not exists decoy_pin_algo text;
alter table public.decoy_wallet add column if not exists decoy_encrypted_pin text;
alter table public.decoy_wallet add column if not exists setup_complete boolean not null default false;
alter table public.decoy_wallet add column if not exists setup_completed_at timestamptz;
alter table public.decoy_wallet add column if not exists agreements_complete boolean not null default false;
alter table public.decoy_wallet add column if not exists agreements_completed_at timestamptz;
alter table public.decoy_wallet add column if not exists decoy_seed_armed boolean not null default false;
alter table public.decoy_wallet add column if not exists decoy_seed_contacts_enabled boolean not null default false;
alter table public.decoy_wallet add column if not exists decoy_seed_decoy_id text;
alter table public.decoy_wallet add column if not exists decoy_seed_armed_at timestamptz;
alter table public.decoy_wallet add column if not exists decoy_seed_last_triggered_at timestamptz;
alter table public.decoy_wallet add column if not exists decoy_pin_911_enabled boolean;
alter table public.decoy_wallet add column if not exists decoy_pin_contacts_enabled boolean;
alter table public.decoy_wallet add column if not exists last_teardown_at timestamptz;
alter table public.decoy_wallet add column if not exists current_wallet_balance numeric;
alter table public.decoy_wallet add column if not exists updated_at timestamptz not null default now();
alter table public.decoy_wallet add column if not exists contacts_ciphertext text;
alter table public.decoy_wallet add column if not exists contacts_nonce text;
alter table public.decoy_wallet add column if not exists contacts_version integer;
alter table public.decoy_wallet add column if not exists address_ciphertext text;
alter table public.decoy_wallet add column if not exists address_nonce text;
alter table public.decoy_wallet add column if not exists address_version integer;
alter table public.decoy_wallet add column if not exists personal_ciphertext text;
alter table public.decoy_wallet add column if not exists personal_nonce text;
alter table public.decoy_wallet add column if not exists personal_version integer;
alter table public.decoy_wallet add column if not exists email_verified boolean not null default false;
alter table public.decoy_wallet add column if not exists email_verified_at timestamptz;
alter table public.decoy_wallet add column if not exists pending_email text;
alter table public.decoy_wallet add column if not exists pending_email_hash text;
alter table public.decoy_wallet add column if not exists phone_e164_hash text;
alter table public.decoy_wallet add column if not exists email_hash text;
alter table public.decoy_wallet add column if not exists use_current_location boolean;
alter table public.decoy_wallet add column if not exists personal_complete boolean;
alter table public.decoy_wallet add column if not exists address_complete boolean;
alter table public.decoy_wallet add column if not exists contacts_complete boolean;
alter table public.decoy_wallet add column if not exists has_decoy_seed_ack boolean;
alter table public.decoy_wallet add column if not exists has_decoy_pin_ack boolean;

create unique index if not exists decoy_wallet_user_id_key
  on public.decoy_wallet(user_id);

create table if not exists public.decoy_triggers (
  id uuid primary key default gen_random_uuid(),
  decoy_id text not null,
  user_id uuid references auth.users(id) on delete cascade,
  trigger_type text not null,
  txid text,
  txid_hmac text,
  observed_at timestamptz not null default now(),
  raw_event jsonb
);

create index if not exists decoy_triggers_user_id_idx
  on public.decoy_triggers(user_id);
create index if not exists decoy_triggers_decoy_id_idx
  on public.decoy_triggers(decoy_id);

create table if not exists public.emergency_contacts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  contact_ciphertext text,
  contact_nonce text,
  key_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists emergency_contacts_user_id_idx
  on public.emergency_contacts(user_id);

create table if not exists public.emergency_contact_consents (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  contact_slot integer not null,
  first_name text,
  last_name text,
  phone_number text,
  status text not null default 'pending',
  latest_request_id uuid,
  confirmed_at timestamptz,
  denied_at timestamptz,
  opted_out_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists emergency_contact_consents_user_id_idx
  on public.emergency_contact_consents(user_id);

create table if not exists public.emergency_contact_consent_requests (
  id uuid primary key default gen_random_uuid(),
  consent_id uuid references public.emergency_contact_consents(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  contact_slot integer not null,
  phone_number text,
  token_hash text,
  status text not null default 'pending',
  decision text,
  expires_at timestamptz,
  sent_at timestamptz,
  responded_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists emergency_contact_consent_requests_user_id_idx
  on public.emergency_contact_consent_requests(user_id);

create table if not exists public.alert_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  trigger_type text not null,
  success boolean not null default false,
  error_message text,
  lat double precision,
  lng double precision,
  created_at timestamptz not null default now(),
  txid text,
  txid_hmac text,
  location_ciphertext text,
  location_nonce text,
  location_version text,
  location_wrapped_datakey text
);

create index if not exists alert_logs_user_id_idx on public.alert_logs(user_id);

create table if not exists public.sms_queue (
  id uuid primary key default gen_random_uuid(),
  alert_id uuid references public.alert_logs(id) on delete cascade,
  user_id uuid references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  processed boolean not null default false
);

create index if not exists sms_queue_processed_idx
  on public.sms_queue(processed);

create table if not exists public.decoy_seen_txs (
  decoy_id text not null,
  txid_hmac text not null,
  first_seen_at timestamptz not null default now(),
  primary key (decoy_id, txid_hmac)
);

create table if not exists public.decoy_seed_baselines (
  decoy_id text primary key,
  baselined_at timestamptz not null default now()
);

create table if not exists public.decoy_seed_scan_state (
  decoy_id text primary key,
  last_index integer not null default 0,
  updated_at timestamptz not null default now()
);

create table if not exists public.decoy_seed_utxo_state (
  decoy_id text not null,
  outpoint_hmac text not null,
  address text,
  txid_hmac text,
  vout integer,
  value_sats bigint,
  first_seen_at timestamptz not null default now(),
  spent_at timestamptz,
  trigger_txid_hmac text,
  primary key (decoy_id, outpoint_hmac)
);

create table if not exists public.notification_jobs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  type text not null,
  title text,
  body text,
  send_at timestamptz,
  status text not null default 'pending',
  attempts integer not null default 0,
  last_error text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists notification_jobs_status_idx
  on public.notification_jobs(status);

create table if not exists public.user_consents (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  feature text not null,
  consent_version text,
  checkboxes jsonb,
  app_version text,
  created_at timestamptz not null default now()
);

create index if not exists user_consents_user_id_idx
  on public.user_consents(user_id);

create table if not exists public.user_settings (
  user_id uuid primary key references auth.users(id) on delete cascade,
  push_enabled boolean not null default false,
  biometrics_enabled boolean not null default false,
  location_enabled boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.user_settings add column if not exists push_enabled boolean not null default false;
alter table public.user_settings add column if not exists biometrics_enabled boolean not null default false;
alter table public.user_settings add column if not exists location_enabled boolean not null default false;
alter table public.user_settings add column if not exists created_at timestamptz not null default now();
alter table public.user_settings add column if not exists updated_at timestamptz not null default now();

create table if not exists public.user_devices (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  device_id text not null,
  platform text,
  fcm_token text not null,
  updated_at timestamptz not null default now(),
  fcm_token_updated_at timestamptz
);

create unique index if not exists user_devices_user_device_key
  on public.user_devices(user_id, device_id);

create table if not exists public.user_entitlements (
  user_id uuid not null references auth.users(id) on delete cascade,
  entitlement text not null,
  is_active boolean not null default false,
  updated_at timestamptz not null default now(),
  provider text,
  provider_customer_id text,
  provider_subscription_id text,
  provider_status text,
  current_period_end timestamptz,
  cancel_at_period_end boolean,
  renewal_reminder_sent_at timestamptz,
  activation_notified_at timestamptz,
  pending_provider text,
  pending_provider_subscription_id text,
  pending_provider_customer_id text,
  pending_starts_at timestamptz,
  switch_initiated_at timestamptz,
  teardown_grace_until timestamptz,
  primary key (user_id, entitlement)
);

alter table public.user_entitlements add column if not exists is_active boolean not null default false;
alter table public.user_entitlements add column if not exists updated_at timestamptz not null default now();
alter table public.user_entitlements add column if not exists provider text;
alter table public.user_entitlements add column if not exists provider_customer_id text;
alter table public.user_entitlements add column if not exists provider_subscription_id text;
alter table public.user_entitlements add column if not exists provider_status text;
alter table public.user_entitlements add column if not exists current_period_end timestamptz;
alter table public.user_entitlements add column if not exists cancel_at_period_end boolean;
alter table public.user_entitlements add column if not exists renewal_reminder_sent_at timestamptz;
alter table public.user_entitlements add column if not exists activation_notified_at timestamptz;
alter table public.user_entitlements add column if not exists pending_provider text;
alter table public.user_entitlements add column if not exists pending_provider_subscription_id text;
alter table public.user_entitlements add column if not exists pending_provider_customer_id text;
alter table public.user_entitlements add column if not exists pending_starts_at timestamptz;
alter table public.user_entitlements add column if not exists switch_initiated_at timestamptz;
alter table public.user_entitlements add column if not exists teardown_grace_until timestamptz;

create or replace view public.armed_decoy_seeds as
select
  wallet.user_id,
  decoy.id::text as decoy_id,
  null::text as first_name,
  null::text as last_name,
  decoy.addresses,
  decoy.xpub,
  decoy.zpub,
  decoy.watch_public_key,
  decoy.watch_public_key_type,
  decoy.derivation_path
from public.decoy_wallet wallet
join public.decoys decoy
  on decoy.id::text = wallet.decoy_seed_decoy_id
where coalesce(wallet.decoy_seed_armed, false) = true
  and coalesce(wallet.decoy_seed_contacts_enabled, false) = true
  and coalesce(decoy.active, true) = true;

alter table public.decoys enable row level security;
alter table public.decoy_wallet enable row level security;
alter table public.decoy_triggers enable row level security;
alter table public.emergency_contacts enable row level security;
alter table public.emergency_contact_consents enable row level security;
alter table public.emergency_contact_consent_requests enable row level security;
alter table public.alert_logs enable row level security;
alter table public.sms_queue enable row level security;
alter table public.notification_jobs enable row level security;
alter table public.user_consents enable row level security;
alter table public.user_settings enable row level security;
alter table public.user_devices enable row level security;
alter table public.user_entitlements enable row level security;

drop policy if exists "Users can read own decoys" on public.decoys;
create policy "Users can read own decoys"
  on public.decoys for select
  using (auth.uid() = user_id);

drop policy if exists "Users can write own decoys" on public.decoys;
create policy "Users can write own decoys"
  on public.decoys for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "Users can read own decoy wallet" on public.decoy_wallet;
create policy "Users can read own decoy wallet"
  on public.decoy_wallet for select
  using (auth.uid() = user_id);

drop policy if exists "Users can write own decoy wallet" on public.decoy_wallet;
create policy "Users can write own decoy wallet"
  on public.decoy_wallet for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "Users can read own emergency contacts" on public.emergency_contacts;
create policy "Users can read own emergency contacts"
  on public.emergency_contacts for select
  using (auth.uid() = user_id);

drop policy if exists "Users can write own emergency contacts" on public.emergency_contacts;
create policy "Users can write own emergency contacts"
  on public.emergency_contacts for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "Users can read own contact consents" on public.emergency_contact_consents;
create policy "Users can read own contact consents"
  on public.emergency_contact_consents for select
  using (auth.uid() = user_id);

drop policy if exists "Users can write own contact consents" on public.emergency_contact_consents;
create policy "Users can write own contact consents"
  on public.emergency_contact_consents for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "Users can read own contact consent requests" on public.emergency_contact_consent_requests;
create policy "Users can read own contact consent requests"
  on public.emergency_contact_consent_requests for select
  using (auth.uid() = user_id);

drop policy if exists "Users can write own contact consent requests" on public.emergency_contact_consent_requests;
create policy "Users can write own contact consent requests"
  on public.emergency_contact_consent_requests for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "Users can read own alerts" on public.alert_logs;
create policy "Users can read own alerts"
  on public.alert_logs for select
  using (auth.uid() = user_id);

drop policy if exists "Users can read own sms queue" on public.sms_queue;
create policy "Users can read own sms queue"
  on public.sms_queue for select
  using (auth.uid() = user_id);

drop policy if exists "Users can read own notification jobs" on public.notification_jobs;
create policy "Users can read own notification jobs"
  on public.notification_jobs for select
  using (auth.uid() = user_id);

drop policy if exists "Users can read own consents" on public.user_consents;
create policy "Users can read own consents"
  on public.user_consents for select
  using (auth.uid() = user_id);

drop policy if exists "Users can write own consents" on public.user_consents;
create policy "Users can write own consents"
  on public.user_consents for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "Users can read own settings" on public.user_settings;
create policy "Users can read own settings"
  on public.user_settings for select
  using (auth.uid() = user_id);

drop policy if exists "Users can write own settings" on public.user_settings;
create policy "Users can write own settings"
  on public.user_settings for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "Users can read own devices" on public.user_devices;
create policy "Users can read own devices"
  on public.user_devices for select
  using (auth.uid() = user_id);

drop policy if exists "Users can write own devices" on public.user_devices;
create policy "Users can write own devices"
  on public.user_devices for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "Users can read own entitlements" on public.user_entitlements;
create policy "Users can read own entitlements"
  on public.user_entitlements for select
  using (auth.uid() = user_id);
