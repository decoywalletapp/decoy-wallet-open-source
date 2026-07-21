import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'auth_router_model.dart';
export 'auth_router_model.dart';

class AuthRouterWidget extends StatefulWidget {
  const AuthRouterWidget({
    super.key,
    this.type,
    this.accessToken,
    this.refreshToken,
  });

  final String? type;
  final String? accessToken;
  final String? refreshToken;

  static String routeName = 'AuthRouter';
  static String routePath = '/authRouter';

  @override
  State<AuthRouterWidget> createState() => _AuthRouterWidgetState();
}

class _AuthRouterWidgetState extends State<AuthRouterWidget> {
  late AuthRouterModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _hideContentForPinHandoff = false;

  static const _pinHandoffFadeOutDuration = Duration(milliseconds: 180);
  static const _pinRouteFadeDuration = Duration(milliseconds: 220);

  Future<void> _goToPinPageAfterCleanHandoff() async {
    safeSetState(() {
      _hideContentForPinHandoff = true;
    });
    await Future.delayed(_pinHandoffFadeOutDuration);
    if (!mounted) {
      return;
    }
    context.goNamedAuth(
      PINPageWidget.routeName,
      context.mounted,
      extra: <String, dynamic>{
        '__transition_info__': TransitionInfo(
          hasTransition: true,
          transitionType: PageTransitionType.fade,
          duration: _pinRouteFadeDuration,
        ),
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AuthRouterModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (widget.type == 'recovery') {
        _model.refreshingOuuu = await actions.refreshSupabaseSession2(
          widget.accessToken!,
          widget.refreshToken!,
        );
        if (_model.refreshingOuuu == true) {
          context.goNamedAuth(
              UpdatePasswordPageWidget.routeName, context.mounted);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'ERROR #024 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT',
                style: TextStyle(
                  color: FlutterFlowTheme.of(context).primaryText,
                ),
              ),
              duration: Duration(milliseconds: 4000),
              backgroundColor: FlutterFlowTheme.of(context).secondary,
            ),
          );
        }
      } else {
        _model.pushRoute = await actions.initPushTapListener(
          context,
        );
        if ((_model.pushRoute != null && _model.pushRoute != '') &&
            (_model.pushRoute == 'renew_btcpay')) {
          FFAppState().openRenewalFromPush = true;
          safeSetState(() {});
        }
        _model.refreshOut = await actions.refreshSupabaseSession();
        _model.authUserResp = await GetAuthUserCall.call(
          jwt: currentJwtToken,
        );

        _model.emailHashResp = await GetEmailHashCall.call(
          jwt: currentJwtToken,
          email: functions.normalizeEmail(getJsonField(
            (_model.authUserResp?.jsonBody ?? ''),
            r'''$.email''',
          ).toString()),
        );

        FFAppState().isLocked = true;
        safeSetState(() {});
        _model.query1 = await DecoyWalletTable().queryRows(
          queryFn: (q) => q
              .eqOrNull(
                'user_id',
                currentUserUid,
              )
              .order('created_at'),
        );
        _model.dwList = _model.query1!.toList().cast<DecoyWalletRow>();
        _model.hasRow = _model.query1 != null && (_model.query1)!.isNotEmpty;
        _model.authEmail = currentUserEmail;
        _model.pendingEmail = _model.query1?.elementAtOrNull(0)?.pendingEmail;
        safeSetState(() {});
        if (_model.hasRow == false) {
          _model.firstInsert = await DecoyWalletTable().insert({
            'user_id': currentUserUid,
            'email_verified': false,
            'email_verified_at': supaSerialize<DateTime>(null),
            'is_phone_verified': false,
            'created_at': supaSerialize<DateTime>(getCurrentTimestamp),
            'email_hash': GetEmailHashCall.emailHash(
              (_model.emailHashResp?.jsonBody ?? ''),
            ).toString(),
            'pending_email_hash': null,
          });
          _model.query2 = await DecoyWalletTable().queryRows(
            queryFn: (q) => q.eqOrNull(
              'user_id',
              currentUserUid,
            ),
          );
          _model.dwList = _model.query2!.toList().cast<DecoyWalletRow>();
          _model.hasRow = _model.query2 != null && (_model.query2)!.isNotEmpty;
          _model.setupComplete =
              _model.query2?.elementAtOrNull(0)?.setupComplete;
          _model.agreementsComplete =
              _model.query2?.elementAtOrNull(0)?.agreementsComplete;
          safeSetState(() {});
        } else {
          await DecoyWalletTable().update(
            data: {
              'email_verified': true,
              'email_verified_at': supaSerialize<DateTime>(getCurrentTimestamp),
              'email_hash': GetEmailHashCall.emailHash(
                (_model.emailHashResp?.jsonBody ?? ''),
              ).toString(),
              'pending_email_hash': null,
            },
            matchingRows: (rows) => rows.eqOrNull(
              'user_id',
              currentUserUid,
            ),
          );
          _model.query3 = await DecoyWalletTable().queryRows(
            queryFn: (q) => q.eqOrNull(
              'user_id',
              currentUserUid,
            ),
          );
          _model.dwList = _model.query3!.toList().cast<DecoyWalletRow>();
          _model.hasRow = _model.query3 != null && (_model.query3)!.isNotEmpty;
          _model.setupComplete =
              _model.query3?.elementAtOrNull(0)?.setupComplete;
          _model.agreementsComplete =
              _model.query3?.elementAtOrNull(0)?.agreementsComplete;
          safeSetState(() {});
        }

        _model.pushSettingsRows = await UserSettingsTable().queryRows(
          queryFn: (q) => q.eqOrNull(
            'user_id',
            currentUserUid,
          ),
        );
        FFAppState().pushEnabled =
            _model.pushSettingsRows?.elementAtOrNull(0)?.pushEnabled == true;
        safeSetState(() {});
        if (FFAppState().pushEnabled == true) {
          _model.pushTokenRefreshResult =
              await actions.requestPushPermissionAndGetToken();
          _model.pushPermissionRefreshResult =
              await actions.getPushPermissionStatus();
          safeSetState(() {});
        }

        _model.verifiedViaEmail =
            _model.dwList.elementAtOrNull(0)!.emailVerified!;
        _model.needPhone = !_model.dwList.elementAtOrNull(0)!.isPhoneVerified!;
        safeSetState(() {});
        if (_model.verifiedViaEmail == false) {
          context.goNamedAuth(
              ConfirmEmailPageWidget.routeName, context.mounted);
        } else {
          if (_model.needPhone == true) {
            context.goNamedAuth(
                PhoneNumberInputWidget.routeName, context.mounted);
          } else {
            if (FFAppState().biometricsEnabled == true) {
              final _localAuth = LocalAuthentication();
              bool _isBiometricSupported = await _localAuth.isDeviceSupported();

              if (_isBiometricSupported) {
                try {
                  _model.authRouterBioResult = await _localAuth.authenticate(
                      localizedReason:
                          'Please authenticate to unlock your wallet');
                } on PlatformException {
                  _model.authRouterBioResult = false;
                }
                safeSetState(() {});
              }

              if (_model.authRouterBioResult == true) {
                FFAppState().isLocked = false;
                safeSetState(() {});
                _model.entitlementRow1 =
                    await UserEntitlementsTable().queryRows(
                  queryFn: (q) => q
                      .eqOrNull(
                        'user_id',
                        currentUserUid,
                      )
                      .eqOrNull(
                        'entitlement',
                        'decoy_wallet',
                      ),
                );
                if ((_model.entitlementRow1?.elementAtOrNull(0)?.provider ==
                        'stripe') &&
                    (_model.entitlementRow1?.elementAtOrNull(0)?.isActive ==
                        false)) {
                  _model.apiResultRSE = await RepairStripeEntitlementCall.call(
                    userId: currentUserUid,
                    jwt: currentJwtToken,
                  );

                  if ((_model.apiResultRSE?.succeeded ?? true)) {
                    _model.secondEntitlementQue =
                        await UserEntitlementsTable().queryRows(
                      queryFn: (q) => q
                          .eqOrNull(
                            'user_id',
                            currentUserUid,
                          )
                          .eqOrNull(
                            'entitlement',
                            'decoy_wallet',
                          ),
                    );
                    FFAppState().hasActiveSubscription =
                        (_model.secondEntitlementQue != null &&
                                (_model.secondEntitlementQue)!.isNotEmpty) &&
                            functions.isEntitlementUsableForProtection(
                              _model.secondEntitlementQue
                                  ?.elementAtOrNull(0)
                                  ?.isActive,
                              _model.secondEntitlementQue
                                  ?.elementAtOrNull(0)
                                  ?.currentPeriodEnd,
                              _model.secondEntitlementQue
                                  ?.elementAtOrNull(0)
                                  ?.pendingProvider,
                              _model.secondEntitlementQue
                                  ?.elementAtOrNull(0)
                                  ?.pendingStartsAt,
                              _model.secondEntitlementQue
                                  ?.elementAtOrNull(0)
                                  ?.pendingProviderSubscriptionId,
                            );
                    safeSetState(() {});
                  }
                } else {
                  FFAppState().hasActiveSubscription =
                      (_model.entitlementRow1 != null &&
                              (_model.entitlementRow1)!.isNotEmpty) &&
                          functions.isEntitlementUsableForProtection(
                            _model.entitlementRow1
                                ?.elementAtOrNull(0)
                                ?.isActive,
                            _model.entitlementRow1
                                ?.elementAtOrNull(0)
                                ?.currentPeriodEnd,
                            _model.entitlementRow1
                                ?.elementAtOrNull(0)
                                ?.pendingProvider,
                            _model.entitlementRow1
                                ?.elementAtOrNull(0)
                                ?.pendingStartsAt,
                            _model.entitlementRow1
                                ?.elementAtOrNull(0)
                                ?.pendingProviderSubscriptionId,
                          );
                  safeSetState(() {});
                }

                if (FFAppState().hasActiveSubscription == true) {
                  if (_model.agreementsComplete != true) {
                    context.goNamedAuth(
                        AgreementsPageWidget.routeName, context.mounted);
                  } else {
                    if (_model.setupComplete != true) {
                      context.goNamedAuth(
                          CreatePinWidget.routeName, context.mounted);
                    } else {
                      if (((_model.query2 != null &&
                                  (_model.query2)!.isNotEmpty) &&
                              (_model.setupComplete == true)) ||
                          ((_model.query3 != null &&
                                  (_model.query3)!.isNotEmpty) &&
                              (_model.setupComplete == true))) {
                        await _goToPinPageAfterCleanHandoff();
                      } else {
                        context.goNamedAuth(
                          CreatePinWidget.routeName,
                          context.mounted,
                          extra: <String, dynamic>{
                            '__transition_info__': TransitionInfo(
                              hasTransition: true,
                              transitionType: PageTransitionType.fade,
                            ),
                          },
                        );
                      }
                    }
                  }
                } else {
                  if (_model.agreementsComplete != true) {
                    context.goNamedAuth(
                        AgreementsPageWidget.routeName, context.mounted);
                  } else {
                    if (_model.setupComplete != true) {
                      context.goNamedAuth(
                          CreatePinWidget.routeName, context.mounted);
                    } else {
                      context.goNamedAuth(
                          HomePageWidget.routeName, context.mounted);
                    }
                  }
                }
              } else {
                GoRouter.of(context).prepareAuthEvent();
                await authManager.signOut();
                GoRouter.of(context).clearRedirectLocation();

                FFAppState().isLocked = false;
                safeSetState(() {});

                context.goNamedAuth(LoginPageWidget.routeName, context.mounted);
              }
            } else {
              FFAppState().isLocked = false;
              safeSetState(() {});
              _model.entitlementRow2 = await UserEntitlementsTable().queryRows(
                queryFn: (q) => q
                    .eqOrNull(
                      'user_id',
                      currentUserUid,
                    )
                    .eqOrNull(
                      'entitlement',
                      'decoy_wallet',
                    ),
              );
              if ((_model.entitlementRow2?.elementAtOrNull(0)?.provider ==
                      'stripe') &&
                  (_model.entitlementRow2?.elementAtOrNull(0)?.isActive ==
                      false)) {
                _model.api2Result2RSE = await RepairStripeEntitlementCall.call(
                  userId: currentUserUid,
                  jwt: currentJwtToken,
                );

                if ((_model.api2Result2RSE?.succeeded ?? true)) {
                  _model.thirdEntitlementQue =
                      await UserEntitlementsTable().queryRows(
                    queryFn: (q) => q
                        .eqOrNull(
                          'user_id',
                          currentUserUid,
                        )
                        .eqOrNull(
                          'entitlement',
                          'decoy_wallet',
                        ),
                  );
                  FFAppState().hasActiveSubscription =
                      (_model.thirdEntitlementQue != null &&
                              (_model.thirdEntitlementQue)!.isNotEmpty) &&
                          functions.isEntitlementUsableForProtection(
                            _model.thirdEntitlementQue
                                ?.elementAtOrNull(0)
                                ?.isActive,
                            _model.thirdEntitlementQue
                                ?.elementAtOrNull(0)
                                ?.currentPeriodEnd,
                            _model.thirdEntitlementQue
                                ?.elementAtOrNull(0)
                                ?.pendingProvider,
                            _model.thirdEntitlementQue
                                ?.elementAtOrNull(0)
                                ?.pendingStartsAt,
                            _model.thirdEntitlementQue
                                ?.elementAtOrNull(0)
                                ?.pendingProviderSubscriptionId,
                          );
                  safeSetState(() {});
                }
              } else {
                FFAppState().hasActiveSubscription =
                    (_model.entitlementRow2 != null &&
                            (_model.entitlementRow2)!.isNotEmpty) &&
                        functions.isEntitlementUsableForProtection(
                          _model.entitlementRow2?.elementAtOrNull(0)?.isActive,
                          _model.entitlementRow2
                              ?.elementAtOrNull(0)
                              ?.currentPeriodEnd,
                          _model.entitlementRow2
                              ?.elementAtOrNull(0)
                              ?.pendingProvider,
                          _model.entitlementRow2
                              ?.elementAtOrNull(0)
                              ?.pendingStartsAt,
                          _model.entitlementRow2
                              ?.elementAtOrNull(0)
                              ?.pendingProviderSubscriptionId,
                        );
                safeSetState(() {});
              }

              if (FFAppState().hasActiveSubscription == true) {
                if (_model.agreementsComplete != true) {
                  context.goNamedAuth(
                      AgreementsPageWidget.routeName, context.mounted);
                } else {
                  if (_model.setupComplete != true) {
                    context.goNamedAuth(
                        CreatePinWidget.routeName, context.mounted);
                  } else {
                    if (((_model.query2 != null &&
                                (_model.query2)!.isNotEmpty) &&
                            (_model.setupComplete == true)) ||
                        ((_model.query3 != null &&
                                (_model.query3)!.isNotEmpty) &&
                            (_model.setupComplete == true))) {
                      await _goToPinPageAfterCleanHandoff();
                    } else {
                      context.goNamedAuth(
                        CreatePinWidget.routeName,
                        context.mounted,
                        extra: <String, dynamic>{
                          '__transition_info__': TransitionInfo(
                            hasTransition: true,
                            transitionType: PageTransitionType.fade,
                          ),
                        },
                      );
                    }
                  }
                }
              } else {
                if (_model.agreementsComplete != true) {
                  context.goNamedAuth(
                      AgreementsPageWidget.routeName, context.mounted);
                } else {
                  if (_model.setupComplete != true) {
                    context.goNamedAuth(
                        CreatePinWidget.routeName, context.mounted);
                  } else {
                    context.goNamedAuth(
                        HomePageWidget.routeName, context.mounted);
                  }
                }
              }
            }
          }
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: PopScope(
        canPop: false,
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: Color(0x001D2428),
          body: SafeArea(
            top: true,
            child: AnimatedOpacity(
              opacity: _hideContentForPinHandoff ? 0.0 : 1.0,
              duration: _pinHandoffFadeOutDuration,
              curve: Curves.easeOut,
              child: Align(
                alignment: AlignmentDirectional(0.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 40.0),
                        child: Container(
                          width: double.infinity,
                          height: 80.0,
                          decoration: BoxDecoration(
                            color: Color(0x001D2428),
                          ),
                          child: Align(
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: Text(
                              '₿itcoin Wallet',
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context)
                                  .displayMedium
                                  .override(
                                    fontFamily: 'InterTight',
                                    color: FlutterFlowTheme.of(context).primary,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
