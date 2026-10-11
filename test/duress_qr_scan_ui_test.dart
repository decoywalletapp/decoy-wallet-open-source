import 'dart:async';

import 'package:decoy_wallet_app/app_state.dart';
import 'package:decoy_wallet_app/duress_mode/duress_scan_q_r/duress_scan_q_r_widget.dart';
import 'package:decoy_wallet_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'localization_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const scannerChannel = MethodChannel('flutter_barcode_scanner');
  const permissionChannel =
      MethodChannel('flutter.baseflow.com/permissions/methods');
  const legacy = '1BoatSLRHtKNngkdXEeobR76b53LETtpyT';
  const segwit = 'bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4';
  const zeroProgram = 'bc1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq9e75rs';
  const taproot =
      'bc1p0xlxvlhemja6c4dqv22uapctqupfhlxm9h8z3k2e72q4k9hcz7vqzk5jj0';

  late Future<String?> Function() scan;
  late Future<int> Function() permission;
  final calls = <MethodCall>[];
  var settingsOpened = 0;
  var permissionRequests = 0;

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await loadLocalizationFonts();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    FFAppState.reset();
    await FFAppState().initializePersistedState();
    FFAppState().scannedAddress = 'unchanged-next-screen-address';
    FFAppState().decoySeedArmed = true;
    scan = () async => legacy;
    permission = () async => 1;
    calls.clear();
    settingsOpened = 0;
    permissionRequests = 0;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(scannerChannel, (call) async {
      expect(call.method, 'scanBarcode');
      calls.add(call);
      return scan();
    });
    messenger.setMockMethodCallHandler(permissionChannel, (call) async {
      if (call.method == 'requestPermissions') {
        expect(call.arguments, [1]);
        permissionRequests++;
        return <int, int>{1: await permission()};
      }
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

  final scanButton = find.byKey(const ValueKey('duress-qr-scan'));
  final field = find.byType(TextFormField);
  TextEditingController controller(WidgetTester tester) =>
      tester.widget<TextFormField>(field).controller!;

  Future<void> openPage(WidgetTester tester, TargetPlatform platform) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const DuressScanQRWidget()),
      GoRoute(
        path: '/send',
        name: 'DuressSendBTC',
        builder: (_, __) => const Scaffold(body: Text('SEND AMOUNT PAGE')),
      ),
    ]);
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(
      routerConfig: router,
      theme: ThemeData(platform: platform, useMaterial3: false),
      locale: const Locale('en'),
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

  final valid = <String, String>{
    legacy: legacy,
    '3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy': '3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy',
    segwit: segwit,
    segwit.toUpperCase(): segwit,
    zeroProgram.toUpperCase(): zeroProgram,
    taproot: taproot,
    taproot.toUpperCase(): taproot,
    'BITCOIN:${zeroProgram.toUpperCase()}?amount=0.1': zeroProgram,
    'bitcoin:$legacy?label=Test': legacy,
  };

  for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
    for (final entry in valid.entries) {
      testWidgets('${platform.name} scan fills complete address: ${entry.key}',
          (tester) async {
        await openPage(tester, platform);
        scan = () async => entry.key;
        await tapScan(tester);
        expect(controller(tester).text, entry.value);
        expect(controller(tester).selection.baseOffset, entry.value.length);
        expect(find.text('SEND AMOUNT PAGE'), findsNothing);
        expect(FFAppState().scannedAddress, 'unchanged-next-screen-address');
        expect(FFAppState().decoySeedArmed, isTrue);
        expect(calls.single.arguments['scanMode'], 0);
        expect(calls.single.arguments['isContinuousScan'], isFalse);
        expect(tester.takeException(), isNull);
      });
    }

    for (final result in <String?>['-1', '', '  ', null]) {
      testWidgets('${platform.name} cancel/empty ($result) preserves text',
          (tester) async {
        await openPage(tester, platform);
        await tester.enterText(field, legacy);
        scan = () async => result;
        await tapScan(tester);
        expect(controller(tester).text, legacy);
        expect(find.byType(SnackBar), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }

    for (final result in [
      '1QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ9',
      segwit.replaceFirst('bc1', 'bC1'),
      'bitcoin:invalid?label=$legacy',
      '$segwit $legacy',
    ]) {
      testWidgets('${platform.name} invalid scan preserves text: $result',
          (tester) async {
        await openPage(tester, platform);
        await tester.enterText(field, legacy);
        scan = () async => result;
        await tapScan(tester);
        expect(controller(tester).text, legacy);
        expect(find.text('NOT QUITE - TRY AGAIN'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('${platform.name} scanner failure preserves text and can retry',
        (tester) async {
      await openPage(tester, platform);
      await tester.enterText(field, legacy);
      scan = () async => throw PlatformException(code: 'camera_failed');
      await tapScan(tester);
      expect(controller(tester).text, legacy);
      expect(
          find.text(
              'Could not open the QR scanner. Please try again or paste the text.'),
          findsOneWidget);
      scan = () async => zeroProgram.toUpperCase();
      await tapScan(tester);
      expect(controller(tester).text, zeroProgram);
      expect(calls, hasLength(2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('${platform.name} denied camera does not start scanner',
        (tester) async {
      await openPage(tester, platform);
      await tester.enterText(field, legacy);
      permission = () async => 0;
      await tapScan(tester);
      expect(calls, isEmpty);
      expect(controller(tester).text, legacy);
      await tester.tap(find.text('Open Device Settings'));
      await tester.pumpAndSettle();
      expect(settingsOpened, 1);
      permission = () async => 1;
      await tapScan(tester);
      expect(calls, hasLength(1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('${platform.name} repeated taps open only one scanner',
        (tester) async {
      await openPage(tester, platform);
      final pending = Completer<String?>();
      scan = () => pending.future;
      await tapScan(tester);
      await tapScan(tester);
      expect(permissionRequests, 1);
      expect(calls, hasLength(1));
      pending.complete(zeroProgram.toUpperCase());
      await tester.pumpAndSettle();
      expect(controller(tester).text, zeroProgram);
      expect(tester.takeException(), isNull);
    });

    testWidgets('${platform.name} result after leaving page is ignored',
        (tester) async {
      await openPage(tester, platform);
      final pending = Completer<String?>();
      scan = () => pending.future;
      await tapScan(tester);
      await tester.pumpWidget(const SizedBox.shrink());
      pending.complete(zeroProgram.toUpperCase());
      await tester.pumpAndSettle();
      expect(FFAppState().scannedAddress, 'unchanged-next-screen-address');
      expect(tester.takeException(), isNull);
    });

    testWidgets('${platform.name} Send Funds passes the full scanned address',
        (tester) async {
      await openPage(tester, platform);
      scan = () async => zeroProgram.toUpperCase();
      await tapScan(tester);
      final send = find.text('Send Funds');
      await tester.ensureVisible(send);
      await tester.tap(send);
      await tester.pumpAndSettle();
      expect(find.text('SEND AMOUNT PAGE'), findsOneWidget);
      expect(FFAppState().scannedAddress, zeroProgram);
      expect(FFAppState().decoySeedArmed, isTrue);
      expect(tester.takeException(), isNull);
    });
  }
}
