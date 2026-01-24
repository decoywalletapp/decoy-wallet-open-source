import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/actions/index.dart' as actions;
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
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
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
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
                                Material(
                                  color: Colors.transparent,
                                  elevation: 3.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Container(
                                    width: 350.0,
                                    height: 120.0,
                                    decoration: BoxDecoration(
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            8.0, 12.0, 8.0, 12.0),
                                        child: Text(
                                          'Manage access Method',
                                          textAlign: TextAlign.center,
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.bebasNeue(
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .info,
                                                fontSize: 48.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                                lineHeight: 1.125,
                                              ),
                                        ),
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
                                                              style: TextStyle(
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

                                                      safeSetState(() {});
                                                    },
                                                    text:
                                                        'Renew Bitcoin Payment',
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
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleMediumFamily,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .info,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleMediumIsCustom,
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
                                                  if (_model.providerCustomerId !=
                                                          null &&
                                                      _model.providerCustomerId !=
                                                          '') {
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
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'ERROR #019 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT',
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
                                                text: 'Manage Card Payments',
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
                                                  textStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleMediumFamily,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .info,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleMediumIsCustom,
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
                                        if (_model.manageQue
                                                ?.elementAtOrNull(0)
                                                ?.isActive ==
                                            true)
                                          Text(
                                            'ACTIVE',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMediumFamily,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .success,
                                                  fontSize: 16.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.bold,
                                                  useGoogleFonts:
                                                      !FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMediumIsCustom,
                                                ),
                                          ),
                                        if (_model.manageQue
                                                ?.elementAtOrNull(0)
                                                ?.isActive ==
                                            false)
                                          Text(
                                            'INACTIVE',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMediumFamily,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .error,
                                                  fontSize: 16.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.bold,
                                                  useGoogleFonts:
                                                      !FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMediumIsCustom,
                                                ),
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
                                                textStyle: FlutterFlowTheme.of(
                                                        context)
                                                    .titleMedium
                                                    .override(
                                                      fontFamily:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleMediumFamily,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .info,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      useGoogleFonts:
                                                          !FlutterFlowTheme.of(
                                                                  context)
                                                              .titleMediumIsCustom,
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
