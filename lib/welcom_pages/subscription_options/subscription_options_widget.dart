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

  Future<void> _goBack() async {
    if (loggedIn == true) {
      context.pushNamed(
        HomePageWidget.routeName,
        extra: <String, dynamic>{
          '__transition_info__': TransitionInfo(
            hasTransition: true,
            transitionType: PageTransitionType.rightToLeft,
          ),
        },
      );
    } else {
      context.goNamed(
        LoginPageWidget.routeName,
        extra: <String, dynamic>{
          '__transition_info__': TransitionInfo(
            hasTransition: true,
            transitionType: PageTransitionType.rightToLeft,
          ),
        },
      );
    }
  }

  Future<void> _openBtcPayInvoice() async {
    _model.apiResultk1h = await CreateBTCPayInvoiceCall.call(
      currentUserUid: currentUserUid,
      jwt: currentJwtToken,
    );

    final invoiceUrl = CreateBTCPayInvoiceCall.invoiceUrl(
      (_model.apiResultk1h?.jsonBody ?? ''),
    );
    if ((_model.apiResultk1h?.succeeded ?? false) &&
        invoiceUrl != null &&
        invoiceUrl.isNotEmpty) {
      await actions.openExternalUrl(invoiceUrl);
    }

    safeSetState(() {});
  }

  Future<void> _openCardCheckout() async {
    _model.checkoutResp = await CreateCheckoutSessionCall.call(
      currentUserUid: currentUserUid,
      jwt: currentJwtToken,
    );

    final checkoutUrl = CreateCheckoutSessionCall.url(
      (_model.checkoutResp?.jsonBody ?? ''),
    );
    if (checkoutUrl != null && checkoutUrl.isNotEmpty) {
      await actions.openExternalUrl(checkoutUrl);
    }

    safeSetState(() {});
  }

  TextStyle _decoyHeaderStyle(BuildContext context, double fontSize) =>
      FlutterFlowTheme.of(context).bodyMedium.override(
            fontFamily: 'DECOY BEBAS',
            color: FlutterFlowTheme.of(context).info,
            fontSize: fontSize,
            letterSpacing: 0.5,
            fontWeight: FontWeight.normal,
            lineHeight: 1.0,
          );

  Widget _headerPanel(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(maxWidth: 350.0),
            height: 76.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primary,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: FlutterFlowTheme.of(context).primary,
              ),
            ),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(14.0, 8.0, 14.0, 8.0),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'CHOOSE ACCESS',
                  textAlign: TextAlign.center,
                  style: _decoyHeaderStyle(context, 52.0),
                ),
              ),
            ),
          ),
        ),
        Material(
          color: Colors.transparent,
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10.0),
              bottomRight: Radius.circular(10.0),
            ),
          ),
          child: Container(
            width: 190.0,
            height: 62.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10.0),
                bottomRight: Radius.circular(10.0),
              ),
            ),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'METHOD',
                textAlign: TextAlign.center,
                style: _decoyHeaderStyle(context, 52.0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _paymentOption({
    required BuildContext context,
    required String assetPath,
    required double imageHeight,
    required BoxFit imageFit,
    required String buttonText,
    required String caption,
    required Future<void> Function() onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(maxWidth: 350.0),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).info,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: FlutterFlowTheme.of(context).primary,
            width: 3.0,
          ),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(20.0, 18.0, 20.0, 18.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  assetPath,
                  width: 200.0,
                  height: imageHeight,
                  fit: imageFit,
                  alignment: Alignment(0.0, 0.0),
                ),
              ),
              FFButtonWidget(
                onPressed: onPressed,
                text: buttonText,
                options: FFButtonOptions(
                  width: 250.0,
                  height: 50.0,
                  padding: EdgeInsets.all(8.0),
                  iconPadding:
                      EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  color: FlutterFlowTheme.of(context).primary,
                  textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                        font: GoogleFonts.heebo(
                          fontWeight: FontWeight.w600,
                          fontStyle: FlutterFlowTheme.of(context)
                              .titleMedium
                              .fontStyle,
                        ),
                        color: FlutterFlowTheme.of(context).info,
                        letterSpacing: 0.25,
                        fontWeight: FontWeight.w600,
                        fontStyle:
                            FlutterFlowTheme.of(context).titleMedium.fontStyle,
                      ),
                  elevation: 3.0,
                  borderSide: BorderSide(
                    color: Colors.transparent,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              Text(
                caption,
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                      color: FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0.0,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).bodySmallIsCustom,
                    ),
              ),
            ].divide(SizedBox(height: 12.0)),
          ),
        ),
      ),
    );
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 28.0),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Align(
                          alignment: AlignmentDirectional(-1.0, -1.0),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                10.0, 0.0, 0.0, 0.0),
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
                              onPressed: _goBack,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              24.0, 28.0, 24.0, 0.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _headerPanel(context),
                              SizedBox(height: 34.0),
                              _paymentOption(
                                context: context,
                                assetPath:
                                    'assets/images/2a4d10ac-3000-4b7c-8891-b50ff1bdf6d0.jpg',
                                imageHeight: 96.0,
                                imageFit: BoxFit.contain,
                                buttonText: 'Pay with Bitcoin',
                                caption: 'BTCPay invoice in your browser',
                                onPressed: _openBtcPayInvoice,
                              ),
                              SizedBox(height: 16.0),
                              _paymentOption(
                                context: context,
                                assetPath:
                                    'assets/images/Stripe_Logo,_revised_2016.svg.png',
                                imageHeight: 72.0,
                                imageFit: BoxFit.contain,
                                buttonText: 'Pay with Card',
                                caption: 'Stripe checkout in your browser',
                                onPressed: _openCardCheckout,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
