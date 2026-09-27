import 'dart:io';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:decoy_wallet_app/app_state.dart';
import 'package:decoy_wallet_app/components/auth_wallet_heading.dart';
import 'package:decoy_wallet_app/emergancy_contact_information/create_decoy_emergency_contacts_setup/create_decoy_emergency_contacts_setup_widget.dart';
import 'package:decoy_wallet_app/duress_mode/duress_settings_page/duress_settings_page_widget.dart';
import 'package:decoy_wallet_app/duress_mode/wallet_feature_preview/wallet_feature_preview_widget.dart';
import 'package:decoy_wallet_app/home_pages/settings/settings_widget.dart';
import 'package:decoy_wallet_app/settings_pages/control_center/control_center_widget.dart';
import 'package:decoy_wallet_app/pin_pages/decoy_pin_acknowledgements/decoy_pin_acknowledgements_widget.dart';
import 'package:decoy_wallet_app/create_decoy_seed/decoy_seed_acknowledgements/decoy_seed_acknowledgements_widget.dart';
import 'package:decoy_wallet_app/emergancy_contact_information/personal_information/personal_information_widget.dart';
import 'package:decoy_wallet_app/emergancy_contact_information/emergency_contacts/emergency_contacts_widget.dart';
import 'package:decoy_wallet_app/l10n/app_language_controller.dart';
import 'package:decoy_wallet_app/l10n/app_localizations.dart';
import 'package:decoy_wallet_app/settings_pages/configure_bitcoin_balance/configure_bitcoin_balance_widget.dart';
import 'package:decoy_wallet_app/welcom_pages/create_account/create_account_widget.dart';
import 'package:decoy_wallet_app/welcom_pages/login_page/login_page_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'localization_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final client = MockClient((request) async {
    if (request.url.path.endsWith('/getConsentStatuses')) {
      return http.Response('{"slot1Status":"confirmed"}', 200,
          request: request, headers: {'content-type': 'application/json'});
    }
    return http.Response(
        jsonEncode(request.url.path.endsWith('/decoy_wallet')
            ? [
                {
                  'personal_complete': false,
                  'contacts_complete': true,
                  'address_complete': false,
                  'decoy_seed_armed': false,
                  'decoy_pin_911_enabled': false,
                  'decoy_pin_contacts_enabled': false,
                  'use_current_location': false,
                }
              ]
            : []),
        200,
        request: request,
        headers: {'content-type': 'application/json'});
  });

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await loadLocalizationFonts();
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
  });
  setUp(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/local_auth'), (call) async {
      if (call.method == 'getAvailableBiometrics') return <String>[];
      return false;
    });
    messenger.setMockMethodCallHandler(
        const MethodChannel('flutter.baseflow.com/permissions/methods'),
        (call) async => 0);
    messenger.setMockMethodCallHandler(
        const MethodChannel('flutter.baseflow.com/geolocator'),
        (call) async => call.method == 'isLocationServiceEnabled' ? false : 0);
    messenger.setMockMethodCallHandler(
        const MethodChannel('com.llfbandit.app_links/messages'),
        (call) async => null);
    messenger.setMockMethodCallHandler(
        const MethodChannel('com.llfbandit.app_links/events'),
        (call) async => null);
  });
  tearDownAll(() => Supabase.instance.dispose());

  final pages = <String, Widget>{
    'login': const LoginPageWidget(),
    'create-account': const CreateAccountWidget(),
    'settings': const SettingsWidget(),
    'balance': const ConfigureBitcoinBalanceWidget(),
    'wallet-settings': const DuressSettingsPageWidget(),
    'recurring-buy': const WalletFeaturePreviewWidget(feature: 'recurring-buy'),
    'pin-acknowledgements': const DecoyPinAcknowledgementsWidget(),
    'seed-acknowledgements': const DecoySeedAcknowledgementsWidget(),
    if (const String.fromEnvironment('DECOY_SUPABASE_URL') ==
        'https://test.invalid') ...{
      'emergency-setup': const CreateDecoyEmergencyContactsSetupWidget(),
      'control-center': const ControlCenterWidget(),
      'personal-information': const PersonalInformationWidget(),
      'emergency-contacts': const EmergencyContactsWidget(),
    },
  };
  for (final locale in AppLanguageController.supportedLanguageCodes) {
    for (final size in [
      const Size(320, 640),
      const Size(402, 874),
      const Size(768, 1024)
    ]) {
      for (final page in pages.entries) {
        testWidgets('${page.key} $locale at $size has no overflow',
            (tester) async {
          await http.runWithClient(() async {
            tester.view.physicalSize = size;
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            SharedPreferences.setMockInitialValues({});
            FlutterSecureStorage.setMockInitialValues({});
            FFAppState.reset();
            await FFAppState().initializePersistedState();
            FFAppState().fakeBtcBalance = 0.12;
            FFAppState().currentBtcPrice = 80000;
            final language = AppLanguageController();
            await language.initialize();
            await language.setLanguage(locale);
            final boundaryKey = GlobalKey();
            await tester.pumpWidget(MultiProvider(
              providers: [
                ChangeNotifierProvider.value(value: FFAppState()),
                ChangeNotifierProvider.value(value: language),
              ],
              child: MaterialApp(
                theme: ThemeData(
                    useMaterial3: false,
                    fontFamily: 'robot',
                    fontFamilyFallback: decoyFontFallbacks(Locale(locale))),
                locale: Locale(locale),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: RepaintBoundary(key: boundaryKey, child: page.value),
              ),
            ));
            await tester.pumpAndSettle();
            expect(
                Localizations.localeOf(
                        tester.element(find.byType(Scaffold).first))
                    .languageCode,
                locale);
            if (page.key == 'settings') {
              final block = find.byKey(const ValueKey('settings-title-block'));
              final bounds = tester.getRect(block);
              expect(bounds.center.dx, closeTo(size.width / 2, 0.01));
              expect(bounds.height, 71);
              if (locale == 'en') expect(bounds.width, 190);
              final labels =
                  find.descendant(of: block, matching: find.byType(Text));
              Rect? combinedBounds;
              for (final element in labels.evaluate()) {
                final paragraph = element.renderObject! as RenderParagraph;
                expect(paragraph.didExceedMaxLines, isFalse);
                final painted = MatrixUtils.transformRect(
                    paragraph.getTransformTo(null),
                    Offset.zero & paragraph.size);
                expect(painted.left, greaterThanOrEqualTo(bounds.left));
                expect(painted.right, lessThanOrEqualTo(bounds.right));
                expect(painted.top, greaterThanOrEqualTo(bounds.top));
                expect(painted.bottom, lessThanOrEqualTo(bounds.bottom));
                combinedBounds =
                    combinedBounds?.expandToInclude(painted) ?? painted;
              }
              expect(
                  combinedBounds!.center.dx, closeTo(bounds.center.dx, 0.01));
              if (locale != 'en') {
                expect(
                    combinedBounds.center.dy, closeTo(bounds.center.dy, 0.01));
              }
            }
            if (page.key == 'emergency-setup') {
              for (final key in [
                'emergency-setup-title',
                'emergency-setup-subtitle'
              ]) {
                final block = find.byKey(ValueKey(key));
                final bounds = tester.getRect(block);
                final labels =
                    find.descendant(of: block, matching: find.byType(Text));
                for (final element in labels.evaluate()) {
                  final box = element.renderObject! as RenderBox;
                  final painted = MatrixUtils.transformRect(
                      box.getTransformTo(null), Offset.zero & box.size);
                  expect(painted.left, greaterThanOrEqualTo(bounds.left));
                  expect(painted.right, lessThanOrEqualTo(bounds.right));
                  expect(painted.top, greaterThanOrEqualTo(bounds.top));
                  expect(painted.bottom, lessThanOrEqualTo(bounds.bottom));
                }
              }
              final label = tester.widget<Text>(
                  find.byKey(const ValueKey('emergency-contacts-tile-label')));
              expect(label.textAlign, TextAlign.center);
            }
            if (const bool.fromEnvironment('DECOY_CAPTURE_LOCALIZATION')) {
              final boundary = boundaryKey.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
              await tester.runAsync(() async {
                final image = await boundary.toImage();
                final bytes =
                    await image.toByteData(format: ui.ImageByteFormat.png);
                final directory =
                    Directory('/private/tmp/decoy-localization-screens');
                await directory.create(recursive: true);
                await File(
                        '${directory.path}/${page.key}-$locale-${size.width.toInt()}.png')
                    .writeAsBytes(bytes!.buffer.asUint8List());
                image.dispose();
              });
            }
            if (page.key == 'login' || page.key == 'create-account') {
              expect(find.byType(AuthWalletHeading), findsOneWidget);
              expect(find.byKey(const ValueKey('language-picker')),
                  findsOneWidget);
              final scroll = find.byKey(const ValueKey('auth-page-scroll'));
              final scrollable = tester.state<ScrollableState>(find
                  .descendant(of: scroll, matching: find.byType(Scrollable))
                  .first);
              expect(
                  scrollable.position.physics
                      .shouldAcceptUserOffset(scrollable.position),
                  isTrue);
              final heading = find.byKey(const ValueKey('auth-wallet-heading'));
              if ({'ar', 'he'}.contains(locale)) {
                expect(tester.widget<Text>(heading).data,
                    contains('\u2066\u20bfitcoin\u2069'));
              }
              final initialY = tester.getTopLeft(heading).dy;
              await tester.drag(scroll, const Offset(0, -100));
              expect(tester.getTopLeft(heading).dy, lessThan(initialY));
              await tester.pumpAndSettle();
              scrollable.position.jumpTo(0);
              await tester.pumpAndSettle();
              final pageTitle = find.byKey(ValueKey(page.key == 'login'
                  ? 'login-welcome-heading'
                  : 'create-account-heading'));
              expect(
                  tester.widget<Text>(pageTitle).textAlign, TextAlign.center);
              expect(
                  tester.getCenter(pageTitle).dx, closeTo(size.width / 2, 1));
              expect(
                  tester.getSize(pageTitle).width, closeTo(size.width - 64, 1));
              final brandBlock =
                  find.byKey(const ValueKey('auth-wallet-heading-block'));
              expect(tester.getTopLeft(pageTitle).dy,
                  closeTo(tester.getBottomLeft(brandBlock).dy, 1),
                  reason:
                      'Both pages use the same gap below the wallet heading');
              tester.view.viewInsets = const FakeViewPadding(bottom: 280);
              addTearDown(tester.view.resetViewInsets);
              await tester.tap(find.byType(EditableText).first);
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
            }
          }, () => client);
        });
      }
    }
  }
}
