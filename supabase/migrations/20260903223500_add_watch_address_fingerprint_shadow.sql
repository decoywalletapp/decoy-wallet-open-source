create table if not exists public.decoy_watch_address_fingerprints (
  decoy_id uuid not null,
  address_hmac text not null,
  fingerprint_version text not null default 'watch-address-v1',
  source_type text,
  address_index integer,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (decoy_id, address_hmac)
);

create index if not exists decoy_watch_address_fingerprints_address_hmac_idx
  on public.decoy_watch_address_fingerprints (address_hmac);

alter table public.decoy_watch_address_fingerprints enable row level security;

comment on table public.decoy_watch_address_fingerprints is
  'Shadow-mode watch-only address fingerprints. Stores HMAC-SHA256 fingerprints only; never raw receive addresses, extended public keys, seed phrases, or private keys.';

comment on column public.decoy_watch_address_fingerprints.decoy_id is
  'Decoy identifier used by service-role backend code for shadow comparison. This table intentionally does not store user_id.';

comment on column public.decoy_watch_address_fingerprints.address_hmac is
  'HMAC-SHA256 fingerprint of a normalized watched receive address using WATCH_ADDRESS_HMAC_KEY.';

comment on column public.decoy_watch_address_fingerprints.fingerprint_version is
  'Fingerprint normalization and HMAC input version. Current value: watch-address-v1.';
