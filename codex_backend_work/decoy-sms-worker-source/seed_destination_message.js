function cleanAddress(value) {
  const text = typeof value === 'string' ? value.trim() : '';
  if (!/^[A-Za-z0-9]{14,120}$/.test(text)) return '';
  return text;
}

function uniqueAddresses(addresses, maxCount) {
  const seen = new Set();
  const out = [];

  for (const value of Array.isArray(addresses) ? addresses : []) {
    const address = cleanAddress(value);
    if (!address) continue;

    const key = /^(bc1|tb1|bcrt1)/i.test(address) ? address.toLowerCase() : address;
    if (seen.has(key)) continue;

    seen.add(key);
    out.push(address);

    if (out.length >= maxCount) break;
  }

  return out;
}

export function seedDestinationAddressesFromAlert(alert, options = {}) {
  const maxCount = Math.max(1, Math.min(5, Number(options.maxCount || 3)));
  return uniqueAddresses(alert?.destination_addresses, maxCount);
}

export function seedDestinationLinesFromAlert(alert, options = {}) {
  const addresses = seedDestinationAddressesFromAlert(alert, options);
  if (!addresses.length) return [];

  if (addresses.length === 1) {
    return [
      'POSSIBLE TRANSACTION TO ADDRESS:',
      addresses[0],
      '',
    ];
  }

  return [
    'POSSIBLE TRANSACTION TO ADDRESSES:',
    ...addresses.map((address, index) => `${index + 1}. ${address}`),
    '',
  ];
}
