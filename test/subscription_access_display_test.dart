import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:decoy_wallet_app/app_state.dart';
import 'package:decoy_wallet_app/auth/supabase_auth/supabase_user_provider.dart';
import 'package:decoy_wallet_app/backend/supabase/supabase.dart';
import 'package:decoy_wallet_app/backend/public_config.dart';
import 'package:decoy_wallet_app/components/redemption_option_card.dart';
import 'package:decoy_wallet_app/components/workshop_qr_option_card.dart';
import 'package:decoy_wallet_app/home_pages/settings/settings_widget.dart';
import 'package:decoy_wallet_app/l10n/app_localizations.dart';
import 'package:decoy_wallet_app/settings_pages/manage_subscription/manage_subscription_widget.dart';
import 'package:decoy_wallet_app/welcom_pages/subscription_options/subscription_options_widget.dart';
import 'package:decoy_wallet_app/workshop/workshop_claim_client.dart';
import 'package:decoy_wallet_app/workshop/workshop_qr_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import 'localization_fonts.dart';

class _RecordingLauncher extends UrlLauncherPlatform {
  final urls = <String>[];

  @override
  get linkDelegate => null;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    expect(Uri.parse(url).host, 'test.invalid');
    urls.add(url);
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  Map<String, dynamic>? entitlement;
  var failRead = false;
  final launcher = _RecordingLauncher();
  final requests = <http.Request>[];
  const userId = 'subscription-display-owner';
  final user = User(
      id: userId,
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: '2026-01-01T00:00:00Z');
  final client = MockClient((request) async {
    requests.add(request);
    expect(request.url.host, 'test.invalid');
    expect(request.url.path, '/rest/v1/user_entitlements');
    expect(request.method, 'GET');
    expect(request.url.queryParameters['user_id'], 'eq.$userId');
    expect(request.url.queryParameters['entitlement'], 'eq.decoy_wallet');
    return http.Response(
        jsonEncode(failRead
            ? {'message': 'synthetic outage', 'code': '503'}
            : [if (entitlement != null) entitlement]),
        failRead ? 503 : 200,
        request: request,
        headers: {'content-type': 'application/json'});
  });

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await loadLocalizationFonts();
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    await FFAppState().initializePersistedState();
    for (final channel in [
      'com.llfbandit.app_links/messages',
      'com.llfbandit.app_links/events'
    ]) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannel(channel), (_) async => null);
    }
    await Supabase.initialize(
        url: 'https://test.invalid',
        anonKey: 'synthetic',
        debug: false,
        httpClient: client,
        authOptions: const FlutterAuthClientOptions(
            autoRefreshToken: false,
            detectSessionInUri: false,
            localStorage: EmptyLocalStorage()));
  });
  tearDownAll(() async => Supabase.instance.dispose());
  setUp(() {
    final previousLauncher = UrlLauncherPlatform.instance;
    UrlLauncherPlatform.instance = launcher;
    addTearDown(() => UrlLauncherPlatform.instance = previousLauncher);
    launcher.urls.clear();
    FFAppState().pendingStripeCheckoutSessionId = '';
    currentUser = DecoyWalletAppSupabaseUser(user);
    failRead = false;
    requests.clear();
    entitlement = {
      'user_id': userId,
      'entitlement': 'decoy_wallet',
      'is_active': false,
      'provider': 'stripe',
      'current_period_end':
          DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      'promotional_access_until':
          DateTime.now().add(const Duration(days: 30)).toIso8601String()
    };
  });
  tearDown(() => currentUser = null);

  Widget shell(Widget child) => MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(fontFamily: 'robot', useMaterial3: false),
        home: child,
      );

  for (final scenario in ['promo', 'paid', 'expired', 'missing']) {
    testWidgets('My Subscription always opens management: $scenario',
        (tester) async {
      if (scenario == 'paid') {
        entitlement!['is_active'] = true;
        entitlement!['current_period_end'] =
            entitlement!['promotional_access_until'];
        entitlement!['promotional_access_until'] = null;
      } else if (scenario == 'expired') {
        entitlement!['promotional_access_until'] = null;
      } else if (scenario == 'missing') {
        entitlement = null;
      }
      final router = GoRouter(routes: [
        GoRoute(path: '/', builder: (_, __) => const SettingsWidget()),
        GoRoute(
            path: '/manage',
            name: ManageSubscriptionWidget.routeName,
            builder: (_, __) => const ManageSubscriptionWidget()),
        GoRoute(
            path: '/options',
            name: SubscriptionOptionsWidget.routeName,
            builder: (_, __) =>
                const Scaffold(body: Text('Purchase-only page'))),
      ]);
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(
          routerConfig: router,
          locale: const Locale('en'),
          theme: ThemeData(fontFamily: 'robot', useMaterial3: false),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales));
      await tester.pumpAndSettle();
      await tester.tap(find.text('My Subscription'));
      await tester.pumpAndSettle();
      expect(find.byType(ManageSubscriptionWidget), findsOneWidget);
      final days = scenario == 'expired' || scenario == 'missing' ? 0 : 30;
      expect(find.text('$days DAYS LEFT'), findsOneWidget);
      expect(find.text('Purchase-only page'), findsNothing);
      await tester.ensureVisible(find.text('$days DAYS LEFT'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  for (final width in [320.0, 402.0]) {
    for (final scenario in [
      'promo',
      'workshop',
      'stripe',
      'bitcoin',
      'mixed',
      'inactive-paid',
      'pending-stripe',
      'expired',
      'missing'
    ]) {
      testWidgets('management page shows remaining access: $scenario at $width',
          (tester) async {
        tester.view.physicalSize = Size(width, 874);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var days = 30;
        if (scenario == 'workshop') {
          days = 36500;
          entitlement!['promotional_access_until'] =
              DateTime.now().add(Duration(days: days)).toIso8601String();
        } else if (scenario == 'stripe' ||
            scenario == 'bitcoin' ||
            scenario == 'mixed') {
          entitlement!['is_active'] = true;
          entitlement!['provider'] =
              scenario == 'bitcoin' ? 'btcpay' : 'stripe';
          entitlement!['current_period_end'] =
              DateTime.now().add(const Duration(days: 15)).toIso8601String();
          if (scenario != 'mixed') {
            days = 15;
            entitlement!['promotional_access_until'] = null;
          }
        } else if (scenario == 'expired') {
          days = 0;
          entitlement!['promotional_access_until'] = DateTime.now()
              .subtract(const Duration(seconds: 1))
              .toIso8601String();
        } else if (scenario == 'missing') {
          days = 0;
          entitlement = null;
        } else if (scenario == 'inactive-paid') {
          entitlement!['current_period_end'] =
              DateTime.now().add(const Duration(days: 100)).toIso8601String();
        } else if (scenario == 'pending-stripe') {
          entitlement!['is_active'] = true;
          entitlement!['provider'] = 'btcpay';
          entitlement!['current_period_end'] =
              DateTime.now().add(const Duration(days: 15)).toIso8601String();
          entitlement!['pending_provider'] = 'stripe';
          entitlement!['pending_starts_at'] =
              entitlement!['current_period_end'];
          entitlement!['pending_provider_subscription_id'] =
              'synthetic-pending';
        }
        final before = jsonEncode(entitlement);
        final key = GlobalKey();
        await tester.pumpWidget(shell(RepaintBoundary(
            key: key, child: const ManageSubscriptionWidget())));
        await tester.pumpAndSettle();
        final remaining = find.text('$days DAYS LEFT');
        expect(remaining, findsOneWidget);
        await tester.ensureVisible(remaining);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(jsonEncode(entitlement), before);
        expect(find.text('Cancel Subscription'), findsNothing);
        final workshop = find.byType(WorkshopQrOptionCard);
        final redemption = find.byType(RedemptionOptionCard);
        expect(workshop, findsOneWidget);
        expect(tester.getSize(workshop), tester.getSize(redemption));
        expect(tester.getTopLeft(workshop).dy,
            greaterThan(tester.getBottomLeft(redemption).dy));
        expect(tester.getTopLeft(remaining).dy,
            greaterThan(tester.getBottomLeft(workshop).dy));
        if (days > 0) {
          expect(find.byKey(const ValueKey('subscription-access-end')),
              findsOneWidget);
        }
        if (const bool.fromEnvironment('DECOY_CAPTURE_SUBSCRIPTION') &&
            scenario == 'workshop') {
          final boundary =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          await tester.runAsync(() async {
            final image = await boundary.toImage();
            final bytes =
                await image.toByteData(format: ui.ImageByteFormat.png);
            final dir = Directory('/private/tmp/decoy-subscription-display');
            await dir.create(recursive: true);
            await File('${dir.path}/days-left-${width.toInt()}.png')
                .writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
      });
    }
  }

  testWidgets('failed access read offers retry instead of falsely showing zero',
      (tester) async {
    failRead = true;
    await tester.pumpWidget(shell(const ManageSubscriptionWidget()));
    await tester.pumpAndSettle();
    expect(find.text('0 DAYS LEFT'), findsNothing);
    final retry = find.text('Retry');
    expect(retry, findsOneWidget);
    await tester.ensureVisible(retry);
    failRead = false;
    await tester.tap(retry);
    await tester.pumpAndSettle();
    expect(find.text('30 DAYS LEFT'), findsOneWidget);
  });

  testWidgets('return from browser refreshes the displayed access',
      (tester) async {
    await tester.pumpWidget(shell(const ManageSubscriptionWidget()));
    await tester.pumpAndSettle();
    entitlement!['promotional_access_until'] =
        DateTime.now().add(const Duration(days: 36500)).toIso8601String();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('36500 DAYS LEFT'), findsOneWidget);
    expect(find.text('30 DAYS LEFT'), findsNothing);
  });

  testWidgets('active access with no expiry never invents zero days',
      (tester) async {
    entitlement!['is_active'] = true;
    entitlement!['current_period_end'] = null;
    entitlement!['promotional_access_until'] = null;
    await tester.pumpWidget(shell(const ManageSubscriptionWidget()));
    await tester.pumpAndSettle();
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('0 DAYS LEFT'), findsNothing);
    expect(find.byKey(const ValueKey('subscription-access-end')), findsNothing);
  });

  testWidgets('management keeps the shared scanner and refreshes after success',
      (tester) async {
    const scanner = MethodChannel('flutter_barcode_scanner');
    const permission =
        MethodChannel('flutter.baseflow.com/permissions/methods');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(scanner, (_) async => workshopPreviewQr);
    messenger.setMockMethodCallHandler(
        permission, (_) async => <int, int>{1: 1});
    addTearDown(() {
      messenger.setMockMethodCallHandler(scanner, null);
      messenger.setMockMethodCallHandler(permission, null);
    });
    await tester.pumpWidget(shell(const ManageSubscriptionWidget()));
    await tester.pumpAndSettle();
    final workshop = find.text('Workshop QR');
    await tester.ensureVisible(workshop);
    await tester.tap(workshop);
    await tester.pumpAndSettle();
    expect(find.text('Test QR recognized'), findsOneWidget);
    expect(find.byType(WorkshopQrPage), findsOneWidget);
    expect(requests.every((request) => request.method == 'GET'), isTrue);
    // Simulate the existing scanner returning a confirmed server result.
    entitlement!['promotional_access_until'] =
        DateTime.now().add(const Duration(days: 36500)).toIso8601String();
    Navigator.of(tester.element(find.byType(WorkshopQrPage))).pop(true);
    await tester.pumpAndSettle();
    expect(find.byType(ManageSubscriptionWidget), findsOneWidget);
    expect(find.text('36500 DAYS LEFT'), findsOneWidget);
  });

  for (final scenario in [
    'new-card',
    'bitcoin-switch',
    'stripe-portal',
    'cancel',
    'redeem',
    'bitcoin-invoice'
  ]) {
    for (final interval in ['monthly', 'yearly']) {
      testWidgets('management preserves $scenario $interval request',
          (tester) async {
        await http.runWithClient(() async {
          entitlement!['provider'] = null;
          entitlement!['current_period_end'] = null;
          if (scenario == 'bitcoin-switch' || scenario == 'bitcoin-invoice') {
            entitlement!['provider'] = 'btcpay';
            entitlement!['is_active'] = true;
            entitlement!['current_period_end'] =
                DateTime.now().add(const Duration(days: 15)).toIso8601String();
          } else if (scenario == 'stripe-portal' || scenario == 'cancel') {
            entitlement!['provider'] = 'stripe';
            entitlement!['is_active'] = true;
            entitlement!['provider_customer_id'] = 'synthetic-customer';
          }
          final before = jsonEncode(entitlement);
          await tester.pumpWidget(shell(const ManageSubscriptionWidget()));
          await tester.pumpAndSettle();
          if (interval == 'yearly') {
            await tester.tap(find.text('Yearly'));
            await tester.pumpAndSettle();
          }
          final button = find.text(switch (scenario) {
            'new-card' => 'Pay with Card',
            'bitcoin-switch' => 'Switch to Card Payments',
            'stripe-portal' => 'Manage Card Payments',
            'cancel' => 'Cancel Subscription',
            'redeem' => 'Redeem Code',
            _ => 'Renew Bitcoin Payments',
          });
          await tester.ensureVisible(button);
          await tester.tap(button);
          await tester.pumpAndSettle();
          await tester.pump(const Duration(seconds: 3));
          await tester.pumpAndSettle();
          expect(launcher.urls, ['https://test.invalid/checkout']);
          expect(jsonEncode(entitlement), before);
          expect(tester.takeException(), isNull);
        },
            () => MockClient((request) async {
                  final expectedPath = switch (scenario) {
                    'stripe-portal' ||
                    'cancel' =>
                      '/create-billing-portal-session',
                    'redeem' => '/create-redemption-session',
                    'bitcoin-invoice' => '/create-btcpay-invoice',
                    _ => '/create-checkout-session',
                  };
                  expect(request.url.host, 'test.invalid');
                  expect(request.url.path, expectedPath);
                  expect(request.method, 'POST');
                  final body = jsonDecode(request.body) as Map<String, dynamic>;
                  if (scenario == 'redeem') {
                    expect(body, {'return_to': 'home'});
                  } else {
                    expect(body['user_id'], userId);
                    if (scenario == 'stripe-portal' || scenario == 'cancel') {
                      expect(body['customer_id'], 'synthetic-customer');
                      expect(body['return_url'], kBillingReturnUrl);
                    } else {
                      expect(body['billing_interval'], interval);
                      if (scenario == 'bitcoin-switch') {
                        expect(
                            body['trial_end'],
                            DateTime.parse(entitlement!['current_period_end'])
                                    .millisecondsSinceEpoch ~/
                                1000);
                      } else {
                        expect(body['trial_end'], isNull);
                      }
                    }
                  }
                  return http.Response(
                      jsonEncode({
                        'url': 'https://test.invalid/checkout',
                        'session_id': 'synthetic-checkout',
                      }),
                      200,
                      headers: {'content-type': 'application/json'});
                }));
      }, skip: kPaymentBaseUrl != 'https://test.invalid');
    }
  }
}
