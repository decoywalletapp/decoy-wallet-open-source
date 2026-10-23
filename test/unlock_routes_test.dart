import 'dart:async';
import 'package:decoy_wallet_app/auth/base_auth_user_provider.dart';
import 'package:decoy_wallet_app/flutter_flow/nav/nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class SyntheticUser extends BaseAuthUser {
  SyntheticUser(this.id);
  final String? id;
  @override
  bool get loggedIn => id != null;
  @override
  bool get emailVerified => true;
  @override
  AuthUserInfo get authUserInfo => AuthUserInfo(uid: id);
  @override
  Future? delete() => null;
  @override
  Future? updateEmail(String email) => null;
  @override
  Future? updatePassword(String password) => null;
  @override
  Future? sendEmailVerification() => null;
}

void main() {
  final app = AppStateNotifier.instance;
  late GoRouter router;
  final constructed = <String>[];
  setUp(() {
    app.unlock.lock();
    app.clearRedirectLocation();
    app.update(SyntheticUser('synthetic-owner'));
    app.stopShowingSplashImage();
    constructed.clear();
  });
  tearDown(() => router.dispose());

  Future<void> launch(WidgetTester tester, String location) async {
    final production = createRouter(app);
    final routes = production.configuration.routes
        .cast<GoRoute>()
        .map((r) => (r.name!, r.path))
        .toList();
    production.dispose();
    router = GoRouter(
        initialLocation: location,
        refreshListenable: app,
        errorBuilder: (_, __) => const Text('unknown-route'),
        routes: routes
            .map((r) => FFRoute(
                name: r.$1,
                path: r.$2,
                builder: (_, __) {
                  constructed.add(r.$1);
                  return Text(r.$1, textDirection: TextDirection.ltr);
                }).toRoute(app))
            .toList());
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
  }

  for (final uri in [
    '/settings',
    '/SeTTiNgS',
    '/settings/',
    '/settings?isLocked=false&unlocked=true#owner',
    '/%73ettings',
    '/foo/../settings',
    '/controlCenter',
    '/emergencyContacts',
    '/changePin',
    '/createPin',
    '/updatePasswordPage?type=recovery',
    '/duressHomePage',
    '/paymentReturn?session_id=fake-test-only'
  ]) {
    testWidgets('locked route cannot construct private page: $uri',
        (tester) async {
      await launch(tester, uri);
      expect(constructed.where((n) => !{'AuthRouter', 'LoginPage'}.contains(n)),
          isEmpty);
    });
  }

  testWidgets(
      'owner PIN allows intended destination and preserves checkout query',
      (tester) async {
    await launch(tester, '/paymentReturn?session_id=synthetic-checkout');
    expect(constructed, isNot(contains('PaymentReturn')));
    app.unlock.preparePin(app.unlock.attempt, paidDecoyAllowed: false);
    app.unlock.unlockOwner(app.unlock.attempt);
    await tester.pumpAndSettle();
    expect(constructed, contains('PaymentReturn'));
    expect(
        router.routeInformationProvider.value.uri.queryParameters['session_id'],
        'synthetic-checkout');
  });

  testWidgets(
      'private pages are removed when proof is revoked beneath a public page',
      (tester) async {
    app.unlock.preparePin(app.unlock.attempt, paidDecoyAllowed: true);
    app.unlock.unlockOwner(app.unlock.attempt);
    await launch(tester, '/settings');
    expect(find.text('Settings'), findsOneWidget);
    unawaited(router.push('/privacyPolicy'));
    await tester.pumpAndSettle();
    expect(router.canPop(), isTrue);
    app.unlock.lock();
    await tester.pumpAndSettle();
    expect(find.text('Settings', skipOffstage: false), findsNothing);
    if (router.canPop()) router.pop();
    await tester.pumpAndSettle();
    expect(find.text('Settings', skipOffstage: false), findsNothing);
  });

  testWidgets(
      'decoy cannot escape through owner, entry, legal, recovery or first-PIN links',
      (tester) async {
    final attempt = app.unlock.attempt;
    app.unlock.preparePin(attempt, paidDecoyAllowed: true);
    app.unlock.beginDecoy(attempt);
    app.unlock.finishDecoy(attempt);
    await launch(tester, '/duressHomePage');
    for (final route in [
      '/settings',
      '/',
      '/loginPage',
      '/authRouter',
      '/createPin',
      '/updatePasswordPage?type=recovery',
      '/privacyPolicy',
      '/SeTTiNgS/'
    ]) {
      router.go(route);
      await tester.pumpAndSettle();
      expect(find.text('DuressHomePage'), findsOneWidget);
    }
    expect(constructed.toSet(), {'DuressHomePage'});
    expect(app.hasRedirect(), isFalse);
  });

  testWidgets('first-time setup is limited and cannot open owner settings',
      (tester) async {
    app.unlock.allowSetup(app.unlock.attempt,
        setupComplete: false, hasAccountPin: false);
    await launch(tester, '/createPin');
    expect(find.text('CreatePin'), findsOneWidget);
    router.go('/settings');
    await tester.pumpAndSettle();
    expect(constructed, isNot(contains('Settings')));
    expect(find.text('AuthRouter'), findsOneWidget);
  });

  testWidgets('existing simulated feature pages stay inside decoy mode',
      (tester) async {
    final attempt = app.unlock.attempt;
    app.unlock.preparePin(attempt, paidDecoyAllowed: true);
    app.unlock.beginDecoy(attempt);
    app.unlock.finishDecoy(attempt);
    await launch(tester, '/wallet-feature-preview?feature=recurring-buy');
    expect(find.text('WalletFeaturePreview'), findsOneWidget);
    router.go('/configure-bitcoin-balance');
    await tester.pumpAndSettle();
    expect(find.text('DuressHomePage'), findsOneWidget);
    expect(constructed, isNot(contains('ConfigureBitcoinBalance')));
  });

  testWidgets(
      'successful decoy grant does not interrupt the initiating PIN widget',
      (tester) async {
    final attempt = app.unlock.attempt;
    app.unlock.preparePin(attempt, paidDecoyAllowed: true);
    await launch(tester, '/PINPage');
    app.unlock.beginDecoy(attempt);
    await tester.pumpAndSettle();
    expect(find.text('PINPage'), findsOneWidget);
    app.unlock.finishDecoy(attempt);
    await tester.pumpAndSettle();
    expect(find.text('DuressHomePage'), findsOneWidget);
    expect(constructed, isNot(contains('HomePage')));
  });

  testWidgets(
      'same-user session refresh preserves unlock but a new user cannot reuse it',
      (tester) async {
    app.unlock.preparePin(app.unlock.attempt, paidDecoyAllowed: true);
    app.unlock.unlockOwner(app.unlock.attempt);
    await launch(tester, '/settings');
    app.update(SyntheticUser('synthetic-owner'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    app.update(SyntheticUser('different-owner'));
    await tester.pumpAndSettle();
    expect(find.text('Settings', skipOffstage: false), findsNothing);
    expect(find.text('AuthRouter'), findsOneWidget);
  });

  testWidgets('raw recovery query cannot replace verified recovery capability',
      (tester) async {
    await launch(tester, '/updatePasswordPage?type=recovery');
    expect(constructed, isNot(contains('UpdatePasswordPage')));
    app.clearRedirectLocation();
    app.unlock.allowRecovery(app.unlock.attempt);
    router.go('/updatePasswordPage');
    await tester.pumpAndSettle();
    expect(find.text('UpdatePasswordPage'), findsOneWidget);
    router.go('/settings');
    await tester.pumpAndSettle();
    expect(constructed, isNot(contains('Settings')));
  });

  testWidgets('every configured owner route is denied before its builder runs',
      (tester) async {
    await launch(tester, '/authRouter');
    final production = createRouter(app);
    final ownerRoutes = production.configuration.routes
        .cast<GoRoute>()
        .where((r) =>
            FFRoute(
                name: r.name!,
                path: r.path,
                builder: (_, __) => const SizedBox()).access ==
            AppRouteAccess.owner)
        .toList();
    production.dispose();
    expect(ownerRoutes.length, greaterThan(15));
    for (final route in ownerRoutes) {
      app.clearRedirectLocation();
      router.go(route.path);
      await tester.pumpAndSettle();
      expect(constructed, isNot(contains(route.name)), reason: route.name);
      expect(find.text('AuthRouter'), findsOneWidget);
    }
  });

  testWidgets('late async route data cannot rebuild a private page after lock',
      (tester) async {
    final completion = Completer<dynamic>();
    app.unlock.preparePin(app.unlock.attempt, paidDecoyAllowed: true);
    app.unlock.unlockOwner(app.unlock.attempt);
    router = GoRouter(
        initialLocation: '/settings?document=synthetic',
        refreshListenable: app,
        routes: [
          FFRoute(
              name: 'Settings',
              path: '/settings',
              asyncParams: {'document': (_) => completion.future},
              builder: (_, __) {
                constructed.add('Settings');
                return const Text('private-data');
              }).toRoute(app),
          FFRoute(
              name: 'AuthRouter',
              path: '/authRouter',
              builder: (_, __) => const Text('unlock')).toRoute(app),
        ]);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump();
    final beforeLock = constructed.length;
    app.unlock.lock();
    await tester.pumpAndSettle();
    completion.complete('synthetic-document');
    await tester.pumpAndSettle();
    expect(constructed.length, beforeLock);
    expect(find.text('private-data', skipOffstage: false), findsNothing);
  });

  testWidgets(
      'pending checkout does not suppress the real PIN navigation helper',
      (tester) async {
    await launch(tester, '/paymentReturn?session_id=synthetic-handoff');
    final context = tester.element(find.text('AuthRouter'));
    app.unlock.preparePin(app.unlock.attempt, paidDecoyAllowed: false);
    context.goNamedAuth('PINPage', context.mounted);
    await tester.pumpAndSettle();
    expect(find.text('PINPage'), findsOneWidget);
    expect(app.hasRedirect(), isTrue);
    app.unlock.unlockOwner(app.unlock.attempt);
    await tester.pumpAndSettle();
    expect(find.text('PaymentReturn'), findsOneWidget);
    expect(
        router.routeInformationProvider.value.uri.queryParameters['session_id'],
        'synthetic-handoff');
  });

  testWidgets(
      'signed-out signup may display confirmation instructions, not settings',
      (tester) async {
    app.update(SyntheticUser(null));
    await launch(
        tester, '/confirmEmailPage?emailEntry=synthetic@example.invalid');
    expect(find.text('confirmEmailPage'), findsOneWidget);
    router.go('/settings');
    await tester.pumpAndSettle();
    expect(constructed, isNot(contains('Settings')));
    expect(find.text('LoginPage'), findsOneWidget);
  });

  testWidgets('an account switch drops the previous account continuation',
      (tester) async {
    await launch(tester, '/paymentReturn?session_id=previous-account');
    expect(app.hasRedirect(), isTrue);
    app.update(SyntheticUser('new-account'));
    expect(app.hasRedirect(), isFalse);
    await tester.pumpAndSettle();
  });
}
