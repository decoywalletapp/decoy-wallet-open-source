create table if not exists public.decoy_seed_utxo_state (
  decoy_id uuid not null,
  outpoint_hmac text not null,
  first_seen_at timestamptz not null default now(),
  last_seen_at timestamptz not null default now(),
  spent_at timestamptz,
  trigger_recorded_at timestamptz,
  source text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (decoy_id, outpoint_hmac)
);

create index if not exists decoy_seed_utxo_state_open_idx
  on public.decoy_seed_utxo_state (decoy_id, spent_at)
  where spent_at is null;

alter table public.decoy_seed_utxo_state enable row level security;

comment on table public.decoy_seed_utxo_state is
  'Watch-only decoy seed UTXO state used by the backend watcher. Stores HMAC fingerprints only; never raw transaction IDs, addresses, seed phrases, or private keys.';

comment on column public.decoy_seed_utxo_state.outpoint_hmac is
  'HMAC-SHA256 fingerprint of the watched UTXO outpoint using the watcher TXID_HMAC_KEY.';
