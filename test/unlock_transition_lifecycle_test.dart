import 'dart:async';

import 'package:decoy_wallet_app/auth/base_auth_user_provider.dart';
import 'package:decoy_wallet_app/flutter_flow/nav/nav.dart';
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
      {bool animatedEntry = true}) async {
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
            builder: (_, __) => const Text('DECOY')).toRoute(app),
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
        theme: ThemeData(platform: platform), routerConfig: router));
    await tester.pumpAndSettle();
    originalPin = tester.state(find.byType(_PinProbe));
    // Match the native Router's serialized route report before a later refresh.
    // Widget tests do not reliably exercise this round trip automatically.
    router.routeInformationProvider.routerReportsNewRouteInformation(router
        .routeInformationParser
        .restoreRouteInformation(router.routerDelegate.currentConfiguration)!);
  }

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
