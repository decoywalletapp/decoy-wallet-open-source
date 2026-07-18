class DecoyBuildProvenance {
  const DecoyBuildProvenance._();

  static const repository = String.fromEnvironment(
    'DECOY_SOURCE_REPOSITORY',
    defaultValue: 'https://github.com/decoywalletapp/decoy-wallet-open-source',
  );
  static const sourceRef = String.fromEnvironment(
    'DECOY_SOURCE_REF',
    defaultValue: 'unverified-local-build',
  );
  static const sourceCommit = String.fromEnvironment(
    'DECOY_SOURCE_COMMIT',
    defaultValue: 'unknown',
  );
  static const buildChannel = String.fromEnvironment(
    'DECOY_BUILD_CHANNEL',
    defaultValue: 'local',
  );
  static const buildVerification = String.fromEnvironment(
    'DECOY_BUILD_VERIFICATION',
    defaultValue: 'not-attested',
  );
  static const buildPlatform = String.fromEnvironment(
    'DECOY_BUILD_PLATFORM',
    defaultValue: 'unknown',
  );
  static const buildVersion = String.fromEnvironment(
    'DECOY_BUILD_VERSION',
    defaultValue: '1.0.4',
  );
  static const buildNumber = String.fromEnvironment(
    'DECOY_BUILD_NUMBER',
    defaultValue: '10004',
  );

  static bool get hasSourceCommit =>
      sourceCommit.isNotEmpty && sourceCommit != 'unknown';

  static String get shortCommit {
    if (!hasSourceCommit) {
      return 'unknown';
    }
    return sourceCommit.length <= 12
        ? sourceCommit
        : sourceCommit.substring(0, 12);
  }

  static String get repositoryLabel {
    final label = repository
        .replaceFirst('https://github.com/', '')
        .replaceFirst('http://github.com/', '');
    return label.endsWith('/') ? label.substring(0, label.length - 1) : label;
  }

  static String get versionLabel {
    if (buildNumber.isEmpty) {
      return buildVersion;
    }
    return '$buildVersion+$buildNumber';
  }

  static String? get commitUrl {
    if (!hasSourceCommit) {
      return null;
    }
    final normalizedRepository = repository.endsWith('/')
        ? repository.substring(0, repository.length - 1)
        : repository;
    return '$normalizedRepository/commit/$sourceCommit';
  }
}
