#!/usr/bin/env node

import fs from 'node:fs';

const [serviceJsonPath, outputPath, publicUrl] = process.argv.slice(2);
if (!serviceJsonPath || !outputPath || !publicUrl) {
  throw new Error('Usage: write_canary_env.mjs service.json env.json publicUrl');
}

const service = JSON.parse(fs.readFileSync(serviceJsonPath, 'utf8'));
const env = Object.fromEntries(
  (service.spec?.template?.spec?.containers?.[0]?.env ?? [])
    .filter((entry) => typeof entry.value === 'string')
    .map((entry) => [entry.name, entry.value]),
);

delete env.MEMBERSHIP_CODE_PEPPER;
delete env.REDEMPTION_SESSION_PEPPER;
delete env.STRIPE_PROMO_100_COUPON_ID;
env.PUBLIC_BASE_URL = publicUrl;

fs.writeFileSync(outputPath, JSON.stringify(env), { mode: 0o600 });
