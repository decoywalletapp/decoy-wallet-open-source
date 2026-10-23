import 'package:decoy_wallet_app/auth/base_auth_user_provider.dart';
import 'package:decoy_wallet_app/flutter_flow/nav/nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TestUser extends BaseAuthUser {
  TestUser(this.id);
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
  Future<GoRouter> launch(WidgetTester tester, String? id) async {
    final state = AppStateNotifier.instance;
    state.clearRedirectLocation();
    state.update(TestUser(id));
    state.stopShowingSplashImage();
    final router = GoRouter(
      initialLocation: '/homePage',
      refreshListenable: state,
      routes: [
        FFRoute(
            name: 'HomePage',
            path: '/homePage',
            requireAuth: true,
            builder: (_, __) => const Text('owner-settings')).toRoute(state),
        FFRoute(
            name: 'AuthRouter',
            path: '/authRouter',
            builder: (_, __) => const Text('unlock-required')).toRoute(state),
        FFRoute(
            name: 'LoginPage',
            path: '/loginPage',
            builder: (_, __) => const Text('login')).toRoute(state),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    return router;
  }

  testWidgets('baseline control: signed-out visitor is sent to login',
      (tester) async {
    final router = await launch(tester, null);
    expect(find.text('login'), findsOneWidget);
    expect(find.text('owner-settings'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    router.dispose();
  });

  testWidgets(
      'retained login now requires local unlock before owner construction',
      (tester) async {
    final router = await launch(tester, 'synthetic-owner');
    expect(find.text('owner-settings'), findsNothing);
    expect(find.text('unlock-required'), findsOneWidget);
    expect(find.text('login'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    router.dispose();
  });
}
