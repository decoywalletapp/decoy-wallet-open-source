import 'package:decoy_wallet_app/flutter_flow/custom_functions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('international phone number normalization', () {
    test('preserves valid E.164 numbers for non-US countries', () {
      expect(normalizePhoneToE164('+33 6 12 34 56 78'), '+33612345678');
      expect(normalizePhoneToE164('+64 21 123 4567'), '+64211234567');
      expect(normalizePhoneToE164('+44 7700 900123'), '+447700900123');
    });

    test('accepts common international dialing prefixes', () {
      expect(normalizePhoneToE164('00 33 6 12 34 56 78'), '+33612345678');
      expect(normalizePhoneToE164('011 64 21 123 4567'), '+64211234567');
    });

    test('keeps the US shortcut limited to NANP-shaped numbers', () {
      expect(normalizePhoneToE164('(586) 246-9339'), '+15862469339');
      expect(displayPhoneNumber('+15862469339'), '(586) 246-9339');
      expect(formatAsUsPhone('5862469339'), '(586) 246-9339');
    });

    test('does not treat non-US local numbers as US phone numbers', () {
      expect(normalizePhoneToE164('06 12 34 56 78'), '');
      expect(normalizeToTenDigits('06 12 34 56 78'), '');
      expect(formatAsUsPhone('0612345678'), '0612345678');
    });
  });
}
