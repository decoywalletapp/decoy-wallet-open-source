// In-memory PostgreSQL only. This runner never reads production credentials.
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { randomUUID } from 'node:crypto';

const { PGlite } = await import(process.env.PGLITE_TEST_MODULE ?? '@electric-sql/pglite');
const db = new PGlite();
const users = Array.from({ length: 5 }, () => randomUUID());
let checks = 0;
const test = async (name, run) => { await run(); console.log(`PASS ${++checks}: ${name}`); };
const operation = (kind, sats, expected_epoch = null, fee_sats = 0) => ({
  id: randomUUID(), kind, sats, expected_epoch, fee_sats,
  at: new Date().toISOString(),
});

async function owner(id, run) {
  await db.query("select set_config('request.jwt.claim.sub', $1, false)", [id ?? '']);
  await db.exec('set role authenticated');
  try { return await run(); } finally { await db.exec('reset role'); }
}
async function call(id, op = null, expectedOwner = id) {
  return owner(id, async () => (await db.query(
    'select public.account_simulated_balance_v2($1, $2::jsonb) as value',
    [expectedOwner, op == null ? null : JSON.stringify(op)])).rows[0].value);
}

try {
  await db.exec(`
    create role anon;
    create role authenticated;
    create role service_role;
    create schema auth;
    create table auth.users(id uuid primary key);
    create function auth.uid() returns uuid language sql stable as $$
      select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid
    $$;
  `);
  await db.exec(await readFile(new URL(
    '../../supabase/migrations/20261003180000_account_simulated_balance_pilot.sql',
    import.meta.url), 'utf8'));
  await test('new client endpoint is unavailable before the new migration', async () => {
    assert.equal((await db.query("select to_regprocedure('public.account_simulated_balance_v2(uuid,jsonb)') as fn")).rows[0].fn, null);
  });
  const legacyUsers = Array.from({ length: 3 }, () => randomUUID());
  for (const [index, id] of legacyUsers.entries()) {
    await db.query('insert into auth.users values ($1)', [id]);
    await db.query(`insert into public.account_simulated_balances(user_id, sats, seeded_at, epoch)
      values ($1, $2, $3, $4)`, [id, index === 0 ? 19500000000 : 0,
      index === 2 ? null : '2026-01-01T00:00:00Z', index === 2 ? null : randomUUID()]);
  }
  const oldRows = (await db.query('select * from public.account_simulated_balances order by user_id')).rows;
  await db.exec(await readFile(new URL(
    '../../supabase/migrations/20261003220000_account_balance_drain_refill.sql',
    import.meta.url), 'utf8'));
  await test('upgrade preserves existing balances and never invents a drain timestamp', async () => {
    for (const before of oldRows) {
      const after = (await db.query('select * from public.account_simulated_balances where user_id = $1', [before.user_id])).rows[0];
      assert.equal(after.sats, before.sats);
      assert.equal(after.epoch, before.epoch);
      assert.deepEqual(after.seeded_at, before.seeded_at);
      assert.equal(after.configured_sats, before.epoch == null ? null : before.sats);
      assert.equal(after.drained_at, null);
      assert.equal(after.refilled_from_epoch, null);
    }
  });
  for (const id of users) await db.query('insert into auth.users values ($1)', [id]);

  await test('migration enrolls nobody automatically', async () => {
    assert.equal((await call(users[0])).eligible, false);
  });
  for (const id of users.slice(0, 4)) {
    await db.query('insert into public.simulated_balance_pilot_users values ($1)', [id]);
  }
  await test('four test users are eligible, outsider is not', async () => {
    for (const id of users.slice(0, 4)) assert.equal((await call(id)).eligible, true);
    assert.equal((await call(users[4], operation('configure', 1))).eligible, false);
  });
  await test('unauthenticated or forged account ownership is rejected', async () => {
    await assert.rejects(() => call(null, null, users[0]), /balance_owner_mismatch/);
    await assert.rejects(() => call(users[0], operation('configure', 10), users[1]), /balance_owner_mismatch/);
  });
  await test('clients cannot read balance or enrollment tables directly', async () => {
    for (const table of ['account_simulated_balances', 'simulated_balance_pilot_users',
      'simulated_balance_operations']) {
      await assert.rejects(() => owner(users[0], () => db.query(`select * from public.${table}`)), /permission denied/);
    }
  });
  await test('RLS and anonymous RPC restrictions are preserved', async () => {
    const tables = (await db.query(`select relrowsecurity from pg_class
      where oid in ('public.account_simulated_balances'::regclass,
        'public.simulated_balance_pilot_users'::regclass,
        'public.simulated_balance_operations'::regclass)`)).rows;
    assert.equal(tables.length, 3);
    assert.ok(tables.every(row => row.relrowsecurity));
    await db.exec('set role anon');
    try {
      await assert.rejects(() => db.query('select public.account_simulated_balance_v2($1)', [users[0]]), /permission denied/);
      await assert.rejects(() => db.query('select public.account_simulated_balance($1)', [users[0]]), /permission denied/);
    } finally { await db.exec('reset role'); }
  });
  await test('clients cannot enroll themselves or overwrite another account', async () => {
    await assert.rejects(() => owner(users[4], () => db.query(
      'insert into public.simulated_balance_pilot_users values ($1)', [users[4]])), /permission denied/);
    await assert.rejects(() => owner(users[0], () => db.query(
      'update public.account_simulated_balances set sats = 999 where user_id = $1', [users[1]])), /permission denied/);
  });
  await test('random seed accepted only in the existing 1 to 5 BTC range', async () => {
    await assert.rejects(() => call(users[0], operation('seed', 99999999)), /invalid_initial_balance/);
    await assert.rejects(() => call(users[0], operation('seed', 500000001)), /invalid_initial_balance/);
    assert.equal((await call(users[0], operation('seed', 300000000))).balance.sats, 300000000);
  });
  await test('second device seed does not replace an existing live balance', async () => {
    assert.equal((await call(users[0], operation('seed', 500000000))).balance.sats, 300000000);
  });
  await test('each user retains their own configuration', async () => {
    for (let i = 0; i < 4; i++) await call(users[i], operation('configure', (i + 1) * 100000000));
    for (let i = 0; i < 4; i++) assert.equal((await call(users[i])).balance.sats, (i + 1) * 100000000);
  });
  await test('partial spending preserves the target and does not start a cooldown', async () => {
    const before = (await call(users[0])).balance;
    const after = (await call(users[0], operation('spend', 25000000, before.epoch, 1000))).balance;
    assert.equal(after.sats, 75000000);
    assert.equal(after.seeded_at, before.seeded_at);
    assert.equal(after.configured_sats, 100000000);
    assert.equal(after.drained_at, null);
  });
  await test('duplicate operation after a lost response is idempotent', async () => {
    const before = (await call(users[0])).balance;
    const op = operation('spend', 10000000, before.epoch);
    const first = await call(users[0], op);
    const retry = await call(users[0], op);
    assert.equal(first.balance.sats, 65000000);
    assert.equal(retry.balance.sats, 65000000);
  });
  await test('multiple devices subtract independently without losing a spend', async () => {
    const before = (await call(users[1])).balance;
    const results = await Promise.all([
      call(users[1], operation('spend', 25000000, before.epoch)),
      call(users[1], operation('spend', 50000000, before.epoch)),
    ]);
    assert.equal(results.at(-1).balance.sats, 125000000);
  });
  await test('drained balance stays at zero before expiration', async () => {
    const before = (await call(users[0])).balance;
    await call(users[0], operation('spend', before.sats, before.epoch));
    const drained = (await call(users[0])).balance;
    assert.ok(drained.drained_at);
    assert.equal(drained.configured_sats, 100000000);
    assert.equal((await call(users[0], operation('seed', 200000000))).balance.sats, 0);
  });
  await test('early seed and repeated sends at zero do not change the drain clock', async () => {
    const before = (await call(users[0])).balance;
    await db.query("update public.account_simulated_balances set seeded_at = now() - interval '90 days' where user_id = $1", [users[0]]);
    assert.equal((await call(users[0], operation('seed', 300000000, before.epoch))).balance.sats, 0);
    const after = (await call(users[0], operation('spend', 100000000, before.epoch))).balance;
    assert.equal(after.drained_at, before.drained_at);
  });
  await test('only a full 24 hours since draining permits restoring the custom amount', async () => {
    const before = (await call(users[0])).balance;
    await db.query("update public.account_simulated_balances set drained_at = now() - interval '23 hours 59 minutes' where user_id = $1", [users[0]]);
    assert.equal((await call(users[0], operation('seed', 200000000, before.epoch))).balance.sats, 0);
    await db.query("update public.account_simulated_balances set drained_at = now() - interval '24 hours' where user_id = $1", [users[0]]);
    const op = operation('seed', 200000000, before.epoch);
    const after = (await call(users[0], op)).balance;
    assert.equal(after.sats, 100000000);
    assert.equal(after.configured_sats, 100000000);
    assert.equal(after.drained_at, null);
    assert.notEqual(after.epoch, before.epoch);
    assert.equal(after.refilled_from_epoch, before.epoch);
    assert.deepEqual((await call(users[0], op)).balance, after);
  });
  await test('old offline spend cannot drain a newly configured epoch', async () => {
    const old = (await call(users[0])).balance;
    await call(users[0], operation('configure', 500000000));
    assert.equal((await call(users[0], operation('spend', 500000000, old.epoch))).balance.sats, 500000000);
  });
  await test('manual zero survives old age, spending, and reseeding attempts', async () => {
    await call(users[0], operation('configure', 0));
    await db.query("update public.account_simulated_balances set seeded_at = now() - interval '90 days' where user_id = $1", [users[0]]);
    const before = (await call(users[0])).balance;
    await call(users[0], operation('spend', 1, before.epoch));
    const after = (await call(users[0], operation('seed', 500000000, before.epoch))).balance;
    assert.equal(after.sats, 0);
    assert.equal(after.configured_sats, 0);
    assert.equal(after.drained_at, null);
  });
  await test('200 minus 5 stays 195 after 90 days, including through the old endpoint', async () => {
    const before = (await call(users[0], operation('configure', 20000000000))).balance;
    await call(users[0], operation('spend', 500000000, before.epoch));
    await db.query("update public.account_simulated_balances set seeded_at = now() - interval '90 days' where user_id = $1", [users[0]]);
    const after = (await call(users[0], operation('seed', 100000000, before.epoch))).balance;
    assert.equal(after.sats, 19500000000);
    assert.equal(after.configured_sats, 20000000000);
    assert.equal(after.drained_at, null);
    const legacy = await owner(users[0], async () => (await db.query(
      'select public.account_simulated_balance($1, $2::jsonb) as value',
      [users[0], JSON.stringify(operation('seed', 200000000, before.epoch))])).rows[0].value);
    assert.equal(legacy.balance.sats, 19500000000);
  });
  await test('a lost drain response is idempotent and client timestamps cannot shorten cooldown', async () => {
    const before = (await call(users[0])).balance;
    const op = operation('spend', before.sats, before.epoch);
    op.at = '2000-01-01T00:00:00Z';
    const first = (await call(users[0], op)).balance;
    const retry = (await call(users[0], op)).balance;
    assert.equal(first.sats, 0);
    assert.equal(first.drained_at, retry.drained_at);
    const age = (await db.query('select now() - drained_at < interval \'1 minute\' as recent from public.account_simulated_balances where user_id = $1', [users[0]])).rows[0].recent;
    assert.equal(age, true);
  });
  await test('reconfiguration cancels the old cooldown and changes the target', async () => {
    const old = (await call(users[0])).balance;
    const after = (await call(users[0], operation('configure', 700000000))).balance;
    assert.equal(after.drained_at, null);
    assert.equal(after.configured_sats, 700000000);
    assert.equal(after.refilled_from_epoch, null);
    assert.equal((await call(users[0], operation('seed', 300000000, old.epoch))).balance.sats, 700000000);
    assert.equal((await call(users[0], operation('spend', 700000000, old.epoch))).balance.sats, 700000000);
  });
  await test('fee-sized dust is drained, but a zero amount cannot create a drain', async () => {
    const before = (await call(users[0], operation('configure', 2002))).balance;
    assert.equal((await call(users[0], operation('spend', 0, before.epoch, 10000))).balance.sats, 2002);
    const partial = (await call(users[0], operation('spend', 1000, before.epoch, 1000))).balance;
    assert.equal(partial.sats, 1002);
    assert.equal(partial.drained_at, null);
    const drained = (await call(users[0], operation('spend', 1, before.epoch, 1000))).balance;
    assert.equal(drained.sats, 0);
    assert.ok(drained.drained_at);
    assert.equal(drained.configured_sats, 2002);
  });
  await test('an unconfigured default gets a random refill only after draining', async () => {
    const id = legacyUsers[2];
    await db.query('insert into public.simulated_balance_pilot_users values ($1)', [id]);
    const first = (await call(id, operation('seed', 400000000))).balance;
    assert.equal(first.configured_sats, null);
    await call(id, operation('spend', 100000000, first.epoch));
    await db.query("update public.account_simulated_balances set seeded_at = now() - interval '90 days' where user_id = $1", [id]);
    assert.equal((await call(id, operation('seed', 100000000, first.epoch))).balance.sats, 300000000);
    await call(id, operation('spend', 300000000, first.epoch));
    await db.query("update public.account_simulated_balances set drained_at = now() - interval '24 hours' where user_id = $1", [id]);
    const reset = operation('seed', 250000000, first.epoch);
    const refill = (await call(id, reset)).balance;
    assert.equal(refill.sats, 250000000);
    assert.equal(refill.configured_sats, null);
    assert.equal(refill.drained_at, null);
    assert.equal(refill.refilled_from_epoch, first.epoch);
    assert.equal((await call(id, operation('seed', 500000000, first.epoch))).balance.sats, 250000000);
    assert.equal((await call(id, operation('spend', 400000000, first.epoch))).balance.sats, 250000000);
    await call(id, operation('spend', 50000000, refill.epoch));
    assert.equal((await call(id, reset)).balance.sats, 200000000);
  });
  await test('competing refill responses identify the same cycle for queued sends', async () => {
    const before = (await call(users[0], operation('configure', 20000000000))).balance;
    await call(users[0], operation('spend', 20000000000, before.epoch));
    await db.query("update public.account_simulated_balances set drained_at = now() - interval '24 hours' where user_id = $1", [users[0]]);
    const first = (await call(users[0], operation('seed', 300000000, before.epoch))).balance;
    const second = (await call(users[0], operation('seed', 400000000, before.epoch))).balance;
    assert.equal(second.epoch, first.epoch);
    assert.equal(second.refilled_from_epoch, before.epoch);
    await call(users[0], operation('spend', 500000000, first.epoch));
    const after = (await call(users[0], operation('spend', 700000000, second.epoch))).balance;
    assert.equal(after.sats, 18800000000);
    assert.equal(after.configured_sats, 20000000000);
    assert.equal(after.refilled_from_epoch, before.epoch);
  });
  await test('malformed and out of range operations are rejected', async () => {
    await assert.rejects(() => call(users[0], operation('configure', -1)), /invalid_balance_operation/);
    await assert.rejects(() => call(users[0], operation('configure', 2100000000000001)), /invalid_balance_operation/);
    await assert.rejects(() => call(users[0], operation('unknown', 1)), /invalid_balance_operation/);
  });
  await test('removing pilot enrollment blocks further operations', async () => {
    await db.query('delete from public.simulated_balance_pilot_users where user_id = $1', [users[2]]);
    assert.equal((await call(users[2], operation('configure', 1))).eligible, false);
  });
  await test('account deletion cascades only that account balance and queue receipts', async () => {
    await db.query('delete from auth.users where id = $1', [users[0]]);
    assert.equal((await db.query('select count(*)::int as n from public.account_simulated_balances where user_id = $1', [users[0]])).rows[0].n, 0);
    assert.equal((await db.query('select count(*)::int as n from public.simulated_balance_operations where user_id = $1', [users[0]])).rows[0].n, 0);
    assert.equal((await call(users[3])).balance.sats, 400000000);
  });
  console.log(`${checks} database checks passed.`);
} finally {
  await db.close();
}
