function asString(value) {
  return typeof value === 'string' ? value.trim() : '';
}

function firstAddress(value) {
  if (!value) return '';
  if (typeof value === 'string') return value.trim();
  if (Array.isArray(value)) {
    return value.map(asString).find(Boolean) || '';
  }
  return '';
}

function outputAddress(output) {
  if (!output || typeof output !== 'object') return '';

  return (
    firstAddress(output.scriptpubkey_address) ||
    firstAddress(output.scriptPubKeyAddress) ||
    firstAddress(output.address) ||
    firstAddress(output.addr) ||
    firstAddress(output.addresses) ||
    firstAddress(output.scriptPubKey && output.scriptPubKey.address) ||
    firstAddress(output.scriptPubKey && output.scriptPubKey.addresses) ||
    firstAddress(output.script_pub_key && output.script_pub_key.address) ||
    firstAddress(output.script_pub_key && output.script_pub_key.addresses)
  );
}

function normalizeTxOutputs(rawOutputs) {
  const outputs = Array.isArray(rawOutputs) ? rawOutputs : [];
  return outputs.map((output) => ({
    scriptpubkey_address: outputAddress(output) || null,
  }));
}

function compareAddress(address) {
  const text = asString(address);
  if (/^(bc1|tb1|bcrt1)/i.test(text)) return text.toLowerCase();
  return text;
}

function inputAddresses(tx) {
  const inputs = Array.isArray(tx && tx.vin) ? tx.vin : [];
  return inputs
    .map((input) => input && input.prevout && input.prevout.scriptpubkey_address)
    .map(asString)
    .filter(Boolean);
}

function outputAddresses(tx) {
  const rawOutputs = Array.isArray(tx && tx.vout) ? tx.vout : [];
  return rawOutputs
    .map((output) => output && output.scriptpubkey_address)
    .map(asString)
    .filter(Boolean);
}

function uniqueAddresses(addresses, maxCount) {
  const seen = new Set();
  const out = [];

  for (const address of addresses) {
    const clean = asString(address);
    if (!clean) continue;

    const key = compareAddress(clean);
    if (seen.has(key)) continue;
    seen.add(key);
    out.push(clean);

    if (out.length >= maxCount) break;
  }

  return out;
}

function destinationAddressCandidates(tx, watchedAddresses = [], options = {}) {
  const maxCount = Math.max(1, Math.min(10, Number(options.maxCount || 3)));
  const excluded = new Set([
    ...inputAddresses(tx).map(compareAddress),
    ...(Array.isArray(watchedAddresses) ? watchedAddresses : []).map(compareAddress),
  ]);

  const candidates = outputAddresses(tx).filter((address) => !excluded.has(compareAddress(address)));
  return uniqueAddresses(candidates, maxCount);
}

module.exports = {
  compareAddress,
  destinationAddressCandidates,
  normalizeTxOutputs,
  outputAddress,
};
