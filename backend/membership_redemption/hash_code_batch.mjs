#!/usr/bin/env node

import fs from 'node:fs';
import { hashSecret, isMembershipCodeFormatValid } from './redemption_core.mjs';

const [inputPath, outputPath] = process.argv.slice(2);
const pepper = process.env.MEMBERSHIP_CODE_PEPPER;
if (!inputPath || !outputPath || !pepper) {
  throw new Error(
    'Usage: MEMBERSHIP_CODE_PEPPER=... node hash_code_batch.mjs input.csv output.sql',
  );
}

const rows = fs
  .readFileSync(inputPath, 'utf8')
  .trim()
  .split(/\r?\n/)
  .slice(1)
  .map((line) => line.split(',')[1]?.trim());

if (!rows.length || rows.some((code) => !isMembershipCodeFormatValid(code))) {
  throw new Error('Input contains a missing or malformed membership code');
}
if (new Set(rows).size !== rows.length) {
  throw new Error('Input contains duplicate membership codes');
}

const values = rows
  .map((code) => `  (campaign.id, '${hashSecret(code, pepper)}', 'available')`)
  .join(',\n');
const sql = `do $$
declare
  campaign public.promo_campaigns%rowtype;
begin
  select * into campaign from public.promo_campaigns where slug = 'mwbs-2026';
  if not found then raise exception 'mwbs-2026 campaign missing'; end if;
  insert into public.promo_codes (campaign_id, code_hash, status)
  values
${values}
  on conflict (code_hash) do nothing;
end $$;
`;

fs.writeFileSync(outputPath, sql, { mode: 0o600 });
process.stdout.write(`Prepared ${rows.length} code hashes at ${outputPath}\n`);
