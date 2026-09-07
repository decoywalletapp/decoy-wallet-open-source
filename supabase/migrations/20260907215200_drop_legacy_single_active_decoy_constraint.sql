begin;

-- Some production databases may still have the legacy single-active-monitor
-- rule as a table constraint instead of a standalone index. Drop both forms so
-- Decoy Keys can keep one generated seed plus multiple imported watch monitors.
alter table public.decoys
  drop constraint if exists one_active_decoy_per_user;

drop index if exists public.one_active_decoy_per_user;
drop index if exists public.decoys_one_active_per_user;

commit;
