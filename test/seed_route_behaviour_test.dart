import 'dart:convert';

import 'package:decoy_wallet_app/app_state.dart';
import 'package:decoy_wallet_app/auth/base_auth_user_provider.dart';
import 'package:decoy_wallet_app/create_decoy_seed/generate_decoy_seed_phrase/generate_decoy_seed_phrase_widget.dart';
import 'package:decoy_wallet_app/create_decoy_seed/seed_handoff.dart';
import 'package:decoy_wallet_app/create_decoy_seed/seed_phrase_verification/seed_phrase_verification_widget.dart';
import 'package:decoy_wallet_app/create_decoy_seed/show_decoy_seed_phrase/show_decoy_seed_phrase_widget.dart';
import 'package:decoy_wallet_app/flutter_flow/nav/nav.dart';
import 'package:decoy_wallet_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'localization_fonts.dart';

class _User extends BaseAuthUser {
  _User(this.id);
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

// Attacker-chosen words in a crafted link, and an unrelated pending seed.
const _injected =
    'abandon abandon abandon abandon abandon abandon abandon abandon '
    'abandon abandon abandon about';
const _pending = 'legal winner thank year wave sausage worth useful legal '
    'winner thank yellow';

/// Drives the production seed routes from `createRouter` and checks what the
/// router exposes: the location, `extra`, and every route update sent to the
/// platform (the browser URL and history state on web).
void main() {
  final app = AppStateNotifier.instance;
  final reported = <Object?>[];
  GoRouter? router;

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await loadLocalizationFonts();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    FFAppState.reset();
    await FFAppState().initializePersistedState();
    app.unlock.lock();
    app.clearRedirectLocation();
    app.update(_User('seed-route-owner'));
    app.stopShowingSplashImage();
    app.unlock.preparePin(app.unlock.attempt, paidDecoyAllowed: false);
    expect(app.unlock.unlockOwner(app.unlock.attempt), isTrue);
    SeedHandoff.clear();
    reported.clear();
  });

  tearDown(() {
    router?.dispose();
    router = null;
    SeedHandoff.clear();
  });

  Future<void> launch(WidgetTester tester, String location) async {
    tester.view.physicalSize = const Size(430, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.navigation, (call) async {
      if (call.method == 'routeInformationUpdated') {
        reported.add(call.arguments);
      }
      return null;
    });
    addTearDown(() =>
        messenger.setMockMethodCallHandler(SystemChannels.navigation, null));

    final production = createRouter(app);
    final seedRoutes = {
      GenerateDecoySeedPhraseWidget.routeName,
      ShowDecoySeedPhraseWidget.routeName,
      SeedPhraseVerificationWidget.routeName,
    };
    final routes = production.configuration.routes
        .whereType<GoRoute>()
        .where((r) => seedRoutes.contains(r.name))
        .toList();
    production.dispose();
    expect(routes, hasLength(3));

    router = GoRouter(
      initialLocation: location,
      refreshListenable: app,
      errorBuilder: (_, __) => const Text('unknown-route'),
      routes: routes,
    );
    await tester.pumpWidget(MaterialApp.router(
      routerConfig: router,
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ));
    await tester.pumpAndSettle();
  }

  Uri location() => router!.routeInformationProvider.value.uri;

  List<RouteMatchList> matchLists() {
    final top = router!.routerDelegate.currentConfiguration;
    return [
      top,
      for (final m in top.matches)
        if (m is ImperativeRouteMatch) m.matches,
    ];
  }

  // A leaked phrase or word list keeps neighbouring words next to each other
  // once punctuation, quotes and %-escapes are collapsed to spaces.
  void expectNoAdjacentWords(String haystack, List<String> words) {
    final flat =
        ' ${haystack.toLowerCase().replaceAll(RegExp('[^a-z]+'), ' ')} ';
    for (var i = 0; i + 1 < words.length; i++) {
      expect(flat, isNot(contains(' ${words[i]} ${words[i + 1]} ')),
          reason: 'words ${i + 1}-${i + 2} of the seed reached the router');
    }
  }

  testWidgets('generating a seed shows it without putting it in the router',
      (tester) async {
    await launch(tester, GenerateDecoySeedPhraseWidget.routePath);
    final strings = AppLocalizations.of(
        tester.element(find.byType(GenerateDecoySeedPhraseWidget)))!;
    final generate = find.text(strings.msgGenerateSeedPhrase);
    await tester.ensureVisible(generate);
    await tester.tap(generate);
    await tester.pumpAndSettle();

    expect(find.byType(ShowDecoySeedPhraseWidget), findsOneWidget);
    final decoyId = FFAppState().decoyActiveId;
    final mnemonic = SeedHandoff.mnemonicFor(decoyId);
    expect(mnemonic, isNotNull);
    final words = mnemonic!.split(' ');
    expect(words, hasLength(12));
    expect(find.text(words.first), findsWidgets);

    // Pushed routes keep the browser URL unchanged; check the pushed match.
    final shown = matchLists().last.uri;
    expect(shown.path, ShowDecoySeedPhraseWidget.routePath);
    expect(shown.queryParameters, {'decoyId': decoyId});
    expect(reported, isNotEmpty, reason: 'route updates must be observed');
    for (final list in matchLists()) {
      expect(list.extra, isNull);
      expect(list.uri.queryParameters.keys, everyElement('decoyId'));
    }
    expectNoAdjacentWords(
        [
          jsonEncode(reported, toEncodable: (o) => o.toString()),
          location().toString(),
          for (final list in matchLists()) list.uri.toString(),
        ].join(' '),
        words);
  });

  for (final path in [
    ShowDecoySeedPhraseWidget.routePath,
    SeedPhraseVerificationWidget.routePath,
  ]) {
    testWidgets('mnemonic in a deep link is ignored: $path', (tester) async {
      await launch(
          tester,
          '$path?decoyId=attacker&mnemonic='
          '${Uri.encodeQueryComponent(_injected)}');
      expect(find.textContaining('abandon'), findsNothing);
      expect(find.byType(ShowDecoySeedPhraseWidget), findsNothing);
      expect(find.byType(SeedPhraseVerificationWidget), findsNothing);
      expect(find.byType(GenerateDecoySeedPhraseWidget), findsOneWidget);
      expect(location().path, GenerateDecoySeedPhraseWidget.routePath);
    });
  }

  testWidgets('a deep link cannot swap in words for the pending decoy',
      (tester) async {
    SeedHandoff.put(mnemonic: _pending, decoyId: 'pending-decoy');
    await launch(
        tester,
        '${ShowDecoySeedPhraseWidget.routePath}?decoyId=pending-decoy'
        '&mnemonic=${Uri.encodeQueryComponent(_injected)}');
    expect(find.byType(ShowDecoySeedPhraseWidget), findsOneWidget);
    expect(find.text('legal'), findsWidgets);
    expect(find.textContaining('abandon'), findsNothing);
  });

  testWidgets('a pending seed is never shown for another decoy id',
      (tester) async {
    SeedHandoff.put(mnemonic: _pending, decoyId: 'pending-decoy');
    await launch(
        tester, '${ShowDecoySeedPhraseWidget.routePath}?decoyId=other-decoy');
    expect(find.text('legal'), findsNothing);
    expect(find.byType(GenerateDecoySeedPhraseWidget), findsOneWidget);
    // Re-entering generation drops the abandoned seed.
    expect(SeedHandoff.hasPending, isFalse);
  });

  testWidgets('verification opens cleanly for the pending seed',
      (tester) async {
    // The quiz options load after the first frame; building must not throw.
    SeedHandoff.put(mnemonic: _pending, decoyId: 'pending-decoy');
    await launch(tester,
        '${SeedPhraseVerificationWidget.routePath}?decoyId=pending-decoy');
    expect(tester.takeException(), isNull);
    expect(find.byType(SeedPhraseVerificationWidget), findsOneWidget);
  });

  group('pending seed lifetime', () {
    late AppUnlockState unlock;
    setUp(() {
      unlock = AppUnlockState()..bindUser('owner');
      SeedHandoff.put(mnemonic: _pending, decoyId: 'pending-decoy');
    });

    test('sign-out clears it', () {
      unlock.bindUser(null);
      expect(SeedHandoff.hasPending, isFalse);
    });

    test('switching account clears it', () {
      unlock.bindUser('someone-else');
      expect(SeedHandoff.hasPending, isFalse);
    });

    test('opening decoy mode with the duress PIN clears it', () {
      expect(unlock.preparePin(unlock.attempt, paidDecoyAllowed: true), isTrue);
      expect(unlock.beginDecoy(unlock.attempt), isTrue);
      expect(SeedHandoff.hasPending, isFalse);
    });

    test('locking keeps it so unlocking returns to the seed screen', () {
      unlock.lock();
      expect(SeedHandoff.mnemonicFor('pending-decoy'), _pending);
    });

    test('a rejected duress attempt keeps it', () {
      // No prepared PIN: beginDecoy is refused and must not touch the seed.
      expect(unlock.beginDecoy(unlock.attempt), isFalse);
      expect(SeedHandoff.hasPending, isTrue);
    });
  });
}
