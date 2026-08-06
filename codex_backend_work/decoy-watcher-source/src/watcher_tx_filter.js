const DEFAULT_CONFIRMED_CATCHUP_MAX_AGE_MS = 2 * 60 * 60 * 1000;

// OUTBOUND ONLY: address appears in vin prevout.scriptpubkey_address.
function isOutboundForAddress(tx, addr) {
  const vin = tx && Array.isArray(tx.vin) ? tx.vin : [];
  for (const input of vin) {
    const prevout = input && input.prevout ? input.prevout : null;
    const a = prevout && prevout.scriptpubkey_address ? prevout.scriptpubkey_address : null;
    if (a && a === addr) return true;
  }
  return false;
}

function outboundWatchedAddress(tx, addressSet) {
  const vin = tx && Array.isArray(tx.vin) ? tx.vin : [];
  for (const input of vin) {
    const prevout = input && input.prevout ? input.prevout : null;
    const addr = prevout && prevout.scriptpubkey_address ? prevout.scriptpubkey_address : null;
    if (addr && addressSet.has(addr)) return addr;
  }
  return null;
}

function isConfirmedTx(tx) {
  return !!(tx && tx.status && tx.status.confirmed === true);
}

function confirmedAt(tx) {
  if (!isConfirmedTx(tx)) return null;
  const blockTime = Number(tx.status.block_time);
  if (!Number.isFinite(blockTime) || blockTime <= 0) return null;
  const d = new Date(blockTime * 1000);
  return Number.isNaN(d.getTime()) ? null : d;
}

function shouldProcessOutboundTx(tx, addr, armedAt, baselineAt, options = {}) {
  if (!isOutboundForAddress(tx, addr)) return false;

  // Unconfirmed txs are the fast path. They should trigger immediately when seen.
  if (!isConfirmedTx(tx)) return true;

  // Confirmed txs are the safety net. Only count transactions confirmed after the
  // current arm/baseline window, so old seed history cannot fire a fresh alert.
  // Also require the confirmed transaction to be recent. This prevents stale
  // provider catch-up from sending emergency SMS for days-old transactions.
  const observedAt = confirmedAt(tx);
  const cutoff = baselineAt || armedAt;
  if (!observedAt || !cutoff) return false;

  const maxAgeMs = Number(options.confirmedCatchupMaxAgeMs || DEFAULT_CONFIRMED_CATCHUP_MAX_AGE_MS);
  const ageMs = Date.now() - observedAt.getTime();
  return observedAt.getTime() > cutoff.getTime() && ageMs <= maxAgeMs;
}

function dateMs(value) {
  const date = value ? new Date(value) : null;
  const ms = date ? date.getTime() : NaN;
  return Number.isFinite(ms) ? ms : null;
}

function shouldTriggerMissingUtxo(row, nowMs, missingConfirmationMs) {
  const minMissingMs = Math.max(0, Number(missingConfirmationMs) || 0);
  if (minMissingMs === 0) return true;

  const lastSeenMs = dateMs(row && (row.last_seen_at || row.first_seen_at));
  if (lastSeenMs === null) return false;

  const observedNowMs = Number.isFinite(Number(nowMs)) ? Number(nowMs) : Date.now();
  return observedNowMs - lastSeenMs >= minMissingMs;
}

module.exports = {
  confirmedAt,
  isConfirmedTx,
  isOutboundForAddress,
  outboundWatchedAddress,
  shouldTriggerMissingUtxo,
  shouldProcessOutboundTx,
};
