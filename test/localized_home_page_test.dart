import 'dart:io';
import 'dart:ui' as ui;

import 'package:decoy_wallet_app/app_state.dart';
import 'package:decoy_wallet_app/home_pages/home_page/home_page_widget.dart';
import 'package:decoy_wallet_app/home_pages/home_page/localized_home_tile_label.dart';
import 'package:decoy_wallet_app/l10n/app_language_controller.dart';
import 'package:decoy_wallet_app/l10n/app_localizations.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
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
    expect(request.url.host, 'test.invalid');
    expect(request.method, 'GET');
    expect(request.url.path, '/rest/v1/user_entitlements');
    return http.Response(
      '[{"is_active":true,"provider_status":"active"}]',
      200,
      request: request,
      headers: {'content-type': 'application/json'},
    );
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
  tearDownAll(() async {
    await Supabase.instance.dispose();
  });

  for (final locale in AppLanguageController.supportedLanguageCodes) {
    for (final size in const [
      Size(320, 740),
      Size(402, 874),
      Size(768, 1024),
    ]) {
      testWidgets('home $locale at $size', (tester) async {
        debugDisableShadows = false;
        try {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          SharedPreferences.setMockInitialValues({});
          FlutterSecureStorage.setMockInitialValues({});
          FFAppState.reset();
          await FFAppState().initializePersistedState();
          final boundaryKey = GlobalKey();
          await tester.pumpWidget(ChangeNotifierProvider.value(
            value: FFAppState(),
            child: MaterialApp(
              theme: ThemeData(
                useMaterial3: false,
                fontFamily: 'robot',
                fontFamilyFallback: decoyFontFallbacks(Locale(locale)),
              ),
              locale: Locale(locale),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: RepaintBoundary(
                key: boundaryKey,
                child: const HomePageWidget(),
              ),
            ),
          ));
          await tester.pumpAndSettle();
          await tester.runAsync(() => precacheImage(
                const AssetImage('assets/images/DecoyLogo1-WOHiRes.jpg'),
                tester.element(find.byType(HomePageWidget)),
              ));
          await tester.pumpAndSettle();
          expect(FFAppState().hasActiveSubscription, isTrue);
          expect(tester.takeException(), isNull);

          if (locale == 'en') {
            expect(find.byType(LocalizedHomeTileLabel), findsNothing);
            // Captured from the unchanged home screen at commit 2787252.
            await expectLater(
              find.byKey(boundaryKey),
              matchesGoldenFile('goldens/home-en-${size.width.toInt()}.png'),
            );
          } else {
            expect(find.byType(LocalizedHomeTileLabel), findsNWidgets(3));
            for (final key in [
              'home-keys-label',
              'home-pin-label',
              'home-contacts-label',
            ]) {
              final label = find.byKey(ValueKey(key));
              final bounds = tester.getRect(label);
              final text =
                  find.descendant(of: label, matching: find.byType(Text));
              Rect? combinedBounds;
              for (final element in text.evaluate()) {
                final widget = element.widget as Text;
                final paragraph = element.renderObject! as RenderParagraph;
                expect(widget.textAlign, TextAlign.center);
                expect(widget.style!.fontSize, greaterThanOrEqualTo(14));
                expect(paragraph.didExceedMaxLines, isFalse,
                    reason: '$locale $key must display the complete label');
                final painted = MatrixUtils.transformRect(
                  paragraph.getTransformTo(null),
                  Offset.zero & paragraph.size,
                );
                expect(painted.left, greaterThanOrEqualTo(bounds.left));
                expect(painted.right, lessThanOrEqualTo(bounds.right));
                expect(painted.top, greaterThanOrEqualTo(bounds.top));
                expect(painted.bottom, lessThanOrEqualTo(bounds.bottom));
                combinedBounds =
                    combinedBounds?.expandToInclude(painted) ?? painted;
                final measurement = TextPainter(
                  text: paragraph.text,
                  textAlign: paragraph.textAlign,
                  textDirection: paragraph.textDirection,
                  textScaler: paragraph.textScaler,
                  locale: Locale(locale),
                )..layout(maxWidth: paragraph.size.width);
                expect(measurement.computeLineMetrics().length,
                    lessThanOrEqualTo(2));
                expect(measurement.height,
                    lessThanOrEqualTo(paragraph.size.height + 0.01));
                for (final line in measurement.computeLineMetrics()) {
                  expect(line.left + line.width / 2,
                      closeTo(paragraph.size.width / 2, 0.01));
                }
                measurement.dispose();
              }
              expect(
                  combinedBounds!.center.dx, closeTo(bounds.center.dx, 0.01));
              expect(combinedBounds.center.dy, closeTo(bounds.center.dy, 0.01));
            }
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
                      '${directory.path}/home-$locale-${size.width.toInt()}.png')
                  .writeAsBytes(bytes!.buffer.asUint8List());
              image.dispose();
            });
          }
        } finally {
          debugDisableShadows = true;
        }
      });
    }
  }
}
