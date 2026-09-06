import assert from 'node:assert/strict';
import test from 'node:test';

import {
  seedDestinationAddressesFromAlert,
  seedDestinationLinesFromAlert,
} from '../seed_destination_message.js';

const address = 'bc1qdestination000000000000000000000000000000';
const secondAddress = '3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy';

test('seed destination lines include one possible transaction address', () => {
  assert.deepEqual(seedDestinationLinesFromAlert({ destination_addresses: [address] }), [
    'POSSIBLE TRANSACTION TO ADDRESS:',
    address,
    '',
  ]);
});

test('seed destination lines include multiple possible transaction addresses', () => {
  assert.deepEqual(
    seedDestinationLinesFromAlert({ destination_addresses: [address, secondAddress] }),
    [
      'POSSIBLE TRANSACTION TO ADDRESSES:',
      `1. ${address}`,
      `2. ${secondAddress}`,
      '',
    ]
  );
});

test('seed destination extraction ignores invalid values and dedupes bech32 case', () => {
  assert.deepEqual(
    seedDestinationAddressesFromAlert({
      destination_addresses: [
        '',
        'not an address with spaces',
        address.toUpperCase(),
        address,
        secondAddress,
      ],
    }),
    [address.toUpperCase(), secondAddress]
  );
});

test('seed destination lines are empty when no destination was captured', () => {
  assert.deepEqual(seedDestinationLinesFromAlert({ destination_addresses: [] }), []);
  assert.deepEqual(seedDestinationLinesFromAlert({}), []);
});
