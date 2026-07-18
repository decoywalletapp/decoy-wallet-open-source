const kSupabaseUrl = String.fromEnvironment('DECOY_SUPABASE_URL');
const kSupabaseAnonKey = String.fromEnvironment('DECOY_SUPABASE_ANON_KEY');
const kFirebaseFunctionsBaseUrl = String.fromEnvironment(
  'DECOY_FIREBASE_FUNCTIONS_BASE_URL',
);
const kDecoyAlertBaseUrl = String.fromEnvironment('DECOY_ALERT_BASE_URL');
const kDataKeyBaseUrl = String.fromEnvironment('DECOY_DATA_KEY_BASE_URL');
const kPaymentBaseUrl = String.fromEnvironment('DECOY_PAYMENT_BASE_URL');
const kVerifyBaseUrl = String.fromEnvironment('DECOY_VERIFY_BASE_URL');
const kEmailConfirmUrl = String.fromEnvironment('DECOY_EMAIL_CONFIRM_URL');
const kEmailConfirmDeepLink = String.fromEnvironment(
  'DECOY_EMAIL_CONFIRM_DEEP_LINK',
  defaultValue: 'decoywalletapp://confirm-email',
);
const kLegalBaseUrl = String.fromEnvironment(
  'DECOY_LEGAL_BASE_URL',
  defaultValue: 'https://example.com',
);
const kSupportEmail = String.fromEnvironment(
  'DECOY_SUPPORT_EMAIL',
  defaultValue: 'support@example.com',
);
const kBillingReturnUrl = String.fromEnvironment(
  'DECOY_BILLING_RETURN_URL',
  defaultValue: 'https://example.com/open',
);
const kTutorialVideoBaseUrl = String.fromEnvironment(
  'DECOY_TUTORIAL_VIDEO_BASE_URL',
);

String requiredPublicConfig(String name, String value) {
  if (value.isEmpty) {
    throw StateError('$name is not configured for this build.');
  }
  return value;
}

String firebaseFunctionUrl(String functionName) {
  final baseUrl = requiredPublicConfig(
    'DECOY_FIREBASE_FUNCTIONS_BASE_URL',
    kFirebaseFunctionsBaseUrl,
  );
  return '$baseUrl/$functionName';
}

String supabaseFunctionUrl(String functionName) {
  final baseUrl = requiredPublicConfig('DECOY_SUPABASE_URL', kSupabaseUrl);
  return '$baseUrl/functions/v1/$functionName';
}

String supabaseRestUrl(String path) {
  final baseUrl = requiredPublicConfig('DECOY_SUPABASE_URL', kSupabaseUrl);
  return '$baseUrl/rest/v1/$path';
}

String supabaseAuthUrl(String path) {
  final baseUrl = requiredPublicConfig('DECOY_SUPABASE_URL', kSupabaseUrl);
  return '$baseUrl/auth/v1/$path';
}

String supabaseRpcUrl(String rpcName) {
  final baseUrl = requiredPublicConfig('DECOY_SUPABASE_URL', kSupabaseUrl);
  return '$baseUrl/rest/v1/rpc/$rpcName';
}

String tutorialVideoUrl(String objectPath) {
  final baseUrl = requiredPublicConfig(
    'DECOY_TUTORIAL_VIDEO_BASE_URL',
    kTutorialVideoBaseUrl,
  );
  return '$baseUrl/$objectPath';
}

String legalDocumentUrl(String path) {
  final baseUrl = requiredPublicConfig('DECOY_LEGAL_BASE_URL', kLegalBaseUrl);
  final normalizedBase = baseUrl.endsWith('/')
      ? baseUrl.substring(0, baseUrl.length - 1)
      : baseUrl;
  final normalizedPath = path.startsWith('/') ? path : '/$path';
  return '$normalizedBase$normalizedPath';
}
