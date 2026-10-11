import 'package:decoy_wallet_app/flutter_flow/custom_functions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const segwit = 'bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4';
  const taproot =
      'bc1p0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vqzk5jj0';
  const legacy = '1BoatSLRHtKNngkdXEeobR76b53LETtpyT';
  const scriptHash = '3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy';
  const zeroProgram = 'bc1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq9e75rs';

  final valid = <String, String>{
    segwit: segwit,
    segwit.toUpperCase(): segwit,
    taproot: taproot,
    taproot.toUpperCase(): taproot,
    legacy: legacy,
    scriptHash: scriptHash,
    zeroProgram.toUpperCase(): zeroProgram,
    '  $segwit\n': segwit,
    'bitcoin:$legacy?amount=0.01&label=Test': legacy,
    'bitcoin:$legacy?label=Test%20label': legacy,
    'BITCOIN:${zeroProgram.toUpperCase()}?amount=0.1': zeroProgram,
    'bitcoin:$taproot?amount=0.01&lightning=LNBC123': taproot,
  };
  for (final entry in valid.entries) {
    test('extracts the complete receive address: ${entry.key}', () {
      expect(extractBitcoinAddress(entry.key), entry.value);
    });
  }

  final invalid = <String?>[
    null,
    '',
    '   ',
    '-1',
    segwit.replaceFirst('bc1', 'bC1'),
    '${segwit.substring(0, segwit.length - 1)}q',
    '${taproot.substring(0, taproot.length - 1)}q',
    '${legacy.substring(0, legacy.length - 1)}X',
    '${scriptHash.substring(0, scriptHash.length - 1)}X',
    '1QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ9',
    'send to $legacy please',
    '$segwit $legacy',
    'prefix${segwit}suffix',
    '${segwit}garbage',
    'https://example.com/$legacy',
    'litecoin:$legacy',
    'bitcoin://$legacy',
    'bitcoin:$legacy#fragment',
    'bitcoin:?label=$legacy',
    'bitcoin:not-an-address?label=$legacy',
    'bitcoin:$legacy?label=Test\n$segwit',
    'bitcoin:$legacy?label=Test $segwit',
    'bitcoin:${legacy}%ZZ',
    'bc1qqqqqqqqqqq',
    'tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sl5k7',
    'mipcBbFg9gMiCh81Kj8tqqdgoZub1ZJRfn',
    'lnbc1notanonchainaddress',
  ];
  for (final input in invalid) {
    test('rejects invalid or ambiguous QR without extracting fragments: $input',
        () {
      expect(extractBitcoinAddress(input), isEmpty);
    });
  }
}
