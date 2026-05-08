import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/auth/base_auth_user_provider.dart';

import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

import '/index.dart';
import 'package:cartesian_chart_library_syxakz/index.dart'
    as $cartesian_chart_library_syxakz;

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  BaseAuthUser? initialUser;
  BaseAuthUser? user;
  bool showSplashImage = true;
  String? _redirectLocation;

  /// Determines whether the app will refresh and build again when a sign
  /// in or sign out happens. This is useful when the app is launched or
  /// on an unexpected logout. However, this must be turned off when we
  /// intend to sign in/out and then navigate or perform any actions after.
  /// Otherwise, this will trigger a refresh and interrupt the action(s).
  bool notifyOnAuthChange = true;

  bool get loading => user == null || showSplashImage;
  bool get loggedIn => user?.loggedIn ?? false;
  bool get initiallyLoggedIn => initialUser?.loggedIn ?? false;
  bool get shouldRedirect => loggedIn && _redirectLocation != null;

  String getRedirectLocation() => _redirectLocation!;
  bool hasRedirect() => _redirectLocation != null;
  void setRedirectLocationIfUnset(String loc) => _redirectLocation ??= loc;
  void clearRedirectLocation() => _redirectLocation = null;

  /// Mark as not needing to notify on a sign in / out when we intend
  /// to perform subsequent actions (such as navigation) afterwards.
  void updateNotifyOnAuthChange(bool notify) => notifyOnAuthChange = notify;

  void update(BaseAuthUser newUser) {
    final shouldUpdate =
        user?.uid == null || newUser.uid == null || user?.uid != newUser.uid;
    initialUser ??= newUser;
    user = newUser;
    // Refresh the app on auth change unless explicitly marked otherwise.
    // No need to update unless the user has changed.
    if (notifyOnAuthChange && shouldUpdate) {
      notifyListeners();
    }
    // Once again mark the notifier as needing to update on auth change
    // (in order to catch sign in / out events).
    updateNotifyOnAuthChange(true);
  }

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

GoRouter createRouter(AppStateNotifier appStateNotifier) {
  $cartesian_chart_library_syxakz.initializeRoutes(
    homePageWidgetName: 'cartesian_chart_library_syxakz.HomePage',
    homePageWidgetPath: '/DuressHomePage',
  );

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    refreshListenable: appStateNotifier,
    navigatorKey: appNavigatorKey,
    errorBuilder: (context, state) =>
        appStateNotifier.loggedIn ? AuthRouterWidget() : LoginPageWidget(),
    routes: [
      FFRoute(
        name: '_initialize',
        path: '/',
        builder: (context, _) =>
            appStateNotifier.loggedIn ? AuthRouterWidget() : LoginPageWidget(),
      ),
      FFRoute(
        name: LoginPageWidget.routeName,
        path: LoginPageWidget.routePath,
        builder: (context, params) => LoginPageWidget(
          type: params.getParam(
            'type',
            ParamType.String,
          ),
          accessToken: params.getParam(
            'accessToken',
            ParamType.String,
          ),
          refreshToken: params.getParam(
            'refreshToken',
            ParamType.String,
          ),
        ),
      ),
      FFRoute(
        name: CreateAccountWidget.routeName,
        path: CreateAccountWidget.routePath,
        builder: (context, params) => CreateAccountWidget(),
      ),
      FFRoute(
        name: ForgotPasswordPageWidget.routeName,
        path: ForgotPasswordPageWidget.routePath,
        builder: (context, params) => ForgotPasswordPageWidget(),
      ),
      FFRoute(
        name: UpdatePasswordPageWidget.routeName,
        path: UpdatePasswordPageWidget.routePath,
        builder: (context, params) => UpdatePasswordPageWidget(
          type: params.getParam(
            'type',
            ParamType.String,
          ),
          accessToken: params.getParam(
            'accessToken',
            ParamType.String,
          ),
          refreshToken: params.getParam(
            'refreshToken',
            ParamType.String,
          ),
        ),
      ),
      FFRoute(
        name: SettingsWidget.routeName,
        path: SettingsWidget.routePath,
        builder: (context, params) => SettingsWidget(),
      ),
      FFRoute(
        name: HomePageWidget.routeName,
        path: HomePageWidget.routePath,
        requireAuth: true,
        builder: (context, params) => HomePageWidget(),
      ),
      FFRoute(
        name: CreatePinWidget.routeName,
        path: CreatePinWidget.routePath,
        builder: (context, params) => CreatePinWidget(),
      ),
      FFRoute(
        name: PINPageWidget.routeName,
        path: PINPageWidget.routePath,
        builder: (context, params) => PINPageWidget(),
      ),
      FFRoute(
        name: PhoneNumberVerificationWidget.routeName,
        path: PhoneNumberVerificationWidget.routePath,
        builder: (context, params) => PhoneNumberVerificationWidget(
          cleanPhone: params.getParam(
            'cleanPhone',
            ParamType.String,
          ),
        ),
      ),
      FFRoute(
        name: DuressSendBTCWidget.routeName,
        path: DuressSendBTCWidget.routePath,
        builder: (context, params) => DuressSendBTCWidget(),
      ),
      FFRoute(
        name: DuressConfirmTransactionSendWidget.routeName,
        path: DuressConfirmTransactionSendWidget.routePath,
        builder: (context, params) => DuressConfirmTransactionSendWidget(),
      ),
      FFRoute(
        name: DuressProcessingTransactionWidget.routeName,
        path: DuressProcessingTransactionWidget.routePath,
        builder: (context, params) => DuressProcessingTransactionWidget(
          amountBtc: params.getParam(
            'amountBtc',
            ParamType.String,
          ),
          toAddress: params.getParam(
            'toAddress',
            ParamType.String,
          ),
          feeBtc: params.getParam(
            'feeBtc',
            ParamType.double,
          ),
        ),
      ),
      FFRoute(
        name: DuressHomePageWidget.routeName,
        path: DuressHomePageWidget.routePath,
        builder: (context, params) => DuressHomePageWidget(),
      ),
      FFRoute(
        name: DuressSettingsPageWidget.routeName,
        path: DuressSettingsPageWidget.routePath,
        builder: (context, params) => DuressSettingsPageWidget(),
      ),
      FFRoute(
        name: ShowDecoySeedPhraseWidget.routeName,
        path: ShowDecoySeedPhraseWidget.routePath,
        builder: (context, params) => ShowDecoySeedPhraseWidget(
          mnemonic: params.getParam(
            'mnemonic',
            ParamType.String,
          ),
          decoyId: params.getParam(
            'decoyId',
            ParamType.String,
          ),
        ),
      ),
      FFRoute(
        name: DecoySeedAcknowledgementsWidget.routeName,
        path: DecoySeedAcknowledgementsWidget.routePath,
        builder: (context, params) => DecoySeedAcknowledgementsWidget(),
      ),
      FFRoute(
        name: PhoneNumberInputWidget.routeName,
        path: PhoneNumberInputWidget.routePath,
        builder: (context, params) => PhoneNumberInputWidget(),
      ),
      FFRoute(
        name: ConfirmEmailPageWidget.routeName,
        path: ConfirmEmailPageWidget.routePath,
        builder: (context, params) => ConfirmEmailPageWidget(
          emailEntry: params.getParam(
            'emailEntry',
            ParamType.String,
          ),
        ),
      ),
      FFRoute(
        name: DuressScanQRWidget.routeName,
        path: DuressScanQRWidget.routePath,
        builder: (context, params) => DuressScanQRWidget(),
      ),
      FFRoute(
        name: CreateDecoyPinWidget.routeName,
        path: CreateDecoyPinWidget.routePath,
        builder: (context, params) => Container(
          color: Color(0xFF1D2428),
          child: CreateDecoyPinWidget(),
        ),
      ),
      FFRoute(
        name: GenerateDecoySeedPhraseWidget.routeName,
        path: GenerateDecoySeedPhraseWidget.routePath,
        builder: (context, params) => GenerateDecoySeedPhraseWidget(),
      ),
      FFRoute(
        name: SeedPhraseVerificationWidget.routeName,
        path: SeedPhraseVerificationWidget.routePath,
        builder: (context, params) => SeedPhraseVerificationWidget(
          decoyId: params.getParam(
            'decoyId',
            ParamType.String,
          ),
          mnemonic: params.getParam(
            'mnemonic',
            ParamType.String,
          ),
        ),
      ),
      FFRoute(
        name: CreateDecoyEmergencyContactsSetupWidget.routeName,
        path: CreateDecoyEmergencyContactsSetupWidget.routePath,
        builder: (context, params) => CreateDecoyEmergencyContactsSetupWidget(),
      ),
      FFRoute(
        name: EmergencyContactsWidget.routeName,
        path: EmergencyContactsWidget.routePath,
        builder: (context, params) => EmergencyContactsWidget(),
      ),
      FFRoute(
        name: BiometricVerificationWidget.routeName,
        path: BiometricVerificationWidget.routePath,
        builder: (context, params) => BiometricVerificationWidget(),
      ),
      FFRoute(
        name: PersonalInformationWidget.routeName,
        path: PersonalInformationWidget.routePath,
        builder: (context, params) => PersonalInformationWidget(),
      ),
      FFRoute(
        name: AuthRouterWidget.routeName,
        path: AuthRouterWidget.routePath,
        builder: (context, params) => AuthRouterWidget(
          type: params.getParam(
            'type',
            ParamType.String,
          ),
          accessToken: params.getParam(
            'accessToken',
            ParamType.String,
          ),
          refreshToken: params.getParam(
            'refreshToken',
            ParamType.String,
          ),
        ),
      ),
      FFRoute(
        name: ChangeEmailRouterWidget.routeName,
        path: ChangeEmailRouterWidget.routePath,
        builder: (context, params) => ChangeEmailRouterWidget(
          type: params.getParam(
            'type',
            ParamType.String,
          ),
        ),
      ),
      FFRoute(
        name: ChangePinWidget.routeName,
        path: ChangePinWidget.routePath,
        builder: (context, params) => ChangePinWidget(),
      ),
      FFRoute(
        name: SupportTicketWidget.routeName,
        path: SupportTicketWidget.routePath,
        builder: (context, params) => SupportTicketWidget(),
      ),
      FFRoute(
        name: ControlCenterWidget.routeName,
        path: ControlCenterWidget.routePath,
        builder: (context, params) => ControlCenterWidget(),
      ),
      FFRoute(
        name: DecoyPinSystemValuesWidget.routeName,
        path: DecoyPinSystemValuesWidget.routePath,
        builder: (context, params) => Container(
          color: Color(0xFF1D2428),
          child: DecoyPinSystemValuesWidget(),
        ),
      ),
      FFRoute(
        name: DecoySeedSystemValuesWidget.routeName,
        path: DecoySeedSystemValuesWidget.routePath,
        builder: (context, params) => DecoySeedSystemValuesWidget(),
      ),
      FFRoute(
        name: DeleteUserAccountWidget.routeName,
        path: DeleteUserAccountWidget.routePath,
        builder: (context, params) => DeleteUserAccountWidget(),
      ),
      FFRoute(
        name: DuressOrderProcessedWidget.routeName,
        path: DuressOrderProcessedWidget.routePath,
        builder: (context, params) => DuressOrderProcessedWidget(
          amountBtc: params.getParam(
            'amountBtc',
            ParamType.String,
          ),
          toAddress: params.getParam(
            'toAddress',
            ParamType.String,
          ),
          feeBtc: params.getParam(
            'feeBtc',
            ParamType.double,
          ),
        ),
      ),
      FFRoute(
        name: TermsofUseWidget.routeName,
        path: TermsofUseWidget.routePath,
        builder: (context, params) => TermsofUseWidget(),
      ),
      FFRoute(
        name: DecoyPinAcknowledgementsWidget.routeName,
        path: DecoyPinAcknowledgementsWidget.routePath,
        builder: (context, params) => DecoyPinAcknowledgementsWidget(),
      ),
      FFRoute(
        name: PrivacyPolicyWidget.routeName,
        path: PrivacyPolicyWidget.routePath,
        builder: (context, params) => PrivacyPolicyWidget(),
      ),
      FFRoute(
        name: SubscriptionOptionsWidget.routeName,
        path: SubscriptionOptionsWidget.routePath,
        requireAuth: true,
        builder: (context, params) => SubscriptionOptionsWidget(),
      ),
      FFRoute(
        name: PaymentReturnWidget.routeName,
        path: PaymentReturnWidget.routePath,
        requireAuth: true,
        builder: (context, params) => PaymentReturnWidget(
          ts: params.getParam(
            'ts',
            ParamType.String,
          ),
          sessionId: params.getParam(
            'session_id',
            ParamType.String,
          ),
        ),
      ),
      FFRoute(
        name: ManageSubscriptionWidget.routeName,
        path: ManageSubscriptionWidget.routePath,
        builder: (context, params) => ManageSubscriptionWidget(),
      ),
      FFRoute(
        name: TutorialsWidget.routeName,
        path: TutorialsWidget.routePath,
        builder: (context, params) => TutorialsWidget(),
      ),
      FFRoute(
        name: LocationAuthorizationWidget.routeName,
        path: LocationAuthorizationWidget.routePath,
        builder: (context, params) => LocationAuthorizationWidget(),
      ),
      FFRoute(
        name: EnableNotificationsWidget.routeName,
        path: EnableNotificationsWidget.routePath,
        builder: (context, params) => EnableNotificationsWidget(),
      ),
      FFRoute(
        name: HomeAddressEntryPageWidget.routeName,
        path: HomeAddressEntryPageWidget.routePath,
        builder: (context, params) => HomeAddressEntryPageWidget(),
      ),
      FFRoute(
        name: AgreementsPageWidget.routeName,
        path: AgreementsPageWidget.routePath,
        builder: (context, params) => AgreementsPageWidget(),
      ),
      FFRoute(
        name: $cartesian_chart_library_syxakz.HomePageWidget.routeName,
        path: $cartesian_chart_library_syxakz.HomePageWidget.routePath,
        builder: (context, params) =>
            $cartesian_chart_library_syxakz.HomePageWidget(),
      )
    ].map((r) => r.toRoute(appStateNotifier)).toList(),
    observers: [routeObserver],
  );
}

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
}

extension NavigationExtensions on BuildContext {
  void goNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : goNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void pushNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : pushNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void safePop() {
    // If there is only one route on the stack, navigate to the initial
    // page instead of popping.
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

extension GoRouterExtensions on GoRouter {
  AppStateNotifier get appState => AppStateNotifier.instance;
  void prepareAuthEvent([bool ignoreRedirect = false]) =>
      appState.hasRedirect() && !ignoreRedirect
          ? null
          : appState.updateNotifyOnAuthChange(false);
  bool shouldRedirect(bool ignoreRedirect) =>
      !ignoreRedirect && appState.hasRedirect();
  void clearRedirectLocation() => appState.clearRedirectLocation();
  void setRedirectLocationIfUnset(String location) =>
      appState.updateNotifyOnAuthChange(false);
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo {
    final possibleKeys = [
      '__transition_info__',
      '__transition_info__cartesian_chart_library_syxakz'
    ];
    for (final key in possibleKeys) {
      if (extraMap.containsKey(key)) {
        return extraMap[key] as TransitionInfo;
      }
    }
    return TransitionInfo.appDefault();
  }
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.allParams.length == 1 &&
          state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
        state.allParams.entries.where(isAsyncParam).map(
          (param) async {
            final doc = await asyncParams[param.key]!(param.value)
                .onError((_, __) => null);
            if (doc != null) {
              futureParamValues[param.key] = doc;
              return true;
            }
            return false;
          },
        ),
      ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(
    String paramName,
    ParamType type, {
    bool isList = false,
    List<String>? collectionNamePath,
  }) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    // Got parameter from `extras`, so just directly return it.
    if (param is! String) {
      return param;
    }
    // Return serialized value.
    return deserializeParam<T>(
      param,
      type,
      isList,
      collectionNamePath: collectionNamePath,
    );
  }
}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
        name: name,
        path: path,
        redirect: (context, state) {
          if (appStateNotifier.shouldRedirect) {
            final redirectLocation = appStateNotifier.getRedirectLocation();
            appStateNotifier.clearRedirectLocation();
            return redirectLocation;
          }

          if (requireAuth && !appStateNotifier.loggedIn) {
            appStateNotifier.setRedirectLocationIfUnset(state.uri.toString());
            return '/loginPage';
          }
          return null;
        },
        pageBuilder: (context, state) {
          fixStatusBarOniOS16AndBelow(context);
          final ffParams = FFParameters(state, asyncParams);
          final page = ffParams.hasFutures
              ? FutureBuilder(
                  future: ffParams.completeFutures(),
                  builder: (context, _) => builder(context, ffParams),
                )
              : builder(context, ffParams);
          final child = appStateNotifier.loading
              ? Center(
                  child: LinearProgressIndicator(
                    color: FlutterFlowTheme.of(context).primary,
                  ),
                )
              : page;

          final transitionInfo = state.transitionInfo;
          return transitionInfo.hasTransition
              ? CustomTransitionPage(
                  key: state.pageKey,
                  name: state.name,
                  child: child,
                  transitionDuration: transitionInfo.duration,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          PageTransition(
                    type: transitionInfo.transitionType,
                    duration: transitionInfo.duration,
                    reverseDuration: transitionInfo.duration,
                    alignment: transitionInfo.alignment,
                    child: child,
                  ).buildTransitions(
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ),
                )
              : MaterialPage(
                  key: state.pageKey, name: state.name, child: child);
        },
        routes: routes,
      );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() => TransitionInfo(hasTransition: false);
}

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouterState.of(context).uri.toString();
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) => Provider.value(
        value: RootPageContext(true, errorRoute),
        child: child,
      );
}

extension GoRouterLocationExtension on GoRouter {
  String getCurrentLocation() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}
