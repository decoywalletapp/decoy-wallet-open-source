import 'dart:async';
import 'dart:convert';
import 'package:decoy_wallet_app/app_state.dart';
import 'package:decoy_wallet_app/l10n/app_localizations.dart';
import 'package:decoy_wallet_app/auth/supabase_auth/supabase_user_provider.dart';
import 'package:decoy_wallet_app/auth/supabase_auth/auth_util.dart';
import 'package:decoy_wallet_app/flutter_flow/nav/nav.dart';
import 'package:decoy_wallet_app/custom_code/widgets/verify_any_link.dart';
import 'package:decoy_wallet_app/welcom_pages/login_page/login_page_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final app = AppStateNotifier.instance;
  Completer<void>? responseGate;
  var requests = 0;
  String part(Object value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final token = '${part({'alg': 'HS256'})}.${part({
        'sub': 'synthetic-owner',
        'exp': now + 7200,
        'iat': now
      })}.synthetic';
  final response = jsonEncode({
    'access_token': token,
    'refresh_token': 'synthetic-refresh',
    'token_type': 'bearer',
    'expires_in': 7200,
    'user': {
      'id': 'synthetic-owner',
      'aud': 'authenticated',
      'email': 'owner@example.invalid',
      'app_metadata': {},
      'user_metadata': {},
      'created_at': '2026-01-01T00:00:00Z'
    }
  });
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    await FFAppState().initializePersistedState();
    GoogleFonts.config.allowRuntimeFetching = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('com.llfbandit.app_links/messages'),
            (_) async => null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('com.llfbandit.app_links/events'),
            (_) async => null);
    await Supabase.initialize(
        url: 'https://synthetic.invalid',
        anonKey: 'synthetic-anon',
        debug: false,
        authOptions: const FlutterAuthClientOptions(
            authFlowType: AuthFlowType.implicit,
            autoRefreshToken: false,
            detectSessionInUri: false,
            localStorage: EmptyLocalStorage()),
        httpClient: MockClient((request) async {
          if (request.url.host != 'synthetic.invalid')
            throw StateError('unexpected host');
          requests++;
          if (responseGate != null) await responseGate!.future;
          return http.Response(response, 200,
              headers: {'content-type': 'application/json'});
        }));
    await Supabase.instance.client.auth
        .setSession('synthetic-retained-session');
  });
  tearDownAll(() async => Supabase.instance.dispose());

  test('query and fragment payload detection grants no unlock', () {
    app.unlock.lock();
    for (final uri in [
      '/loginPage#type=recovery&refresh_token=synthetic',
      '/loginPage?type=recovery&refreshToken=synthetic',
      '/loginPage#?type=recovery&token_hash=synthetic',
    ]) {
      expect(VerifyAnyLink.hasAuthPayload(Uri.parse(uri)), isTrue);
    }
    expect(VerifyAnyLink.hasAuthPayload(Uri.parse('/loginPage?type=recovery')),
        isFalse);
    expect(app.unlock.ownerUnlocked, isFalse);
    expect(app.unlock.recoveryAllowed, isFalse);
  });

  testWidgets(
      'real login waits for delayed fragment recovery and grants only recovery access',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    currentUser =
        DecoyWalletAppSupabaseUser(Supabase.instance.client.auth.currentUser);
    app.update(currentUser!);
    app.unlock.lock();
    app.clearRedirectLocation();
    app.stopShowingSplashImage();
    requests = 0;
    responseGate = Completer<void>();
    final router = GoRouter(
        initialLocation:
            '/loginPage#type=recovery&refresh_token=synthetic-delayed-reset',
        refreshListenable: app,
        routes: [
          FFRoute(
              name: 'LoginPage',
              path: '/loginPage',
              builder: (_, __) => const LoginPageWidget()).toRoute(app),
          FFRoute(
                  name: 'AuthRouter',
                  path: '/authRouter',
                  builder: (_, __) => const Text('premature-auth-router'))
              .toRoute(app),
          FFRoute(
                  name: 'UpdatePasswordPage',
                  path: '/updatePasswordPage',
                  builder: (_, __) => const Text('verified-password-recovery'))
              .toRoute(app),
        ]);
    await tester.pumpWidget(ChangeNotifierProvider.value(
        value: FFAppState(), child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(requests, 1);
    expect(find.text('premature-auth-router'), findsNothing);
    expect(find.byType(LoginPageWidget), findsOneWidget);
    expect(app.unlock.recoveryAllowed, isFalse);
    responseGate!.complete();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.text('verified-password-recovery'), findsOneWidget);
    expect(app.unlock.recoveryAllowed, isTrue);
    expect(app.unlock.ownerUnlocked, isFalse);
    responseGate = null;
    await tester.pumpWidget(const SizedBox());
    router.dispose();
  });

  testWidgets('logout discards a platform launch lookup already in progress',
      (tester) async {
    final initialLink = Completer<String?>();
    var initialReads = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('com.llfbandit.app_links/messages'),
            (call) async {
      if (call.method == 'getInitialLink') {
        initialReads++;
        return initialLink.future;
      }
      return null;
    });
    app.unlock.lock();
    app.clearRedirectLocation();
    app.update(DecoyWalletAppSupabaseUser(
        Supabase.instance.client.auth.currentUser));
    app.stopShowingSplashImage();
    final router = GoRouter(
      initialLocation: '/loginPage',
      refreshListenable: app,
      routes: [
        FFRoute(name: 'LoginPage', path: '/loginPage',
            builder: (_, __) => const LoginPageWidget()).toRoute(app),
        FFRoute(name: 'AuthRouter', path: '/authRouter',
            builder: (_, __) => const Text('unexpected-auth-router')).toRoute(app),
        FFRoute(name: 'UpdatePasswordPage', path: '/updatePasswordPage',
            builder: (_, __) => const Text('unexpected-recovery')).toRoute(app),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: FFAppState(),
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ));
    await tester.pumpAndSettle();
    expect(initialReads, 1);
    final loginState = tester.state(find.byType(LoginPageWidget));
    await tester.runAsync(() async => authManager.signOut());
    currentUser = DecoyWalletAppSupabaseUser(null);
    app.update(currentUser!);
    requests = 0;
    initialLink.complete(
        'decoywallet://loginPage?type=recovery&refresh_token=synthetic-stale-late');
    for (var tick = 0; tick < 20; tick++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pumpAndSettle();
    expect(tester.state(find.byType(LoginPageWidget)), same(loginState));
    expect(requests, 0);
    expect(Supabase.instance.client.auth.currentSession, isNull);
    expect(app.unlock.recoveryAllowed, isFalse);
    expect(app.unlock.ownerUnlocked, isFalse);
    expect(find.byType(SnackBar), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
