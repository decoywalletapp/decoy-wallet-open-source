const crypto = require('crypto');

function redactSensitiveText(value) {
  let text = String(value || '');
  const replacements = [
    /\b(?:xpub|ypub|zpub|tpub|upub|vpub)[1-9A-HJ-NP-Za-km-z]{20,}\b/g,
    /\bbc1[qp][0-9a-z]{20,90}\b/gi,
    /\b[13][a-km-zA-HJ-NP-Z1-9]{25,34}\b/g,
  ];

  for (const pattern of replacements) {
    text = text.replace(pattern, '[redacted-watch-data]');
  }

  return text;
}

function sensitiveRef(scope, value, hmacKey) {
  const clean = String(value || '').trim();
  if (!clean) return `${scope}:empty`;

  const digest = crypto
    .createHmac('sha256', String(hmacKey || ''))
    .update(`${scope}:${clean}`)
    .digest('hex')
    .slice(0, 16);

  return `${scope}:${digest}`;
}

module.exports = {
  redactSensitiveText,
  sensitiveRef,
};
