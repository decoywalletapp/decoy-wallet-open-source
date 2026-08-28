import '/backend/public_config.dart';
import '/build_provenance.dart';

String emailConfirmationRedirect([String? configuredRedirectUrl]) {
  final configured = configuredRedirectUrl?.trim() ?? kEmailConfirmUrl.trim();
  final deepLink = kEmailConfirmDeepLink.trim();

  if (DecoyBuildProvenance.backendEnvironment == 'staging' &&
      deepLink.isNotEmpty) {
    return deepLink;
  }

  if (_isLocalhostRedirect(configured) && deepLink.isNotEmpty) {
    return deepLink;
  }

  if (configured.isNotEmpty) {
    return configured;
  }

  return requiredPublicConfig(
    'DECOY_EMAIL_CONFIRM_DEEP_LINK',
    deepLink,
  );
}

bool _isLocalhostRedirect(String redirectUrl) {
  final uri = Uri.tryParse(redirectUrl);
  final host = uri?.host.toLowerCase();
  return host == 'localhost' || host == '127.0.0.1';
}
