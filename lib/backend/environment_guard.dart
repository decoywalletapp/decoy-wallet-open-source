import '/backend/public_config.dart';
import '/build_provenance.dart';

const _stagingSupabaseProjectRef = 'dxsihfandgbrkreeokkm';
const _stagingSupabaseHost = '$_stagingSupabaseProjectRef.supabase.co';

class DecoyBackendEnvironmentSnapshot {
  const DecoyBackendEnvironmentSnapshot({
    required this.backendEnvironment,
    required this.supabaseUrl,
    required this.firebaseFunctionsBaseUrl,
    required this.alertBaseUrl,
    required this.dataKeyBaseUrl,
    required this.paymentBaseUrl,
    required this.verifyBaseUrl,
    required this.emailConfirmUrl,
    required this.emailConfirmDeepLink,
  });

  factory DecoyBackendEnvironmentSnapshot.fromBuild() {
    return DecoyBackendEnvironmentSnapshot(
      backendEnvironment: DecoyBuildProvenance.backendEnvironment,
      supabaseUrl: kSupabaseUrl,
      firebaseFunctionsBaseUrl: kFirebaseFunctionsBaseUrl,
      alertBaseUrl: kDecoyAlertBaseUrl,
      dataKeyBaseUrl: kDataKeyBaseUrl,
      paymentBaseUrl: kPaymentBaseUrl,
      verifyBaseUrl: kVerifyBaseUrl,
      emailConfirmUrl: kEmailConfirmUrl,
      emailConfirmDeepLink: kEmailConfirmDeepLink,
    );
  }

  final String backendEnvironment;
  final String supabaseUrl;
  final String firebaseFunctionsBaseUrl;
  final String alertBaseUrl;
  final String dataKeyBaseUrl;
  final String paymentBaseUrl;
  final String verifyBaseUrl;
  final String emailConfirmUrl;
  final String emailConfirmDeepLink;
}

void validateDecoyBackendEnvironment([
  DecoyBackendEnvironmentSnapshot? snapshot,
]) {
  final problems = inspectDecoyBackendEnvironment(
    snapshot ?? DecoyBackendEnvironmentSnapshot.fromBuild(),
  );
  if (problems.isNotEmpty) {
    throw StateError(
      'Invalid Decoy backend environment wiring: ${problems.join('; ')}',
    );
  }
}

List<String> inspectDecoyBackendEnvironment(
  DecoyBackendEnvironmentSnapshot snapshot,
) {
  final env = snapshot.backendEnvironment.trim().toLowerCase();
  final problems = <String>[];

  if (env != 'production' && env != 'staging') {
    problems.add('DECOY_BACKEND_ENV must be production or staging');
    return problems;
  }

  _requireHttpsUrl(problems, 'DECOY_SUPABASE_URL', snapshot.supabaseUrl);
  _requireHttpsUrl(
    problems,
    'DECOY_FIREBASE_FUNCTIONS_BASE_URL',
    snapshot.firebaseFunctionsBaseUrl,
  );
  _requireHttpsUrl(
    problems,
    'DECOY_ALERT_BASE_URL',
    snapshot.alertBaseUrl,
  );
  _requireHttpsUrl(
    problems,
    'DECOY_DATA_KEY_BASE_URL',
    snapshot.dataKeyBaseUrl,
  );
  _requireHttpsUrl(
    problems,
    'DECOY_PAYMENT_BASE_URL',
    snapshot.paymentBaseUrl,
  );
  _requireHttpsUrl(
    problems,
    'DECOY_VERIFY_BASE_URL',
    snapshot.verifyBaseUrl,
  );

  if (snapshot.emailConfirmUrl.trim().isNotEmpty) {
    _requireHttpsUrl(
      problems,
      'DECOY_EMAIL_CONFIRM_URL',
      snapshot.emailConfirmUrl,
    );
  }
  _rejectLocalhost(
    problems,
    'DECOY_EMAIL_CONFIRM_URL',
    snapshot.emailConfirmUrl,
  );
  _requireDeepLink(
    problems,
    'DECOY_EMAIL_CONFIRM_DEEP_LINK',
    snapshot.emailConfirmDeepLink,
  );

  if (env == 'staging') {
    _requireHost(
      problems,
      'DECOY_SUPABASE_URL',
      snapshot.supabaseUrl,
      _stagingSupabaseHost,
    );
    _requireStagingApiRoute(
      problems,
      'DECOY_FIREBASE_FUNCTIONS_BASE_URL',
      snapshot.firebaseFunctionsBaseUrl,
      'firebase',
    );
    _requireStagingApiRoute(
      problems,
      'DECOY_ALERT_BASE_URL',
      snapshot.alertBaseUrl,
      'alerts',
    );
    _requireStagingApiRoute(
      problems,
      'DECOY_DATA_KEY_BASE_URL',
      snapshot.dataKeyBaseUrl,
      'data-key',
    );
    _requireStagingApiRoute(
      problems,
      'DECOY_PAYMENT_BASE_URL',
      snapshot.paymentBaseUrl,
      'payment',
    );
    _requireStagingFunctionPath(
      problems,
      'DECOY_VERIFY_BASE_URL',
      snapshot.verifyBaseUrl,
      '/functions/v1/verify-link',
    );
    if (snapshot.emailConfirmUrl.trim().isNotEmpty) {
      _requireStagingFunctionPath(
        problems,
        'DECOY_EMAIL_CONFIRM_URL',
        snapshot.emailConfirmUrl,
        '/functions/v1/verify-link',
      );
    }
  } else {
    final productionValues = <String, String>{
      'DECOY_SUPABASE_URL': snapshot.supabaseUrl,
      'DECOY_FIREBASE_FUNCTIONS_BASE_URL': snapshot.firebaseFunctionsBaseUrl,
      'DECOY_ALERT_BASE_URL': snapshot.alertBaseUrl,
      'DECOY_DATA_KEY_BASE_URL': snapshot.dataKeyBaseUrl,
      'DECOY_PAYMENT_BASE_URL': snapshot.paymentBaseUrl,
      'DECOY_VERIFY_BASE_URL': snapshot.verifyBaseUrl,
      'DECOY_EMAIL_CONFIRM_URL': snapshot.emailConfirmUrl,
    };
    productionValues.forEach((name, value) {
      if (value.contains(_stagingSupabaseProjectRef)) {
        problems.add('$name points at the staging Supabase project');
      }
      if (value.contains('/functions/v1/staging-api')) {
        problems.add('$name points at a staging-only helper route');
      }
    });
  }

  return problems;
}

void _requireHttpsUrl(List<String> problems, String name, String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    problems.add('$name is not configured');
    return;
  }
  final uri = Uri.tryParse(trimmed);
  if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
    problems.add('$name must be an https URL');
    return;
  }
  _rejectLocalhost(problems, name, trimmed);
}

void _requireDeepLink(List<String> problems, String name, String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    problems.add('$name is not configured');
    return;
  }
  final uri = Uri.tryParse(trimmed);
  if (uri == null || uri.scheme.isEmpty) {
    problems.add('$name must be a URL or app deep link');
  }
}

void _rejectLocalhost(List<String> problems, String name, String value) {
  final uri = Uri.tryParse(value.trim());
  final host = uri?.host.toLowerCase();
  if (host == 'localhost' || host == '127.0.0.1') {
    problems.add('$name points at localhost');
  }
}

void _requireHost(
  List<String> problems,
  String name,
  String value,
  String expectedHost,
) {
  final uri = Uri.tryParse(value.trim());
  if (uri?.host.toLowerCase() != expectedHost) {
    problems.add('$name must point at $expectedHost for staging builds');
  }
}

void _requireStagingApiRoute(
  List<String> problems,
  String name,
  String value,
  String route,
) {
  final uri = Uri.tryParse(value.trim());
  final expectedPath = '/functions/v1/staging-api/$route';
  if (uri?.host.toLowerCase() != _stagingSupabaseHost ||
      uri?.path != expectedPath) {
    problems.add('$name must point at staging-api/$route for staging builds');
  }
}

void _requireStagingFunctionPath(
  List<String> problems,
  String name,
  String value,
  String expectedPath,
) {
  final uri = Uri.tryParse(value.trim());
  if (uri?.host.toLowerCase() != _stagingSupabaseHost ||
      uri?.path != expectedPath) {
    problems.add(
      '$name must point at $expectedPath on $_stagingSupabaseHost for staging builds',
    );
  }
}
