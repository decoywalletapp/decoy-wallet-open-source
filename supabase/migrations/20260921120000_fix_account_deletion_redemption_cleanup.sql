begin;

-- Patch only the reviewed live definition. Fail closed if it has changed.
-- CREATE OR REPLACE retains the function's owner and existing permissions.
do $migration$
declare
  definition text;
  anchor constant text := E'  delete from auth.users\n  where id = uid;';
  cleanup constant text := $cleanup$  -- Detach promo references before auth.users cascades remove sessions.
  -- Never reset code status: redeemed/reserved codes must not become reusable.
  update public.promo_codes
  set reservation_session_id = null,
      reserved_by = case when reserved_by = uid then null else reserved_by end,
      redeemed_by = case when redeemed_by = uid then null else redeemed_by end
  where reserved_by = uid
     or redeemed_by = uid
     or reservation_session_id in (
       select id from public.promo_redemption_sessions where user_id = uid
     );

  delete from public.promo_redemptions
  where user_id = uid;

  delete from public.promo_redemption_sessions
  where user_id = uid;

$cleanup$;
begin
  definition := pg_get_functiondef('public.delete_current_user_account()'::regprocedure);
  if position(cleanup in definition) > 0 then
    return;
  end if;
  if md5(definition) <> '88829989b343866d771feaebb55269a4'
      or position(anchor in definition) = 0 then
    raise exception 'Account deletion definition changed; review before applying cleanup';
  end if;
  execute replace(definition, anchor, cleanup || anchor);
end;
$migration$;

commit;
