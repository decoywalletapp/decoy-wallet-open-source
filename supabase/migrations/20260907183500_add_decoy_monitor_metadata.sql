begin;

alter table public.decoys
  add column if not exists source_type text,
  add column if not exists archived_at timestamptz;

create index if not exists decoys_user_active_unarchived_idx
  on public.decoys (user_id, active)
  where archived_at is null;

comment on column public.decoys.source_type is
  'Origin of this Decoy Keys monitor, for example generated-seed, address-list, xpub, or zpub.';

comment on column public.decoys.archived_at is
  'Soft-delete marker for user-managed Decoy Keys monitors. Archived rows must not participate in active monitoring.';

commit;
