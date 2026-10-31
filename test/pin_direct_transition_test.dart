import 'dart:ui' as ui;

import 'package:decoy_wallet_app/auth/base_auth_user_provider.dart';
import 'package:decoy_wallet_app/components/pin_unlock_handoff.dart';
import 'package:decoy_wallet_app/components/wallet_title_splash.dart';
import 'package:decoy_wallet_app/flutter_flow/nav/nav.dart';
import 'package:decoy_wallet_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  Future<int> pixel(WidgetTester tester, GlobalKey key,
      {double horizontal = 0}) async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    return (await tester.runAsync(() async {
      final image = await boundary.toImage();
      try {
        final bytes =
            (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
        final x = (horizontal * (image.width - 1)).round();
        return bytes.getUint8((image.width + x) * 4);
      } finally {
        image.dispose();
      }
    }))!;
  }

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
        'verified PIN uses opaque account slide or unchanged Decoy fade: decoy=$decoy',
        (tester) async {
      final app = AppStateNotifier.instance;
      app.update(_User());
      app.stopShowingSplashImage();
      app.clearRedirectLocation();
      app.unlock.lock();
      app.unlock.preparePin(app.unlock.attempt, paidDecoyAllowed: true);
      final frame = GlobalKey();
      final router = GoRouter(
        initialLocation: '/PINPage',
        refreshListenable: app,
        routes: [
          FFRoute(
              name: 'PINPage',
              path: '/PINPage',
              builder: (_, __) => const ColoredBox(
                  color: Colors.black,
                  child: Center(child: Text('PIN')))).toRoute(app),
          FFRoute(
              name: 'HomePage',
              path: '/homePage',
              builder: (_, __) => const ColoredBox(
                  color: Colors.white,
                  child: Center(child: Text('HOME')))).toRoute(app),
          FFRoute(
              name: 'DuressHomePage',
              path: '/duressHomePage',
              builder: (_, __) => const ColoredBox(
                  color: Colors.white,
                  child: Center(child: Text('DECOY')))).toRoute(app),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(RepaintBoundary(
          key: frame,
          child: MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          )));
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
      final route = ModalRoute.of(tester.element(destination))!;
      expect(route.transitionDuration, const Duration(milliseconds: 280));
      expect(route.reverseTransitionDuration, Duration.zero);
      final fade = find.byKey(const ValueKey('wallet-entry-fade'));
      final slide = find.byKey(const ValueKey('account-home-entry-slide'));
      expect(fade, decoy ? findsOneWidget : findsNothing);
      expect(slide, decoy ? findsNothing : findsOneWidget);
      if (decoy) {
        expect(tester.widget<FadeTransition>(fade).opacity.value, 0);
      } else {
        expect(tester.widget<SlideTransition>(slide).position.value,
            const Offset(1, 0));
      }
      expect(await pixel(tester, frame), 0);
      await tester.pump(const Duration(milliseconds: 80));
      final partial = decoy
          ? tester.widget<FadeTransition>(fade).opacity.value
          : 1 - tester.widget<SlideTransition>(slide).position.value.dx;
      expect(partial, greaterThan(0));
      expect(partial, lessThan(1));
      if (decoy) {
        expect(await pixel(tester, frame), inInclusiveRange(1, 254));
      } else {
        expect(await pixel(tester, frame), 0);
        expect(await pixel(tester, frame, horizontal: 0.99), 255);
      }
      expect(find.byType(WalletTitleSplash), findsNothing);
      await tester.pumpAndSettle();
      if (decoy) {
        expect(tester.widget<FadeTransition>(fade).opacity.value, 1);
      } else {
        expect(tester.widget<SlideTransition>(slide).position.value, Offset.zero);
      }
      expect(await pixel(tester, frame), 255);
    });
  }
}
