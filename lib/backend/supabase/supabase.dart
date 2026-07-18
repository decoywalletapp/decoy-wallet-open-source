import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;

import '/backend/public_config.dart';

export 'database/database.dart';

class SupaFlow {
  SupaFlow._();

  static SupaFlow? _instance;
  static SupaFlow get instance => _instance ??= SupaFlow._();

  final _supabase = Supabase.instance.client;
  static SupabaseClient get client => instance._supabase;

  static Future initialize() {
    return Supabase.initialize(
      url: requiredPublicConfig('DECOY_SUPABASE_URL', kSupabaseUrl),
      headers: {'X-Client-Info': 'flutterflow'},
      anonKey: requiredPublicConfig(
        'DECOY_SUPABASE_ANON_KEY',
        kSupabaseAnonKey,
      ),
      debug: false,
      authOptions: FlutterAuthClientOptions(
        authFlowType: AuthFlowType.implicit,
      ),
    );
  }
}
