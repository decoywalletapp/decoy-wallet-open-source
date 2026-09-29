import 'dart:io';
import 'dart:ui' as ui;

import 'package:decoy_wallet_app/app_state.dart';
import 'package:decoy_wallet_app/auth/supabase_auth/supabase_user_provider.dart';
import 'package:decoy_wallet_app/custom_code/widgets/verify_any_link.dart';
import 'package:decoy_wallet_app/flutter_flow/nav/nav.dart';
import 'package:decoy_wallet_app/l10n/app_language_controller.dart';
import 'package:decoy_wallet_app/l10n/app_localizations.dart';
import 'package:decoy_wallet_app/welcom_pages/confirm_email_page/confirm_email_page_widget.dart';
import 'package:decoy_wallet_app/welcom_pages/login_page/login_page_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'localization_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  var authRequests = 0;

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await loadLocalizationFonts();
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://test.invalid',
      anonKey: 'test-key',
      debug: false,
      httpClient: MockClient((request) async {
        authRequests++;
        throw StateError('Navigation must not make an authentication request');
      }),
      authOptions: const FlutterAuthClientOptions(
        autoRefreshToken: false,
        detectSessionInUri: false,
        localStorage: EmptyLocalStorage(),
      ),
    );
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    for (final channel in [
      'com.llfbandit.app_links/messages',
      'com.llfbandit.app_links/events',
    ]) {
      messenger.setMockMethodCallHandler(
          MethodChannel(channel), (call) async => null);
    }
  });
  tearDownAll(() => Supabase.instance.dispose());

  setUp(() async {
    authRequests = 0;
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    FFAppState.reset();
    await FFAppState().initializePersistedState();
    currentUser = DecoyWalletAppSupabaseUser(null);
    AppStateNotifier.instance.user = currentUser;
    AppStateNotifier.instance.showSplashImage = false;
    AppStateNotifier.instance.clearRedirectLocation();
  });

  for (final locale in AppLanguageController.supportedLanguageCodes) {
    for (final size in [
      const Size(320, 640),
      const Size(402, 874),
      const Size(768, 1024),
    ]) {
      testWidgets(
          'confirmation login is readable and navigation-only: $locale $size',
          (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final language = AppLanguageController();
        await language.initialize();
        await language.setLanguage(locale);
        addTearDown(language.dispose);
        final boundaryKey = GlobalKey();
        final router = GoRouter(
          initialLocation: ConfirmEmailPageWidget.routePath,
          routes: [
            FFRoute(
              name: ConfirmEmailPageWidget.routeName,
              path: ConfirmEmailPageWidget.routePath,
              builder: (_, __) => RepaintBoundary(
                key: boundaryKey,
                child: const ConfirmEmailPageWidget(
                    emailEntry: 'confirmation-test@example.invalid'),
              ),
            ).toRoute(AppStateNotifier.instance),
            FFRoute(
              name: LoginPageWidget.routeName,
              path: LoginPageWidget.routePath,
              builder: (_, __) => const LoginPageWidget(),
            ).toRoute(AppStateNotifier.instance),
          ],
        );
        addTearDown(router.dispose);
        await tester.pumpWidget(MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: FFAppState()),
            ChangeNotifierProvider.value(value: language),
          ],
          child: MaterialApp.router(
            theme: ThemeData(
              useMaterial3: false,
              platform: TargetPlatform.iOS,
              fontFamily: 'robot',
              fontFamilyFallback: decoyFontFallbacks(Locale(locale)),
            ),
            locale: Locale(locale),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ));
        await tester.pumpAndSettle();
        final strings = AppLocalizations.of(
            tester.element(find.byType(ConfirmEmailPageWidget)))!;
        expect(find.text(strings.msgAlreadyConfirmedYourEmail), findsOneWidget);
        expect(find.byType(VerifyAnyLink), findsOneWidget);
        final button = find.byKey(const ValueKey('confirmed-email-login'));
        await tester.ensureVisible(button);
        await tester.pumpAndSettle();
        final buttonBounds = tester.getRect(button);
        expect(buttonBounds.left, greaterThanOrEqualTo(0));
        expect(buttonBounds.right, lessThanOrEqualTo(size.width));
        expect(buttonBounds.bottom, lessThanOrEqualTo(size.height));
        final paragraph = tester.renderObject<RenderParagraph>(
            find.text(strings.msgAlreadyConfirmedYourEmail));
        expect(paragraph.didExceedMaxLines, isFalse);
        final instructions = tester
            .getRect(find.text(strings.msgClickTheLinkInTheEmailToConfirm));
        final prompt =
            tester.getRect(find.text(strings.msgAlreadyConfirmedYourEmail));
        expect(prompt.top, greaterThan(instructions.bottom));
        expect(buttonBounds.top, greaterThan(prompt.bottom));
        expect(authRequests, 0);
        expect(Supabase.instance.client.auth.currentSession, isNull);
        expect(tester.takeException(), isNull);

        if (const bool.fromEnvironment('DECOY_CAPTURE_CONFIRMATION') &&
            ['en', 'de', 'ar', 'ja'].contains(locale) &&
            size.width <= 402) {
          final boundary = boundaryKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
          await tester.runAsync(() async {
            final image = await boundary.toImage();
            final bytes =
                await image.toByteData(format: ui.ImageByteFormat.png);
            final directory = Directory('/private/tmp/decoy-confirmation-ui');
            await directory.create(recursive: true);
            await File('${directory.path}/$locale-${size.width.toInt()}.png')
                .writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }

        await tester.tap(button);
        await tester.pumpAndSettle();
        expect(router.routeInformationProvider.value.uri.path,
            LoginPageWidget.routePath);
        expect(find.byType(LoginPageWidget), findsOneWidget);
        expect(find.byType(ConfirmEmailPageWidget), findsNothing);
        expect(authRequests, 0);
        expect(Supabase.instance.client.auth.currentSession, isNull);
        expect(AppStateNotifier.instance.loggedIn, isFalse);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      });
    }
  }
}
