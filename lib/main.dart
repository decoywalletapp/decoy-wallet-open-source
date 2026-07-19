import 'dart:async';
import 'dart:ui';

import '/custom_code/actions/index.dart' as actions;
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'auth/supabase_auth/supabase_user_provider.dart';
import 'auth/supabase_auth/auth_util.dart';

import '/backend/supabase/supabase.dart';
import 'backend/firebase/firebase_config.dart';
import 'flutter_flow/flutter_flow_util.dart';

void main() {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    _configureGlobalErrorHandling();

    await _startApp();
  }, (error, _) {
    _logSafeStartupError('Uncaught async error', error);
  });
}

Future<void> _startApp() async {
  try {
    GoRouter.optionURLReflectsImperativeAPIs = true;
    usePathUrlStrategy();

    final environmentValues = FFDevEnvironmentValues();
    await environmentValues.initialize();

    await initFirebase();

    // Start initial custom actions code
    await actions.lockPortrait();
    // End initial custom actions code

    await SupaFlow.initialize();

    final appState = FFAppState(); // Initialize FFAppState
    await appState.initializePersistedState();

    runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => appState,
        ),
      ],
      child: MyApp(),
    ));
  } catch (error) {
    final errorLabel = _startupErrorLabel(error);
    _logSafeStartupError('App startup failed', error);
    runApp(_StartupFailureApp(errorLabel: errorLabel));
  }
}

void _configureGlobalErrorHandling() {
  FlutterError.onError = (details) {
    _logSafeStartupError('Flutter framework error', details.exception);
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, _) {
    _logSafeStartupError('Uncaught platform error', error);
    return true;
  };
}

void _logSafeStartupError(String prefix, Object error) {
  debugPrint('$prefix: ${_startupErrorLabel(error)}');
}

String _startupErrorLabel(Object error) {
  final dynamic dynamicError = error;
  try {
    final plugin = dynamicError.plugin;
    final code = dynamicError.code;
    if (plugin is String &&
        plugin.isNotEmpty &&
        code is String &&
        code.isNotEmpty) {
      return '$plugin/$code';
    }
  } catch (_) {}

  if (error is StateError) {
    return 'Configuration is incomplete';
  }
  if (error is FormatException) {
    return 'Configuration format error';
  }

  final type = error.runtimeType.toString();
  return type.isEmpty ? 'Unknown startup error' : type;
}

class _StartupFailureApp extends StatelessWidget {
  const _StartupFailureApp({
    required this.errorLabel,
  });

  final String errorLabel;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF8F8F8),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 42.0,
                    color: Color(0xFFB42318),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'App could not start',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1D1D1F),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    'Please install the latest test build or contact support '
                    'with startup code: $errorLabel',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15.0,
                      height: 1.35,
                      color: Color(0xFF3C3C43),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
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

class _DecoyDisplayGuard extends StatelessWidget {
  const _DecoyDisplayGuard({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return MediaQuery(
      data: mediaQuery.copyWith(
        boldText: false,
        textScaler: TextScaler.noScaling,
      ),
      child: child,
    );
  }
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

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
      });
    jwtTokenStream.listen((_) {});
    Future.delayed(
      Duration(milliseconds: 1000),
      () => _appStateNotifier.stopShowingSplashImage(),
    );
  }

  void setThemeMode(ThemeMode mode) => safeSetState(() {
        _themeMode = ThemeMode.light;
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'My Bitcoin Wallet',
      scrollBehavior: MyAppScrollBehavior(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', '')],
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: false,
      ),
      themeMode: _themeMode,
      routerConfig: _router,
      builder: (context, child) => _DecoyDisplayGuard(
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
