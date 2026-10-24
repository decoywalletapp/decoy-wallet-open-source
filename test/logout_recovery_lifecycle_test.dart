import 'dart:async';
import 'dart:convert';

import 'package:app_links/app_links.dart';
import 'package:app_links_platform_interface/app_links_platform_interface.dart';
import 'package:decoy_wallet_app/app_state.dart';
import 'package:decoy_wallet_app/auth/supabase_auth/auth_util.dart';
import 'package:decoy_wallet_app/auth/supabase_auth/supabase_user_provider.dart';
import 'package:decoy_wallet_app/flutter_flow/nav/nav.dart';
import 'package:decoy_wallet_app/home_pages/settings/settings_widget.dart';
import 'package:decoy_wallet_app/l10n/app_localizations.dart';
import 'package:decoy_wallet_app/welcom_pages/login_page/login_page_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'localization_fonts.dart';

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

class _Links extends AppLinksPlatform {
  final events = StreamController<Uri>.broadcast();
  var initialReads = 0;
  @override
  Future<Uri?> getInitialLink() async {
    initialReads++;
    return Uri.parse('decoywallet://authRouter?type=recovery'
        '&accessToken=synthetic-access&refreshToken=synthetic-consumed-launch');
  }

  @override
  Stream<Uri> get uriLinkStream => events.stream;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final app = AppStateNotifier.instance;
  final requests = <String>[];
  final tokenRequests = <String>[];
  late Map<String, dynamic> session;

  setUpAll(() async {
    await loadLocalizationFonts();
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    await FFAppState().initializePersistedState();
    String part(Object value) =>
        base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    session = {
      'access_token': '${part({'alg': 'HS256'})}.${part({
            'sub': 'synthetic-owner',
            'iat': now,
            'exp': now + 7200
          })}.synthetic',
      'refresh_token': 'synthetic-current-session',
      'expires_in': 7200,
      'token_type': 'bearer',
      'user': {
        'id': 'synthetic-owner',
        'email': 'owner@example.invalid',
        'email_confirmed_at': '2026-01-01T00:00:00Z',
        'aud': 'authenticated',
        'app_metadata': {},
        'user_metadata': {},
        'created_at': '2026-01-01T00:00:00Z',
      },
    };
    await Supabase.initialize(
      url: 'https://test.invalid',
      anonKey: 'synthetic-anon',
      debug: false,
      authOptions: FlutterAuthClientOptions(
        authFlowType: AuthFlowType.implicit,
        autoRefreshToken: false,
        detectSessionInUri: false,
        pkceAsyncStorage: _AuthStorage(),
        localStorage: const EmptyLocalStorage(),
      ),
      httpClient: MockClient((request) async {
        if (request.url.host != 'test.invalid') {
          throw StateError('Only fake authentication is permitted');
        }
        requests.add('${request.method} ${request.url.path}');
        if (request.url.path == '/auth/v1/logout') {
          return http.Response('', 204, request: request);
        }
        if (request.url.path == '/auth/v1/token') {
          final token = jsonDecode(request.body)['refresh_token'] as String;
          tokenRequests.add(token);
          if (token.startsWith('synthetic-new-recovery')) {
            return http.Response(jsonEncode(session), 200,
                headers: {'content-type': 'application/json'});
          }
          return http.Response(
              jsonEncode({
                'code': 'refresh_token_not_found',
                'msg': 'Invalid Refresh Token: Refresh Token Not Found',
              }),
              400,
              headers: {'content-type': 'application/json'});
        }
        throw StateError('Unexpected fake request: ${request.url.path}');
      }),
    );
  });
  tearDownAll(() async {
    await Supabase.instance.dispose();
  });

  testWidgets('Settings logout never replays the consumed launch recovery link',
      (tester) async {
    final links = _Links();
    AppLinksPlatform.instance = links;
    // Production's SDK listener keeps the platform stream alive across pages.
    // Keep that lifecycle here without letting the SDK consume fake callbacks.
    final platformListener = AppLinks().uriLinkStream.listen((_) {});
    addTearDown(() async {
      await platformListener.cancel();
      await links.events.close();
    });
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    // Recovery was handled by AuthRouter; Login's link widget never consumed it.
    await Supabase.instance.client.auth.setInitialSession(jsonEncode(session));
    currentUser =
        DecoyWalletAppSupabaseUser(Supabase.instance.client.auth.currentUser);
    app.update(currentUser!);
    app.clearRedirectLocation();
    app.stopShowingSplashImage();
    app.unlock.preparePin(app.unlock.attempt, paidDecoyAllowed: true);
    expect(app.unlock.unlockOwner(app.unlock.attempt), isTrue);
    final subscription = decoyWalletAppSupabaseUserStream().listen(app.update);
    final router = GoRouter(
      initialLocation: SettingsWidget.routePath,
      refreshListenable: app,
      routes: [
        FFRoute(
          name: SettingsWidget.routeName,
          path: SettingsWidget.routePath,
          builder: (_, __) => const SettingsWidget(),
        ).toRoute(app),
        FFRoute(
          name: LoginPageWidget.routeName,
          path: LoginPageWidget.routePath,
          builder: (_, __) => const LoginPageWidget(),
        ).toRoute(app),
        FFRoute(
          name: 'UpdatePasswordPage',
          path: '/updatePasswordPage',
          builder: (_, __) => const Text('verified-recovery-only'),
        ).toRoute(app),
        FFRoute(
          name: 'AuthRouter',
          path: '/authRouter',
          builder: (_, __) => const Text('unexpected-auth-router'),
        ).toRoute(app),
      ],
    );
    addTearDown(() async {
      await subscription.cancel();
      router.dispose();
    });
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: FFAppState(),
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsWidget), findsOneWidget);
    await tester.ensureVisible(find.text('Log Out'));
    await tester.tap(find.text('Log Out'));
    for (var tick = 0; tick < 20; tick++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pumpAndSettle();
    expect(find.byType(LoginPageWidget), findsOneWidget,
        reason: '${router.routeInformationProvider.value.uri.path}: $requests');
    expect(Supabase.instance.client.auth.currentSession, isNull);
    expect(app.unlock.ownerUnlocked, isFalse);
    expect(app.unlock.recoveryAllowed, isFalse);
    expect(find.byType(SnackBar), findsNothing);
    expect(tokenRequests, isEmpty);
    expect(links.initialReads, 0);
    expect(requests, ['POST /auth/v1/logout']);

    // A genuinely new routed reset link still works after logout.
    router.go('/loginPage?type=recovery&refresh_token=synthetic-new-recovery');
    // Re-enter to mount the production login widget for the new callback.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: FFAppState(),
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ));
    for (var tick = 0; tick < 20; tick++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pumpAndSettle();
    expect(find.text('verified-recovery-only'), findsOneWidget);
    expect(app.unlock.recoveryAllowed, isTrue);
    expect(app.unlock.ownerUnlocked, isFalse);
    expect(tokenRequests, ['synthetic-new-recovery']);
    expect(tester.takeException(), isNull);

    await tester.pump(const Duration(milliseconds: 300));
    await authManager.signOut();
    router.go('/loginPage');
    await tester.pumpAndSettle();
    expect(find.byType(LoginPageWidget), findsOneWidget);
    links.events.add(Uri.parse(
        'decoywallet://loginPage?type=recovery&refresh_token=synthetic-new-recovery-warm'));
    for (var tick = 0; tick < 20; tick++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pumpAndSettle();
    expect(find.text('verified-recovery-only'), findsOneWidget);
    expect(app.unlock.recoveryAllowed, isTrue);
    expect(app.unlock.ownerUnlocked, isFalse);
    expect(tokenRequests,
        ['synthetic-new-recovery', 'synthetic-new-recovery-warm']);

    // Genuine failures on newly opened links must not be hidden by this fix.
    await authManager.signOut();
    router.go('/loginPage');
    await tester.pumpAndSettle();
    links.events.add(Uri.parse(
        'decoywallet://loginPage?type=recovery&refresh_token=synthetic-new-invalid'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginPageWidget), findsOneWidget);
    expect(find.text('Error: Invalid Refresh Token: Refresh Token Not Found'),
        findsOneWidget);
    expect(Supabase.instance.client.auth.currentSession, isNull);
    expect(app.unlock.recoveryAllowed, isFalse);
    expect(app.unlock.ownerUnlocked, isFalse);
    expect(tokenRequests.last, 'synthetic-new-invalid');
    expect(links.initialReads, 0);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await authManager.signOut();
    await tester.pumpAndSettle();
  });
}
