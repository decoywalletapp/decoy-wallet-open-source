import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'subscription_options_model.dart';
export 'subscription_options_model.dart';

/// Create a new page named SubscriptionOptions.
///
/// Centered layout with a simple header and two primary payment choices. At
/// the top show title “Unlock Decoy Wallet” and subtitle “Choose how you want
/// to subscribe”. Add a small pricing line under the subtitle “Subscription
/// required to access premium features”. Add two large full width buttons
/// stacked with spacing 16: Button 1 label “Pay with Card” with a small
/// caption below “Stripe checkout in your browser”. Button 2 label “Pay with
/// Bitcoin” with a small caption below “BTCPay invoice in your browser”.
/// Under the buttons add a small muted note “You will be taken to Safari to
/// complete payment, then returned to the app”. Add a text button at the
/// bottom “Not now” that navigates back. Include loading state placeholders
/// near the buttons area.
class SubscriptionOptionsWidget extends StatefulWidget {
  const SubscriptionOptionsWidget({super.key});

  static String routeName = 'SubscriptionOptions';
  static String routePath = '/subscriptionOptions';

  @override
  State<SubscriptionOptionsWidget> createState() =>
      _SubscriptionOptionsWidgetState();
}

class _SubscriptionOptionsWidgetState extends State<SubscriptionOptionsWidget> {
  late SubscriptionOptionsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  String _billingInterval = 'monthly';

  bool get _isYearly => _billingInterval == 'yearly';

  String get _bitcoinPriceLabel =>
      _isYearly ? '\$39.42 / year' : '\$3.94 / month';

  String get _cardPriceLabel => _isYearly ? '\$49.90 / year' : '\$4.99 / month';

  bool _hasText(String? value) => value != null && value.isNotEmpty;

  void _showPaymentError(String code) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$code - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT',
          style: TextStyle(
            color: FlutterFlowTheme.of(context).primaryText,
          ),
        ),
        duration: Duration(milliseconds: 4000),
        backgroundColor: FlutterFlowTheme.of(context).secondary,
      ),
    );
  }

  Future<bool> _openPaymentUrl(String? url, String errorCode) async {
    if (_hasText(url)) {
      await actions.openExternalUrl(url!);
      return true;
    }

    _showPaymentError(errorCode);
    return false;
  }

  Widget _buildPriceLabel({
    required BuildContext context,
    required String priceLabel,
    required String yearlyCompareLabel,
  }) {
    final priceStyle = FlutterFlowTheme.of(context).bodyMedium.override(
          fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
          color: FlutterFlowTheme.of(context).primary,
          fontSize: 16.0,
          letterSpacing: 0.0,
          fontWeight: FontWeight.w700,
          useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
        );

    if (!_isYearly) {
      return Text(
        priceLabel,
        textAlign: TextAlign.center,
        style: priceStyle,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          yearlyCompareLabel,
          textAlign: TextAlign.center,
          style: priceStyle.copyWith(
            color: FlutterFlowTheme.of(context).error,
            decoration: TextDecoration.lineThrough,
            decorationColor: FlutterFlowTheme.of(context).error,
            decorationThickness: 2.0,
            fontSize: 14.0,
          ),
        ),
        Text(
          priceLabel,
          textAlign: TextAlign.center,
          style: priceStyle,
        ),
      ],
    );
  }

  Widget _buildPlanChoice({
    required BuildContext context,
    required String interval,
    required String title,
    required String subtitle,
  }) {
    final selected = _billingInterval == interval;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10.0),
        onTap: () => safeSetState(() => _billingInterval = interval),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 160),
          padding: EdgeInsetsDirectional.fromSTEB(8.0, 10.0, 8.0, 10.0),
          decoration: BoxDecoration(
            color: selected
                ? FlutterFlowTheme.of(context).primary
                : FlutterFlowTheme.of(context).info,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: FlutterFlowTheme.of(context).primary,
              width: 2.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                      color: selected
                          ? FlutterFlowTheme.of(context).info
                          : FlutterFlowTheme.of(context).primaryText,
                      fontSize: 14.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w700,
                      useGoogleFonts: !FlutterFlowTheme.of(
                        context,
                      ).bodyMediumIsCustom,
                    ),
              ),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                      color: selected
                          ? FlutterFlowTheme.of(context).info
                          : FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 11.0,
                      letterSpacing: 0.0,
                      useGoogleFonts: !FlutterFlowTheme.of(
                        context,
                      ).bodySmallIsCustom,
                    ),
              ),
            ].divide(SizedBox(height: 2.0)),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SubscriptionOptionsModel());

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
      child: PopScope(
        canPop: false,
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).info,
          body: SafeArea(
            top: true,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Align(
                  alignment: AlignmentDirectional(-1.0, -1.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Align(
                        alignment: AlignmentDirectional(-1.0, -1.0),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                            10.0,
                            0.0,
                            0.0,
                            0.0,
                          ),
                          child: FlutterFlowIconButton(
                            borderColor: Colors.transparent,
                            borderRadius: 22.0,
                            borderWidth: 1.0,
                            buttonSize: 40.0,
                            icon: Icon(
                              Icons.arrow_back_rounded,
                              color: FlutterFlowTheme.of(context).primaryText,
                              size: 24.0,
                            ),
                            onPressed: () async {
                              if (loggedIn == true) {
                                context.pushNamed(
                                  HomePageWidget.routeName,
                                  extra: <String, dynamic>{
                                    '__transition_info__': TransitionInfo(
                                      hasTransition: true,
                                      transitionType:
                                          PageTransitionType.rightToLeft,
                                    ),
                                  },
                                );
                              } else {
                                context.goNamed(
                                  LoginPageWidget.routeName,
                                  extra: <String, dynamic>{
                                    '__transition_info__': TransitionInfo(
                                      hasTransition: true,
                                      transitionType:
                                          PageTransitionType.rightToLeft,
                                    ),
                                  },
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    primary: false,
                    padding: EdgeInsetsDirectional.fromSTEB(
                      24.0,
                      0.0,
                      24.0,
                      24.0,
                    ),
                    child: Align(
                      alignment: AlignmentDirectional(0.0, -1.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                              16.0,
                              0.0,
                              16.0,
                              0.0,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Material(
                                      color: Colors.transparent,
                                      elevation: 5.0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: Container(
                                        width: 300.0,
                                        height: 72.0,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(
                                            context,
                                          ).primary,
                                          borderRadius: BorderRadius.circular(
                                            10.0,
                                          ),
                                          border: Border.all(
                                            color: FlutterFlowTheme.of(
                                              context,
                                            ).primary,
                                          ),
                                        ),
                                        alignment: AlignmentDirectional(
                                          0.0,
                                          0.0,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                0.0,
                                                12.0,
                                                0.0,
                                                0.0,
                                              ),
                                              child: Stack(
                                                children: [
                                                  Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                      0.02,
                                                      0.0,
                                                    ),
                                                    child: Text(
                                                      'CHOOSE ACCESS',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style:
                                                          FlutterFlowTheme.of(
                                                        context,
                                                      ).bodyMedium.override(
                                                                fontFamily:
                                                                    'DECOY BEBAS',
                                                                color:
                                                                    FlutterFlowTheme
                                                                        .of(
                                                                  context,
                                                                ).info,
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
                                                      -0.02,
                                                      0.0,
                                                    ),
                                                    child: Text(
                                                      'CHOOSE ACCESS',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style:
                                                          FlutterFlowTheme.of(
                                                        context,
                                                      ).bodyMedium.override(
                                                                fontFamily:
                                                                    'DECOY BEBAS',
                                                                color:
                                                                    FlutterFlowTheme
                                                                        .of(
                                                                  context,
                                                                ).info,
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
                                          ],
                                        ),
                                      ),
                                    ),
                                    Material(
                                      color: Colors.transparent,
                                      elevation: 5.0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(
                                            10.0,
                                          ),
                                          bottomRight: Radius.circular(
                                            10.0,
                                          ),
                                        ),
                                      ),
                                      child: Container(
                                        width: 175.0,
                                        height: 60.0,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(
                                            context,
                                          ).primary,
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(
                                              10.0,
                                            ),
                                            bottomRight: Radius.circular(
                                              10.0,
                                            ),
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Stack(
                                              children: [
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                    0.02,
                                                    0.0,
                                                  ),
                                                  child: Text(
                                                    'METHOD',
                                                    textAlign: TextAlign.center,
                                                    style: FlutterFlowTheme.of(
                                                      context,
                                                    ).bodyMedium.override(
                                                          fontFamily:
                                                              'DECOY BEBAS',
                                                          color:
                                                              FlutterFlowTheme
                                                                  .of(
                                                            context,
                                                          ).info,
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
                                                    -0.02,
                                                    0.0,
                                                  ),
                                                  child: Text(
                                                    'METHOD',
                                                    textAlign: TextAlign.center,
                                                    style: FlutterFlowTheme.of(
                                                      context,
                                                    ).bodyMedium.override(
                                                          fontFamily:
                                                              'DECOY BEBAS',
                                                          color:
                                                              FlutterFlowTheme
                                                                  .of(
                                                            context,
                                                          ).info,
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
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ].divide(SizedBox(height: 0.0)),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                              16.0,
                              0.0,
                              16.0,
                              0.0,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              elevation: 2.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Container(
                                width: 350.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(
                                    context,
                                  ).info,
                                  borderRadius: BorderRadius.circular(
                                    12.0,
                                  ),
                                  border: Border.all(
                                    color: FlutterFlowTheme.of(
                                      context,
                                    ).primary,
                                    width: 2.0,
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(6.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      _buildPlanChoice(
                                        context: context,
                                        interval: 'monthly',
                                        title: 'Monthly',
                                        subtitle: 'Flexible access',
                                      ),
                                      _buildPlanChoice(
                                        context: context,
                                        interval: 'yearly',
                                        title: 'Yearly',
                                        subtitle: '2 months free',
                                      ),
                                    ].divide(SizedBox(width: 6.0)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                              16.0,
                              0.0,
                              16.0,
                              0.0,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  elevation: 3.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      12.0,
                                    ),
                                  ),
                                  child: Container(
                                    width: 350.0,
                                    height: _isYearly ? 280.0 : 260.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(
                                        context,
                                      ).info,
                                      borderRadius: BorderRadius.circular(
                                        12.0,
                                      ),
                                      border: Border.all(
                                        color: FlutterFlowTheme.of(
                                          context,
                                        ).primary,
                                        width: 3.0,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                        20.0,
                                        0.0,
                                        20.0,
                                        0.0,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Align(
                                            alignment: AlignmentDirectional(
                                              0.0,
                                              1.0,
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                      0.0,
                                                      0.0,
                                                      0.0,
                                                      5.0,
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        8.0,
                                                      ),
                                                      child: Image.asset(
                                                        'assets/images/2a4d10ac-3000-4b7c-8891-b50ff1bdf6d0.jpg',
                                                        width: 200.0,
                                                        height: 120.0,
                                                        fit: BoxFit.contain,
                                                        alignment: Alignment(
                                                          0.0,
                                                          0.0,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  _buildPriceLabel(
                                                    context: context,
                                                    priceLabel:
                                                        _bitcoinPriceLabel,
                                                    yearlyCompareLabel:
                                                        '\$47.28 / year',
                                                  ),
                                                  FFButtonWidget(
                                                    onPressed: () async {
                                                      _model.apiResultk1h =
                                                          await CreateBTCPayInvoiceCall
                                                              .call(
                                                        currentUserUid:
                                                            currentUserUid,
                                                        billingInterval:
                                                            _billingInterval,
                                                        jwt: currentJwtToken,
                                                      );

                                                      if ((_model.apiResultk1h
                                                              ?.succeeded ??
                                                          false)) {
                                                        await _openPaymentUrl(
                                                          CreateBTCPayInvoiceCall
                                                              .invoiceUrl(
                                                            (_model.apiResultk1h
                                                                    ?.jsonBody ??
                                                                ''),
                                                          ),
                                                          'ERROR #018',
                                                        );
                                                      } else {
                                                        _showPaymentError(
                                                            'ERROR #018');
                                                      }

                                                      safeSetState(() {});
                                                    },
                                                    text: 'Pay with Bitcoin',
                                                    options: FFButtonOptions(
                                                      width: 250.0,
                                                      height: 50.0,
                                                      padding: EdgeInsets.all(
                                                        8.0,
                                                      ),
                                                      iconPadding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                        0.0,
                                                        0.0,
                                                        0.0,
                                                        0.0,
                                                      ),
                                                      color:
                                                          FlutterFlowTheme.of(
                                                        context,
                                                      ).primary,
                                                      textStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleMedium
                                                              .override(
                                                                font:
                                                                    GoogleFonts
                                                                        .heebo(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontStyle: FlutterFlowTheme
                                                                          .of(
                                                                    context,
                                                                  )
                                                                      .titleMedium
                                                                      .fontStyle,
                                                                ),
                                                                color:
                                                                    FlutterFlowTheme
                                                                        .of(
                                                                  context,
                                                                ).info,
                                                                letterSpacing:
                                                                    0.25,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontStyle: FlutterFlowTheme
                                                                        .of(
                                                                  context,
                                                                )
                                                                    .titleMedium
                                                                    .fontStyle,
                                                              ),
                                                      elevation: 3.0,
                                                      borderSide: BorderSide(
                                                        color:
                                                            Colors.transparent,
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        8.0,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    'BTCPay invoice in your browser',
                                                    textAlign: TextAlign.center,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodySmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme
                                                                  .of(
                                                            context,
                                                          ).bodySmallFamily,
                                                          color:
                                                              FlutterFlowTheme
                                                                  .of(
                                                            context,
                                                          ).primaryText,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                  .of(
                                                            context,
                                                          ).bodySmallIsCustom,
                                                        ),
                                                  ),
                                                ].divide(SizedBox(height: 8.0)),
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
                                    borderRadius: BorderRadius.circular(
                                      12.0,
                                    ),
                                  ),
                                  child: Container(
                                    width: 350.0,
                                    height: _isYearly ? 280.0 : 260.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(
                                        context,
                                      ).info,
                                      borderRadius: BorderRadius.circular(
                                        12.0,
                                      ),
                                      border: Border.all(
                                        color: FlutterFlowTheme.of(
                                          context,
                                        ).primary,
                                        width: 3.0,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                        20.0,
                                        0.0,
                                        20.0,
                                        0.0,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Align(
                                            alignment: AlignmentDirectional(
                                              0.0,
                                              1.0,
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                      0.0,
                                                      0.0,
                                                      0.0,
                                                      20.0,
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        8.0,
                                                      ),
                                                      child: Image.asset(
                                                        'assets/images/Stripe_Logo,_revised_2016.svg.png',
                                                        width: 200.0,
                                                        height: 73.5,
                                                        fit: BoxFit.cover,
                                                        alignment: Alignment(
                                                          0.0,
                                                          0.0,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  _buildPriceLabel(
                                                    context: context,
                                                    priceLabel: _cardPriceLabel,
                                                    yearlyCompareLabel:
                                                        '\$59.88 / year',
                                                  ),
                                                  FFButtonWidget(
                                                    onPressed: () async {
                                                      _model.checkoutResp =
                                                          await CreateCheckoutSessionCall
                                                              .call(
                                                        currentUserUid:
                                                            currentUserUid,
                                                        billingInterval:
                                                            _billingInterval,
                                                        jwt: currentJwtToken,
                                                      );

                                                      if ((_model.checkoutResp
                                                              ?.succeeded ??
                                                          false)) {
                                                        await _openPaymentUrl(
                                                          CreateCheckoutSessionCall
                                                              .url(
                                                            (_model.checkoutResp
                                                                    ?.jsonBody ??
                                                                ''),
                                                          ),
                                                          'ERROR #029',
                                                        );
                                                      } else {
                                                        _showPaymentError(
                                                            'ERROR #029');
                                                      }

                                                      safeSetState(() {});
                                                    },
                                                    text: 'Pay with Card',
                                                    options: FFButtonOptions(
                                                      width: 250.0,
                                                      height: 50.0,
                                                      padding: EdgeInsets.all(
                                                        8.0,
                                                      ),
                                                      iconPadding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                        0.0,
                                                        0.0,
                                                        0.0,
                                                        0.0,
                                                      ),
                                                      color:
                                                          FlutterFlowTheme.of(
                                                        context,
                                                      ).primary,
                                                      textStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleMedium
                                                              .override(
                                                                font:
                                                                    GoogleFonts
                                                                        .heebo(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontStyle: FlutterFlowTheme
                                                                          .of(
                                                                    context,
                                                                  )
                                                                      .titleMedium
                                                                      .fontStyle,
                                                                ),
                                                                color:
                                                                    FlutterFlowTheme
                                                                        .of(
                                                                  context,
                                                                ).info,
                                                                letterSpacing:
                                                                    0.25,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontStyle: FlutterFlowTheme
                                                                        .of(
                                                                  context,
                                                                )
                                                                    .titleMedium
                                                                    .fontStyle,
                                                              ),
                                                      elevation: 3.0,
                                                      borderSide: BorderSide(
                                                        color:
                                                            Colors.transparent,
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        8.0,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    'Stripe checkout in your browser',
                                                    textAlign: TextAlign.center,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodySmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme
                                                                  .of(
                                                            context,
                                                          ).bodySmallFamily,
                                                          color:
                                                              FlutterFlowTheme
                                                                  .of(
                                                            context,
                                                          ).primaryText,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                  .of(
                                                            context,
                                                          ).bodySmallIsCustom,
                                                        ),
                                                  ),
                                                ].divide(SizedBox(height: 8.0)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ].divide(SizedBox(height: 16.0)),
                            ),
                          ),
                        ].divide(SizedBox(height: 18.0)).addToEnd(
                              SizedBox(height: 64.0),
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
    );
  }
}
