import 'dart:async';

import 'package:decoy_wallet_app/auth/base_auth_user_provider.dart';
import 'package:decoy_wallet_app/flutter_flow/nav/nav.dart';
import 'package:decoy_wallet_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _User extends BaseAuthUser {
  @override
  bool get loggedIn => true;
  @override
  bool get emailVerified => true;
  @override
  AuthUserInfo get authUserInfo => AuthUserInfo(uid: 'synthetic-owner');
  @override
  Future? delete() => null;
  @override
  Future? updateEmail(String email) => null;
  @override
  Future? updatePassword(String password) => null;
  @override
  Future? sendEmailVerification() => null;
}

class _PinProbe extends StatefulWidget {
  const _PinProbe();

  @override
  State<_PinProbe> createState() => _PinProbeState();
}

class _PinProbeState extends State<_PinProbe> {
  @override
  Widget build(BuildContext context) => const Text('PIN');
}

class _DecoyProbe extends StatefulWidget {
  const _DecoyProbe();

  @override
  State<_DecoyProbe> createState() => _DecoyProbeState();
}

class _DecoyProbeState extends State<_DecoyProbe> {
  @override
  Widget build(BuildContext context) => const Text('DECOY');
}

class _HomeProbe extends StatefulWidget {
  const _HomeProbe();

  @override
  State<_HomeProbe> createState() => _HomeProbeState();
}

class _HomeProbeState extends State<_HomeProbe> {
  @override
  Widget build(BuildContext context) => const Text('HOME');
}

void main() {
  final app = AppStateNotifier.instance;
  late GoRouter router;
  late State originalPin;
  var privateBuilds = 0;

  setUp(() {
    app.update(_User());
    app.stopShowingSplashImage();
    app.unlock.lock();
    app.clearRedirectLocation();
    app.unlock.preparePin(app.unlock.attempt, paidDecoyAllowed: true);
    privateBuilds = 0;
  });
  tearDown(() => router.dispose());

  Future<void> launch(WidgetTester tester, TargetPlatform platform,
      {bool animatedEntry = true, bool reducedMotion = false}) async {
    router = GoRouter(
      initialLocation: '/PINPage',
      initialExtra: animatedEntry
          ? {
              kTransitionInfoKey: const TransitionInfo(
                  hasTransition: true, duration: Duration(milliseconds: 220)),
            }
          : null,
      refreshListenable: app,
      routes: [
        FFRoute(
            name: 'PINPage',
            path: '/PINPage',
            builder: (_, __) => const _PinProbe()).toRoute(app),
        FFRoute(
            name: 'DuressHomePage',
            path: '/duressHomePage',
            builder: (_, __) => const _DecoyProbe()).toRoute(app),
        FFRoute(
            name: 'HomePage',
            path: '/homePage',
            builder: (_, __) => const _HomeProbe()).toRoute(app),
        FFRoute(
            name: 'AuthRouter',
            path: '/authRouter',
            builder: (_, __) => const Text('AUTH')).toRoute(app),
        FFRoute(
            name: 'Settings',
            path: '/settings',
            builder: (_, __) {
              privateBuilds++;
              return const Text('PRIVATE');
            }).toRoute(app),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(disableAnimations: reducedMotion),
            child: child!),
        theme: ThemeData(platform: platform),
        routerConfig: router));
    await tester.pumpAndSettle();
    originalPin = tester.state(find.byType(_PinProbe));
    // Match the native Router's serialized route report before a later refresh.
    // Widget tests do not reliably exercise this round trip automatically.
    router.routeInformationProvider.routerReportsNewRouteInformation(router
        .routeInformationParser
        .restoreRouteInformation(router.routerDelegate.currentConfiguration)!);
  }

  Future<void> enterWallet(WidgetTester tester, bool decoy) async {
    final attempt = app.unlock.attempt;
    if (decoy) {
      expect(app.unlock.beginDecoy(attempt), isTrue);
      await tester.pump();
      expect(app.unlock.finishDecoy(attempt), isTrue);
    } else {
      expect(app.unlock.unlockOwner(attempt), isTrue);
    }
    await tester.pump();
  }

  for (final decoy in [false, true]) {
    final destination = decoy ? 'decoy wallet' : 'normal home';
    final probe = find.byType(decoy ? _DecoyProbe : _HomeProbe);
    final slide = find.byKey(const ValueKey('wallet-entry-slide'));
    final backdrop = find.byKey(const ValueKey('wallet-transition-backdrop'));

    for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
      for (final reducedMotion in [false, true]) {
        testWidgets(
            '$destination appears directly without an intermediate title: '
            '$platform, reducedMotion=$reducedMotion', (tester) async {
          await launch(tester, platform, reducedMotion: reducedMotion);
          await enterWallet(tester, decoy);
          await tester.pump(const Duration(milliseconds: 32));
          expect(app.unlock.allows(AppRouteAccess.pin), isFalse);
          expect(originalPin.mounted, isFalse);
          expect(find.byType(_PinProbe), findsNothing);
          expect(backdrop, findsNothing);
          expect(slide, findsNothing);
          expect(probe, findsOneWidget);
          expect(privateBuilds, 0);
          final route = ModalRoute.of(tester.element(probe))!;
          expect(route.settings, isA<NoTransitionPage<void>>());
          expect(route.transitionDuration, Duration.zero);

          final originalWallet = tester.state(probe);
          expect(
              find.ancestor(of: probe, matching: find.byType(FadeTransition)),
              findsNothing);
          // A native report must not replace the page or restart its animation.
          router.routeInformationProvider.routerReportsNewRouteInformation(
              router.routeInformationParser.restoreRouteInformation(
                  router.routerDelegate.currentConfiguration)!);
          app.notifyListeners();
          await tester.pump();
          expect(tester.state(probe), same(originalWallet));
          expect(slide, findsNothing);
          await tester.pump(const Duration(milliseconds: 128));
          expect(slide, findsNothing);
          expect(backdrop, findsNothing);
          await tester.pumpAndSettle();
          expect(slide, findsNothing);
          expect(tester.state(probe), same(originalWallet));

          router.go('/settings');
          await tester.pumpAndSettle();
          expect(find.text('PRIVATE'), decoy ? findsNothing : findsOneWidget);
          if (decoy) {
            expect(probe, findsOneWidget);
            expect(privateBuilds, 0);
          }
          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('$destination is still inaccessible before PIN verification',
        (tester) async {
      await launch(tester, TargetPlatform.iOS);
      router.go(decoy ? '/duressHomePage' : '/homePage');
      await tester.pumpAndSettle();
      expect(tester.state(find.byType(_PinProbe)), same(originalPin));
      expect(probe, findsNothing);
      expect(privateBuilds, 0);
    });

    testWidgets('$destination disappears immediately if locked after entry',
        (tester) async {
      await launch(tester, TargetPlatform.iOS);
      await enterWallet(tester, decoy);
      await tester.pump(const Duration(milliseconds: 32));
      final wallet = tester.state(probe);
      expect(slide, findsNothing);
      app.unlock.lock();
      await tester.pump();
      expect(wallet.mounted, isFalse);
      expect(probe, findsNothing);
      expect(find.byType(_PinProbe), findsNothing);
      await tester.pumpAndSettle();
      expect(find.text('AUTH'), findsOneWidget);
      expect(privateBuilds, 0);
    });
  }

  testWidgets('normal home is removed before entering decoy mode',
      (tester) async {
    await launch(tester, TargetPlatform.iOS);
    await enterWallet(tester, false);
    await tester.pumpAndSettle();
    final home = tester.state(find.byType(_HomeProbe));
    app.unlock.lock();
    app.unlock.preparePin(app.unlock.attempt, paidDecoyAllowed: true);
    await tester.pumpAndSettle();
    expect(home.mounted, isFalse);
    expect(find.byType(_HomeProbe), findsNothing);
    final attempt = app.unlock.attempt;
    app.unlock.beginDecoy(attempt);
    await tester.pump();
    app.unlock.finishDecoy(attempt);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 32));
    expect(find.byType(_HomeProbe), findsNothing);
    expect(
        find.byKey(const ValueKey('wallet-transition-backdrop')), findsNothing);
    router.go('/homePage');
    await tester.pumpAndSettle();
    expect(find.text('DECOY'), findsOneWidget);
    expect(find.byType(_HomeProbe), findsNothing);
    expect(privateBuilds, 0);
  });

  for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
    for (final animatedEntry in [false, true]) {
      testWidgets(
          'pending decoy preserves PIN state: $platform, '
          'animated=$animatedEntry', (tester) async {
        await launch(tester, platform, animatedEntry: animatedEntry);
        final attempt = app.unlock.attempt;
        expect(app.unlock.beginDecoy(attempt), isTrue);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        expect(tester.state(find.byType(_PinProbe)), same(originalPin));
        expect(originalPin.mounted, isTrue);

        router.go('/settings');
        await tester.pumpAndSettle();
        expect(tester.state(find.byType(_PinProbe)), same(originalPin));
        expect(privateBuilds, 0);
        expect(app.unlock.finishDecoy(attempt), isTrue);
        await tester.pumpAndSettle();
        expect(find.text('DECOY'), findsOneWidget);
        router.go('/settings');
        await tester.pumpAndSettle();
        expect(find.text('DECOY'), findsOneWidget);
        expect(privateBuilds, 0);
      });
    }
  }

  testWidgets('failed preparation keeps the same PIN available for retry',
      (tester) async {
    await launch(tester, TargetPlatform.iOS);
    final attempt = app.unlock.attempt!;
    app.unlock.beginDecoy(attempt);
    final preparation = Completer<void>();
    final pending =
        app.unlock.runDecoyPreparation(attempt, () => preparation.future);
    final failure = expectLater(pending, throwsStateError);
    await tester.pumpAndSettle();
    preparation.completeError(StateError('synthetic failure'));
    await failure;
    await tester.pumpAndSettle();
    expect(tester.state(find.byType(_PinProbe)), same(originalPin));
    expect(app.unlock.pinReady, isTrue);
    expect(app.unlock.ownerUnlocked, isFalse);
    expect(app.unlock.beginDecoy(app.unlock.attempt), isTrue);
    await tester.pumpAndSettle();
    expect(tester.state(find.byType(_PinProbe)), same(originalPin));
    expect(privateBuilds, 0);
  });

  testWidgets('revoked proof still removes PIN and rejects late completion',
      (tester) async {
    await launch(tester, TargetPlatform.iOS);
    final attempt = app.unlock.attempt;
    app.unlock.beginDecoy(attempt);
    await tester.pumpAndSettle();
    app.unlock.lock();
    await tester.pumpAndSettle();
    expect(originalPin.mounted, isFalse);
    expect(find.text('AUTH'), findsOneWidget);
    expect(app.unlock.finishDecoy(attempt), isFalse);
    expect(privateBuilds, 0);
  });
}
