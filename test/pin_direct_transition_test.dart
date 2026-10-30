import 'package:decoy_wallet_app/auth/base_auth_user_provider.dart';
import 'package:decoy_wallet_app/components/pin_unlock_handoff.dart';
import 'package:decoy_wallet_app/components/wallet_title_splash.dart';
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

void main() {
  testWidgets('pending PIN keeps input visible without a title interstitial',
      (tester) async {
    final active = ValueNotifier(false);
    addTearDown(active.dispose);
    var taps = 0;
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: ValueListenableBuilder<bool>(
          valueListenable: active,
          child: TextButton(
            onPressed: () => taps++,
            child: const Text('PIN INPUT'),
          ),
          builder: (_, value, child) =>
              PinUnlockHandoff(active: value, child: child!),
        ),
      ),
    ));
    final original = tester.element(find.byType(TextButton));
    active.value = true;
    await tester.pumpAndSettle();
    expect(find.byType(WalletTitleSplash), findsNothing);
    expect(tester.element(find.byType(TextButton)), same(original));
    expect(find.text('PIN INPUT').hitTestable(), findsNothing);
    expect(find.byType(Opacity), findsNothing);
    expect(taps, 0);
    active.value = false;
    await tester.pump();
    await tester.tap(find.text('PIN INPUT'));
    expect(taps, 1);
  });

  for (final decoy in [false, true]) {
    testWidgets(
        'verified PIN enters destination without branding: decoy=$decoy',
        (tester) async {
      final app = AppStateNotifier.instance;
      app.update(_User());
      app.stopShowingSplashImage();
      app.clearRedirectLocation();
      app.unlock.lock();
      app.unlock.preparePin(app.unlock.attempt, paidDecoyAllowed: true);
      final router = GoRouter(
        initialLocation: '/PINPage',
        refreshListenable: app,
        routes: [
          FFRoute(
              name: 'PINPage',
              path: '/PINPage',
              builder: (_, __) => const Text('PIN')).toRoute(app),
          FFRoute(
              name: 'HomePage',
              path: '/homePage',
              builder: (_, __) => const Text('HOME')).toRoute(app),
          FFRoute(
              name: 'DuressHomePage',
              path: '/duressHomePage',
              builder: (_, __) => const Text('DECOY')).toRoute(app),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ));
      await tester.pumpAndSettle();
      final attempt = app.unlock.attempt;
      if (decoy) {
        app.unlock.beginDecoy(attempt);
        app.unlock.finishDecoy(attempt);
      } else {
        app.unlock.unlockOwner(attempt);
      }
      await tester.pump();
      await tester.pump();
      final destination = find.text(decoy ? 'DECOY' : 'HOME');
      expect(destination, findsOneWidget);
      expect(find.text('PIN'), findsNothing);
      expect(find.byType(WalletTitleSplash), findsNothing);
      expect(ModalRoute.of(tester.element(destination))!.transitionDuration,
          Duration.zero);
    });
  }
}
