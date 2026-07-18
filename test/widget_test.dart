import 'package:decoy_wallet_app/app_state.dart';
import 'package:decoy_wallet_app/backend/supabase/supabase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('requires Supabase configuration before initialization', () async {
    SharedPreferences.setMockInitialValues({});

    expect(
      () => SupaFlow.initialize(),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('DECOY_SUPABASE_URL is not configured'),
        ),
      ),
    );
    expect(FFAppState(), same(FFAppState()));
  });
}
