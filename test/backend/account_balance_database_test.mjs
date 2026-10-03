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
    'select public.account_simulated_balance($1, $2::jsonb) as value',
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
  await test('spending does not restart the 24 hour timer', async () => {
    const before = (await call(users[0])).balance;
    const after = (await call(users[0], operation('spend', 25000000, before.epoch, 1000))).balance;
    assert.equal(after.sats, 75000000);
    assert.equal(after.seeded_at, before.seeded_at);
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
    assert.equal((await call(users[0], operation('seed', 200000000))).balance.sats, 0);
  });
  await test('expiration resets balance after 24 hours', async () => {
    await db.query("update public.account_simulated_balances set seeded_at = now() - interval '24 hours' where user_id = $1", [users[0]]);
    assert.equal((await call(users[0], operation('seed', 200000000))).balance.sats, 200000000);
  });
  await test('old offline spend cannot drain a newly configured epoch', async () => {
    const old = (await call(users[0])).balance;
    await call(users[0], operation('configure', 500000000));
    assert.equal((await call(users[0], operation('spend', 500000000, old.epoch))).balance.sats, 500000000);
  });
  await test('manual zero survives reseeding attempts', async () => {
    await call(users[0], operation('configure', 0));
    assert.equal((await call(users[0], operation('seed', 500000000))).balance.sats, 0);
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
