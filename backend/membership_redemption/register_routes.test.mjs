import assert from 'node:assert/strict';
import test from 'node:test';
import { registerMembershipRedemptionRoutes } from './register_routes.mjs';

function createHarness({ rpcResponses, syncStripePromotion = async () => {} }) {
  const handlers = new Map();
  const rpcCalls = [];
  const app = {
    post(path, handler) {
      handlers.set(`POST ${path}`, handler);
    },
    get(path, handler) {
      handlers.set(`GET ${path}`, handler);
    },
  };
  const supabaseAdmin = {
    rpc: async (name, args) => {
      rpcCalls.push({ name, args });
      const response = rpcResponses[name];
      return typeof response === 'function' ? response(args) : response;
    },
  };
  registerMembershipRedemptionRoutes({
    app,
    supabaseAdmin,
    publicRedeemUrl: 'https://example.com/redeem-membership',
    apiBaseUrl: 'https://api.example.com',
    codePepper: 'code-pepper',
    sessionPepper: 'session-pepper',
    syncStripePromotion,
  });

  return { handler: handlers.get('POST /redeem-membership-code'), rpcCalls };
}

function responseHarness() {
  return {
    statusCode: 200,
    body: undefined,
    status(code) {
      this.statusCode = code;
      return this;
    },
    json(body) {
      this.body = body;
      return this;
    },
  };
}

function request() {
  return {
    body: {
      session: 'session-token',
      code: 'mwbs7k9dp4xmq2vt',
    },
  };
}

test('billing failure leaves access unfinalized and returns a retryable error', async () => {
  const { handler, rpcCalls } = createHarness({
    rpcResponses: {
      reserve_membership_code: {
        data: [{
          reservation_id: 'reservation-1',
          user_id: 'user-1',
          access_started_at: '2026-09-19T00:00:00Z',
          access_ends_at: '2027-09-19T00:00:00Z',
          billing_sync_status: 'pending',
        }],
        error: null,
      },
    },
    syncStripePromotion: async () => {
      throw new Error('Stripe unavailable');
    },
  });
  const res = responseHarness();

  await handler(request(), res);

  assert.equal(res.statusCode, 503);
  assert.match(res.body.error, /safely reserved/);
  assert.deepEqual(rpcCalls.map(({ name }) => name), ['reserve_membership_code']);
});

test('non-Stripe redemption finalizes without requesting billing synchronization', async () => {
  let syncCalls = 0;
  const { handler, rpcCalls } = createHarness({
    rpcResponses: {
      reserve_membership_code: {
        data: [{
          reservation_id: 'reservation-2',
          user_id: 'user-2',
          access_started_at: '2026-09-19T00:00:00Z',
          access_ends_at: '2027-09-19T00:00:00Z',
          billing_sync_status: 'not_required',
        }],
        error: null,
      },
      finalize_membership_code: {
        data: [{ access_ends_at: '2027-09-19T00:00:00Z' }],
        error: null,
      },
    },
    syncStripePromotion: async () => {
      syncCalls += 1;
    },
  });
  const res = responseHarness();

  await handler(request(), res);

  assert.equal(res.statusCode, 200);
  assert.equal(res.body.ok, true);
  assert.equal(syncCalls, 0);
  assert.deepEqual(rpcCalls.map(({ name }) => name), [
    'reserve_membership_code',
    'finalize_membership_code',
  ]);
  assert.equal(rpcCalls[1].args.p_billing_sync_complete, false);
});

test('retry after a lost success response returns the completed redemption', async () => {
  const { handler, rpcCalls } = createHarness({
    rpcResponses: {
      reserve_membership_code: { data: null, error: { message: 'already redeemed' } },
      completed_membership_redemption: {
        data: [{ access_ends_at: '2027-09-19T00:00:00Z' }],
        error: null,
      },
    },
  });
  const res = responseHarness();

  await handler(request(), res);

  assert.equal(res.statusCode, 200);
  assert.equal(res.body.ok, true);
  assert.equal(res.body.already_completed, true);
  assert.deepEqual(rpcCalls.map(({ name }) => name), [
    'reserve_membership_code',
    'completed_membership_redemption',
  ]);
});
