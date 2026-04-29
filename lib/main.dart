import 'dart:async';

import '/custom_code/actions/index.dart' as actions;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'auth/supabase_auth/supabase_user_provider.dart';
import 'auth/supabase_auth/auth_util.dart';

import '/backend/supabase/supabase.dart';
import 'backend/firebase/firebase_config.dart';
import 'flutter_flow/flutter_flow_util.dart';

Future<void> _upsertFcmTokenForUser(String userId, String token) async {
  if (userId.isEmpty || token.isEmpty) return;

  try {
    await SupaFlow.client.rpc(
      'upsert_user_device',
      params: {
        'p_device_id': token,
        'p_platform': 'mobile',
        'p_fcm_token': token,
      },
    );
  } catch (_) {
    // Push token refresh should never block app launch.
  }
}

Future<void> _syncCurrentFcmTokenForUser(String userId) async {
  if (userId.isEmpty) return;

  try {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();

    // Do not trigger the iOS notification prompt from app startup or auth refresh.
    // The onboarding notifications page asks for permission only after the user continues.
    final allowed =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;

    if (!allowed) return;

    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      for (var i = 0; i < 6 && (apnsToken == null || apnsToken.isEmpty); i++) {
        await Future.delayed(const Duration(milliseconds: 500));
        apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      }
    }

    final token = await FirebaseMessaging.instance.getToken();
    if (token == null || token.isEmpty) return;

    await _upsertFcmTokenForUser(userId, token);
  } catch (_) {
    // Token sync is best-effort; the user can still use the app.
  }
}

Future<void> _syncPushTokenWhenUserAvailable() async {
  for (var i = 0; i < 15; i++) {
    final userId = SupaFlow.client.auth.currentUser?.id ?? currentUserUid;
    if (userId.isNotEmpty) {
      await _syncCurrentFcmTokenForUser(userId);
      return;
    }

    await Future.delayed(const Duration(seconds: 1));
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  final environmentValues = FFDevEnvironmentValues();
  await environmentValues.initialize();

  await initFirebase();
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // Start initial custom actions code
  await actions.lockPortrait();
  // End initial custom actions code

  await SupaFlow.initialize();

  FirebaseMessaging.instance.onTokenRefresh.listen((token) {
    final userId = SupaFlow.client.auth.currentUser?.id ?? '';
    unawaited(_upsertFcmTokenForUser(userId, token));
  });

  SupaFlow.client.auth.onAuthStateChange.listen((authState) {
    final userId = authState.session?.user.id ?? '';
    unawaited(_syncCurrentFcmTokenForUser(userId));
  });

  final initialUserId = SupaFlow.client.auth.currentUser?.id ?? '';
  await _syncCurrentFcmTokenForUser(initialUserId);
  unawaited(_syncPushTokenWhenUserAvailable());

  final appState = FFAppState(); // Initialize FFAppState
  await appState.initializePersistedState();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => appState)],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class MyAppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;
  String getRoute([RouteMatch? routeMatch]) {
    final RouteMatch lastMatch =
        routeMatch ?? _router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : _router.routerDelegate.currentConfiguration;
    return matchList.uri.path;
  }

  List<String> getRouteStack() =>
      _router.routerDelegate.currentConfiguration.matches
          .map((e) => getRoute(e))
          .toList();
  late Stream<BaseAuthUser> userStream;

  @override
  void initState() {
    super.initState();

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
    userStream = decoyWalletAppSupabaseUserStream()
      ..listen((user) {
        _appStateNotifier.update(user);
        final userId = user.uid ?? '';
        if (user.loggedIn && userId.isNotEmpty) {
          unawaited(_syncCurrentFcmTokenForUser(userId));
        }
      });
    jwtTokenStream.listen((_) {});
    Future.delayed(
      Duration(milliseconds: 1000),
      () => _appStateNotifier.stopShowingSplashImage(),
    );
  }

  void setThemeMode(ThemeMode mode) => safeSetState(() {
        _themeMode = mode;
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Decoy Wallet App',
      scrollBehavior: MyAppScrollBehavior(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', '')],
      theme: ThemeData(brightness: Brightness.light, useMaterial3: false),
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}
