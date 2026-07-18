import 'package:decoy_wallet_app/build_provenance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses safe public defaults when build metadata is not injected', () {
    expect(
      DecoyBuildProvenance.repository,
      'https://github.com/decoywalletapp/decoy-wallet-open-source',
    );
    expect(DecoyBuildProvenance.repositoryLabel,
        'decoywalletapp/decoy-wallet-open-source');
    expect(DecoyBuildProvenance.hasSourceCommit, isFalse);
    expect(DecoyBuildProvenance.shortCommit, 'unknown');
    expect(DecoyBuildProvenance.commitUrl, isNull);
    expect(DecoyBuildProvenance.versionLabel, '1.0.4+10004');
  });
}
