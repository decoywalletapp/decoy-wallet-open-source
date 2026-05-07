import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'payment_return_model.dart';
export 'payment_return_model.dart';

class PaymentReturnWidget extends StatefulWidget {
  const PaymentReturnWidget({
    super.key,
    this.ts,
    this.sessionId,
  });

  final String? ts;
  final String? sessionId;

  static String routeName = 'PaymentReturn';
  static String routePath = '/paymentreturn';

  @override
  State<PaymentReturnWidget> createState() => _PaymentReturnWidgetState();
}

class _PaymentReturnWidgetState extends State<PaymentReturnWidget> {
  late PaymentReturnModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showManualRefresh = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PaymentReturnModel());

    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        safeSetState(() => _showManualRefresh = true);
      }
    });

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      FFAppState().entitlementCheckCompleted = false;
      FFAppState().hasActiveSubscription = false;
      safeSetState(() {});
      final checkoutSessionId =
          (widget.sessionId != null && widget.sessionId != '')
              ? widget.sessionId
              : FFAppState().pendingStripeCheckoutSessionId;
      if (checkoutSessionId != null && checkoutSessionId != '') {
        _model.stripeSwitchSyncResult = await FinalizeStripeSwitchCall.call(
          userId: currentUserUid,
          sessionId: checkoutSessionId,
          jwt: currentJwtToken,
        );
      }
      _model.entitlementsQuery = await UserEntitlementsTable().queryRows(
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
      final entitlement = _model.entitlementsQuery?.elementAtOrNull(0);
      final stripeSwitchConfirmed =
          entitlement?.provider == 'stripe' ||
              (entitlement?.pendingProvider == 'stripe' &&
                  (entitlement?.pendingProviderSubscriptionId ?? '')
                      .isNotEmpty);
      if (stripeSwitchConfirmed) {
        FFAppState().pendingStripeCheckoutSessionId = '';
      }
      FFAppState().entitlementCheckCompleted = true;
      safeSetState(() {});
      if ((_model.entitlementsQuery != null &&
              (_model.entitlementsQuery)!.isNotEmpty) &&
          (_model.entitlementsQuery?.elementAtOrNull(0)?.isActive == true)) {
        FFAppState().hasActiveSubscription = true;
        safeSetState(() {});

        context.goNamed(HomePageWidget.routeName);
      } else {
        FFAppState().hasActiveSubscription = false;
        safeSetState(() {});

        context.goNamed(SubscriptionOptionsWidget.routeName);
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
          backgroundColor: FlutterFlowTheme.of(context).info,
          body: SafeArea(
            top: true,
            child: Align(
              alignment: AlignmentDirectional(0.0, 0.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: AlignmentDirectional(0.0, 0.0),
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 250),
                      child: !_showManualRefresh
                          ? ClipRRect(
                              key: ValueKey('paymentReturnLogo'),
                              borderRadius: BorderRadius.circular(0.0),
                              child: Image.asset(
                                'assets/images/DecoyLogo1-WOHiRes.jpg',
                                width: 200.0,
                                height: 120.0,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Row(
                              key: ValueKey('paymentReturnRefresh'),
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Align(
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      FFAppState()
                                              .entitlementCheckCompleted =
                                          false;
                                      FFAppState().hasActiveSubscription =
                                          false;
                                      safeSetState(() {});
                                      _model.entitlementsQueryRefresh =
                                          await UserEntitlementsTable()
                                              .queryRows(
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
                                      FFAppState()
                                          .entitlementCheckCompleted = true;
                                      safeSetState(() {});
                                      if ((_model.entitlementsQueryRefresh !=
                                                  null &&
                                              (_model
                                                      .entitlementsQueryRefresh)!
                                                  .isNotEmpty) &&
                                          (_model.entitlementsQueryRefresh
                                                  ?.elementAtOrNull(0)
                                                  ?.isActive ==
                                              true)) {
                                        FFAppState().hasActiveSubscription =
                                            true;
                                        safeSetState(() {});

                                        context.goNamed(
                                            HomePageWidget.routeName);
                                      } else {
                                        FFAppState().hasActiveSubscription =
                                            false;
                                        safeSetState(() {});

                                        context.goNamed(
                                            SubscriptionOptionsWidget
                                                .routeName);
                                      }

                                      safeSetState(() {});
                                    },
                                    child: Text(
                                      'Refresh',
                                      textAlign: TextAlign.start,
                                      style: FlutterFlowTheme.of(context)
                                          .displayMedium
                                          .override(
                                            fontFamily: 'InterTight',
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                            fontSize: 24.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().entitlementCheckCompleted =
                                        false;
                                    FFAppState().hasActiveSubscription = false;
                                    safeSetState(() {});
                                    _model.entitlementsQueryRefreshButton =
                                        await UserEntitlementsTable()
                                            .queryRows(
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
                                    FFAppState().entitlementCheckCompleted =
                                        true;
                                    safeSetState(() {});
                                    if ((_model.entitlementsQueryRefreshButton !=
                                                null &&
                                            (_model
                                                    .entitlementsQueryRefreshButton)!
                                                .isNotEmpty) &&
                                        (_model.entitlementsQueryRefreshButton
                                                ?.elementAtOrNull(0)
                                                ?.isActive ==
                                            true)) {
                                      FFAppState().hasActiveSubscription = true;
                                      safeSetState(() {});

                                      context
                                          .goNamed(HomePageWidget.routeName);
                                    } else {
                                      FFAppState().hasActiveSubscription =
                                          false;
                                      safeSetState(() {});

                                      context.goNamed(
                                          SubscriptionOptionsWidget.routeName);
                                    }

                                    safeSetState(() {});
                                  },
                                  child: Icon(
                                    Icons.refresh_sharp,
                                    color:
                                        FlutterFlowTheme.of(context).primary,
                                    size: 24.0,
                                  ),
                                ),
                              ].divide(SizedBox(width: 6.0)),
                            ),
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
