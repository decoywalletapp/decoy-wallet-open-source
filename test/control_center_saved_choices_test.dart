import 'dart:async';
import 'dart:convert';

import 'package:decoy_wallet_app/app_state.dart';
import 'package:decoy_wallet_app/auth/supabase_auth/supabase_user_provider.dart';
import 'package:decoy_wallet_app/flutter_flow/flutter_flow_widgets.dart';
import 'package:decoy_wallet_app/l10n/app_localizations.dart';
import 'package:decoy_wallet_app/settings_pages/control_center/control_center_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'localization_fonts.dart';

class _NoLocation extends GeolocatorPlatform {
  _NoLocation(this.hold);
  final Future<void> Function() hold;
  @override
  Future<bool> isLocationServiceEnabled() async {
    await hold();
    return false;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final user = User(
      id: 'choice-owner',
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: '2026-10-24T00:00:00Z');
  late Map<String, dynamic> row;
  final writes = <http.Request>[];
  Completer<void>? loadHold;
  Completer<void>? locationHold;
  var failLoad = false;
  var failSave = false;
  var failUserSave = false;
  var activeAccess = true;
  var biometricAccepted = false;
  final client = MockClient((request) async {
    http.Response reply(String body, int status,
            {Map<String, String> headers = const {}}) =>
        http.Response(body, status, request: request, headers: headers);
    if (request.method == 'PATCH') {
      writes.add(request);
      if (failUserSave && request.url.path.endsWith('/user_settings')) {
        return reply('{"message":"synthetic user settings failure"}', 400);
      }
      if (failSave) return reply('{"message":"synthetic failure"}', 400);
      if (request.url.path.endsWith('/decoy_wallet')) {
        row.addAll(jsonDecode(request.body) as Map<String, dynamic>);
        return reply(jsonEncode([row]), 200,
            headers: {'content-type': 'application/json'});
      }
      return reply('', 204);
    }
    if (request.url.path.endsWith('/decoy_wallet')) {
      final snapshot = Map<String, dynamic>.from(row);
      await loadHold?.future;
      return reply(
          failLoad ? '{"message":"synthetic failure"}' : jsonEncode([snapshot]),
          failLoad ? 400 : 200,
          headers: {'content-type': 'application/json'});
    }
    if (request.url.path.endsWith('/user_entitlements')) {
      return reply(
          jsonEncode([
            {
              'user_id': user.id,
              'entitlement': 'decoy_wallet',
              'is_active': activeAccess,
              'current_period_end': DateTime.now()
                  .add(const Duration(days: 30))
                  .toIso8601String(),
            }
          ]),
          200,
          headers: {'content-type': 'application/json'});
    }
    throw StateError(
        'Unexpected request ${request.method} ${request.url.path}');
  });

  setUpAll(() async {
    await loadLocalizationFonts();
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
        url: 'https://test.invalid',
        anonKey: 'test-key',
        httpClient: client,
        debug: false,
        authOptions: const FlutterAuthClientOptions(
            autoRefreshToken: false,
            detectSessionInUri: false,
            localStorage: EmptyLocalStorage()));
  });
  tearDownAll(() => Supabase.instance.dispose());
  setUp(() async {
    writes.clear();
    loadHold = null;
    locationHold = null;
    failLoad = false;
    failSave = false;
    failUserSave = false;
    activeAccess = true;
    biometricAccepted = false;
    currentUser = DecoyWalletAppSupabaseUser(user);
    FlutterSecureStorage.setMockInitialValues({});
    FFAppState.reset();
    await FFAppState().initializePersistedState();
    FFAppState().hasActiveSubscription = true;
    FFAppState().entitlementCheckCompleted = true;
    row = {
      'id': 'choice-wallet',
      'user_id': user.id,
      'decoy_pin_contacts_enabled': true,
      'decoy_pin_911_enabled': true,
      'decoy_seed_armed': true,
      'decoy_seed_contacts_enabled': false,
      'decoy_seed_armed_at': '2026-10-01T00:00:00Z',
      'use_current_location': false,
    };
    GeolocatorPlatform.instance =
        _NoLocation(() async => await locationHold?.future);
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/local_auth'), (call) async {
      if (call.method == 'getAvailableBiometrics') return <String>[];
      if (call.method == 'isDeviceSupported') return true;
      if (call.method == 'authenticate') return biometricAccepted;
      return false;
    });
  });

  Future<void> open(WidgetTester tester, {bool settle = true}) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(routes: [
      GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(body: Text('SETTINGS')),
          routes: [
            GoRoute(
                path: 'control',
                builder: (_, __) => const ControlCenterWidget())
          ])
    ]);
    addTearDown(router.dispose);
    await tester.pumpWidget(ChangeNotifierProvider.value(
        value: FFAppState(),
        child: MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales)));
    router.push('/control');
    await tester.pump();
    if (settle) await tester.pumpAndSettle();
  }

  SwitchListTile tile(WidgetTester tester, int index) =>
      tester.widget<SwitchListTile>(find.byType(SwitchListTile).at(index));
  Future<void> save(WidgetTester tester) async {
    await tester.tap(find.text('Save & Exit'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  }

  for (final enabled in [false, true]) {
    testWidgets('opening respects saved $enabled despite opposite phone cache',
        (tester) async {
      row['decoy_pin_contacts_enabled'] = enabled;
      row['decoy_seed_armed'] = enabled;
      FFAppState().decoyPinContactsEnabled = !enabled;
      FFAppState().decoySeedArmed = !enabled;
      await open(tester);
      expect(tile(tester, 1).value, enabled);
      expect(tile(tester, 2).value, enabled);
      expect(writes, isEmpty);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('pending load does not display cached choices or allow saving',
      (tester) async {
    loadHold = Completer<void>();
    await open(tester, settle: false);
    expect(find.byType(SwitchListTile), findsNothing);
    expect(find.widgetWithText(FFButtonWidget, 'Save & Exit'), findsNothing);
    expect(writes, isEmpty);
    loadHold!.complete();
    await tester.pumpAndSettle();
    expect(tile(tester, 1).value, isTrue);
  });

  testWidgets('save without edits preserves all existing choices',
      (tester) async {
    final before = Map<String, dynamic>.from(row);
    await open(tester);
    await save(tester);
    expect(writes.where((r) => r.url.path.endsWith('/decoy_wallet')), isEmpty);
    expect(row, before);
    expect(tester.takeException(), isNull);
  });

  testWidgets('editing location preserves changes saved on another device',
      (tester) async {
    await open(tester);
    row['decoy_pin_contacts_enabled'] = false;
    row['decoy_seed_armed'] = false;
    final location = find.byKey(const ValueKey('control-location'));
    await tester.scrollUntilVisible(location, 500);
    tester.widget<SwitchListTile>(location).onChanged!(true);
    await tester.pump();
    await save(tester);
    final patch =
        writes.singleWhere((r) => r.url.path.endsWith('/decoy_wallet'));
    final data = jsonDecode(patch.body) as Map<String, dynamic>;
    expect(data.keys.toSet(), {'use_current_location', 'updated_at'});
    expect(row['decoy_pin_contacts_enabled'], isFalse);
    expect(row['decoy_seed_armed'], isFalse);
    expect(patch.url.queryParameters['id'], 'eq.choice-wallet');
    expect(patch.url.queryParameters['user_id'], 'eq.choice-owner');
  });

  testWidgets('explicit contact change writes only that choice',
      (tester) async {
    await open(tester);
    tile(tester, 1).onChanged!(false);
    await tester.pump();
    await save(tester);
    final patch =
        writes.singleWhere((r) => r.url.path.endsWith('/decoy_wallet'));
    final data = jsonDecode(patch.body) as Map<String, dynamic>;
    expect(data.keys.toSet(), {'decoy_pin_contacts_enabled', 'updated_at'});
    expect(row['decoy_pin_contacts_enabled'], isFalse);
    expect(row['decoy_pin_911_enabled'], isTrue);
    expect(row['decoy_seed_contacts_enabled'], isFalse);
  });

  testWidgets('failed load offers retry without guessed switches or writes',
      (tester) async {
    failLoad = true;
    await open(tester);
    expect(find.byType(SwitchListTile), findsNothing);
    expect(find.text('Retry'), findsOneWidget);
    expect(writes, isEmpty);
    expect(tester.takeException(), isNull);
    failLoad = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(tile(tester, 1).value, isTrue);
  });

  testWidgets('account change during load cannot hydrate another account',
      (tester) async {
    loadHold = Completer<void>();
    await open(tester, settle: false);
    currentUser = DecoyWalletAppSupabaseUser(null);
    loadHold!.complete();
    await tester.pumpAndSettle();
    expect(find.byType(SwitchListTile), findsNothing);
    expect(FFAppState().decoyPinContactsEnabled, isFalse);
    expect(writes, isEmpty);
  });

  testWidgets('account change after load prevents every save', (tester) async {
    await open(tester);
    tile(tester, 1).onChanged!(false);
    await tester.pump();
    currentUser = DecoyWalletAppSupabaseUser(null);
    await save(tester);
    expect(writes, isEmpty);
  });

  testWidgets('failed save does not claim new contact setting was saved',
      (tester) async {
    await open(tester);
    tile(tester, 1).onChanged!(false);
    await tester.pump();
    failSave = true;
    await save(tester);
    expect(row['decoy_pin_contacts_enabled'], isTrue);
    expect(FFAppState().decoyPinContactsEnabled, isTrue);
    expect(find.byType(ControlCenterWidget), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'saving after account changes during location lookup writes nothing',
      (tester) async {
    await open(tester);
    tile(tester, 1).onChanged!(false);
    await tester.pump();
    locationHold = Completer<void>();
    await tester.tap(find.text('Save & Exit'));
    await tester.pump();
    currentUser = DecoyWalletAppSupabaseUser(null);
    locationHold!.complete();
    await tester.pumpAndSettle();
    expect(writes, isEmpty);
  });

  testWidgets(
      'toggling back to the loaded choice does not overwrite another device',
      (tester) async {
    await open(tester);
    tile(tester, 1).onChanged!(false);
    await tester.pump();
    tile(tester, 1).onChanged!(true);
    await tester.pump();
    row['decoy_pin_contacts_enabled'] = false;
    await save(tester);
    expect(writes, isEmpty);
    expect(row['decoy_pin_contacts_enabled'], isFalse);
  });

  testWidgets('seed disarm changes only its linked settings', (tester) async {
    await open(tester);
    tile(tester, 2).onChanged!(false);
    await tester.pump();
    await save(tester);
    final patch =
        writes.singleWhere((r) => r.url.path.endsWith('/decoy_wallet'));
    expect((jsonDecode(patch.body) as Map).keys.toSet(), {
      'decoy_seed_armed',
      'decoy_seed_contacts_enabled',
      'decoy_seed_armed_at',
      'updated_at',
    });
    expect(row['decoy_seed_armed'], isFalse);
    expect(row['decoy_seed_armed_at'], isNull);
    expect(row['decoy_pin_contacts_enabled'], isTrue);
  });

  for (final missing in ['id', 'user_id']) {
    testWidgets('missing $missing cannot enable editing or unscoped writes',
        (tester) async {
      row.remove(missing);
      await open(tester);
      expect(find.byType(SwitchListTile), findsNothing);
      expect(find.text('Retry'), findsOneWidget);
      expect(writes, isEmpty);
    });
  }

  testWidgets(
      'null saved flags are not silently normalized by opening or saving',
      (tester) async {
    row['decoy_pin_contacts_enabled'] = null;
    row['decoy_seed_armed'] = null;
    FFAppState().decoyPinContactsEnabled = true;
    await open(tester);
    expect(tile(tester, 1).value, isFalse);
    await save(tester);
    expect(writes, isEmpty);
    expect(row['decoy_pin_contacts_enabled'], isNull);
    expect(row['decoy_seed_armed'], isNull);
  });

  testWidgets('expired access cannot edit the saved alert choices',
      (tester) async {
    activeAccess = false;
    await open(tester);
    expect(tile(tester, 1).value, isTrue);
    expect(tile(tester, 1).onChanged, isNull);
    expect(tile(tester, 2).onChanged, isNull);
    expect(find.text('Save & Exit'), findsNothing);
    expect(writes, isEmpty);
  });

  testWidgets(
      'partial settings failure can retry without replaying alert writes',
      (tester) async {
    await open(tester);
    final location = find.byKey(const ValueKey('control-location'));
    await tester.scrollUntilVisible(location, 500);
    tester.widget<SwitchListTile>(location).onChanged!(true);
    await tester.pump();
    failUserSave = true;
    await save(tester);
    expect(row['use_current_location'], isTrue);
    expect(find.byType(ControlCenterWidget), findsOneWidget);
    writes.clear();
    failUserSave = false;
    await save(tester);
    expect(writes, hasLength(1));
    expect(writes.single.url.path, endsWith('/user_settings'));
    expect(jsonDecode(writes.single.body), {'location_enabled': true});
    expect(writes.single.url.queryParameters['user_id'], 'eq.choice-owner');
    expect(row['decoy_pin_contacts_enabled'], isTrue);
    expect(tester.takeException(), isNull);
  });

  for (final initiallyEnabled in [false, true]) {
    for (final accepts in [false, true]) {
      testWidgets(
          'biometric save preserves alert choices: '
          'initial=$initiallyEnabled accepted=$accepts', (tester) async {
        FFAppState().biometricsEnabled = initiallyEnabled;
        biometricAccepted = accepts;
        await open(tester);
        final strings = AppLocalizations.of(
            tester.element(find.byType(ControlCenterWidget)))!;
        final bio = find.widgetWithText(
            SwitchListTile, strings.msgBiometricAuthentication);
        await tester.scrollUntilVisible(bio, 500);
        tester.widget<SwitchListTile>(bio).onChanged!(!initiallyEnabled);
        await tester.pump();
        row['decoy_pin_contacts_enabled'] = false;
        await save(tester);
        expect(
            writes.where((r) => r.url.path.endsWith('/decoy_wallet')), isEmpty);
        expect(row['decoy_pin_contacts_enabled'], isFalse);
        final expected = initiallyEnabled ? false : accepts;
        expect(FFAppState().biometricsEnabled, expected);
        if (initiallyEnabled || accepts) {
          expect(
              jsonDecode(writes.single.body), {'biometrics_enabled': expected});
        } else {
          expect(writes, isEmpty);
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
}
