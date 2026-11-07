import 'package:decoy_wallet_app/create_decoy_seed/secure_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<String> calls;
  setUp(() {
    calls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SecureScreen.channel, (call) async {
      calls.add(call.method);
      return null;
    });
  });
  tearDown(() async {
    while (SecureScreen.depth > 0) {
      await SecureScreen.disable();
    }
  });

  test('enables once and clears only after last seed screen leaves', () async {
    await SecureScreen.enable(); // show seed
    await SecureScreen.enable(); // verify pushed on top
    await SecureScreen.disable();
    expect(calls, ['enable']);
    await SecureScreen.disable();
    expect(calls, ['enable', 'disable']);
  });

  test('extra disable is a no-op', () async {
    await SecureScreen.disable();
    expect(calls, isEmpty);
  });

  test('missing platform implementation does not throw', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SecureScreen.channel, null);
    await SecureScreen.enable();
    await SecureScreen.disable();
  });
}
