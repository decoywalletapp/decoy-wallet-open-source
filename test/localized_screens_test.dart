import 'dart:io';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:decoy_wallet_app/app_state.dart';
import 'package:decoy_wallet_app/components/auth_wallet_heading.dart';
import 'package:decoy_wallet_app/emergancy_contact_information/create_decoy_emergency_contacts_setup/create_decoy_emergency_contacts_setup_widget.dart';
import 'package:decoy_wallet_app/duress_mode/duress_settings_page/duress_settings_page_widget.dart';
import 'package:decoy_wallet_app/duress_mode/wallet_feature_preview/wallet_feature_preview_widget.dart';
import 'package:decoy_wallet_app/home_pages/settings/settings_widget.dart';
import 'package:decoy_wallet_app/l10n/app_language_controller.dart';
import 'package:decoy_wallet_app/l10n/app_localizations.dart';
import 'package:decoy_wallet_app/settings_pages/configure_bitcoin_balance/configure_bitcoin_balance_widget.dart';
import 'package:decoy_wallet_app/welcom_pages/create_account/create_account_widget.dart';
import 'package:decoy_wallet_app/welcom_pages/login_page/login_page_widget.dart';
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final client = MockClient((request) async {
    if (request.url.path.endsWith('/getConsentStatuses')) {
      return http.Response('{"slot1Status":"confirmed"}', 200, request: request,
          headers: {'content-type': 'application/json'});
    }
    return http.Response(
        jsonEncode(request.url.path.endsWith('/decoy_wallet')
            ? [
                {
                  'personal_complete': false,
                  'contacts_complete': true,
                  'address_complete': false
                }
              ]
            : []),
        200,
        request: request,
        headers: {'content-type': 'application/json'});
  });

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    final fonts = <String, List<String>>{
      'DECOY BEBAS': ['BebasNeue-Regular.ttf'],
      'InterTight': ['InterTight-Regular.ttf', 'InterTight-Bold.ttf'],
      'hello': ['Inter_24pt-Regular.ttf', 'Inter_28pt-Bold.ttf'],
      'Outterbox': ['Outfit-Regular.ttf', 'Outfit-Bold.ttf'],
      'robot': ['Roboto-Regular.ttf', 'Roboto-Bold.ttf'],
      'Roboto': ['Roboto-Regular.ttf', 'Roboto-Bold.ttf'],
    };
    for (final entry in fonts.entries) {
      final loader = FontLoader(entry.key);
      for (final asset in entry.value) {
        loader.addFont(rootBundle.load('assets/fonts/$asset'));
      }
      await loader.load();
    }
    await (FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
        .load();
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
  tearDownAll(() => Supabase.instance.dispose());

  final pages = <String, Widget>{
    'login': const LoginPageWidget(),
    'create-account': const CreateAccountWidget(),
    'settings': const SettingsWidget(),
    'balance': const ConfigureBitcoinBalanceWidget(),
    'wallet-settings': const DuressSettingsPageWidget(),
    'recurring-buy': const WalletFeaturePreviewWidget(feature: 'recurring-buy'),
    if (const String.fromEnvironment('DECOY_SUPABASE_URL') ==
        'https://test.invalid')
      'emergency-setup': const CreateDecoyEmergencyContactsSetupWidget(),
  };
  for (final locale in ['en', 'es']) {
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
                theme: ThemeData(useMaterial3: false, fontFamily: 'robot'),
                locale: Locale(locale),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: RepaintBoundary(key: boundaryKey, child: page.value),
              ),
            ));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
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
              final initialY = tester.getTopLeft(heading).dy;
              await tester.drag(scroll, const Offset(0, -100));
              expect(tester.getTopLeft(heading).dy, lessThan(initialY));
              await tester.pumpAndSettle();
              scrollable.position.jumpTo(0);
              await tester.pumpAndSettle();
              if (page.key == 'create-account') {
                final heading =
                    find.byKey(const ValueKey('create-account-heading'));
                expect(
                    tester.widget<Text>(heading).textAlign, TextAlign.center);
                expect(
                    tester.getCenter(heading).dx, closeTo(size.width / 2, 1));
              }
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
