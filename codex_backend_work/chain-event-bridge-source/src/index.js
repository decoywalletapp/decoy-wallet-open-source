const http = require('node:http');
const crypto = require('node:crypto');

const PORT = Number(process.env.PORT || 8080);
const WATCHER_URL = (process.env.WATCHER_URL || '').replace(/\/+$/, '');
const WATCHER_CHAIN_EVENT_SECRET = (process.env.WATCHER_CHAIN_EVENT_SECRET || '').trim();
const CHAIN_EVENT_BRIDGE_SECRET = (process.env.CHAIN_EVENT_BRIDGE_SECRET || '').trim();
const JSON_BODY_LIMIT_BYTES = Math.max(1024, Math.min(5 * 1024 * 1024, Number(process.env.JSON_BODY_LIMIT_BYTES || 1024 * 1024)));
const FORWARD_TIMEOUT_MS = Math.max(1000, Math.min(60000, Number(process.env.FORWARD_TIMEOUT_MS || 15000)));

function log(tag, payload = {}) {
  console.log('[decoy-chain-event-bridge]', tag, JSON.stringify(payload));
}

function sendJson(res, status, body) {
  res.writeHead(status, { 'content-type': 'application/json' });
  res.end(JSON.stringify(body));
}

function secretFromRequest(req) {
  const explicit = req.headers['x-decoy-chain-event-secret'] || req.headers['x-chain-event-secret'] || '';
  if (explicit) return String(explicit).trim();

  const authorization = req.headers.authorization || '';
  const match = String(authorization).match(/^Bearer\s+(.+)$/i);
  return match ? match[1].trim() : '';
}

function timingSafeSecretEquals(expected, actual) {
  if (!expected || !actual) return false;
  const a = Buffer.from(expected);
  const b = Buffer.from(actual);
  return a.length === b.length && crypto.timingSafeEqual(a, b);
}

function authorized(req) {
  return timingSafeSecretEquals(CHAIN_EVENT_BRIDGE_SECRET, secretFromRequest(req));
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    let total = 0;

    req.on('data', (chunk) => {
      total += chunk.length;
      if (total > JSON_BODY_LIMIT_BYTES) {
        reject(Object.assign(new Error('body too large'), { status: 413 }));
        req.destroy();
        return;
      }
      chunks.push(chunk);
    });

    req.on('error', reject);
    req.on('end', () => resolve(Buffer.concat(chunks).toString('utf8') || '{}'));
  });
}

async function getIdentityToken() {
  const url =
    'http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/identity' +
    `?audience=${encodeURIComponent(WATCHER_URL)}`;
  const resp = await fetch(url, { headers: { 'Metadata-Flavor': 'Google' } });
  if (!resp.ok) {
    const text = await resp.text().catch(() => '');
    throw new Error(`identity token failed: ${resp.status} ${text.slice(0, 120)}`);
  }
  return resp.text();
}

async function forwardToWatcher(req, bodyText) {
  const token = await getIdentityToken();
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), FORWARD_TIMEOUT_MS);

  try {
    const resp = await fetch(`${WATCHER_URL}/chain-event`, {
      method: 'POST',
      headers: {
        authorization: `Bearer ${token}`,
        'content-type': 'application/json',
        'x-decoy-chain-event-secret': WATCHER_CHAIN_EVENT_SECRET,
        'x-decoy-chain-event-source':
          req.headers['x-decoy-chain-event-source'] ||
          req.headers['x-quicknode-stream-id'] ||
          req.headers['x-webhook-source'] ||
          'chain-event-bridge',
      },
      body: bodyText,
      signal: controller.signal,
    });

    const text = await resp.text();
    return { status: resp.status, text };
  } finally {
    clearTimeout(timeout);
  }
}

async function handleChainEvent(req, res) {
  if (!WATCHER_URL || !WATCHER_CHAIN_EVENT_SECRET || !CHAIN_EVENT_BRIDGE_SECRET) {
    sendJson(res, 503, { ok: false, error: 'bridge not configured' });
    return;
  }

  if (!authorized(req)) {
    sendJson(res, 401, { ok: false, error: 'unauthorized' });
    return;
  }

  let bodyText;
  try {
    bodyText = await readBody(req);
    JSON.parse(bodyText);
  } catch (error) {
    sendJson(res, error.status || 400, { ok: false, error: error.status === 413 ? 'body too large' : 'invalid json' });
    return;
  }

  try {
    const forwarded = await forwardToWatcher(req, bodyText);
    log('FORWARDED_CHAIN_EVENT', { watcherStatus: forwarded.status });
    res.writeHead(forwarded.status, { 'content-type': 'application/json' });
    res.end(forwarded.text || '{}');
  } catch (error) {
    log('FORWARD_CHAIN_EVENT_FAILED', { message: error && error.message ? error.message : String(error) });
    sendJson(res, 502, { ok: false, error: 'watcher forward failed' });
  }
}

const server = http.createServer((req, res) => {
  if (req.method === 'GET' && req.url === '/') {
    sendJson(res, 200, {
      ok: true,
      service: 'decoy-chain-event-bridge',
      watcherConfigured: !!WATCHER_URL,
      secretConfigured: !!CHAIN_EVENT_BRIDGE_SECRET,
    });
    return;
  }

  if (req.method === 'POST' && req.url === '/chain-event') {
    handleChainEvent(req, res);
    return;
  }

  sendJson(res, 404, { ok: false, error: 'not found' });
});

server.listen(PORT, () => {
  log('STARTED', {
    port: PORT,
    watcherConfigured: !!WATCHER_URL,
    bridgeSecretConfigured: !!CHAIN_EVENT_BRIDGE_SECRET,
    watcherSecretConfigured: !!WATCHER_CHAIN_EVENT_SECRET,
  });
});
