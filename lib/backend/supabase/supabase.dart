import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;

import '/backend/public_config.dart';
import '/auth/auth_link_service.dart';
import 'package:http/http.dart' as http;

export 'database/database.dart';

class SupaFlow {
  SupaFlow._();

  static SupaFlow? _instance;
  static SupaFlow get instance => _instance ??= SupaFlow._();

  final _supabase = Supabase.instance.client;
  static SupabaseClient get client => instance._supabase;
  static AuthLinkService? _authLinks;
  static AuthLinkService get authLinks => _authLinks ??= AuthLinkService(
    auth: client.auth,
    authUrl: '${requiredPublicConfig('DECOY_SUPABASE_URL', kSupabaseUrl)}/auth/v1',
    anonKey: requiredPublicConfig('DECOY_SUPABASE_ANON_KEY', kSupabaseAnonKey),
  );

  static void configureAuthLinks({
    required String url,
    required String anonKey,
    http.Client Function()? clientFactory,
  }) {
    _authLinks?.cancelPending();
    _authLinks = AuthLinkService(auth: client.auth, authUrl: '$url/auth/v1',
        anonKey: anonKey, clientFactory: clientFactory);
  }

  static void cancelPendingAuthLinks() => _authLinks?.cancelPending();
  static bool hasCompletedAuthLink(Uri uri) =>
      _authLinks?.hasCompleted(uri) ?? false;

  static Future initialize({http.Client? httpClient}) {
    return Supabase.initialize(
      url: requiredPublicConfig('DECOY_SUPABASE_URL', kSupabaseUrl),
      headers: {'X-Client-Info': 'flutterflow'},
      anonKey: requiredPublicConfig(
        'DECOY_SUPABASE_ANON_KEY',
        kSupabaseAnonKey,
      ),
      debug: false,
      httpClient: httpClient,
      authOptions: FlutterAuthClientOptions(
        authFlowType: AuthFlowType.implicit,
        detectSessionInUri: false,
      ),
    );
  }
}
