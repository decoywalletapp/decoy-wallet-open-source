import 'dart:async';
import 'dart:convert';

import 'package:app_links/app_links.dart';
import 'package:app_links_platform_interface/app_links_platform_interface.dart';
import 'package:decoy_wallet_app/app_state.dart';
import 'package:decoy_wallet_app/auth/supabase_auth/supabase_user_provider.dart';
import 'package:decoy_wallet_app/backend/public_config.dart';
import 'package:decoy_wallet_app/backend/supabase/supabase.dart';
import 'package:decoy_wallet_app/custom_code/actions/refresh_supabase_session2.dart';
import 'package:decoy_wallet_app/custom_code/actions/supa_exchange_deep_link_for_session.dart';
import 'package:decoy_wallet_app/custom_code/actions/supa_recovery_update_password.dart';
import 'package:decoy_wallet_app/custom_code/actions/supa_send_reset_password_email.dart';
import 'package:decoy_wallet_app/custom_code/widgets/verify_any_link.dart';
import 'package:decoy_wallet_app/flutter_flow/nav/nav.dart';
import 'package:decoy_wallet_app/l10n/app_language_controller.dart';
import 'package:decoy_wallet_app/l10n/app_localizations.dart';
import 'package:decoy_wallet_app/main.dart';
import 'package:decoy_wallet_app/welcom_pages/login_page/login_page_widget.dart';
import 'package:decoy_wallet_app/welcom_pages/update_password_page/update_password_page_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_link_service_test.dart' show linkSession;
import 'localization_fonts.dart';

class _Links extends AppLinksPlatform {
  final events = StreamController<Uri>.broadcast();
  Uri? initial;
  @override
  Future<Uri?> getInitialLink() async => initial;
  @override
  Stream<Uri> get uriLinkStream => events.stream;
}

void main() {
  if (kSupabaseUrl != 'https://test.invalid' ||
      kSupabaseAnonKey != 'synthetic-anon') {
    test('production link entrypoints require isolated configuration', () {},
        skip: 'Run with test.invalid and synthetic-anon dart-defines.');
    return;
  }
  TestWidgetsFlutterBinding.ensureInitialized();
  final app = AppStateNotifier.instance;
  final links = _Links();
  final calls = <String>[];
  var target = 'recipient';
  var sequence = 0;
  late MockClient client;
  StreamSubscription<Uri>? platformListener;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    await FFAppState().initializePersistedState();
    await loadLocalizationFonts();
    GoogleFonts.config.allowRuntimeFetching = false;
    AppLinksPlatform.instance = links;
    client = MockClient((request) async {
      expect(request.url.host, 'test.invalid');
      calls.add('${request.method} ${request.url.path}');
      if (request.url.path == '/auth/v1/logout') return http.Response('', 204);
      if (request.url.path == '/auth/v1/recover') {
        expect(jsonDecode(request.body)['email'], 'recipient@example.invalid');
        return http.Response('{}', 200);
      }
      if (request.url.path == '/auth/v1/user' && request.method == 'GET') {
        return http.Response(jsonEncode(linkSession(target)['user']), 200);
      }
      if (request.url.path == '/auth/v1/token' ||
          request.url.path == '/auth/v1/verify') {
        return http.Response(jsonEncode(linkSession(target)), 200);
      }
      throw StateError(
          'Unexpected synthetic request: ${request.method} ${request.url.path}');
    });
    // Exercise the actual production initialization, not a test copy of its options.
    await SupaFlow.initialize(httpClient: client);
    // The production root keeps this stream subscribed across screen changes.
    platformListener = AppLinks().uriLinkStream.listen((_) {});
  });

  setUp(() async {
    target = 'recipient';
    links.initial = null;
    sequence++;
    SupaFlow.configureAuthLinks(
        url: 'https://test.invalid',
        anonKey: 'synthetic-anon',
        clientFactory: () => client);
    await SupaFlow.client.auth
        .setInitialSession(jsonEncode(linkSession('recipient')));
    app.update(DecoyWalletAppSupabaseUser(SupaFlow.client.auth.currentUser));
    app.unlock.lock();
    app.clearRedirectLocation();
    app.stopShowingSplashImage();
    calls.clear();
  });
  tearDownAll(() async {
    await Supabase.instance.dispose();
    await platformListener?.cancel();
    await links.events.close();
  });

  test('production SDK listener cannot adopt an implicit link by itself',
      () async {
    target = 'other';
    final original = SupaFlow.client.auth.currentSession;
    final payload = linkSession(target);
    links.events.add(Uri(
        scheme: 'decoywallet',
        host: 'loginPage',
        fragment: Uri(queryParameters: {
          'access_token': payload['access_token'] as String,
          'refresh_token': payload['refresh_token'] as String,
          'token_type': 'bearer',
          'expires_in': '7200',
          'type': 'recovery',
        }).query));
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(calls, isEmpty);
    expect(SupaFlow.client.auth.currentSession, same(original));
  });

  for (final helper in [
    'recovery router',
    'token hash action',
    'password action'
  ]) {
    test('$helper rejects a different account before changing shared auth',
        () async {
      target = 'other';
      final original = SupaFlow.client.auth.currentSession;
      final ok = switch (helper) {
        'recovery router' => await refreshSupabaseSession2(
            'synthetic-access', 'synthetic-refresh'),
        'token hash action' => await supaExchangeDeepLinkForSession(
            '/loginPage?type=recovery&token_hash=synthetic-hash'),
        _ => (await supaRecoveryUpdatePassword('synthetic-access',
            'synthetic-refresh', 'synthetic-password'))['ok'],
      };
      expect(ok, isFalse);
      expect(SupaFlow.client.auth.currentSession, same(original));
      expect(calls.where((value) => value.startsWith('PUT')), isEmpty);
    });
  }

  test('recovery helper still accepts the same account', () async {
    expect(
        await refreshSupabaseSession2('synthetic-access', 'synthetic-refresh'),
        isTrue);
    expect(SupaFlow.client.auth.currentUser!.id, 'recipient');
    expect(calls, ['POST /auth/v1/token', 'GET /auth/v1/user']);
    expect(app.unlock.ownerUnlocked, isFalse);
  });

  for (final encoding in ['query', 'fragment', 'conflict']) {
    for (final entry in ['routed', 'platform launch', 'platform stream']) {
      testWidgets('$entry $encoding rejects a different account',
          (tester) async {
        target = 'other';
        final original = SupaFlow.client.auth.currentSession;
        final payload = switch (encoding) {
          'query' => '?type=recovery&tokenHash=synthetic-$sequence',
          'fragment' => '#?type=recovery&refreshToken=synthetic-$sequence',
          _ => '?type=recovery&tokenHash=one#token_hash=two',
        };
        final uri = Uri.parse('/loginPage$payload');
        if (entry == 'platform launch') links.initial = uri;
        final router = GoRouter(
          initialLocation: entry == 'routed' ? uri.toString() : '/loginPage',
          routes: [
            GoRoute(
                path: '/loginPage',
                builder: (_, state) =>
                    Scaffold(body: VerifyAnyLink(routedUri: state.uri))),
            GoRoute(
                name: 'UpdatePasswordPage',
                path: '/updatePasswordPage',
                builder: (_, __) => const Text('unexpected recovery')),
          ],
        );
        await tester.pumpWidget(MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales));
        await tester.pumpAndSettle();
        if (entry == 'platform stream') {
          await tester.runAsync(() async {
            links.events.add(uri);
            await Future<void>.delayed(Duration.zero);
          });
          await tester.pumpAndSettle();
        }
        expect(SupaFlow.client.auth.currentSession, same(original));
        expect(find.text('unexpected recovery'), findsNothing);
        expect(app.unlock.recoveryAllowed, isFalse);
        expect(app.unlock.ownerUnlocked, isFalse);
        expect(find.byType(SnackBar), findsOneWidget);
        expect(calls, encoding == 'conflict' ? isEmpty : hasLength(1));
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        router.dispose();
      });
    }
  }

  testWidgets('a newer callback reuses one recipient confirmation',
      (tester) async {
    await tester.runAsync(() => SupaFlow.client.auth.signOut());
    app.update(DecoyWalletAppSupabaseUser(null));
    calls.clear();
    final router = GoRouter(
        initialLocation: '/loginPage?type=recovery&token_hash=first-prompt',
        routes: [
          GoRoute(
              path: '/loginPage',
              builder: (_, state) =>
                  Scaffold(body: VerifyAnyLink(routedUri: state.uri))),
          GoRoute(
              name: 'UpdatePasswordPage',
              path: '/updatePasswordPage',
              builder: (_, __) => const Text('confirmed recovery')),
        ]);
    await tester.pumpWidget(MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('auth-link-email')), findsOneWidget);
    router.go('/loginPage?type=recovery&token_hash=second-prompt');
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('auth-link-email'), skipOffstage: false),
        findsOneWidget);
    expect(calls, isEmpty);
    await tester.enterText(find.byKey(const ValueKey('auth-link-email')),
        'recipient@example.invalid');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('confirmed recovery'), findsOneWidget);
    expect(find.byType(AlertDialog, skipOffstage: false), findsNothing);
    expect(calls, ['POST /auth/v1/verify']);
    expect(SupaFlow.client.auth.currentUser!.id, 'recipient');
    expect(app.unlock.ownerUnlocked, isFalse);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
  });

  for (final localRequest in [false, true]) {
    for (final delivery in [
      'plugin only',
      'platform only',
      'plugin then platform',
      'platform then plugin',
      'plugin prompt then platform',
    ]) {
      testWidgets(
          'browser recovery from retained login: $delivery, local request $localRequest',
          (tester) async {
        final language = AppLanguageController();
        await tester.runAsync(() async {
          await SupaFlow.client.auth.signOut();
          await language.initialize();
        });
        app.update(DecoyWalletAppSupabaseUser(null));
        tester.view.physicalSize = const Size(1200, 2400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(MultiProvider(providers: [
          ChangeNotifierProvider.value(value: language),
          ChangeNotifierProvider.value(value: FFAppState()),
        ], child: MyApp()));
        await tester.pumpAndSettle(const Duration(milliseconds: 100));
        final router =
            GoRouter.of(tester.element(find.byType(LoginPageWidget)));
        unawaited(router.push('/forgotPasswordPage'));
        await tester.pumpAndSettle();
        expect(VerifyAnyLink.hasListener, isTrue);
        calls.clear();
        if (localRequest) {
          expect(
              await supaSendResetPasswordEmail(
                  'recipient@example.invalid', 'https://test.invalid/verify'),
              'ok');
          expect(calls, ['POST /auth/v1/recover']);
          calls.clear();
        }
        final payload = linkSession('recipient');
        final uri = Uri(
          scheme: 'decoywalletapp',
          host: 'authRouter',
          queryParameters: {
            'type': 'recovery',
            'accessToken': payload['access_token'] as String,
            'refreshToken': 'browser-$sequence',
          },
        );
        Future<void> plugin() => tester.runAsync(() async {
              links.events.add(uri);
              await Future<void>.delayed(Duration.zero);
            });
        Future<void> platform() async {
          await tester.binding.handlePushRoute(uri.toString());
        }

        switch (delivery) {
          case 'plugin only':
            await plugin();
          case 'platform only':
            await platform();
          case 'plugin then platform':
            await plugin();
            await platform();
          case 'platform then plugin':
            await platform();
            await plugin();
          case 'plugin prompt then platform':
            await plugin();
            await tester.pumpAndSettle();
            expect(find.byKey(const ValueKey('auth-link-email')),
                localRequest ? findsNothing : findsOneWidget);
            await platform();
        }
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('auth-link-email')),
            localRequest ? findsNothing : findsOneWidget,
            reason:
                'Only a locally requested recovery can reuse intended email.');
        if (!localRequest) {
          expect(calls, isEmpty);
          await tester.enterText(find.byKey(const ValueKey('auth-link-email')),
              'recipient@example.invalid');
          await tester.tap(find.text('Continue'));
          await tester.pumpAndSettle();
        }
        expect(find.byType(UpdatePasswordPageWidget), findsOneWidget);
        expect(app.unlock.recoveryAllowed, isTrue);
        expect(app.unlock.ownerUnlocked, isFalse);
        expect(calls, ['POST /auth/v1/token', 'GET /auth/v1/user']);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 1));
        router.dispose();
        language.dispose();
      });
    }
  }

  testWidgets('root listener routes a fresh link from a page with no receiver',
      (tester) async {
    final language = AppLanguageController();
    await tester.runAsync(() async {
      await SupaFlow.client.auth.signOut();
      await language.initialize();
    });
    app.update(DecoyWalletAppSupabaseUser(null));
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MultiProvider(providers: [
      ChangeNotifierProvider.value(value: language),
      ChangeNotifierProvider.value(value: FFAppState()),
    ], child: MyApp()));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.byType(LoginPageWidget), findsOneWidget);
    final router = GoRouter.of(tester.element(find.byType(LoginPageWidget)));
    router.go('/forgotPasswordPage');
    await tester.pumpAndSettle();
    expect(VerifyAnyLink.hasListener, isFalse);
    calls.clear();
    await tester.runAsync(() async {
      links.events.add(Uri.parse(
          'decoywallet://authRouter?type=recovery&token_hash=fresh-root'));
      await Future<void>.delayed(Duration.zero);
    });
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('auth-link-email')), findsOneWidget);
    expect(calls, isEmpty,
        reason: 'No exchange before recipient confirmation.');
    await tester.enterText(find.byKey(const ValueKey('auth-link-email')),
        'recipient@example.invalid');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(
        router.routeInformationProvider.value.uri.path, '/updatePasswordPage');
    expect(app.unlock.recoveryAllowed, isTrue);
    expect(app.unlock.ownerUnlocked, isFalse);
    expect(calls, ['POST /auth/v1/verify']);
    final recoveryForm = tester.state(find.byType(UpdatePasswordPageWidget));
    for (final duplicate in [
      '/authRouter?type=recovery&token_hash=fresh-root',
      '/loginPage#type=recovery&tokenHash=fresh-root',
    ]) {
      router.go(duplicate);
      await tester.pumpAndSettle();
      // A redirect to the current page can leave the incoming URL in the
      // provider. Check the resolved route and retained form, not that input.
      expect(router.routerDelegate.currentConfiguration.uri.path,
          '/updatePasswordPage');
      expect(tester.state(find.byType(UpdatePasswordPageWidget)),
          same(recoveryForm));
      expect(app.unlock.recoveryAllowed, isTrue);
      expect(app.unlock.ownerUnlocked, isFalse);
      expect(calls, ['POST /auth/v1/verify'],
          reason:
              'Duplicate delivery must not discard recovery or exchange again.');
    }
    // A later callback also has to cross the boundary while recovery is open.
    final original = SupaFlow.client.auth.currentSession;
    target = 'other';
    await tester.runAsync(() async {
      links.events.add(Uri.parse(
          'decoywallet://authRouter?type=recovery&token_hash=wrong-root'));
      await Future<void>.delayed(Duration.zero);
    });
    await tester.pumpAndSettle();
    expect(SupaFlow.client.auth.currentSession, same(original));
    expect(app.unlock.ownerUnlocked, isFalse);
    expect(app.unlock.recoveryAllowed, isFalse);
    expect(find.byType(SnackBar), findsOneWidget);
    target = 'recipient';
    await tester.runAsync(() async {
      links.events.add(Uri.parse(
          'decoywallet://authRouter?type=recovery&token_hash=next-root'));
      await Future<void>.delayed(Duration.zero);
    });
    await tester.pumpAndSettle();
    expect(
        router.routeInformationProvider.value.uri.path, '/updatePasswordPage');
    expect(app.unlock.recoveryAllowed, isTrue);
    expect(app.unlock.ownerUnlocked, isFalse);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
    router.dispose();
    language.dispose();
  });
}
