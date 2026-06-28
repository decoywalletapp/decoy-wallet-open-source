import 'package:decoy_wallet_app/app_state.dart';
import 'package:decoy_wallet_app/backend/supabase/supabase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('initializes Supabase and app state singletons', () async {
    SharedPreferences.setMockInitialValues({});
    await SupaFlow.initialize();

    expect(SupaFlow.client, isNotNull);
    expect(FFAppState(), same(FFAppState()));
  });
}
