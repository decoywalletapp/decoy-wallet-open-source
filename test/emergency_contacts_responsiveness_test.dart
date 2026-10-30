import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:decoy_wallet_app/app_state.dart';
import 'package:decoy_wallet_app/auth/supabase_auth/supabase_user_provider.dart';
import 'package:decoy_wallet_app/custom_code/actions/aes_gcm_encrypt_string.dart';
import 'package:decoy_wallet_app/custom_code/actions/aes_gcm_decrypt_to_map.dart';
import 'package:decoy_wallet_app/emergancy_contact_information/emergency_contacts/emergency_contacts_widget.dart';
import 'package:decoy_wallet_app/flutter_flow/flutter_flow_widgets.dart';
import 'package:decoy_wallet_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'localization_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  if (const String.fromEnvironment('DECOY_SUPABASE_URL') !=
          'https://test.invalid' ||
      const String.fromEnvironment('DECOY_DATA_KEY_BASE_URL') !=
          'https://test.invalid/unwrap') {
    test('contact UI uses isolated endpoints', () {},
        skip: 'Requires test.invalid Supabase and data-key dart defines.');
    return;
  }
  final key = base64UrlEncode(List<int>.generate(16, (i) => i));
  var sequence = 0;
  late User user;
  late Map<String, dynamic> row;
  var statuses = <String, dynamic>{};
  final writes = <Map<String, dynamic>>[];
  final invitations = <Map<String, dynamic>>[];
  final syncs = <Map<String, dynamic>>[];
  var rowFailure = false;
  var statusFailure = false;
  Completer<void>? rowHold;
  Completer<void>? inviteHold;
  final statusHolds = <Completer<void>>[];
  var statusRequests = 0;
  var pickerCalls = 0;
  final boundary = GlobalKey();

  final client = MockClient((request) async {
    expect(request.url.host, 'test.invalid');
    final path = request.url.path;
    Object response;
    if (path == '/rest/v1/decoy_wallet') {
      if (request.method == 'PATCH') {
        final data = Map<String, dynamic>.from(jsonDecode(request.body));
        writes.add(data);
        row.addAll(data);
        return http.Response('', 204, request: request);
      }
      await rowHold?.future;
      if (rowFailure) return http.Response('{"message":"offline"}', 503);
      response =
          request.headers['Accept']?.contains('object') == true ? row : [row];
    } else if (path.endsWith('/getConsentStatuses')) {
      statusRequests++;
      final snapshot = Map<String, dynamic>.from(statuses);
      if (statusHolds.isNotEmpty) await statusHolds.removeAt(0).future;
      if (statusFailure) return http.Response('{}', 503);
      response = snapshot;
    } else if (path == '/unwrap') {
      response = jsonDecode(request.body).containsKey('dataKeyB64')
          ? {'wrappedB64': 'synthetic-wrapped-key'}
          : {'dataKeyB64': key};
    } else if (path.endsWith('/syncConsentSlots')) {
      syncs.add(Map<String, dynamic>.from(jsonDecode(request.body)));
      response = {'ok': true};
    } else if (path.endsWith('/createConsentRequest')) {
      invitations.add(Map<String, dynamic>.from(jsonDecode(request.body)));
      await inviteHold?.future;
      response = {'ok': true};
    } else {
      throw StateError('Unexpected request: ${request.method} $path');
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
      httpClient: client,
      debug: false,
      authOptions: const FlutterAuthClientOptions(
          autoRefreshToken: false,
          detectSessionInUri: false,
          localStorage: EmptyLocalStorage()),
    );
  });
  tearDownAll(() => Supabase.instance.dispose());

  setUp(() async {
    user = User(
        id: 'contact-ui-${++sequence}',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: '2026-10-30T00:00:00Z');
    final token = '${base64UrlEncode(utf8.encode('{"alg":"none"}'))}.'
        '${base64UrlEncode(utf8.encode(jsonEncode({
          'sub': user.id,
          'exp': DateTime.now()
                  .add(const Duration(hours: 1))
                  .millisecondsSinceEpoch ~/
              1000
        })))}.synthetic';
    await Supabase.instance.client.auth.setInitialSession(jsonEncode({
      'access_token': token,
      'refresh_token': 'synthetic',
      'token_type': 'bearer',
      'expires_in': 3600,
      'user': user.toJson()
    }));
    currentUser = DecoyWalletAppSupabaseUser(user);
    row = {'user_id': user.id, 'contacts_complete': false};
    statuses = {};
    writes.clear();
    invitations.clear();
    syncs.clear();
    rowFailure = false;
    statusFailure = false;
    rowHold = null;
    inviteHold = null;
    statusRequests = 0;
    pickerCalls = 0;
    statusHolds.clear();
    FlutterSecureStorage.setMockInitialValues({'decoy_data_key_b64': key});
    FFAppState.reset();
    await FFAppState().initializePersistedState();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('decoy_wallet/contact_picker'), (call) async {
      expect(call.method, 'pickContact');
      pickerCalls++;
      return {
        'firstName': 'Taylor',
        'lastName': 'Example',
        'phoneNumber': '+12025550124'
      };
    });
  });

  Future<void> seed(WidgetTester tester,
      {bool cached = false, int count = 1}) async {
    final contacts = [
      for (var slot = 1; slot <= count; slot++)
        {
          'slot': slot,
          'first': slot == 1 ? 'Alex' : 'Taylor',
          'last': 'Example',
          'phone': '+1202555012${slot + 2}',
          'consent_status': 'pending'
        }
    ];
    final encrypted = (await tester.runAsync(() => aesGcmEncryptString(
        jsonEncode({'version': 2, 'contacts': contacts, 'validCount': count}),
        key)))!;
    row.addAll({
      'contacts_ciphertext': encrypted['ciphertextB64'],
      'contacts_nonce': encrypted['nonceB64'],
      'wrapped_datakey': 'synthetic-wrapped-key'
    });
    statuses = {
      for (final c in contacts) ...{
        'slot${c['slot']}Status': 'confirmed',
        'slot${c['slot']}First': c['first'],
        'slot${c['slot']}Last': c['last'],
        'slot${c['slot']}Phone': c['phone']
      }
    };
    if (cached)
      FlutterSecureStorage.setMockInitialValues({
        'decoy_data_key_b64': key,
        'decoy_contacts_cipher_b64.${user.id}': encrypted['ciphertextB64'],
        'decoy_contacts_nonce_b64.${user.id}': encrypted['nonceB64'],
        'decoy_contacts_wrapped_b64.${user.id}': 'synthetic-wrapped-key',
      });
  }

  Future<void> open(WidgetTester tester,
      {Size size = const Size(402, 874),
      double scale = 1,
      bool settle = true}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(initialLocation: '/contacts', routes: [
      GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(body: Text('Settings'))),
      GoRoute(
          path: '/contacts',
          builder: (_, __) => RepaintBoundary(
              key: boundary, child: const EmergencyContactsWidget())),
    ]);
    addTearDown(router.dispose);
    await tester.pumpWidget(ChangeNotifierProvider.value(
        value: FFAppState(),
        child: MaterialApp.router(
            routerConfig: router,
            theme: ThemeData(useMaterial3: false),
            builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(scale)),
                child: child!),
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales)));
    if (settle)
      await tester.pumpAndSettle();
    else {
      for (var i = 0; i < 10; i++)
        await tester.pump(const Duration(milliseconds: 20));
    }
  }

  Finder field(int slot, String name) =>
      find.byKey(ValueKey('contact-$slot-$name'));
  Finder status(int slot, String text) => find.descendant(
      of: find.byKey(ValueKey('contact-status-$slot')),
      matching: find.text(text));
  bool saveEnabled(WidgetTester tester) =>
      tester
          .widget<FFButtonWidget>(
              find.byKey(const ValueKey('save-emergency-contacts')))
          .onPressed !=
      null;

  testWidgets(
      'fresh matching status appears before slow contact load; actions wait',
      (tester) async {
    await http.runWithClient(() async {
      await seed(tester, cached: true);
      rowHold = Completer<void>();
      await open(tester, settle: false);
      expect(statusRequests, 1);
      expect(status(1, 'Confirmed'), findsOneWidget);
      expect(saveEnabled(tester), isFalse);
      expect(writes, isEmpty);
      expect(invitations, isEmpty);
      rowHold!.complete();
      await tester.pumpAndSettle();
      expect(saveEnabled(tester), isTrue);
      expect(status(1, 'Confirmed'), findsOneWidget);
    }, () => client);
  });

  for (final wrongPhone in [null, '+12025550999']) {
    testWidgets('early status never applies to unmatched number $wrongPhone',
        (tester) async {
      await http.runWithClient(() async {
        await seed(tester, cached: true);
        statuses['slot1Phone'] = wrongPhone;
        rowHold = Completer<void>();
        await open(tester, settle: false);
        expect(statusRequests, 1);
        expect(status(1, 'Confirmed'), findsNothing);
        expect(saveEnabled(tester), isFalse);
        rowHold!.complete();
        await tester.pumpAndSettle();
      }, () => client);
    });
  }

  testWidgets(
      'failed initial read offers retry without enabling a partial save',
      (tester) async {
    await http.runWithClient(() async {
      rowFailure = true;
      await open(tester);
      expect(saveEnabled(tester), isFalse);
      expect(find.byKey(const ValueKey('retry-contact-load')), findsOneWidget);
      expect(writes, isEmpty);
      rowFailure = false;
      await tester.tap(find.byKey(const ValueKey('retry-contact-load')));
      await tester.pumpAndSettle();
      expect(saveEnabled(tester), isTrue);
      expect(find.byKey(const ValueKey('retry-contact-load')), findsNothing);
      expect(writes, isEmpty);
    }, () => client);
  });

  testWidgets('manual entry and native picker remain available',
      (tester) async {
    await http.runWithClient(() async {
      await open(tester);
      final strings =
          AppLocalizations.of(tester.element(find.byType(Scaffold)))!;
      await tester.tap(find.text(strings.msgEnterManually));
      await tester.pumpAndSettle();
      await tester.enterText(field(1, 'firstName'), 'Alex');
      await tester
          .ensureVisible(find.byKey(const ValueKey('add-emergency-contact')));
      await tester.tap(find.byKey(const ValueKey('add-emergency-contact')));
      await tester.pumpAndSettle();
      final picker = find.text(strings.msgChooseFromContacts);
      await tester.ensureVisible(picker);
      await tester.tap(picker);
      await tester.pumpAndSettle();
      expect(pickerCalls, 1);
      expect(
          tester.widget<TextFormField>(field(2, 'firstName')).controller!.text,
          'Taylor');
      expect(
          tester
              .widget<TextFormField>(field(2, 'phone'))
              .controller!
              .text
              .replaceAll(RegExp(r'\D'), ''),
          '12025550124');
      expect(writes, isEmpty);
      expect(invitations, isEmpty);
    }, () => client);
  });

  testWidgets('late status from a failed load cannot overwrite retry preview',
      (tester) async {
    await http.runWithClient(() async {
      await seed(tester, cached: true);
      final first = Completer<void>(), second = Completer<void>();
      statusHolds.addAll([first, second]);
      rowFailure = true;
      await open(tester);
      expect(statusRequests, 1);
      rowFailure = false;
      statuses['slot1Status'] = 'opted_out';
      await tester.tap(find.byKey(const ValueKey('retry-contact-load')));
      for (var i = 0; i < 10; i++)
        await tester.pump(const Duration(milliseconds: 20));
      expect(statusRequests, 2);
      first.complete();
      for (var i = 0; i < 10; i++)
        await tester.pump(const Duration(milliseconds: 20));
      expect(status(1, 'Confirmed'), findsNothing);
      expect(saveEnabled(tester), isFalse);
      second.complete();
      await tester.pumpAndSettle();
      expect(status(1, 'Opted out'), findsOneWidget);
      expect(saveEnabled(tester), isTrue);
      expect(writes, isEmpty);
    }, () => client);
  });

  testWidgets('phone edits clear displayed consent immediately',
      (tester) async {
    await http.runWithClient(() async {
      await seed(tester);
      await open(tester);
      expect(status(1, 'Confirmed'), findsOneWidget);
      await tester.enterText(field(1, 'phone'), '2025550199');
      await tester.pump();
      expect(status(1, 'Not sent'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      expect(writes, isEmpty);
    }, () => client);
  });

  testWidgets('failed status fetch does not label cached consent as current',
      (tester) async {
    await http.runWithClient(() async {
      await seed(tester, cached: true);
      statusFailure = true;
      await open(tester);
      expect(status(1, 'Pending'), findsNothing);
      expect(status(1, 'Confirmed'), findsNothing);
      expect(status(1, '--'), findsOneWidget);
      expect(saveEnabled(tester), isTrue);
      expect(writes, isEmpty);
      expect(invitations, isEmpty);
    }, () => client);
  });

  testWidgets('five-contact limit and deletion preserve remaining contacts',
      (tester) async {
    await http.runWithClient(() async {
      await seed(tester, count: 5);
      statuses['slot2Status'] = 'opted_out';
      await open(tester);
      final list = find.byKey(const ValueKey('emergency-contact-list'));
      await tester.drag(list, const Offset(0, -2500));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('add-emergency-contact')), findsNothing);
      await tester.drag(list, const Offset(0, 2500));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('delete-contact-1')));
      await tester.pumpAndSettle();
      expect(
          tester.widget<TextFormField>(field(1, 'firstName')).controller!.text,
          'Taylor');
      expect(status(1, 'Opted out'), findsOneWidget);
      await tester.drag(list, const Offset(0, -2500));
      await tester.pumpAndSettle();
      expect(
          find.byKey(const ValueKey('add-emergency-contact')), findsOneWidget);
      expect(writes, isEmpty);
      expect(invitations, isEmpty);
    }, () => client);
  });

  testWidgets('visible invitation progress prevents duplicate sends',
      (tester) async {
    await http.runWithClient(() async {
      await seed(tester);
      await open(tester);
      inviteHold = Completer<void>();
      final invite = find.byKey(const ValueKey('invite-contact-1'));
      await tester.ensureVisible(invite);
      await tester.tap(invite);
      for (var i = 0; i < 30; i++)
        await tester.pump(const Duration(milliseconds: 20));
      expect(invitations, hasLength(1));
      expect(find.byKey(const ValueKey('invite-progress-1')), findsOneWidget);
      await tester.tap(invite);
      await tester.pump();
      expect(invitations, hasLength(1));
      expect(invitations.single['contactSlot'], 1);
      expect(invitations.single['phoneNumber'], '2025550123');
      inviteHold!.complete();
      await tester.pumpAndSettle();
      expect(find.text('Confirmation Link Sent'), findsOneWidget);
      await tester.pump(const Duration(seconds: 6));
      expect(writes, hasLength(1));
      expect(syncs, hasLength(1));
    }, () => client);
  });

  testWidgets('save uses existing encrypted payload and consent sync once',
      (tester) async {
    await http.runWithClient(() async {
      await seed(tester);
      await open(tester);
      await tester
          .ensureVisible(find.byKey(const ValueKey('save-emergency-contacts')));
      await tester.tap(find.byKey(const ValueKey('save-emergency-contacts')));
      await tester.pumpAndSettle();
      expect(writes, hasLength(1));
      expect(syncs, hasLength(1));
      expect(invitations, isEmpty);
      final saved = (await tester.runAsync(() => aesGcmDecryptToMap(
          writes.single['contacts_ciphertext'],
          writes.single['contacts_nonce'],
          key)))!;
      expect(saved['contacts'][0], {
        'slot': 1,
        'first': 'Alex',
        'last': 'Example',
        'phone': '+12025550123',
        'consent_status': 'confirmed'
      });
      expect(writes.single['contacts_complete'], true);
      expect(jsonEncode(writes), isNot(contains('2025550123')));
    }, () => client);
  });

  for (final size in [
    const Size(320, 640),
    const Size(402, 874),
    const Size(768, 1024)
  ]) {
    for (final scale in [1.0, 1.5]) {
      testWidgets('filled contacts fit $size scale $scale', (tester) async {
        await http.runWithClient(() async {
          await seed(tester);
          statuses['slot2Status'] = 'pending';
          await open(tester, size: size, scale: scale);
          expect(tester.takeException(), isNull);
          if (scale == 1 &&
              const bool.fromEnvironment('DECOY_CAPTURE_LOCALIZATION')) {
            final render = boundary.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
            void repaint(RenderObject node) {
              node.markNeedsPaint();
              node.visitChildren(repaint);
            }

            final previousShadows = debugDisableShadows;
            debugDisableShadows = false;
            try {
              repaint(render);
              await tester.pump();
              await tester.runAsync(() async {
                final image = await render.toImage();
                final bytes =
                    await image.toByteData(format: ui.ImageByteFormat.png);
                final file = File(
                    '/private/tmp/decoy-contacts-original-${size.width.toInt()}.png');
                await file.writeAsBytes(bytes!.buffer.asUint8List());
                image.dispose();
              });
            } finally {
              debugDisableShadows = previousShadows;
              repaint(render);
              await tester.pump();
            }
          }
          await tester.showKeyboard(field(1, 'phone'));
          tester.view.viewInsets = const FakeViewPadding(bottom: 280);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          tester.view.resetViewInsets();
        }, () => client);
      });
    }
  }
}
