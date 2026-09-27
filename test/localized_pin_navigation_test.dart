import 'dart:convert';

import 'package:decoy_wallet_app/app_state.dart';
import 'package:decoy_wallet_app/backend/public_config.dart';
import 'package:decoy_wallet_app/l10n/app_localizations.dart';
import 'package:decoy_wallet_app/auth/supabase_auth/supabase_user_provider.dart';
import 'package:decoy_wallet_app/custom_code/actions/aes_gcm_encrypt_string.dart';
import 'package:decoy_wallet_app/pin_pages/p_i_n_page/p_i_n_page_widget.dart';
import 'package:flutter/material.dart';
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

class NoLocation extends GeolocatorPlatform {
  @override
  Future<bool> isLocationServiceEnabled() async => false;
}

void main() {
  if (kDecoyAlertBaseUrl.isEmpty ||
      kDataKeyBaseUrl.isEmpty ||
      kFirebaseFunctionsBaseUrl.isEmpty) {
    test('localized PIN integration uses isolated mock endpoints', () {},
        skip:
            'Run with test.invalid endpoint dart-defines; see docs/localization.md');
    return;
  }
  TestWidgetsFlutterBinding.ensureInitialized();
  var languageCode = 'en';
  final key = base64UrlEncode(List<int>.generate(16, (i) => i));
  final user = User(
      id: 'test-user',
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: '2026-09-24T00:00:00Z');
  late Map<String, dynamic> row;
  final alerts = <Map<String, dynamic>>[];
  final paths = <String>[];
  var consent = 'confirmed';
  final client = MockClient((request) async {
    final path = request.url.path;
    paths.add(path);
    Object? response;
    if (path == '/rest/v1/decoy_wallet') {
      if (request.method == 'PATCH')
        return http.Response('', 204, request: request);
      response =
          request.headers['Accept']?.contains('object') == true ? row : [row];
    } else if (path.endsWith('/verifyPin')) {
      final pin = jsonDecode(request.body)['pin'];
      response = {
        'ok': true,
        'isDecoy': pin == '9876',
        'isAccount': pin == '1234'
      };
    } else if (path.endsWith('/getConsentStatuses')) {
      response = {
        'slot1Status': row['contacts_ciphertext'] != null ? consent : 'not_sent'
      };
    } else if (path == '/unwrap') {
      response = {'dataKeyB64': key};
    } else if (path.endsWith('/sendEmergencyAlerts')) {
      alerts.add(jsonDecode(request.body));
      response = {'ok': true};
    } else {
      throw StateError('Unexpected request: ${request.method} $path');
    }
    return http.Response(jsonEncode(response), 200,
        request: request, headers: {'content-type': 'application/json'});
  });

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    GoogleFonts.config.allowRuntimeFetching = false;
    GeolocatorPlatform.instance = NoLocation();
    await Supabase.initialize(
        url: 'https://test.invalid',
        anonKey: 'test-key',
        httpClient: client,
        debug: false,
        authOptions: FlutterAuthClientOptions(
            autoRefreshToken: false,
            detectSessionInUri: false,
            localStorage: EmptyLocalStorage()));
    final token = '${base64UrlEncode(utf8.encode('{"alg":"none"}'))}.'
        '${base64UrlEncode(utf8.encode(jsonEncode({
          'sub': user.id,
          'exp': DateTime.now()
                  .add(const Duration(hours: 1))
                  .millisecondsSinceEpoch ~/
              1000
        })))}.signature';
    await Supabase.instance.client.auth.setInitialSession(jsonEncode({
      'access_token': token,
      'refresh_token': 'test-refresh',
      'token_type': 'bearer',
      'expires_in': 3600,
      'user': user.toJson(),
    }));
    currentUser = DecoyWalletAppSupabaseUser(user);
  });

  tearDownAll(() async => Supabase.instance.dispose());

  setUp(() async {
    paths.clear();
    alerts.clear();
    consent = 'confirmed';
    FlutterSecureStorage.setMockInitialValues({'decoy_data_key_b64': key});
    FFAppState.reset();
    await FFAppState().initializePersistedState();
    FFAppState().hasActiveSubscription = true;
    FFAppState().decoyPinContactsEnabled = true;
    FFAppState().fakeSeeded = true;
    FFAppState().fakeBtcBalance = 1;
    row = {
      'user_id': user.id,
      'use_current_location': false,
      'contacts_complete': false,
      'personal_complete': false
    };
  });

  Future<void> enter(WidgetTester tester, String pin) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const PINPageWidget()),
      GoRoute(
          name: 'DuressHomePage',
          path: '/duressHomePage',
          builder: (_, __) => const Scaffold(body: Text('DECOY DESTINATION'))),
      GoRoute(
          name: 'HomePage',
          path: '/homePage',
          builder: (_, __) =>
              const Scaffold(body: Text('ACCOUNT DESTINATION'))),
    ]);
    addTearDown(router.dispose);
    await http.runWithClient(() async {
      await tester.pumpWidget(ChangeNotifierProvider.value(
          value: FFAppState(),
          child: MaterialApp.router(
            routerConfig: router,
            locale: Locale(languageCode),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          )));
      await tester.pumpAndSettle();
      for (final digit in pin.split('')) {
        await tester.tap(find.text(digit));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text(languageCode == 'es' ? 'Entrar' : 'Enter'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }, () => client);
  }

  for (final code in ['en', 'es']) {
    group(code, () {
      setUp(() => languageCode = code);
      for (final personal in [false, true]) {
        for (final contacts in [false, true]) {
          testWidgets(
              'actual PIN navigation personal=$personal contacts=$contacts',
              (tester) async {
            await tester.runAsync(() async {
              if (personal) {
                final enc = await aesGcmEncryptString(
                    jsonEncode({'firstName': 'Test', 'lastName': 'User'}), key);
                row.addAll({
                  'personal_ciphertext': enc['ciphertextB64'],
                  'personal_nonce': enc['nonceB64'],
                  'wrapped_datakey': 'wrapped'
                });
              }
              if (contacts) {
                final enc = await aesGcmEncryptString(
                    jsonEncode({
                      'contacts': [
                        {
                          'slot': 1,
                          'first': 'Test',
                          'last': 'Contact',
                          'phone': '+12025550123',
                          'consent_status': 'confirmed'
                        }
                      ]
                    }),
                    key);
                row.addAll({
                  'contacts_ciphertext': enc['ciphertextB64'],
                  'contacts_nonce': enc['nonceB64'],
                  'contacts_complete': true,
                  'wrapped_datakey': 'wrapped'
                });
              }
            });
            await enter(tester, '9876');
            expect(find.text('DECOY DESTINATION'), findsOneWidget);
            expect(alerts, hasLength(contacts ? 1 : 0));
            if (contacts) {
              expect(alerts.single['triggerType'], 'PIN_DECOY');
              expect(alerts.single['contacts'][0]['phone'], '+12025550123');
              expect(alerts.single['ownerName'], personal ? 'Test User' : ' ');
            }
          });
        }
      }

      testWidgets('account PIN still opens account without optional data',
          (tester) async {
        await enter(tester, '1234');
        expect(find.text('ACCOUNT DESTINATION'), findsOneWidget);
        expect(alerts, isEmpty);
      });

      testWidgets('wrong PIN does not open either destination or send an alert',
          (tester) async {
        await enter(tester, '5555');
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();
        expect(find.text('DECOY DESTINATION'), findsNothing);
        expect(find.text('ACCOUNT DESTINATION'), findsNothing);
        expect(find.byType(PINPageWidget), findsOneWidget);
        expect(alerts, isEmpty);
      });

      for (final enabled in [false, true]) {
        testWidgets('unconfirmed contacts never cause alert: enabled=$enabled',
            (tester) async {
          consent = 'pending';
          FFAppState().decoyPinContactsEnabled = enabled;
          await tester.runAsync(() async {
            final enc = await aesGcmEncryptString(
                jsonEncode({
                  'contacts': [
                    {
                      'slot': 1,
                      'first': 'Test',
                      'last': 'Contact',
                      'phone': '+12025550123',
                      'consent_status': 'confirmed'
                    }
                  ]
                }),
                key);
            row.addAll({
              'contacts_ciphertext': enc['ciphertextB64'],
              'contacts_nonce': enc['nonceB64'],
              'contacts_complete': true,
              'wrapped_datakey': 'wrapped'
            });
          });
          await enter(tester, '9876');
          expect(find.text('DECOY DESTINATION'), findsOneWidget);
          expect(alerts, isEmpty);
        });
      }
    });
  }
}
