import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'agreements_page_model.dart';
export 'agreements_page_model.dart';

const String _termsOfUseText = '''
Welcome to Decoy Wallet.

By continuing, you agree to Decoy Wallet LLC's Terms of Use. Decoy Wallet is personal-safety software. It is not a bank, broker, exchange, custodian, financial adviser, emergency dispatcher, or law enforcement service.

Decoy Wallet does not hold cryptocurrency, access private keys, execute transactions, or guarantee that an emergency alert will be received or acted on.

Emergency-trigger features, including decoy PINs, decoy seed phrases, QR-triggered alerts, contact alerts, and related app behavior, must be used only for lawful and legitimate safety situations.

You are responsible for the accuracy of your account information, emergency contacts, phone numbers, device permissions, and app settings. Network availability, device battery, operating system settings, notification permissions, SMS delivery, provider outages, location accuracy, and third-party service availability may affect alert delivery.

False, abusive, unlawful, or improper emergency use may have legal consequences. You accept responsibility for any misuse of emergency features, including false alerts, contact notifications, fees, penalties, disputes, or other harm caused by improper use.

All services are provided as-is and as-available. To the fullest extent allowed by law, Decoy Wallet LLC and its owners, officers, employees, contractors, and developers are not liable for personal injury, death, financial loss, lost cryptocurrency, failed alerts, delayed alerts, inaccurate alerts, actions or inactions of emergency services, data loss, software bugs, device failures, or third-party service issues.

You also agree to any full Terms of Use text made available in the app, on Decoy Wallet's website, or through Decoy Wallet support.
''';

const String _privacyPolicyText = '''
Decoy Wallet LLC respects your privacy and uses your information to operate the app, protect accounts, provide safety features, and deliver account-related or emergency-related messages you enable.

Information you provide may include your name, phone number, email address, emergency contact names and phone numbers, home or safe-location address, subscription/payment status, and settings you choose inside the app.

The app may also process device information, push notification tokens, app usage events, coarse or precise location during emergency-trigger behavior, and emergency event details needed to deliver safety alerts.

Location information is used for emergency and safety workflows when enabled. Decoy Wallet is not intended to collect background location data for unrelated tracking.

SMS and phone data are used only for account-related, consent-related, and emergency alert messages that you enable. Decoy Wallet does not sell, rent, or share mobile numbers, SMS consent, or text messaging originator opt-in data with third parties or affiliates for their own marketing or promotional purposes.

Decoy Wallet may use service providers such as Supabase, Firebase, Twilio, Google Cloud, BTCPay, Stripe, Apple, and emergency-service integration partners when needed to operate app features. These providers may process data only as needed for app functionality, security, support, payments, notifications, SMS delivery, or emergency workflows.

You can manage app permissions through device settings. You may request account deletion or data deletion through the app where available or by contacting Decoy Wallet support.

You also agree to any full Privacy Policy text made available in the app, on Decoy Wallet's website, or through Decoy Wallet support.
''';

class AgreementsPageWidget extends StatefulWidget {
  const AgreementsPageWidget({super.key});

  static String routeName = 'AgreementsPage';
  static String routePath = '/agreementsPage';

  @override
  State<AgreementsPageWidget> createState() => _AgreementsPageWidgetState();
}

class _AgreementsPageWidgetState extends State<AgreementsPageWidget> {
  late AgreementsPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool get _canContinue =>
      (_model.checkboxValue1 == true) && (_model.checkboxValue2 == true);

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AgreementsPageModel());
    _model.pageViewController = PageController(initialPage: 0);

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Future<void> _selectAgreementPage(int index) async {
    _model.agreementPageIndex = index;
    safeSetState(() {});
    await _model.pageViewController?.animateToPage(
      index,
      duration: Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  Future<void> _completeOnboarding() async {
    if (!_canContinue) return;

    try {
      final acceptedAt = getCurrentTimestamp;

      _model.ins1 = await UserConsentsTable().insert({
        'user_id': currentUserUid,
        'feature': 'onboarding_agreements',
        'consent_version': 'terms_privacy_v1',
        'checkboxes': {
          'terms_of_use': true,
          'privacy_policy': true,
          'accepted_at': acceptedAt.toIso8601String(),
        },
        'app_version': '0.1.0',
      });

      _model.up1 = await DecoyWalletTable().update(
        data: {
          'setup_complete': true,
          'setup_completed_at': supaSerialize<DateTime>(acceptedAt),
        },
        matchingRows: (rows) => rows.eqOrNull(
          'user_id',
          currentUserUid,
        ),
      );

      if (!mounted) return;

      context.goNamed(
        HomePageWidget.routeName,
        extra: <String, dynamic>{
          '__transition_info__': TransitionInfo(
            hasTransition: true,
            transitionType: PageTransitionType.fade,
          ),
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not finish setup. Please try again.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: FlutterFlowTheme.of(context).info,
            ),
          ),
          duration: Duration(milliseconds: 4000),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    }

    safeSetState(() {});
  }

  Widget _agreementTab({
    required int index,
    required String label,
  }) {
    final selected = _model.agreementPageIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () async => _selectAgreementPage(index),
        borderRadius: BorderRadius.circular(10.0),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsetsDirectional.fromSTEB(10.0, 10.0, 10.0, 10.0),
          decoration: BoxDecoration(
            color: selected
                ? FlutterFlowTheme.of(context).primary
                : FlutterFlowTheme.of(context).info,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: FlutterFlowTheme.of(context).primary,
              width: 1.0,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                  color: selected
                      ? FlutterFlowTheme.of(context).info
                      : FlutterFlowTheme.of(context).primaryText,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w700,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                ),
          ),
        ),
      ),
    );
  }

  Widget _legalDocument({
    required String title,
    required String body,
  }) {
    return SingleChildScrollView(
      padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).headlineSmall.override(
                  fontFamily: FlutterFlowTheme.of(context).headlineSmallFamily,
                  color: FlutterFlowTheme.of(context).primaryText,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.bold,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).headlineSmallIsCustom,
                ),
          ),
          SizedBox(height: 14.0),
          Text(
            body.trim(),
            textAlign: TextAlign.left,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                  color: FlutterFlowTheme.of(context).primaryText,
                  letterSpacing: 0.0,
                  lineHeight: 1.45,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                ),
          ),
        ],
      ),
    );
  }

  Widget _checkboxRow({
    required bool? value,
    required ValueChanged<bool?> onChanged,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Theme(
          data: ThemeData(
            checkboxTheme: CheckboxThemeData(
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
            unselectedWidgetColor: FlutterFlowTheme.of(context).alternate,
          ),
          child: Checkbox(
            value: value ?? false,
            onChanged: onChanged,
            side: BorderSide(
              width: 2,
              color: FlutterFlowTheme.of(context).alternate,
            ),
            activeColor: FlutterFlowTheme.of(context).primary,
            checkColor: FlutterFlowTheme.of(context).info,
          ),
        ),
        Expanded(
          child: Text(
            label,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                  color: FlutterFlowTheme.of(context).primaryText,
                  letterSpacing: 0.0,
                  lineHeight: 1.35,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                ),
          ),
        ),
      ].divide(SizedBox(width: 12.0)),
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
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 0.0, 0.0),
                      child: FlutterFlowIconButton(
                        borderColor: Colors.transparent,
                        borderRadius: 20.0,
                        borderWidth: 1.0,
                        buttonSize: 40.0,
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: FlutterFlowTheme.of(context).primaryText,
                          size: 24.0,
                        ),
                        onPressed: () async {
                          context.safePop();
                        },
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(24.0, 6.0, 24.0, 10.0),
                  child: Material(
                    color: Colors.transparent,
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Container(
                      width: double.infinity,
                      height: 70.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primary,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: Text(
                        'Agreements',
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'DECOY BEBAS',
                              color: FlutterFlowTheme.of(context).info,
                              fontSize: 48.0,
                              letterSpacing: 0.1,
                              fontWeight: FontWeight.normal,
                              lineHeight: 1.125,
                            ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                    child: Material(
                      color: Colors.transparent,
                      elevation: 3.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color(0xFFF9F9F9),
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: FlutterFlowTheme.of(context).primary,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  12.0, 12.0, 12.0, 6.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  _agreementTab(
                                    index: 0,
                                    label: 'Terms',
                                  ),
                                  SizedBox(width: 8.0),
                                  _agreementTab(
                                    index: 1,
                                    label: 'Privacy',
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: PageView(
                                controller: _model.pageViewController,
                                onPageChanged: (index) async {
                                  _model.agreementPageIndex = index;
                                  safeSetState(() {});
                                },
                                children: [
                                  _legalDocument(
                                    title: 'Terms of Use',
                                    body: _termsOfUseText,
                                  ),
                                  _legalDocument(
                                    title: 'Privacy Policy',
                                    body: _privacyPolicyText,
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  12.0, 0.0, 12.0, 12.0),
                              child: Text(
                                'Swipe left or right to switch documents. Scroll within each document to read.',
                                textAlign: TextAlign.center,
                                style: FlutterFlowTheme.of(context)
                                    .bodySmall
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodySmallFamily,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      letterSpacing: 0.0,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .bodySmallIsCustom,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).info,
                  ),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                        24.0, 12.0, 24.0, 10.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _checkboxRow(
                          value: _model.checkboxValue1,
                          label:
                              'I agree to the Terms of Use policy outlined by DECOY WALLET LLC',
                          onChanged: (newValue) async {
                            safeSetState(() =>
                                _model.checkboxValue1 = newValue ?? false);
                          },
                        ),
                        SizedBox(height: 8.0),
                        _checkboxRow(
                          value: _model.checkboxValue2,
                          label:
                              'I agree to the Privacy policy outlined by DECOY WALLET LLC',
                          onChanged: (newValue) async {
                            safeSetState(() =>
                                _model.checkboxValue2 = newValue ?? false);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 12.0),
                  child: FFButtonWidget(
                    onPressed: _canContinue ? _completeOnboarding : null,
                    text: 'Continue',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 52.0,
                      padding: EdgeInsets.all(8.0),
                      iconPadding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: FlutterFlowTheme.of(context).primary,
                      disabledColor: FlutterFlowTheme.of(context).alternate,
                      disabledTextColor: FlutterFlowTheme.of(context).secondaryText,
                      textStyle:
                          FlutterFlowTheme.of(context).titleMedium.override(
                                font: GoogleFonts.heebo(
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .fontStyle,
                                ),
                                color: FlutterFlowTheme.of(context).info,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .fontStyle,
                              ),
                      elevation: 3.0,
                      borderSide: BorderSide(
                        color: FlutterFlowTheme.of(context).primary,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(14.0),
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
