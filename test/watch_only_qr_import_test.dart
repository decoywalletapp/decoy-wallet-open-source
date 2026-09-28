import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:decoy_wallet_app/app_state.dart';
import 'package:decoy_wallet_app/backend/public_config.dart';
import 'package:decoy_wallet_app/build_provenance.dart';
import 'package:decoy_wallet_app/create_decoy_seed/import_watch_only_wallet/import_watch_only_wallet_widget.dart';
import 'package:decoy_wallet_app/custom_code/actions/generate_decoy_draft.dart';
import 'package:decoy_wallet_app/custom_code/actions/prepare_watch_only_decoy_draft.dart';
import 'package:decoy_wallet_app/l10n/app_language_controller.dart';
import 'package:decoy_wallet_app/l10n/app_localizations.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'localization_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('iOS camera permission check is enabled without removing other flags',
      () {
    final podfile = File('ios/Podfile').readAsStringSync();
    expect(podfile, contains("target.name == 'permission_handler_apple'"));
    expect(podfile, contains("<< 'PERMISSION_CAMERA=1'"));
    expect(File('ios/Runner/Info.plist').readAsStringSync(),
        contains('NSCameraUsageDescription'));
  });
  if (!DecoyBuildProvenance.watchOnlyImportEnabled) {
    test('QR import tests require the existing watch-only build flag', () {},
        skip: 'Run with --dart-define=DECOY_ENABLE_WATCH_ONLY_IMPORT=true');
    return;
  }

  const scannerChannel = MethodChannel('flutter_barcode_scanner');
  const permissionChannel =
      MethodChannel('flutter.baseflow.com/permissions/methods');
  final requests = <Map<String, dynamic>>[];
  final scannerCalls = <MethodCall>[];
  var settingsOpened = 0;
  late Future<String?> Function() scan;
  late Future<int> Function() permission;
  late Map draft;
  final client = MockClient((request) async {
    expect(request.url.host, 'test.invalid');
    expect(request.url.path, '/functions/v1/manage-decoy-monitors');
    final body = jsonDecode(request.body) as Map<String, dynamic>;
    expect(body['action'], 'checkDuplicate');
    requests.add(body);
    return http.Response('{"duplicate":false}', 200,
        request: request, headers: {'content-type': 'application/json'});
  });

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await loadLocalizationFonts();
    draft = await generateDecoyDraft() as Map;
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://test.invalid',
      anonKey: 'test-key',
      debug: false,
      httpClient: client,
      authOptions: const FlutterAuthClientOptions(
        autoRefreshToken: false,
        detectSessionInUri: false,
        localStorage: EmptyLocalStorage(),
      ),
    );
    final user = User(
      id: 'qr-test-user',
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: '2026-09-28T00:00:00Z',
    );
    final token = '${base64UrlEncode(utf8.encode('{"alg":"none"}'))}.'
        '${base64UrlEncode(utf8.encode(jsonEncode({
          'sub': user.id,
          'exp': DateTime.now()
                  .add(const Duration(hours: 1))
                  .millisecondsSinceEpoch ~/
              1000,
        })))}.signature';
    await Supabase.instance.client.auth.setInitialSession(jsonEncode({
      'access_token': token,
      'refresh_token': 'test-refresh',
      'token_type': 'bearer',
      'expires_in': 3600,
      'user': user.toJson(),
    }));
  });
  tearDownAll(() => Supabase.instance.dispose());

  setUp(() async {
    requests.clear();
    scannerCalls.clear();
    settingsOpened = 0;
    scan = () async => '1BoatSLRHtKNngkdXEeobR76b53LETtpyT';
    permission = () async => 1;
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    FFAppState.reset();
    await FFAppState().initializePersistedState();
    FFAppState().decoySeedArmed = true;
    FFAppState().draftWatchPublicKey = 'unchanged-draft';
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(scannerChannel, (call) async {
      expect(call.method, 'scanBarcode');
      scannerCalls.add(call);
      return scan();
    });
    messenger.setMockMethodCallHandler(permissionChannel, (call) async {
      if (call.method == 'requestPermissions') {
        expect(call.arguments, [1]);
        return <int, int>{1: await permission()};
      }
      if (call.method == 'checkPermissionStatus') return 0;
      if (call.method == 'openAppSettings') {
        settingsOpened++;
        return true;
      }
      throw StateError('Unexpected permission call ${call.method}');
    });
  });
  tearDown(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(scannerChannel, null);
    messenger.setMockMethodCallHandler(permissionChannel, null);
  });

  final scanButton = find.byKey(const ValueKey('watch-only-qr-scan'));
  final field = find.byType(TextFormField);
  final boundaryKey = GlobalKey();
  TextEditingController controller(WidgetTester tester) =>
      tester.widget<TextFormField>(field).controller!;

  Future<void> openPage(WidgetTester tester,
      {String locale = 'en',
      Size size = const Size(402, 874),
      TargetPlatform platform = TargetPlatform.iOS}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(routes: [
      GoRoute(
          path: '/',
          builder: (_, __) => RepaintBoundary(
              key: boundaryKey, child: const ImportWatchOnlyWalletWidget())),
      GoRoute(
          name: 'DecoySeedSystemValues',
          path: '/review',
          builder: (_, __) => const Scaffold(body: Text('REVIEW IMPORT'))),
    ]);
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(
      routerConfig: router,
      theme: ThemeData(
          platform: platform,
          useMaterial3: false,
          fontFamily: 'robot',
          fontFamilyFallback: decoyFontFallbacks(Locale(locale))),
      locale: Locale(locale),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ));
    await tester.pumpAndSettle();
  }

  Future<void> tapScan(WidgetTester tester) async {
    await tester.ensureVisible(scanButton);
    await tester.tap(scanButton);
    await tester.pumpAndSettle();
  }

  final inputs = <String, String Function()>{
    'xpub': () => draft['xpub'] as String,
    'zpub': () => draft['zpub'] as String,
    'legacy address': () => '1BoatSLRHtKNngkdXEeobR76b53LETtpyT',
    'P2SH address': () => '3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy',
    'native SegWit address': () => (draft['addresses'] as List).first as String,
    // Mainnet v1/32-byte test vector from bitcoin/bips, BIP-0350.
    'Taproot address': () =>
        'bc1p0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vqzk5jj0',
    'Bitcoin URI': () =>
        'bitcoin:${draft['addresses'][0]}?amount=0.01&label=Test',
    'address list': () => '${draft['addresses'][0]}\n${draft['addresses'][1]}',
  };
  for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
    for (final entry in inputs.entries) {
      testWidgets(
          '${platform.name} QR fills ${entry.key} exactly without importing',
          (tester) async {
        await openPage(tester, platform: platform);
        final value = entry.value();
        scan = () async => value;
        await tapScan(tester);
        expect(controller(tester).text, value);
        expect(controller(tester).selection.baseOffset, value.length);
        expect(find.text('REVIEW IMPORT'), findsNothing);
        expect(requests, isEmpty);
        expect(FFAppState().draftWatchPublicKey, 'unchanged-draft');
        expect(FFAppState().decoySeedArmed, isTrue);
        expect(scannerCalls.single.arguments['scanMode'], 0);
        expect(scannerCalls.single.arguments['isContinuousScan'], isFalse);
        expect(scannerCalls.single.arguments['isShowFlashIcon'], isTrue);
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final result in <String?>['-1', '', '  ', null]) {
    testWidgets('cancel/empty scan ($result) preserves entered text',
        (tester) async {
      await openPage(tester);
      await tester.enterText(field, 'keep this input');
      scan = () async => result;
      await tapScan(tester);
      expect(controller(tester).text, 'keep this input');
      expect(requests, isEmpty);
      expect(tester.widget<IconButton>(scanButton).onPressed, isNotNull);
    });
  }

  for (final status in [0, 2, 4]) {
    testWidgets('camera permission $status preserves input and allows retry',
        (tester) async {
      await openPage(tester);
      await tester.enterText(field, 'keep this input');
      permission = () async => status;
      await tapScan(tester);
      expect(scannerCalls, isEmpty);
      expect(controller(tester).text, 'keep this input');
      expect(find.textContaining('Camera access is required'), findsOneWidget);
      await tester.tap(find.text('Open Device Settings'));
      await tester.pumpAndSettle();
      expect(settingsOpened, 1);
      permission = () async => 1;
      await tapScan(tester);
      expect(controller(tester).text, inputs['legacy address']!());
    });
  }

  for (final failPermission in [false, true]) {
    testWidgets('scanner/permission error ($failPermission) preserves input',
        (tester) async {
      await openPage(tester);
      await tester.enterText(field, 'keep this input');
      if (failPermission) {
        permission = () async => throw PlatformException(code: 'camera-error');
      } else {
        scan = () async => throw PlatformException(code: 'camera-error');
      }
      await tapScan(tester);
      expect(controller(tester).text, 'keep this input');
      expect(
          find.textContaining('Could not open the QR scanner'), findsOneWidget);
      expect(tester.widget<IconButton>(scanButton).onPressed, isNotNull);
      expect(requests, isEmpty);
    });
  }

  testWidgets(
      'only one scan can be pending and late result after leaving is ignored',
      (tester) async {
    final pending = Completer<String?>();
    scan = () => pending.future;
    await openPage(tester);
    await tapScan(tester);
    expect(tester.widget<IconButton>(scanButton).onPressed, isNull);
    expect(tester.widget<EditableText>(find.byType(EditableText)).readOnly,
        isTrue);
    await tester.tap(scanButton);
    expect(scannerCalls, hasLength(1));
    await tester.pumpWidget(const SizedBox());
    pending.complete('late result');
    await tester.pumpAndSettle();
    expect(requests, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('leaving during permission request never opens the scanner',
      (tester) async {
    final pending = Completer<int>();
    permission = () => pending.future;
    await openPage(tester);
    await tapScan(tester);
    await tester.pumpWidget(const SizedBox());
    pending.complete(1);
    await tester.pumpAndSettle();
    expect(scannerCalls, isEmpty);
    expect(requests, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('unsupported platforms preserve input without opening scanner',
      (tester) async {
    await openPage(tester, platform: TargetPlatform.macOS);
    await tester.enterText(field, 'keep this input');
    await tapScan(tester);
    expect(scannerCalls, isEmpty);
    expect(requests, isEmpty);
    expect(controller(tester).text, 'keep this input');
    expect(
        find.textContaining('Could not open the QR scanner'), findsOneWidget);
  });

  for (final entry in inputs.entries) {
    testWidgets('Continue preserves pasted ${entry.key} validation and draft',
        (tester) async {
      await http.runWithClient(() async {
        await openPage(tester);
        final input = entry.value();
        scan = () async => input;
        await tapScan(tester);
        expect(requests, isEmpty);
        final expected = prepareWatchOnlyDecoyDraftPayload(input);
        await tester.ensureVisible(find.text('Continue'));
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        expect(find.text('REVIEW IMPORT'), findsOneWidget);
        expect(requests, hasLength(1));
        expect(
            requests.single['watch_public_key'], expected['watch_public_key']);
        expect(requests.single['watch_public_key_type'],
            expected['watch_public_key_type']);
        expect(requests.single['source_type'], expected['source_type']);
        expect(requests.single['addresses'], expected['addresses']);
        expect(FFAppState().draftWatchPublicKey, expected['watch_public_key']);
        expect(FFAppState().draftWatchPublicKeyType,
            expected['watch_public_key_type']);
        expect(FFAppState().draftAddresses, expected['addresses']);
        expect(FFAppState().draftDerivationPath, expected['derivation_path']);
        expect(FFAppState().decoySeedArmed, isTrue);
      }, () => client);
    }, skip: kSupabaseUrl != 'https://test.invalid');
  }

  final invalidInputs = <String, String Function()>{
    'private extended key': () => 'xprv123',
    'seed phrase': () => draft['mnemonic'] as String,
    'unsupported key type': () => 'ypub123',
    'mixed key and address': () => '${draft['xpub']}\n${draft['addresses'][0]}',
    'malformed address': () => 'not-an-address',
  };
  for (final entry in invalidInputs.entries) {
    testWidgets('scanned ${entry.key} still rejected locally on Continue',
        (tester) async {
      await openPage(tester);
      scan = () async => entry.value();
      await tapScan(tester);
      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('REVIEW IMPORT'), findsNothing);
      expect(requests, isEmpty);
      expect(FFAppState().draftWatchPublicKey, 'unchanged-draft');
      expect(FFAppState().decoySeedArmed, isTrue);
    });
  }

  for (final locale in AppLanguageController.supportedLanguageCodes) {
    for (final width in [320.0, 402.0]) {
      testWidgets('QR import layout $locale at $width', (tester) async {
        await openPage(tester, locale: locale, size: Size(width, 874));
        await tester.ensureVisible(scanButton);
        final buttonBounds = tester.getRect(scanButton);
        final fieldBounds = tester.getRect(field);
        expect(fieldBounds.contains(buttonBounds.center), isTrue);
        expect(buttonBounds.width, greaterThanOrEqualTo(48));
        final l10n = AppLocalizations.of(tester.element(field))!;
        expect(tester.widget<IconButton>(scanButton).tooltip,
            l10n.msgTapToOpenQrScanner);
        await tapScan(tester);
        expect(
            scannerCalls.single.arguments['cancelButtonText'], l10n.msgCancel);
        await tester.enterText(field, inputs['xpub']!());
        tester.view.viewInsets = const FakeViewPadding(bottom: 280);
        addTearDown(tester.view.resetViewInsets);
        await tester.pumpAndSettle();
        await tester.ensureVisible(scanButton);
        if (const bool.fromEnvironment('DECOY_CAPTURE_LOCALIZATION')) {
          tester.view.viewInsets = const FakeViewPadding();
          FocusManager.instance.primaryFocus?.unfocus();
          controller(tester).clear();
          await tester.pumpAndSettle();
          await tester.runAsync(() async {
            final boundary = boundaryKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
            final image = await boundary.toImage(pixelRatio: 2);
            final bytes =
                await image.toByteData(format: ui.ImageByteFormat.png);
            final directory = Directory('/private/tmp/decoy-qr-import-screens');
            await directory.create(recursive: true);
            await File('${directory.path}/import-$locale-${width.toInt()}.png')
                .writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
      });
    }
  }
}
