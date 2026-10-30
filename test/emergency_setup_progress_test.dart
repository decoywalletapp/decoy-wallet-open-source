import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:decoy_wallet_app/auth/supabase_auth/supabase_user_provider.dart';
import 'package:decoy_wallet_app/emergancy_contact_information/create_decoy_emergency_contacts_setup/create_decoy_emergency_contacts_setup_widget.dart';
import 'package:decoy_wallet_app/emergancy_contact_information/emergency_contacts/emergency_contacts_widget.dart';
import 'package:decoy_wallet_app/emergancy_contact_information/personal_information/personal_information_widget.dart';
import 'package:decoy_wallet_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:decoy_wallet_app/flutter_flow/flutter_flow_widgets.dart';
import 'package:decoy_wallet_app/flutter_flow/flutter_flow_icon_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'localization_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  if (const String.fromEnvironment('DECOY_SUPABASE_URL') !=
          'https://test.invalid' ||
      const String.fromEnvironment('DECOY_FIREBASE_FUNCTIONS_BASE_URL') !=
          'https://test.invalid') {
    test('setup UI requires synthetic endpoints', () {},
        skip: 'Requires test.invalid Supabase and function endpoints.');
    return;
  }

  late Map<String, dynamic> row;
  var status = 'pending';
  var statusRequests = 0;
  final writes = <Map<String, dynamic>>[];
  final visits = <String, int>{};
  final boundaryKey = GlobalKey();
  final client = MockClient((request) async {
    expectSync(request.url.host, 'test.invalid');
    Object response;
    if (request.url.path == '/rest/v1/decoy_wallet') {
      expectSync(
          request.url.queryParameters['user_id'], 'eq.synthetic-setup-owner');
      if (request.method == 'PATCH') {
        final data = Map<String, dynamic>.from(jsonDecode(request.body));
        expectSync(data.keys.toSet(), {'contacts_complete', 'updated_at'});
        writes.add(data);
        row.addAll(data);
        return http.Response('', 204, request: request);
      }
      expectSync(request.method, 'GET');
      response = [row];
    } else if (request.url.path.endsWith('/getConsentStatuses')) {
      statusRequests++;
      response = {'slot1Status': status};
    } else {
      throw StateError(
          'Unexpected request: ${request.method} ${request.url.path}');
    }
    return http.Response(jsonEncode(response), 200,
        request: request, headers: {'content-type': 'application/json'});
  });

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await loadLocalizationFonts();
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://test.invalid',
      anonKey: 'synthetic',
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
    currentUser = null;
    await Supabase.instance.dispose();
  });
  setUp(() {
    currentUser = DecoyWalletAppSupabaseUser(User(
      id: 'synthetic-setup-owner',
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: '2026-10-30T00:00:00Z',
    ));
    row = {
      'user_id': 'synthetic-setup-owner',
      'personal_complete': false,
      'contacts_complete': false,
      'address_complete': false,
    };
    status = 'pending';
    statusRequests = 0;
    writes.clear();
    visits.clear();
  });

  Future<GoRouter> mount(WidgetTester tester,
      {Size size = const Size(402, 874),
      double scale = 1,
      String locale = 'en',
      bool reduceMotion = false}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    Widget destination(String label) {
      visits.update(label, (value) => value + 1, ifAbsent: () => 1);
      return Scaffold(body: Center(child: Text(label)));
    }

    final router = GoRouter(
      initialLocation: '/setup',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(body: Text('Previous screen')),
          routes: [
            GoRoute(
              path: 'setup',
              builder: (_, __) => RepaintBoundary(
                key: boundaryKey,
                child: const CreateDecoyEmergencyContactsSetupWidget(),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/personal',
          name: PersonalInformationWidget.routeName,
          builder: (_, __) => destination('Personal editor'),
        ),
        GoRoute(
          path: '/contacts',
          name: EmergencyContactsWidget.routeName,
          builder: (_, __) => destination('Contacts editor'),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(
      theme: ThemeData(useMaterial3: false, fontFamily: 'robot'),
      locale: Locale(locale),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(scale),
          disableAnimations: reduceMotion,
          padding: const EdgeInsets.only(top: 54, bottom: 34),
        ),
        child: child!,
      ),
      routerConfig: router,
    ));
    await tester.pumpAndSettle();
    return router;
  }

  Future<void> capture(WidgetTester tester, String name) async {
    if (!const bool.fromEnvironment('DECOY_CAPTURE_SETUP_PROGRESS')) return;
    final boundary = boundaryKey.currentContext!.findRenderObject()!
        as RenderRepaintBoundary;
    final previousShadows = debugDisableShadows;
    try {
      debugDisableShadows = false;
      void repaint(RenderObject object) {
        object.markNeedsPaint();
        object.visitChildren(repaint);
      }

      repaint(boundary);
      await tester.pump();
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final directory =
            Directory('/private/tmp/decoy-setup-progress-preview');
        await directory.create(recursive: true);
        await File('${directory.path}/$name.png')
            .writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    } finally {
      debugDisableShadows = previousShadows;
    }
  }

  Finder tile(String name) =>
      find.byType(FFButtonWidget).at(name == 'personal' ? 0 : 1);
  LinearPercentIndicator indicator(WidgetTester tester) => tester
      .widget<LinearPercentIndicator>(find.byType(LinearPercentIndicator));

  for (final personal in [false, true]) {
    for (final contacts in [false, true]) {
      testWidgets('progress personal=$personal contacts=$contacts',
          (tester) async {
        await http.runWithClient(() async {
          row['personal_complete'] = personal;
          row['address_complete'] = true;
          status = contacts ? 'confirmed' : 'pending';
          await mount(tester);
          final percent = ((personal ? 1 : 0) + (contacts ? 1 : 0)) * 50;
          expect(find.text('$percent % Complete'), findsOneWidget);
          expect(indicator(tester).percent, percent / 100);
          expect(indicator(tester).lineHeight, 14);
          expect(indicator(tester).barRadius, const Radius.circular(7));
          expect(find.byType(FFButtonWidget), findsNWidgets(2));
          expect(writes.single['contacts_complete'], contacts);
          expect(tester.takeException(), isNull);
          await capture(tester, 'personal-$personal-contacts-$contacts');
        }, () => client);
      });
    }
  }

  for (final consent in ['pending', 'denied', 'opted_out', 'expired']) {
    testWidgets('$consent does not become completed', (tester) async {
      await http.runWithClient(() async {
        row['contacts_complete'] = true;
        status = consent;
        await mount(tester);
        expect(indicator(tester).percent, 0);
        expect(writes.single['contacts_complete'], false);
      }, () => client);
    });
  }

  for (final name in ['personal', 'contacts']) {
    testWidgets('$name opens once and refreshes progress on return',
        (tester) async {
      await http.runWithClient(() async {
        final router = await mount(tester);
        await tester.tap(tile(name));
        await tester.tap(tile(name));
        await tester.pumpAndSettle();
        final destination =
            name == 'personal' ? 'Personal editor' : 'Contacts editor';
        expect(find.text(destination), findsOneWidget);
        expect(visits[destination], 1);
        if (name == 'personal') {
          row['personal_complete'] = true;
        } else {
          status = 'confirmed';
        }
        router.pop();
        await tester.pumpAndSettle();
        expect(statusRequests, 2);
        expect(indicator(tester).percent, 0.5);
        expect(find.byType(CircularProgressIndicator), findsNothing);
        await tester.tap(tile(name));
        await tester.pumpAndSettle();
        expect(visits[destination], 2);
        router.pop();
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }, () => client);
    });
  }

  testWidgets('resume refreshes progress without changing trigger settings',
      (tester) async {
    await http.runWithClient(() async {
      status = 'confirmed';
      row['decoy_pin_contacts_enabled'] = true;
      await mount(tester);
      expect(indicator(tester).percent, 0.5);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      status = 'opted_out';
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(indicator(tester).percent, 0);
      expect(row['decoy_pin_contacts_enabled'], true);
      expect(statusRequests, 2);
    }, () => client);
  });

  testWidgets('back returns to the prior screen', (tester) async {
    await http.runWithClient(() async {
      await mount(tester);
      await tester.tap(find.byType(FlutterFlowIconButton));
      await tester.pumpAndSettle();
      expect(find.text('Previous screen'), findsOneWidget);
      expect(statusRequests, 1);
    }, () => client);
  });

  testWidgets('progress exposes its value to accessibility', (tester) async {
    await http.runWithClient(() async {
      final semantics = tester.ensureSemantics();
      try {
        status = 'confirmed';
        await mount(tester);
        final node = tester.getSemantics(
            find.byKey(const ValueKey('emergency-setup-progress')));
        expect(node.label, 'PROGRESS');
        expect(node.value, '50%');
      } finally {
        semantics.dispose();
      }
    }, () => client);
  });

  for (final reduceMotion in [false, true]) {
    testWidgets('progress respects reduced motion: $reduceMotion',
        (tester) async {
      await http.runWithClient(() async {
        status = 'confirmed';
        await mount(tester, reduceMotion: reduceMotion);
        expect(indicator(tester).animation, !reduceMotion);
        expect(indicator(tester).animationDuration, 350);
        expect(indicator(tester).animateFromLastPercent, isTrue);
        expect(indicator(tester).curve, Curves.easeOutCubic);
        expect(indicator(tester).percent, 0.5);
      }, () => client);
    });
  }

  for (final locale in ['en', 'de', 'ar']) {
    for (final width in [320.0, 402.0, 768.0]) {
      testWidgets('$locale large text at $width stays inside the screen',
          (tester) async {
        await http.runWithClient(() async {
          status = 'confirmed';
          await mount(tester, size: Size(width, 874), scale: 2, locale: locale);
          await tester.ensureVisible(find.byType(LinearPercentIndicator));
          await tester.pumpAndSettle();
          for (final element in find.byType(Text).evaluate()) {
            final paragraph = element.renderObject! as RenderParagraph;
            expect(paragraph.didExceedMaxLines, isFalse);
            final rect = MatrixUtils.transformRect(
                paragraph.getTransformTo(null), Offset.zero & paragraph.size);
            expect(rect.left, greaterThanOrEqualTo(-0.01));
            expect(rect.right, lessThanOrEqualTo(width + 0.01));
          }
          expect(tester.takeException(), isNull);
          if (locale == 'en' && width == 320) {
            await capture(tester, 'small-large-text');
          }
        }, () => client);
      });
    }
  }
}
