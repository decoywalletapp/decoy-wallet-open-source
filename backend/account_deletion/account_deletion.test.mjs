import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { test } from 'node:test';

// The database is local/in-memory. No production credentials or APIs are used.
const { PGlite } = await import(process.env.PGLITE_MODULE || '@electric-sql/pglite');
const original = await readFile(new URL('./fixtures/delete_current_user_account_before.sql', import.meta.url), 'utf8');
const migration = await readFile(new URL('../../supabase/migrations/20260921120000_fix_account_deletion_redemption_cleanup.sql', import.meta.url), 'utf8');
const user = '00000000-0000-0000-0000-000000000001';
const other = '00000000-0000-0000-0000-000000000002';

async function database() {
  const db = new PGlite();
  await db.exec(`
    create schema auth;
    create table auth.users(id uuid primary key);
    create function auth.uid() returns uuid language sql stable as
      $$ select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid $$;
    create table public.account_deletion_receipts (
      deleted_user_hash text, deletion_scope_version text, deleted_counts jsonb, note text
    );
    create table public.promo_codes (
      id integer primary key, status text not null,
      reserved_by uuid references auth.users(id) on delete set null,
      redeemed_by uuid references auth.users(id) on delete set null,
      redeemed_at timestamptz, reserved_access_ends_at timestamptz
    );
    create table public.promo_redemptions (
      id integer primary key, promo_code_id integer unique references public.promo_codes(id),
      user_id uuid references auth.users(id) on delete cascade
    );
    create table public.promo_redemption_sessions (
      id integer primary key, user_id uuid references auth.users(id) on delete cascade
    );
    alter table public.promo_codes add column reservation_session_id integer
      references public.promo_redemption_sessions(id) on delete set null;
  `);
  for (const table of ['sms_queue', 'alert_logs', 'emergency_contact_opt_out_tokens',
    'emergency_contact_consent_requests', 'emergency_contact_consents',
    'armed_decoy_seeds', 'decoy_seed_baselines', 'decoy_seed_scan_state',
    'decoy_triggers', 'decoys', 'notification_jobs', 'user_devices', 'user_settings',
    'user_entitlements', 'emergency_contacts', 'decoy_wallet']) {
    await db.exec(`create table public.${table} (
      id integer primary key, user_id uuid, alert_id integer, consent_id integer,
      decoy_id integer, protected_value text
    );`);
  }
  await db.exec(original);
  await db.exec(`insert into auth.users values ('${user}'), ('${other}');`);
  await db.query("select set_config('request.jwt.claim.sub', $1, false)", [user]);
  await db.exec(`
    insert into user_entitlements(id,user_id,protected_value)
      values (1,'${user}','test access'), (2,'${other}','paid through 2027-09-20');
    insert into promo_redemption_sessions values (2,'${other}');
    insert into promo_codes values (2,'redeemed','${other}','${other}',now(),now()+interval '365 days',2);
    insert into promo_redemptions values (2,2,'${other}');
  `);
  return db;
}

async function seed(db, status = 'redeemed', links = 'both') {
  await db.exec(`
    insert into promo_redemption_sessions values (1,'${user}');
    insert into promo_codes values (1,'${status}',
      ${links === 'session_only' ? 'null' : `'${user}'`},
      ${status === 'redeemed' && links !== 'session_only' ? `'${user}'` : 'null'},
      now(),now()+interval '365 days',1);
    ${status === 'redeemed' ? `insert into promo_redemptions values (1,1,'${user}');` : ''}
  `);
}

async function snapshotOther(db) {
  return (await db.query(`select
    (select row_to_json(x) from auth.users x where id='${other}') as account,
    (select row_to_json(x) from user_entitlements x where user_id='${other}') as entitlement,
    (select row_to_json(x) from promo_codes x where id=2) as code,
    (select row_to_json(x) from promo_redemption_sessions x where id=2) as session,
    (select row_to_json(x) from promo_redemptions x where id=2) as redemption`)).rows;
}

test('original function reproduces the promo session foreign-key failure', async () => {
  const db = await database();
  try {
    await seed(db);
    await assert.rejects(db.exec('select public.delete_current_user_account();'),
      error => error.code === '23503' && error.message.includes('reservation_session_id'));
    assert.equal((await db.query('select count(*)::int as n from auth.users')).rows[0].n, 2);
    assert.equal((await db.query('select count(*)::int as n from account_deletion_receipts')).rows[0].n, 0);
  } finally { await db.close(); }
});

for (const status of ['redeemed', 'reserved', 'disabled', 'none', 'session_only']) {
  test(`deletion succeeds for ${status}; other subscriber and code states unchanged`, async () => {
    const db = await database();
    try {
      if (status !== 'none') await seed(db, status === 'session_only' ? 'reserved' : status, status);
      const before = await snapshotOther(db);
      const oldCode = (await db.query('select * from promo_codes where id=1')).rows[0];
      const metadata = (await db.query("select proacl, proowner, prosecdef, proconfig from pg_proc where oid='public.delete_current_user_account()'::regprocedure")).rows;
      await db.exec(migration);
      await db.exec(migration); // Reapplying is harmless.
      assert.deepEqual((await db.query("select proacl, proowner, prosecdef, proconfig from pg_proc where oid='public.delete_current_user_account()'::regprocedure")).rows, metadata);
      await db.exec('select public.delete_current_user_account();');
      assert.equal((await db.query('select * from auth.users where id=$1', [user])).rows.length, 0);
      for (const table of ['user_entitlements', 'promo_redemptions', 'promo_redemption_sessions']) {
        assert.equal((await db.query(`select * from ${table} where user_id=$1`, [user])).rows.length, 0);
      }
      if (oldCode) assert.deepEqual((await db.query('select * from promo_codes where id=1')).rows[0], {
        ...oldCode, reservation_session_id: null, reserved_by: null, redeemed_by: null,
      });
      assert.deepEqual(await snapshotOther(db), before);
      assert.equal((await db.query('select count(*)::int as n from account_deletion_receipts')).rows[0].n, 1);
    } finally { await db.close(); }
  });
}

test('anonymous deletion remains rejected and deletes nothing', async () => {
  const db = await database();
  try {
    await seed(db);
    await db.exec(migration);
    await db.query("select set_config('request.jwt.claim.sub', '', false)");
    await assert.rejects(db.exec('select public.delete_current_user_account();'), /Not authenticated/);
    assert.equal((await db.query('select count(*)::int as n from auth.users')).rows[0].n, 2);
  } finally { await db.close(); }
});

test('later deletion failure rolls back promo cleanup and entitlement removal', async () => {
  const db = await database();
  try {
    await seed(db);
    await db.exec(migration);
    await db.exec(`create table deletion_blocker(user_id uuid references auth.users(id));
      insert into deletion_blocker values ('${user}');`);
    const before = (await db.query('select * from promo_codes order by id')).rows;
    await assert.rejects(db.exec('select public.delete_current_user_account();'), error => error.code === '23503');
    assert.deepEqual((await db.query('select * from promo_codes order by id')).rows, before);
    assert.equal((await db.query('select count(*)::int as n from user_entitlements')).rows[0].n, 2);
    assert.equal((await db.query('select count(*)::int as n from promo_redemption_sessions')).rows[0].n, 2);
    assert.equal((await db.query('select count(*)::int as n from account_deletion_receipts')).rows[0].n, 0);
  } finally { await db.close(); }
});

test('migration refuses to overwrite an unexpectedly changed function', async () => {
  const db = await database();
  try {
    await db.exec(original.replace("'Not authenticated'", "'Authentication required'"));
    await assert.rejects(db.exec(migration), /definition changed/);
    await db.exec('rollback;');
  } finally { await db.close(); }
});
