import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:decoy_wallet_app/app_state.dart';
import 'package:decoy_wallet_app/auth/supabase_auth/supabase_user_provider.dart';
import 'package:decoy_wallet_app/flutter_flow/flutter_flow_widgets.dart';
import 'package:decoy_wallet_app/flutter_flow/nav/nav.dart';
import 'package:decoy_wallet_app/home_pages/settings/settings_widget.dart';
import 'package:decoy_wallet_app/l10n/app_localizations.dart';
import 'package:decoy_wallet_app/welcom_pages/auth_router/auth_router_widget.dart';
import 'package:decoy_wallet_app/welcom_pages/update_password_page/update_password_page_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import 'localization_fonts.dart';

class _RecordingLauncher extends UrlLauncherPlatform {
  final urls = <String>[];

  @override
  get linkDelegate => null;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    urls.add(url);
    return true;
  }
}

Future<void> _capture(WidgetTester tester, GlobalKey key, String name) async {
  if (!const bool.fromEnvironment('DECOY_CAPTURE_UI_POLISH')) return;
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final directory = Directory('/private/tmp/decoy-ui-polish');
    await directory.create(recursive: true);
    await File('${directory.path}/$name.png')
        .writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final user = User(
    id: 'ui-polish-test-user',
    appMetadata: {},
    userMetadata: {},
    aud: 'authenticated',
    createdAt: '2026-09-29T00:00:00Z',
  );
  final passwordRequests = <Map<String, dynamic>>[];
  var rejectPassword = false;
  final client = MockClient((request) async {
    if (request.url.path == '/auth/v1/user' && request.method == 'PUT') {
      passwordRequests.add(jsonDecode(request.body) as Map<String, dynamic>);
      return http.Response(
        jsonEncode(rejectPassword
            ? {'msg': 'Password update rejected', 'code': 422}
            : user.toJson()),
        rejectPassword ? 422 : 200,
        headers: {'content-type': 'application/json'},
      );
    }
    if (request.url.path == '/auth/v1/token') {
      // Hold the real auth-router screen on its loading presentation.
      return Completer<http.Response>().future;
    }
    throw StateError(
        'Unexpected request: ${request.method} ${request.url.path}');
  });

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await loadLocalizationFonts();
    await (FontLoader('packages/font_awesome_flutter/FontAwesomeBrands')
          ..addFont(rootBundle.load(
              'packages/font_awesome_flutter/lib/fonts/fa-brands-400.ttf')))
        .load();
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://test.invalid',
      anonKey: 'test-key',
      httpClient: client,
      debug: false,
      authOptions: const FlutterAuthClientOptions(
        autoRefreshToken: false,
        detectSessionInUri: false,
        localStorage: EmptyLocalStorage(),
      ),
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
    currentUser = DecoyWalletAppSupabaseUser(user);
  });
  tearDownAll(() => Supabase.instance.dispose());

  setUp(() async {
    passwordRequests.clear();
    rejectPassword = false;
    FlutterSecureStorage.setMockInitialValues({});
    FFAppState.reset();
    await FFAppState().initializePersistedState();
    AppStateNotifier.instance.user = DecoyWalletAppSupabaseUser(user);
    AppStateNotifier.instance.showSplashImage = false;
    AppStateNotifier.instance.clearRedirectLocation();
  });

  Future<void> mount(WidgetTester tester, Widget child, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: FFAppState(),
      child: child,
    ));
    await tester.pumpAndSettle();
  }

  for (final width in [320.0, 402.0, 768.0]) {
    testWidgets(
        'GitHub tile matches social buttons and opens public repo at $width',
        (tester) async {
      final previous = UrlLauncherPlatform.instance;
      final launcher = _RecordingLauncher();
      UrlLauncherPlatform.instance = launcher;
      addTearDown(() => UrlLauncherPlatform.instance = previous);
      final boundary = GlobalKey();
      await mount(
          tester,
          MaterialApp(
            theme: ThemeData(useMaterial3: false, fontFamily: 'robot'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: RepaintBoundary(key: boundary, child: const SettingsWidget()),
          ),
          Size(width, 874));
      await tester.runAsync(() async {
        for (final asset in ['primallogo.png', 'rumble.jpg', 'xlogo.png']) {
          await precacheImage(AssetImage('assets/images/$asset'),
              tester.element(find.byType(SettingsWidget)));
        }
      });
      await tester.pumpAndSettle();
      final github = find.byTooltip('GitHub');
      await tester.ensureVisible(github);
      await tester.pumpAndSettle();
      final wrap = find.ancestor(of: github, matching: find.byType(Wrap));
      expect(wrap, findsOneWidget);
      expect(tester.widget<Wrap>(wrap).children, hasLength(6));
      for (final tooltip in ['GitHub', 'X']) {
        final tile = find.descendant(
            of: find.byTooltip(tooltip), matching: find.byType(InkWell));
        expect(tester.getSize(tile), const Size(48, 48));
        final bounds = tester.getRect(tile);
        expect(bounds.left, greaterThanOrEqualTo(0));
        expect(bounds.right, lessThanOrEqualTo(width));
      }
      await _capture(tester, boundary, 'settings-${width.toInt()}');
      await tester.tap(github);
      await tester.pump();
      expect(launcher.urls, [
        'https://github.com/decoywalletapp/decoy-wallet-open-source',
      ]);
      expect(tester.takeException(), isNull);
    });
  }

  Future<GoRouter> mountPassword(
      WidgetTester tester, GlobalKey boundary, TargetPlatform platform) async {
    final router = GoRouter(
      initialLocation: UpdatePasswordPageWidget.routePath,
      routes: [
        FFRoute(
          name: UpdatePasswordPageWidget.routeName,
          path: UpdatePasswordPageWidget.routePath,
          builder: (_, __) => const UpdatePasswordPageWidget(),
        ).toRoute(AppStateNotifier.instance),
        FFRoute(
          name: AuthRouterWidget.routeName,
          path: AuthRouterWidget.routePath,
          builder: (_, __) => const AuthRouterWidget(),
        ).toRoute(AppStateNotifier.instance),
      ],
    );
    addTearDown(router.dispose);
    await mount(
        tester,
        MaterialApp.router(
          theme: ThemeData(platform: platform, useMaterial3: false),
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (_, child) => RepaintBoundary(key: boundary, child: child!),
        ),
        const Size(402, 874));
    return router;
  }

  Future<void> submit(
      WidgetTester tester, String password, String confirm) async {
    await tester.enterText(find.byType(TextFormField).at(0), password);
    await tester.enterText(find.byType(TextFormField).at(1), confirm);
    await tester.ensureVisible(find.byType(FFButtonWidget));
    await tester.tap(find.byType(FFButtonWidget));
    await tester.pump();
    await tester.pump();
  }

  for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
    testWidgets('password handoff has no form/title overlap on $platform',
        (tester) async {
      final boundary = GlobalKey();
      final router = await mountPassword(tester, boundary, platform);
      await _capture(tester, boundary, 'password-before-${platform.name}');
      await submit(tester, 'test-password-2026', 'test-password-2026');
      expect(passwordRequests, hasLength(1));
      expect(passwordRequests.single['password'], 'test-password-2026');
      final passwordPage =
          find.byType(UpdatePasswordPageWidget, skipOffstage: false);
      expect(find.byType(AuthRouterWidget), findsNothing);
      expect(
          tester
              .widget<AnimatedOpacity>(
                  find.byKey(const ValueKey('password-auth-handoff')))
              .opacity,
          0);
      for (var frame = 0; frame < 15; frame++) {
        await tester.pump(const Duration(milliseconds: 20));
        if (find.byType(AuthRouterWidget).evaluate().isNotEmpty) {
          if (passwordPage.evaluate().isNotEmpty) {
            final fade = tester.widget<FadeTransition>(find
                .descendant(
                    of: find.byKey(const ValueKey('password-auth-handoff'),
                        skipOffstage: false),
                    matching: find.byType(FadeTransition, skipOffstage: false))
                .first);
            expect(fade.opacity.value, 0,
                reason:
                    'Outgoing form must be invisible before the next title');
          }
          final scaffold = tester.widget<Scaffold>(find.descendant(
              of: find.byType(AuthRouterWidget),
              matching: find.byType(Scaffold)));
          expect(scaffold.backgroundColor, Colors.white);
        }
        if (frame == 3 || frame == 10) {
          await _capture(
              tester, boundary, 'password-${platform.name}-frame-$frame');
        }
        expect(tester.takeException(), isNull);
      }
      expect(router.routeInformationProvider.value.uri.path,
          AuthRouterWidget.routePath);
      expect(find.byType(UpdatePasswordPageWidget), findsNothing);
      final transition = router.routerDelegate.currentConfiguration.extra
          as Map<String, dynamic>;
      final info = transition[kTransitionInfoKey] as TransitionInfo;
      expect(info.hasTransition, isTrue);
      expect(info.duration, const Duration(milliseconds: 1));
      expect(passwordRequests, hasLength(1));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  }

  for (final scenario in ['mismatch', 'short', 'server rejection']) {
    testWidgets('password $scenario keeps the existing form and validation',
        (tester) async {
      final router =
          await mountPassword(tester, GlobalKey(), TargetPlatform.iOS);
      rejectPassword = scenario == 'server rejection';
      final password = scenario == 'short' ? 'short' : 'test-password-2026';
      await submit(tester, password,
          scenario == 'mismatch' ? 'different-password' : password);
      await tester.pump(const Duration(milliseconds: 300));
      expect(router.routeInformationProvider.value.uri.path,
          UpdatePasswordPageWidget.routePath);
      expect(find.byType(AuthRouterWidget), findsNothing);
      expect(
          tester
              .widget<AnimatedOpacity>(
                  find.byKey(const ValueKey('password-auth-handoff')))
              .opacity,
          1);
      expect(passwordRequests, hasLength(rejectPassword ? 1 : 0));
      final strings = AppLocalizations.of(
          tester.element(find.byType(UpdatePasswordPageWidget)))!;
      final error = switch (scenario) {
        'mismatch' => strings.msgPasswordsDoNotMatch,
        'short' => strings.msgInvalidPasswordMustBeAtLeast10Characters,
        _ => strings.msgPasswordUpdateFailedTryADifferentPassword,
      };
      expect(find.text(error), findsOneWidget);
      expect(
          tester
              .widget<TextFormField>(find.byType(TextFormField).first)
              .controller!
              .text,
          password);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('disposing during the visual handoff does not navigate again',
      (tester) async {
    await mountPassword(tester, GlobalKey(), TargetPlatform.iOS);
    await submit(tester, 'test-password-2026', 'test-password-2026');
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 300));
    expect(passwordRequests, hasLength(1));
    expect(tester.takeException(), isNull);
  });
}
