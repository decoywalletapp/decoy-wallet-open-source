import 'dart:async';
import 'dart:convert';

import 'package:decoy_wallet_app/app_state.dart';
import 'package:decoy_wallet_app/auth/supabase_auth/supabase_user_provider.dart';
import 'package:decoy_wallet_app/backend/public_config.dart';
import 'package:decoy_wallet_app/custom_code/actions/aes_gcm_encrypt_string.dart';
import 'package:decoy_wallet_app/duress_mode/duress_home_page/duress_home_page_widget.dart';
import 'package:decoy_wallet_app/flutter_flow/nav/nav.dart';
import 'package:decoy_wallet_app/l10n/app_localizations.dart';
import 'package:decoy_wallet_app/pin_pages/p_i_n_page/p_i_n_page_widget.dart';
import 'package:decoy_wallet_app/services/account_balance.dart';
import 'package:decoy_wallet_app/welcom_pages/auth_router/auth_router_widget.dart';
import 'package:decoy_wallet_app/welcom_pages/login_page/login_page_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:local_auth_platform_interface/local_auth_platform_interface.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'localization_fonts.dart';
import 'support/account_balance_fakes.dart';

class _Biometrics extends LocalAuthPlatform {
  int calls = 0;
  final firstResponse = Completer<bool>();

  @override
  Future<bool> isDeviceSupported() async => true;

  @override
  Future<bool> authenticate({
    required String localizedReason,
    required Iterable<AuthMessages> authMessages,
    AuthenticationOptions options = const AuthenticationOptions(),
  }) async {
    calls++;
    if (calls == 1) return firstResponse.future;
    return true;
  }
}

class _NoLocation extends GeolocatorPlatform {
  @override
  Future<bool> isLocationServiceEnabled() async => false;
}

class _AuthStorage extends GotrueAsyncStorage {
  final values = <String, String>{};
  @override
  Future<String?> getItem({required String key}) async => values[key];
  @override
  Future<void> setItem({required String key, required String value}) async {
    values[key] = value;
  }

  @override
  Future<void> removeItem({required String key}) async {
    values.remove(key);
  }
}

void main() {
  if (kFirebaseFunctionsBaseUrl != 'https://test.invalid') {
    test('login lifecycle requires isolated fake endpoints', () {},
        skip: 'Run with test.invalid endpoint dart-defines.');
    return;
  }
  TestWidgetsFlutterBinding.ensureInitialized();
  final app = AppStateNotifier.instance;
  final requests = <String>[];
  var responseDelay = const Duration(milliseconds: 50);
  Completer<void>? recoveryGate;
  Map<String, dynamic>? entitlementOverride;
  var entitlementMissing = false;
  var acceptedDecoyPins = 0;
  var stripeRepairUnavailable = false;
  Map<String, dynamic>? entitlementAfterRepair;
  var entitlementMissingAfterRepair = false;
  final alerts = <Map<String, dynamic>>[];
  final dataKey = base64UrlEncode(List<int>.generate(16, (index) => index));
  late Map<String, dynamic> encryptedContacts;
  late Map<String, dynamic> session;
  const userId = 'synthetic-login-owner';
  final user = User(
      id: userId,
      email: 'owner@example.invalid',
      emailConfirmedAt: '2026-01-01T00:00:00Z',
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: '2026-01-01T00:00:00Z');
  final client = MockClient((request) async {
    // The real wallet reads market data; answer locally, never over the network.
    if (request.url.host == 'api.exchange.coinbase.com' &&
        ['/products/BTC-USD/ticker', '/products/BTC-USD/stats']
            .contains(request.url.path)) {
      return http.Response(jsonEncode({'price': '60000', 'open': '59000'}), 200,
          request: request, headers: {'content-type': 'application/json'});
    }
    if (request.url.host != 'test.invalid') {
      throw StateError('Only synthetic authentication is permitted');
    }
    requests.add('${request.method} ${request.url.path}');
    await Future<void>.delayed(responseDelay);
    Object? response;
    switch (request.url.path) {
      case '/auth/v1/token':
        if (recoveryGate != null) await recoveryGate!.future;
        response = session;
        break;
      case '/auth/v1/user':
        response = user.toJson();
        break;
      case '/auth/v1/logout':
        return http.Response('', 204, request: request);
      case '/getEmailHash':
        response = {'email_hash': 'synthetic-email-hash'};
        break;
      case '/functions/v1/verifyPin':
        final pin = jsonDecode(request.body)['pin'];
        if (pin == '9876') acceptedDecoyPins++;
        response = {
          'ok': true,
          'isDecoy': pin == '9876',
          'isAccount': pin == '1234',
        };
        break;
      case '/unwrap':
        response = {'dataKeyB64': dataKey};
        break;
      case '/functions/v1/getConsentStatuses':
        response = {'slot1Status': 'confirmed'};
        break;
      case '/repair-stripe-entitlement':
        if (!stripeRepairUnavailable) {
          entitlementOverride = entitlementAfterRepair ?? entitlementOverride;
          entitlementMissing = entitlementMissingAfterRepair;
        }
        return http.Response(jsonEncode({'ok': !stripeRepairUnavailable}),
            stripeRepairUnavailable ? 503 : 200,
            request: request, headers: {'content-type': 'application/json'});
      case '/sendEmergencyAlerts':
        alerts.add(Map<String, dynamic>.from(jsonDecode(request.body)));
        response = {'ok': true};
        break;
      case '/functions/v1/coingecko-proxy':
        response = {
          'prices': [
            [1700000000000, 59000],
            [1700086400000, 60000]
          ]
        };
        break;
      case '/rest/v1/decoy_wallet':
        if (request.method == 'PATCH') {
          return http.Response('', 204, request: request);
        }
        response = [
          {
            'user_id': userId,
            'setup_complete': true,
            'agreements_complete': true,
            'email_verified': true,
            'permissions_onboarding_step': 'complete',
            'account_pin_hash': 'synthetic-pin-hash',
            'contacts_complete': true,
            'personal_complete': true,
            'decoy_pin_contacts_enabled': true,
            'wrapped_datakey': 'synthetic-wrapped-key',
            'contacts_ciphertext': encryptedContacts['ciphertextB64'],
            'contacts_nonce': encryptedContacts['nonceB64'],
          }
        ];
        break;
      case '/rest/v1/user_settings':
        response = [
          {'user_id': userId, 'push_enabled': false}
        ];
        break;
      case '/rest/v1/user_entitlements':
        response = entitlementMissing
            ? []
            : [
                entitlementOverride ??
                    {
                      'user_id': userId,
                      'entitlement': 'decoy_wallet',
                      'provider': 'promo',
                      'is_active': true,
                      'promotional_access_until': DateTime.now()
                          .add(const Duration(days: 30))
                          .toIso8601String(),
                    }
              ];
        break;
      default:
        throw StateError('Unexpected synthetic request: ${request.url.path}');
    }
    return http.Response(jsonEncode(response), 200,
        request: request, headers: {'content-type': 'application/json'});
  });

  setUpAll(() async {
    await loadLocalizationFonts();
    encryptedContacts = await aesGcmEncryptString(
        jsonEncode({
          'contacts': [
            {
              'slot': 1,
              'first': 'Test',
              'last': 'Contact',
              'phone': '+12025550123',
              'consent_status': 'confirmed',
            }
          ],
        }),
        dataKey);
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    GoogleFonts.config.allowRuntimeFetching = false;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    for (final name in [
      'com.llfbandit.app_links/messages',
      'com.llfbandit.app_links/events',
    ]) {
      messenger.setMockMethodCallHandler(
          MethodChannel(name), (_) async => null);
    }
    await Supabase.initialize(
        url: 'https://test.invalid',
        anonKey: 'synthetic-anon',
        debug: false,
        httpClient: client,
        authOptions: FlutterAuthClientOptions(
            authFlowType: AuthFlowType.implicit,
            autoRefreshToken: false,
            detectSessionInUri: false,
            pkceAsyncStorage: _AuthStorage(),
            localStorage: const EmptyLocalStorage()));
    String part(Object value) =>
        base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    session = {
      'access_token': '${part({'alg': 'HS256'})}.${part({
            'sub': userId,
            'iat': now,
            'exp': now + 7200
          })}.synthetic',
      'refresh_token': 'synthetic-refresh',
      'expires_in': 7200,
      'token_type': 'bearer',
      'user': user.toJson(),
    };
  });
  tearDownAll(() async => Supabase.instance.dispose());

  setUp(() {
    entitlementOverride = null;
    entitlementMissing = false;
    acceptedDecoyPins = 0;
    stripeRepairUnavailable = false;
    entitlementAfterRepair = null;
    entitlementMissingAfterRepair = false;
    alerts.clear();
  });

  const usableAccessCases = {
    'paid Stripe',
    'paid Bitcoin',
    'active legacy with no end date',
    'valid promotion with inactive billing',
    'redeemed gift with expired billing',
    'paid Stripe to Bitcoin handoff',
    'paid Bitcoin to Stripe handoff',
    'scheduled future provider switch',
    'completed provider switch',
    'valid promotion after canceled Stripe',
    'valid promotion when Stripe repair unavailable',
    'Stripe repair restores access',
  };
  for (final accessCase in [
    'expired prepaid',
    'expired date with stale active flag',
    'expired promotion',
    'missing entitlement',
    'Stripe repair unavailable without promotion',
    'Stripe repair unavailable with expired promotion',
    'Stripe repair reread revokes promotion',
    'Stripe repair reread removes entitlement',
    ...usableAccessCases,
  ]) {
    final expectedAccess = usableAccessCases.contains(accessCase);
    for (final initialPath in ['/loginPage', '/authRouter']) {
      for (final biometricsEnabled in [false, true]) {
        for (final cachedAccess in [false, true]) {
          testWidgets(
              '${expectedAccess ? 'usable access permits' : 'unusable access blocks'} actual Decoy PIN: $accessCase, '
              'entry=$initialPath, biometrics=$biometricsEnabled, cachedAccess=$cachedAccess',
              (tester) async {
            responseDelay = const Duration(milliseconds: 50);
            entitlementMissing = accessCase == 'missing entitlement';
            final expiredAt = DateTime.now()
                .subtract(const Duration(days: 1))
                .toUtc()
                .toIso8601String();
            entitlementOverride = {
              'user_id': userId,
              'entitlement': 'decoy_wallet',
              'provider':
                  accessCase == 'expired promotion' ? 'promo' : 'btcpay',
              'status': 'expired',
              'is_active': accessCase == 'expired date with stale active flag',
              'current_period_end': expiredAt,
              'promotional_access_until':
                  accessCase == 'expired promotion' ? expiredAt : null,
            };
            stripeRepairUnavailable = accessCase ==
                    'valid promotion when Stripe repair unavailable' ||
                accessCase.startsWith('Stripe repair unavailable');
            final futureAt = DateTime.now()
                .add(const Duration(days: 30))
                .toUtc()
                .toIso8601String();
            if (expectedAccess) {
              entitlementOverride!.addAll({
                'provider': accessCase == 'paid Stripe' ||
                        accessCase == 'paid Stripe to Bitcoin handoff'
                    ? 'stripe'
                    : 'btcpay',
                'status': 'active',
                'is_active': true,
                'current_period_end': futureAt,
              });
              if (accessCase == 'active legacy with no end date') {
                entitlementOverride!['current_period_end'] = null;
              }
              if (accessCase == 'valid promotion with inactive billing' ||
                  accessCase == 'redeemed gift with expired billing') {
                entitlementOverride!.addAll({
                  'provider':
                      accessCase.startsWith('valid') ? 'promo' : 'btcpay',
                  'is_active': false,
                  'current_period_end': expiredAt,
                  'promotional_access_until': futureAt,
                });
              }
              if (accessCase.endsWith('handoff') ||
                  accessCase == 'scheduled future provider switch') {
                entitlementOverride!.addAll({
                  'current_period_end':
                      accessCase.endsWith('handoff') ? expiredAt : futureAt,
                  'pending_provider':
                      accessCase == 'paid Stripe to Bitcoin handoff'
                          ? 'btcpay'
                          : 'stripe',
                  'pending_starts_at':
                      accessCase.endsWith('handoff') ? expiredAt : futureAt,
                  'pending_provider_subscription_id':
                      'synthetic-paid-subscription',
                });
              }
              if (accessCase == 'valid promotion after canceled Stripe' ||
                  stripeRepairUnavailable) {
                entitlementOverride!.addAll({
                  'provider': 'stripe',
                  'status': 'canceled',
                  'is_active': false,
                  'current_period_end': expiredAt,
                  'promotional_access_until': futureAt,
                });
              }
            }
            if (accessCase.startsWith('Stripe repair')) {
              entitlementOverride!.addAll({
                'provider': 'stripe',
                'status': 'canceled',
                'is_active': false,
                'current_period_end': expiredAt,
                'promotional_access_until': accessCase.contains('reread')
                    ? futureAt
                    : accessCase.endsWith('expired promotion')
                        ? expiredAt
                        : null,
              });
              if (accessCase == 'Stripe repair restores access') {
                entitlementAfterRepair = {
                  ...entitlementOverride!,
                  'status': 'active',
                  'is_active': true,
                  'current_period_end': futureAt,
                };
              } else if (accessCase ==
                  'Stripe repair reread revokes promotion') {
                entitlementAfterRepair = {
                  ...entitlementOverride!,
                  'promotional_access_until': expiredAt,
                };
              } else if (accessCase ==
                  'Stripe repair reread removes entitlement') {
                entitlementMissingAfterRepair = true;
              }
            }
            final previousBiometrics = LocalAuthPlatform.instance;
            final previousLocation = GeolocatorPlatform.instance;
            GeolocatorPlatform.instance = _NoLocation();
            addTearDown(() => GeolocatorPlatform.instance = previousLocation);
            final biometrics = _Biometrics()..firstResponse.complete(true);
            LocalAuthPlatform.instance = biometrics;
            addTearDown(() => LocalAuthPlatform.instance = previousBiometrics);
            await tester.runAsync(() async {
              await Supabase.instance.client.auth.signOut();
              if (initialPath == '/authRouter') {
                await Supabase.instance.client.auth
                    .setInitialSession(jsonEncode(session));
              }
              FFAppState.reset();
              await FFAppState().initializePersistedState();
            });
            currentUser = DecoyWalletAppSupabaseUser(
                Supabase.instance.client.auth.currentUser);
            app.update(currentUser!);
            app.stopShowingSplashImage();
            app.unlock.lock();
            app.clearRedirectLocation();
            requests.clear();
            FFAppState().biometricsEnabled = biometricsEnabled;
            // Neither cached value may override the fetched entitlement.
            FFAppState().hasActiveSubscription = cachedAccess;
            FFAppState().decoyPinContactsEnabled = true;
            final remote = MemoryRemote()..users.add(userId);
            final balance =
                AccountBalance(remote: remote, cache: MemoryCache());
            addTearDown(balance.dispose);
            FFAppState().attachAccountBalance(balance);
            await FFAppState().selectBalanceUser(userId);
            await balance.configure(1);
            await balance.refresh();
            remote.offline = true;
            tester.view.physicalSize = const Size(402, 874);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            final subscription =
                decoyWalletAppSupabaseUserStream().listen(app.update);
            final router = createRouter(app);
            addTearDown(() async {
              await subscription.cancel();
              router.dispose();
            });
            router.go(initialPath);
            await http.runWithClient(() async {
              await tester.pumpWidget(ChangeNotifierProvider.value(
                  value: FFAppState(),
                  child: MaterialApp.router(
                    routerConfig: router,
                    theme: ThemeData(platform: TargetPlatform.iOS),
                    localizationsDelegates:
                        AppLocalizations.localizationsDelegates,
                    supportedLocales: AppLocalizations.supportedLocales,
                  )));
              await tester.pumpAndSettle();
              if (initialPath == '/loginPage') {
                await tester.enterText(
                    find.byType(TextFormField).at(0), 'owner@example.invalid');
                await tester.enterText(
                    find.byType(TextFormField).at(1), 'synthetic-password');
                final strings = AppLocalizations.of(
                    tester.element(find.byType(LoginPageWidget)))!;
                await tester.tap(find.text(strings.msgLogIn));
              }
              for (var tick = 0; tick < 100; tick++) {
                await tester.pump(const Duration(milliseconds: 50));
              }
              await tester.pumpAndSettle();
              expect(find.byType(PINPageWidget), findsOneWidget);
              expect(biometrics.calls, biometricsEnabled ? 1 : 0);
              expect(app.unlock.pinReady, isTrue);
              expect(requests, contains('GET /rest/v1/user_entitlements'));
              if (accessCase.contains('Stripe repair') ||
                  accessCase == 'valid promotion after canceled Stripe') {
                expect(
                    requests.where(
                        (path) => path == 'POST /repair-stripe-entitlement'),
                    hasLength(1));
                expect(
                    requests.where(
                        (path) => path == 'GET /rest/v1/user_entitlements'),
                    hasLength(stripeRepairUnavailable ? 1 : 2));
              }
              final requestsBeforePin = requests.length;
              for (final digit in '9876'.split('')) {
                await tester.tap(find.text(digit));
                await tester.pumpAndSettle();
              }
              final strings = AppLocalizations.of(
                  tester.element(find.byType(PINPageWidget)))!;
              await tester.tap(find.text(strings.msgEnter));
              for (var tick = 0; tick < 40; tick++) {
                await tester.pump(const Duration(milliseconds: 50));
              }
              await tester.pumpAndSettle();
              final pinRequests = requests.skip(requestsBeforePin).toList();
              expect(acceptedDecoyPins, 1);
              expect(FFAppState().hasActiveSubscription, expectedAccess,
                  reason: 'case=$accessCase; route='
                      '${router.routeInformationProvider.value.uri.path}; '
                      'decoy=${app.unlock.inDecoy}; alerts=${alerts.length}');
              expect(
                  pinRequests
                      .where((path) => path == 'POST /functions/v1/verifyPin'),
                  hasLength(1),
                  reason: 'requests=$requests; '
                      'pinReady=${app.unlock.pinReady}; inDecoy=${app.unlock.inDecoy}; '
                      'route=${router.routeInformationProvider.value.uri}');
              if (expectedAccess) {
                expect(router.routeInformationProvider.value.uri.path,
                    '/duressHomePage');
                expect(find.byType(DuressHomePageWidget), findsOneWidget);
                expect(find.byType(PINPageWidget), findsNothing);
                expect(alerts, hasLength(1));
                expect(alerts.single['triggerType'], 'PIN_DECOY');
                expect(alerts.single['contacts'][0]['phone'], '+12025550123');
                expect(
                    requests
                        .where((path) => path.contains('sendEmergencyAlerts')),
                    hasLength(1));
              } else {
                expect(
                    pinRequests,
                    everyElement(isIn([
                      'POST /functions/v1/verifyPin',
                      'GET /rest/v1/decoy_wallet',
                    ])));
                expect(
                    router.routeInformationProvider.value.uri.path, '/PINPage');
                expect(find.byType(PINPageWidget), findsOneWidget);
                expect(alerts, isEmpty);
                expect(
                    requests
                        .where((path) => path.contains('sendEmergencyAlerts')),
                    isEmpty);
              }
              expect(app.unlock.pinReady, !expectedAccess);
              expect(app.unlock.inDecoy, expectedAccess);
              expect(app.unlock.ownerUnlocked, isFalse);
              expect(tester.takeException(), isNull);
              await tester.pumpWidget(const SizedBox());
              await tester.pumpAndSettle();
            }, () => client);
          },
              skip: (expectedAccess &&
                      (kDecoyAlertBaseUrl != 'https://test.invalid' ||
                          kDataKeyBaseUrl != 'https://test.invalid/unwrap')) ||
                  ((accessCase == 'valid promotion after canceled Stripe' ||
                          accessCase.contains('Stripe repair')) &&
                      kPaymentBaseUrl != 'https://test.invalid'));
        }
      }
    }
  }

  for (final changedParameter in ['accessToken', 'refreshToken']) {
    testWidgets('pending recovery survives a changed $changedParameter',
        (tester) async {
      await tester.runAsync(() async {
        await Supabase.instance.client.auth.signOut();
        await Supabase.instance.client.auth
            .setInitialSession(jsonEncode(session));
        FFAppState.reset();
        await FFAppState().initializePersistedState();
      });
      currentUser =
          DecoyWalletAppSupabaseUser(Supabase.instance.client.auth.currentUser);
      app.update(currentUser!);
      app.unlock.lock();
      app.clearRedirectLocation();
      app.stopShowingSplashImage();
      requests.clear();
      recoveryGate = Completer<void>();
      final subscription =
          decoyWalletAppSupabaseUserStream().listen(app.update);
      final router = createRouter(app);
      addTearDown(() async {
        if (recoveryGate?.isCompleted == false) recoveryGate!.complete();
        recoveryGate = null;
        await subscription.cancel();
        router.dispose();
      });
      final parameters = {
        'type': 'recovery',
        'accessToken': 'synthetic-first-access',
        'refreshToken': 'synthetic-first-refresh',
      };
      router
          .go(Uri(path: '/authRouter', queryParameters: parameters).toString());
      await http.runWithClient(() async {
        await tester.pumpWidget(ChangeNotifierProvider.value(
            value: FFAppState(),
            child: MaterialApp.router(
              routerConfig: router,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
            )));
        await tester.pump(const Duration(milliseconds: 100));
        final firstState = tester.state(find.byType(AuthRouterWidget));
        final firstKey = tester.widget(find.byType(AuthRouterWidget)).key!;
        expect(firstKey.toString(), isNot(contains('synthetic-first')));
        router.routeInformationProvider.routerReportsNewRouteInformation(
            router.routeInformationParser.restoreRouteInformation(
                router.routerDelegate.currentConfiguration)!);
        app.notifyListeners();
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.state(find.byType(AuthRouterWidget)), same(firstState));
        expect(requests.where((path) => path.endsWith('/auth/v1/token')).length,
            1);
        parameters[changedParameter] = 'synthetic-second-credential';
        router.go(
            Uri(path: '/authRouter', queryParameters: parameters).toString());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(firstState.mounted, isFalse);
        expect(tester.widget(find.byType(AuthRouterWidget)).key,
            isNot(equals(firstKey)));
        expect(app.unlock.recoveryAllowed, isFalse);
        recoveryGate!.complete();
        for (var tick = 0; tick < 20; tick++) {
          await tester.pump(const Duration(milliseconds: 50));
        }
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(router.routeInformationProvider.value.uri.path,
            '/updatePasswordPage');
        expect(app.unlock.recoveryAllowed, isTrue);
        expect(app.unlock.ownerUnlocked, isFalse);
        expect(requests.where((path) => path.contains('sendEmergencyAlerts')),
            isEmpty);
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      }, () => client);
    });
  }

  for (final initialPath in ['/authRouter', '/loginPage', '/']) {
    final fromLogin = initialPath != '/authRouter';
    for (final latency in [10, 50]) {
      for (final biometricAccepted in [false, true]) {
        for (final recoveryArrives in [false, true]) {
          testWidgets(
              'native auth refresh prompts once: entry=$initialPath, '
              'latency=$latency, accepted=$biometricAccepted, recovery=$recoveryArrives',
              (tester) async {
            responseDelay = Duration(milliseconds: latency);
            final previousBiometrics = LocalAuthPlatform.instance;
            final biometrics = _Biometrics();
            LocalAuthPlatform.instance = biometrics;
            addTearDown(() => LocalAuthPlatform.instance = previousBiometrics);
            await tester.runAsync(() async {
              await Supabase.instance.client.auth.signOut();
              if (!fromLogin) {
                await Supabase.instance.client.auth
                    .setInitialSession(jsonEncode(session));
              }
              FFAppState.reset();
              await FFAppState().initializePersistedState();
            });
            currentUser = DecoyWalletAppSupabaseUser(
                Supabase.instance.client.auth.currentUser);
            app.update(currentUser!);
            app.stopShowingSplashImage();
            app.unlock.lock();
            app.clearRedirectLocation();
            requests.clear();
            FFAppState().biometricsEnabled = true;
            tester.view.physicalSize = const Size(402, 874);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            final subscription =
                decoyWalletAppSupabaseUserStream().listen(app.update);
            final router = createRouter(app);
            addTearDown(() async {
              if (!biometrics.firstResponse.isCompleted) {
                biometrics.firstResponse.complete(false);
              }
              await subscription.cancel();
              router.dispose();
            });
            router.go(initialPath,
                extra: fromLogin
                    ? null
                    : {
                        kTransitionInfoKey: const TransitionInfo(
                            hasTransition: true,
                            duration: Duration(milliseconds: 1)),
                      });
            await http.runWithClient(() async {
              await tester.pumpWidget(ChangeNotifierProvider.value(
                  value: FFAppState(),
                  child: MaterialApp.router(
                    routerConfig: router,
                    theme: ThemeData(platform: TargetPlatform.iOS),
                    localizationsDelegates:
                        AppLocalizations.localizationsDelegates,
                    supportedLocales: AppLocalizations.supportedLocales,
                  )));
              await tester.pumpAndSettle();
              if (fromLogin) {
                await tester.enterText(
                    find.byType(TextFormField).at(0), 'owner@example.invalid');
                await tester.enterText(
                    find.byType(TextFormField).at(1), 'synthetic-password');
                final strings = AppLocalizations.of(
                    tester.element(find.byType(LoginPageWidget)))!;
                await tester.tap(find.text(strings.msgLogIn));
              }
              for (var tick = 0; tick < 100 && biometrics.calls == 0; tick++) {
                await tester.pump(const Duration(milliseconds: 16));
              }
              expect(biometrics.calls, 1, reason: requests.join(', '));
              // Reproduce the phone's route serialization, including lost extras.
              router.routeInformationProvider.routerReportsNewRouteInformation(
                  router.routeInformationParser.restoreRouteInformation(
                      router.routerDelegate.currentConfiguration)!);
              app.notifyListeners();
              await tester.pump();
              await tester.pump(const Duration(milliseconds: 16));
              if (recoveryArrives) {
                router.go(Uri(path: '/authRouter', queryParameters: {
                  'type': 'recovery',
                  'accessToken': 'synthetic-recovery-access',
                  'refreshToken': 'synthetic-recovery-refresh',
                }).toString());
                await tester.pump();
                await tester.pump(const Duration(milliseconds: 100));
              }
              biometrics.firstResponse.complete(biometricAccepted);
              for (var tick = 0; tick < 100; tick++) {
                await tester.pump(const Duration(milliseconds: 50));
              }
              await tester.pumpAndSettle();
              expect(biometrics.calls, 1);
              expect(
                  find.byType(PINPageWidget),
                  biometricAccepted && !recoveryArrives
                      ? findsOneWidget
                      : findsNothing);
              expect(
                  find.byType(LoginPageWidget),
                  biometricAccepted || recoveryArrives
                      ? findsNothing
                      : findsOneWidget,
                  reason: 'route=${router.routeInformationProvider.value.uri}; '
                      'authenticated=${app.loggedIn}; requests=${requests.join(', ')}');
              expect(app.unlock.ownerUnlocked, isFalse);
              expect(app.unlock.inDecoy, isFalse);
              expect(
                  app.unlock.pinReady, biometricAccepted && !recoveryArrives);
              expect(app.unlock.recoveryAllowed, recoveryArrives);
              if (recoveryArrives) {
                expect(router.routeInformationProvider.value.uri.path,
                    '/updatePasswordPage');
                expect(Supabase.instance.client.auth.currentUser?.id, userId);
                expect(
                    requests.where((path) => path.endsWith('/auth/v1/logout')),
                    isEmpty);
              }
              expect(
                  requests
                      .where((path) => path.contains('sendEmergencyAlerts')),
                  isEmpty);
              expect(tester.takeException(), isNull);
              await tester.pumpWidget(const SizedBox());
              await tester.pumpAndSettle();
            }, () => client);
          });
        }
      }
    }
  }
}
