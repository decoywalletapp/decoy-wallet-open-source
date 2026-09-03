const crypto = require('crypto');

const FINGERPRINT_VERSION = 'watch-address-v1';

function normalizeWatchAddress(value) {
  const clean = String(value || '').trim();
  if (/^(bc1|tb1|bcrt1)/i.test(clean)) return clean.toLowerCase();
  return clean;
}

function fingerprintInput(address) {
  return `${FINGERPRINT_VERSION}:${normalizeWatchAddress(address)}`;
}

function hmacWatchAddress(address, key) {
  const normalized = normalizeWatchAddress(address);
  const secret = String(key || '');
  if (!normalized || !secret) return '';

  return crypto.createHmac('sha256', secret).update(fingerprintInput(normalized)).digest('hex');
}

module.exports = {
  FINGERPRINT_VERSION,
  fingerprintInput,
  hmacWatchAddress,
  normalizeWatchAddress,
};
