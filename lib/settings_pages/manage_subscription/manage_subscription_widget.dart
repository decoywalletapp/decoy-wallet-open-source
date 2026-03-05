import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'manage_subscription_model.dart';
export 'manage_subscription_model.dart';

/// Create a Subscription Management page for Decoy Wallet.
///
/// On page load, query user entitlement status and subscription provider.
/// Show current access state (Active or Inactive), plan name, and next
/// billing date if available. Provide buttons: Manage Subscription (opens
/// external Stripe portal link in browser when provider is Stripe), Cancel
/// Subscription (optional if you support direct cancel), and Upgrade or
/// Subscribe (navigates to Subscription Options page). If provider is
/// Bitcoin, show status and message that Bitcoin access is managed in app and
/// payments are not recurring. Include a back arrow to Settings and a help
/// text that deleting an account does not automatically cancel billing unless
/// cancelled first.
class ManageSubscriptionWidget extends StatefulWidget {
  const ManageSubscriptionWidget({super.key});

  static String routeName = 'ManageSubscription';
  static String routePath = '/manageSubscription';

  @override
  State<ManageSubscriptionWidget> createState() =>
      _ManageSubscriptionWidgetState();
}

class _ManageSubscriptionWidgetState extends State<ManageSubscriptionWidget> {
  late ManageSubscriptionModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ManageSubscriptionModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.manageQue = await UserEntitlementsTable().queryRows(
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
      _model.provider = _model.manageQue?.elementAtOrNull(0)?.provider;
      _model.providerCustomerId =
          _model.manageQue?.elementAtOrNull(0)?.providerCustomerId;
      _model.providerSubscriptionId =
          _model.manageQue?.elementAtOrNull(0)?.providerSubscriptionId;
      _model.isActive = _model.manageQue?.elementAtOrNull(0)?.isActive;
      _model.pendingSwitchToStripe =
          (_model.manageQue?.elementAtOrNull(0)?.pendingProvider == 'stripe') &&
              (_model.manageQue?.elementAtOrNull(0)?.provider == 'btcpay') &&
              (_model.manageQue?.elementAtOrNull(0)?.isActive == true) &&
              ((_model.manageQue?.elementAtOrNull(0)?.pendingStartsAt !=
                      null) &&
                  (_model.manageQue!.elementAtOrNull(0)!.pendingStartsAt! >
                      getCurrentTimestamp));
      _model.currentPeriodEnd =
          _model.manageQue?.elementAtOrNull(0)?.currentPeriodEnd;
      safeSetState(() {});
      if ((_model.manageQue?.elementAtOrNull(0)?.pendingProvider == 'stripe') &&
          (_model.manageQue?.elementAtOrNull(0)?.pendingStartsAt != null) &&
          (_model.manageQue!.elementAtOrNull(0)!.pendingStartsAt! <=
              getCurrentTimestamp)) {
        _model.apiResultlc3 = await FinalizeStripeSwitchCall.call(
          userId: currentUserUid,
        );
      }
      _model.trueBranchQue = await UserEntitlementsTable().queryRows(
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
      _model.provider = _model.trueBranchQue?.elementAtOrNull(0)?.provider;
      _model.providerCustomerId =
          _model.trueBranchQue?.elementAtOrNull(0)?.providerCustomerId;
      _model.providerSubscriptionId =
          _model.trueBranchQue?.elementAtOrNull(0)?.providerSubscriptionId;
      _model.isActive = _model.trueBranchQue?.elementAtOrNull(0)?.isActive;
      _model.pendingSwitchToStripe =
          _model.trueBranchQue?.elementAtOrNull(0)?.pendingProvider == 'stripe';
      _model.currentPeriodEnd =
          _model.trueBranchQue?.elementAtOrNull(0)?.currentPeriodEnd;
      safeSetState(() {});
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).info,
        body: SafeArea(
          top: true,
          child: Align(
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Align(
                    alignment: AlignmentDirectional(-1.0, -1.0),
                    child: FlutterFlowIconButton(
                      borderColor: Colors.transparent,
                      borderRadius: 22.0,
                      borderWidth: 1.0,
                      buttonSize: 44.0,
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: FlutterFlowTheme.of(context).primaryText,
                        size: 20.0,
                      ),
                      onPressed: () async {
                        context.safePop();
                      },
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Material(
                                    color: Colors.transparent,
                                    elevation: 3.0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Container(
                                      width: 300.0,
                                      height: 110.0,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 12.0, 0.0, 0.0),
                                            child: Stack(
                                              children: [
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          -0.02, 0.0),
                                                  child: Text(
                                                    'MANAGE ACCESS',
                                                    textAlign: TextAlign.center,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              'DECOY BEBAS',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .info,
                                                          fontSize: 48.0,
                                                          letterSpacing: 0.5,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          lineHeight: 1.0,
                                                        ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0.02, 0.0),
                                                  child: Text(
                                                    'MANAGE ACCESS',
                                                    textAlign: TextAlign.center,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              'DECOY BEBAS',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .info,
                                                          fontSize: 48.0,
                                                          letterSpacing: 0.5,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          lineHeight: 1.0,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Expanded(
                                                child: Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0.0, 0.0),
                                                  child: Stack(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, 0.0),
                                                    children: [
                                                      Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                0.0, 0.0),
                                                        child: Text(
                                                          'METHOD',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                fontFamily:
                                                                    'DECOY BEBAS',
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .info,
                                                                fontSize: 48.0,
                                                                letterSpacing:
                                                                    0.5,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                lineHeight: 1.0,
                                                              ),
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                -0.01, 0.0),
                                                        child: Text(
                                                          'METHOD',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                fontFamily:
                                                                    'DECOY BEBAS',
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .info,
                                                                fontSize: 48.0,
                                                                letterSpacing:
                                                                    0.5,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                lineHeight: 1.0,
                                                              ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ].divide(SizedBox(height: 0.0)),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  elevation: 3.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Container(
                                    width: 350.0,
                                    height: 200.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context).info,
                                      borderRadius: BorderRadius.circular(12.0),
                                      border: Border.all(
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        width: 3.0,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          20.0, 0.0, 20.0, 0.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 5.0, 0.0, 0.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 0.0,
                                                                0.0, 5.0),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                      child: Image.asset(
                                                        'assets/images/Bitcoin-Logo.png',
                                                        width: 200.0,
                                                        height: 120.0,
                                                        fit: BoxFit.contain,
                                                        alignment:
                                                            Alignment(0.0, 0.0),
                                                      ),
                                                    ),
                                                  ),
                                                  FFButtonWidget(
                                                    onPressed: () async {
                                                      if (_model.provider !=
                                                          'stripe') {
                                                        _model.apiResultk1h =
                                                            await CreateBTCPayInvoiceCall
                                                                .call(
                                                          currentUserUid:
                                                              currentUserUid,
                                                        );

                                                        if ((_model.apiResultk1h
                                                                ?.succeeded ??
                                                            true)) {
                                                          await actions
                                                              .openExternalUrl(
                                                            CreateBTCPayInvoiceCall
                                                                .invoiceUrl(
                                                              (_model.apiResultk1h
                                                                      ?.jsonBody ??
                                                                  ''),
                                                            )!,
                                                          );
                                                        } else {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                'ERROR #018 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT',
                                                                style:
                                                                    TextStyle(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                                ),
                                                              ),
                                                              duration: Duration(
                                                                  milliseconds:
                                                                      4000),
                                                              backgroundColor:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondary,
                                                            ),
                                                          );
                                                        }
                                                      } else {
                                                        await UserEntitlementsTable()
                                                            .update(
                                                          data: {
                                                            'pending_provider':
                                                                'btcpay',
                                                            'pending_starts_at':
                                                                supaSerialize<
                                                                        DateTime>(
                                                                    _model
                                                                        .currentPeriodEnd),
                                                            'switch_initiated_at':
                                                                supaSerialize<
                                                                        DateTime>(
                                                                    getCurrentTimestamp),
                                                            'teardown_grace_until':
                                                                supaSerialize<
                                                                        DateTime>(
                                                                    _model
                                                                        .currentPeriodEnd),
                                                            'updated_at':
                                                                supaSerialize<
                                                                        DateTime>(
                                                                    getCurrentTimestamp),
                                                          },
                                                          matchingRows:
                                                              (rows) => rows
                                                                  .eqOrNull(
                                                                    'user_id',
                                                                    currentUserUid,
                                                                  )
                                                                  .eqOrNull(
                                                                    'entitlement',
                                                                    'decoy_wallet',
                                                                  ),
                                                        );
                                                        _model.fBAPIresult =
                                                            await CreateBTCPayInvoiceCall
                                                                .call(
                                                          currentUserUid:
                                                              currentUserUid,
                                                        );

                                                        if ((_model.fBAPIresult
                                                                ?.succeeded ??
                                                            true)) {
                                                          await actions
                                                              .openExternalUrl(
                                                            CreateBTCPayInvoiceCall
                                                                .invoiceUrl(
                                                              (_model.fBAPIresult
                                                                      ?.jsonBody ??
                                                                  ''),
                                                            )!,
                                                          );
                                                        } else {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                'ERROR #027 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT',
                                                                style:
                                                                    TextStyle(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                                ),
                                                              ),
                                                              duration: Duration(
                                                                  milliseconds:
                                                                      4000),
                                                              backgroundColor:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondary,
                                                            ),
                                                          );
                                                        }
                                                      }

                                                      safeSetState(() {});
                                                    },
                                                    text: _model.provider ==
                                                            'btcpay'
                                                        ? 'Renew Bitcoin Payments'
                                                        : 'Switch to Bitcoin Payments',
                                                    options: FFButtonOptions(
                                                      width: 250.0,
                                                      height: 50.0,
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      iconPadding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0.0,
                                                                  0.0,
                                                                  0.0,
                                                                  0.0),
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                      textStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleMedium
                                                              .override(
                                                                fontFamily:
                                                                    'robot',
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .info,
                                                                letterSpacing:
                                                                    0.25,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                      elevation: 3.0,
                                                      borderSide: BorderSide(
                                                        color:
                                                            Colors.transparent,
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                  ),
                                                ].divide(SizedBox(height: 0.0)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  elevation: 3.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Container(
                                    width: 350.0,
                                    height: 200.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context).info,
                                      borderRadius: BorderRadius.circular(12.0),
                                      border: Border.all(
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        width: 3.0,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          20.0, 0.0, 20.0, 0.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        0.0, 0.0, 0.0, 20.0),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  child: Image.asset(
                                                    'assets/images/Stripe_Logo,_revised_2016.svg.png',
                                                    width: 200.0,
                                                    height: 73.5,
                                                    fit: BoxFit.cover,
                                                    alignment:
                                                        Alignment(0.0, 0.0),
                                                  ),
                                                ),
                                              ),
                                              FFButtonWidget(
                                                onPressed: () async {
                                                  if ((_model.providerCustomerId !=
                                                              null &&
                                                          _model.providerCustomerId !=
                                                              '') &&
                                                      (_model.provider ==
                                                          'stripe')) {
                                                    _model.portalRespManage =
                                                        await CreateBillingPortalSessionCall
                                                            .call(
                                                      customerId: _model
                                                          .providerCustomerId,
                                                      returnUrl:
                                                          'https://decoywalletapp.com/open',
                                                    );

                                                    await actions
                                                        .openExternalUrl(
                                                      CreateBillingPortalSessionCall
                                                          .url(
                                                        (_model.portalRespManage
                                                                ?.jsonBody ??
                                                            ''),
                                                      )!,
                                                    );
                                                    await Future.delayed(
                                                      Duration(
                                                        milliseconds: 2000,
                                                      ),
                                                    );
                                                    _model.requery3 =
                                                        await UserEntitlementsTable()
                                                            .queryRows(
                                                      queryFn: (q) =>
                                                          q.eqOrNull(
                                                        'user_id',
                                                        currentUserUid,
                                                      ),
                                                    );
                                                    _model
                                                        .pendingSwitchToStripe = (_model
                                                                .requery3
                                                                ?.elementAtOrNull(
                                                                    0)
                                                                ?.pendingProvider ==
                                                            'stripe') &&
                                                        (_model.requery3
                                                                ?.elementAtOrNull(
                                                                    0)
                                                                ?.pendingStartsAt !=
                                                            null) &&
                                                        (_model.requery3!
                                                                .elementAtOrNull(
                                                                    0)!
                                                                .pendingStartsAt! >
                                                            getCurrentTimestamp);
                                                    _model.provider = _model
                                                        .requery3
                                                        ?.elementAtOrNull(0)
                                                        ?.provider;
                                                    safeSetState(() {});
                                                    safeSetState(() {});
                                                  } else {
                                                    _model.apiResult5g4 =
                                                        await CreateCheckoutSessionCall
                                                            .call(
                                                      currentUserUid:
                                                          currentUserUid,
                                                    );

                                                    if ((_model.apiResult5g4
                                                            ?.succeeded ??
                                                        true)) {
                                                      await actions
                                                          .openExternalUrl(
                                                        CreateCheckoutSessionCall
                                                            .url(
                                                          (_model.apiResult5g4
                                                                  ?.jsonBody ??
                                                              ''),
                                                        )!,
                                                      );
                                                      await Future.delayed(
                                                        Duration(
                                                          milliseconds: 2000,
                                                        ),
                                                      );
                                                      _model.requery5 =
                                                          await UserEntitlementsTable()
                                                              .queryRows(
                                                        queryFn: (q) =>
                                                            q.eqOrNull(
                                                          'user_id',
                                                          currentUserUid,
                                                        ),
                                                      );
                                                      _model
                                                          .pendingSwitchToStripe = (_model
                                                                  .requery5
                                                                  ?.elementAtOrNull(
                                                                      0)
                                                                  ?.pendingProvider ==
                                                              'stripe') &&
                                                          (_model.requery5
                                                                  ?.elementAtOrNull(
                                                                      0)
                                                                  ?.pendingStartsAt !=
                                                              null) &&
                                                          (_model.requery5!
                                                                  .elementAtOrNull(
                                                                      0)!
                                                                  .pendingStartsAt! >
                                                              getCurrentTimestamp);
                                                      _model.provider = _model
                                                          .requery5
                                                          ?.elementAtOrNull(0)
                                                          ?.provider;
                                                      safeSetState(() {});
                                                      safeSetState(() {});
                                                    } else {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            'ERROR #028 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT',
                                                            style: TextStyle(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primaryText,
                                                            ),
                                                          ),
                                                          duration: Duration(
                                                              milliseconds:
                                                                  4000),
                                                          backgroundColor:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .secondary,
                                                        ),
                                                      );
                                                    }
                                                  }

                                                  safeSetState(() {});
                                                },
                                                text: _model.provider ==
                                                        'stripe'
                                                    ? 'Manage Card Payments'
                                                    : 'Switch to Card Payments',
                                                options: FFButtonOptions(
                                                  width: 250.0,
                                                  height: 50.0,
                                                  padding: EdgeInsets.all(8.0),
                                                  iconPadding:
                                                      EdgeInsetsDirectional
                                                          .fromSTEB(0.0, 0.0,
                                                              0.0, 0.0),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  textStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .titleMedium
                                                      .override(
                                                        fontFamily: 'robot',
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .info,
                                                        letterSpacing: 0.25,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                  elevation: 3.0,
                                                  borderSide: BorderSide(
                                                    color: Colors.transparent,
                                                    width: 1.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 0.0)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Account Subscription Status:  ',
                                      textAlign: TextAlign.start,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMediumFamily,
                                            fontSize: 16.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodyMediumIsCustom,
                                          ),
                                    ),
                                    Stack(
                                      children: [
                                        Align(
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              if ((_model.manageQue
                                                          ?.elementAtOrNull(0)
                                                          ?.isActive ==
                                                      true) &&
                                                  (_model.manageQue
                                                          ?.elementAtOrNull(0)
                                                          ?.currentPeriodEnd !=
                                                      null) &&
                                                  (_model.pendingSwitchToStripe ==
                                                      false))
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0.0, 0.0),
                                                  child: Text(
                                                    functions
                                                        .daysLeftFromPeriodEnd(_model
                                                            .manageQue
                                                            ?.elementAtOrNull(0)
                                                            ?.currentPeriodEnd)
                                                        .toString(),
                                                    textAlign: TextAlign.center,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMediumFamily,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .success,
                                                          fontSize: 16.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMediumIsCustom,
                                                        ),
                                                  ),
                                                ),
                                              if ((_model.manageQue
                                                          ?.elementAtOrNull(0)
                                                          ?.isActive ==
                                                      true) &&
                                                  (_model.manageQue
                                                          ?.elementAtOrNull(0)
                                                          ?.currentPeriodEnd !=
                                                      null) &&
                                                  (_model.pendingSwitchToStripe ==
                                                      false))
                                                Text(
                                                  ' DAYS LEFT',
                                                  style:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            letterSpacing: 0.0,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            if (_model.manageQue
                                                    ?.elementAtOrNull(0)
                                                    ?.isActive ==
                                                false)
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: Text(
                                                  'INACTIVE',
                                                  textAlign: TextAlign.center,
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMediumFamily,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .error,
                                                        fontSize: 16.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        useGoogleFonts:
                                                            !FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMediumIsCustom,
                                                      ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            if (_model.pendingSwitchToStripe ==
                                                true)
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: Text(
                                                  'Stripe will take over on  ',
                                                  textAlign: TextAlign.center,
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMediumFamily,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primaryText,
                                                        fontSize: 16.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        useGoogleFonts:
                                                            !FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMediumIsCustom,
                                                      ),
                                                ),
                                              ),
                                            if (_model.pendingSwitchToStripe ==
                                                true)
                                              Text(
                                                dateTimeFormat(
                                                    "yMd",
                                                    _model.manageQue!
                                                        .elementAtOrNull(0)!
                                                        .pendingStartsAt!),
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      fontFamily:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMediumFamily,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .success,
                                                      letterSpacing: 0.0,
                                                      useGoogleFonts:
                                                          !FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMediumIsCustom,
                                                    ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ].divide(SizedBox(height: 8.0)),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      20.0, 0.0, 20.0, 0.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 1.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            FFButtonWidget(
                                              onPressed: () async {
                                                if (_model.providerCustomerId !=
                                                        null &&
                                                    _model.providerCustomerId !=
                                                        '') {
                                                  _model.portalRespCancel =
                                                      await CreateBillingPortalSessionCall
                                                          .call(
                                                    customerId: _model
                                                        .providerCustomerId,
                                                    returnUrl:
                                                        'https://decoywalletapp.com/open',
                                                  );

                                                  await actions.openExternalUrl(
                                                    CreateBillingPortalSessionCall
                                                        .url(
                                                      (_model.portalRespCancel
                                                              ?.jsonBody ??
                                                          ''),
                                                    )!,
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'ERROR #017 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT',
                                                        style: TextStyle(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryText,
                                                        ),
                                                      ),
                                                      duration: Duration(
                                                          milliseconds: 4000),
                                                      backgroundColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .secondary,
                                                    ),
                                                  );
                                                }

                                                safeSetState(() {});
                                              },
                                              text: 'Cancel Subscription',
                                              options: FFButtonOptions(
                                                width: 250.0,
                                                height: 50.0,
                                                padding: EdgeInsets.all(8.0),
                                                iconPadding:
                                                    EdgeInsetsDirectional
                                                        .fromSTEB(
                                                            0.0, 0.0, 0.0, 0.0),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .error,
                                                textStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleMedium
                                                        .override(
                                                          fontFamily: 'robot',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .info,
                                                          letterSpacing: 0.25,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                elevation: 3.0,
                                                borderSide: BorderSide(
                                                  color: Colors.transparent,
                                                  width: 1.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                            ),
                                          ].divide(SizedBox(height: 0.0)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ].divide(SizedBox(height: 18.0)),
                            ),
                          ),
                        ]
                            .divide(SizedBox(height: 20.0))
                            .addToStart(SizedBox(height: 12.0)),
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
