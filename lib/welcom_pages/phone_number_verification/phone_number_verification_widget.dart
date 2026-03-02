import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/instant_timer.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'phone_number_verification_model.dart';
export 'phone_number_verification_model.dart';

/// A page that prompts the user to enter in a 6 digit verification code they
/// received as a text message to verify their phone number with their
/// account.
///
/// This code will check to make sure the user entered the verification code
/// sent to their SMS matches and proceeds if correct. Has the user re-enter
/// if incorrect, and also allows the user to send a new verification code to
/// their phone number if they need to do the process again.
class PhoneNumberVerificationWidget extends StatefulWidget {
  const PhoneNumberVerificationWidget({
    super.key,
    required this.cleanPhone,
  });

  final String? cleanPhone;

  static String routeName = 'PhoneNumberVerification';
  static String routePath = '/phoneNumberVerification';

  @override
  State<PhoneNumberVerificationWidget> createState() =>
      _PhoneNumberVerificationWidgetState();
}

class _PhoneNumberVerificationWidgetState
    extends State<PhoneNumberVerificationWidget> {
  late PhoneNumberVerificationModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PhoneNumberVerificationModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.secondsLeft = 60;
      _model.canResend = false;
      _model.secondsRemaining = 60;
      _model.invalidcodeState = 0;
      safeSetState(() {});
      _model.instantTimer = InstantTimer.periodic(
        duration: Duration(milliseconds: 1000),
        callback: (timer) async {
          _model.secondsRemaining = _model.secondsRemaining + -1;
          safeSetState(() {});
          if (_model.secondsRemaining == 0) {
            _model.instantTimer?.cancel();
          }
        },
        startImmediately: true,
      );
    });

    _model.phoneCodeTextController ??= TextEditingController();
    _model.phoneCodeFocusNode ??= FocusNode();

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
          backgroundColor: Colors.white,
          body: SafeArea(
            top: true,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Align(
                  alignment: AlignmentDirectional(-1.0, 0.0),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 0.0, 0.0),
                    child: FlutterFlowIconButton(
                      borderColor: Colors.transparent,
                      borderRadius: 30.0,
                      borderWidth: 1.0,
                      buttonSize: 40.0,
                      icon: Icon(
                        Icons.arrow_back,
                        color: FlutterFlowTheme.of(context).primaryText,
                        size: 24.0,
                      ),
                      onPressed: () async {
                        context.safePop();
                      },
                    ),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional(0.0, 0.0),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Stack(
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  elevation: 3.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Container(
                                    width: 100.0,
                                    height: 100.0,
                                    decoration: BoxDecoration(
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Icon(
                                      Icons.phone_android_rounded,
                                      color: FlutterFlowTheme.of(context).info,
                                      size: 64.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Enter Verification Code',
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context)
                                  .headlineMedium
                                  .override(
                                    fontFamily: 'InterTight',
                                    fontSize: 24.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            RichText(
                              textScaler: MediaQuery.of(context).textScaler,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'We sent a 6-digit code to ',
                                    style: TextStyle(),
                                  ),
                                  TextSpan(
                                    text: valueOrDefault<String>(
                                      widget.cleanPhone,
                                      '\"\"',
                                    ),
                                    style: TextStyle(
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        '. Enter it below to verify your phone number.',
                                    style: TextStyle(),
                                  )
                                ],
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodyMediumFamily,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      fontSize: 16.0,
                                      letterSpacing: 0.0,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .bodyMediumIsCustom,
                                    ),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ].divide(SizedBox(height: 24.0)),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Container(
                                width: 400.0,
                                height: 50.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                ),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      12.0, 0.0, 12.0, 0.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          width: 400.0,
                                          child: TextFormField(
                                            controller:
                                                _model.phoneCodeTextController,
                                            focusNode:
                                                _model.phoneCodeFocusNode,
                                            onChanged: (_) =>
                                                EasyDebounce.debounce(
                                              '_model.phoneCodeTextController',
                                              Duration(milliseconds: 2000),
                                              () async {
                                                _model.phoneCode = _model
                                                    .phoneCodeTextController
                                                    .text;
                                                _model.otpCode =
                                                    functions.digitsOnly(
                                                        _model.phoneCode);
                                                safeSetState(() {});
                                                if (functions.isCodeSixDigits(
                                                    _model.otpCode)) {
                                                  await actions.dismissKeyboard(
                                                    context,
                                                  );
                                                  _model.invalidcodeState = 2;
                                                  safeSetState(() {});
                                                  _model.checkCodeRes =
                                                      await CheckVerificationCodeCall
                                                          .call(
                                                    cleanPhone:
                                                        widget.cleanPhone,
                                                    code: _model.otpCode,
                                                    jwt: currentJwtToken,
                                                  );

                                                  await Future.delayed(
                                                    Duration(
                                                      milliseconds: 300,
                                                    ),
                                                  );
                                                  if ((CheckVerificationCodeCall
                                                              .success(
                                                            (_model.checkCodeRes
                                                                    ?.jsonBody ??
                                                                ''),
                                                          ) ==
                                                          true) &&
                                                      (CheckVerificationCodeCall
                                                              .status(
                                                            (_model.checkCodeRes
                                                                    ?.jsonBody ??
                                                                ''),
                                                          ) ==
                                                          'approved')) {
                                                    _model.phoneHashResp =
                                                        await GetPhoneHashCall
                                                            .call(
                                                      cleanPhone:
                                                          widget.cleanPhone,
                                                      jwt: currentJwtToken,
                                                    );

                                                    _model.emailHashResp =
                                                        await GetEmailHashCall
                                                            .call(
                                                      email: currentUserEmail,
                                                      jwt: currentJwtToken,
                                                    );

                                                    _model.dataKeyB64 =
                                                        await actions
                                                            .generateDataKeyIfMissing();
                                                    _model.wrapResp =
                                                        await WrapDataKeyCall
                                                            .call(
                                                      dataKeyB64:
                                                          _model.dataKeyB64,
                                                      jwt: currentJwtToken,
                                                    );

                                                    _model.personalJson =
                                                        await actions
                                                            .buildPersonalJson(
                                                      '',
                                                      '',
                                                      widget.cleanPhone,
                                                      currentUserEmail,
                                                    );
                                                    _model.encPersonal =
                                                        await actions
                                                            .aesGcmEncryptString(
                                                      _model.personalJson!,
                                                      _model.dataKeyB64!,
                                                    );
                                                    _model.verifyUpdate =
                                                        await DecoyWalletTable()
                                                            .update(
                                                      data: {
                                                        'is_phone_verified':
                                                            true,
                                                        'verified_at':
                                                            supaSerialize<
                                                                    DateTime>(
                                                                getCurrentTimestamp),
                                                        'phone_e164_hash':
                                                            GetPhoneHashCall
                                                                .phoneHash(
                                                          (_model.phoneHashResp
                                                                  ?.jsonBody ??
                                                              ''),
                                                        ),
                                                        'wrapped_datakey':
                                                            WrapDataKeyCall
                                                                .wrappedB64(
                                                          (_model.wrapResp
                                                                  ?.jsonBody ??
                                                              ''),
                                                        ),
                                                        'personal_ciphertext':
                                                            getJsonField(
                                                          _model.encPersonal,
                                                          r'''$.ciphertextB64''',
                                                        ).toString(),
                                                        'personal_nonce':
                                                            getJsonField(
                                                          _model.encPersonal,
                                                          r'''$.nonceB64''',
                                                        ).toString(),
                                                        'personal_version': 1,
                                                        'email_hash':
                                                            GetEmailHashCall
                                                                .emailHash(
                                                          (_model.emailHashResp
                                                                  ?.jsonBody ??
                                                              ''),
                                                        ).toString(),
                                                      },
                                                      matchingRows: (rows) =>
                                                          rows.eqOrNull(
                                                        'user_id',
                                                        currentUserUid,
                                                      ),
                                                      returnRows: true,
                                                    );
                                                    if (_model.verifyUpdate !=
                                                            null &&
                                                        (_model.verifyUpdate)!
                                                            .isNotEmpty) {
                                                      _model.dwSetupRows =
                                                          await DecoyWalletTable()
                                                              .queryRows(
                                                        queryFn: (q) =>
                                                            q.eqOrNull(
                                                          'user_id',
                                                          currentUserUid,
                                                        ),
                                                      );
                                                      if (_model.dwSetupRows !=
                                                              null &&
                                                          (_model.dwSetupRows)!
                                                              .isNotEmpty) {
                                                        if (_model.dwSetupRows
                                                                ?.elementAtOrNull(
                                                                    0)
                                                                ?.setupComplete ==
                                                            true) {
                                                          context.goNamedAuth(
                                                              HomePageWidget
                                                                  .routeName,
                                                              context.mounted);
                                                        } else {
                                                          context.goNamedAuth(
                                                              BiometricVerificationWidget
                                                                  .routeName,
                                                              context.mounted);
                                                        }
                                                      } else {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              'ERROR #025 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT',
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
                                                    } else {
                                                      _model.verifyInsert =
                                                          await DecoyWalletTable()
                                                              .insert({
                                                        'is_phone_verified':
                                                            true,
                                                        'verified_at':
                                                            supaSerialize<
                                                                    DateTime>(
                                                                getCurrentTimestamp),
                                                        'user_id':
                                                            currentUserUid,
                                                        'phone_e164_hash':
                                                            GetPhoneHashCall
                                                                .phoneHash(
                                                          (_model.phoneHashResp
                                                                  ?.jsonBody ??
                                                              ''),
                                                        ),
                                                        'personal_ciphertext':
                                                            getJsonField(
                                                          _model.encPersonal,
                                                          r'''$.ciphertextB64''',
                                                        ).toString(),
                                                        'personal_nonce':
                                                            getJsonField(
                                                          _model.encPersonal,
                                                          r'''$.nonceB64''',
                                                        ).toString(),
                                                        'personal_version': 1,
                                                      });
                                                      _model.code = '\"\"';
                                                      _model.otpCode = '\"\"';
                                                      _model.phoneCode = '\"\"';
                                                      safeSetState(() {});
                                                      safeSetState(() {
                                                        _model
                                                            .phoneCodeTextController
                                                            ?.text = '';
                                                      });
                                                      _model.invalidcodeState =
                                                          1;
                                                      safeSetState(() {});
                                                      GoRouter.of(context)
                                                          .prepareAuthEvent();
                                                      await authManager
                                                          .signOut();
                                                      GoRouter.of(context)
                                                          .clearRedirectLocation();

                                                      context.goNamedAuth(
                                                          LoginPageWidget
                                                              .routeName,
                                                          context.mounted);
                                                    }
                                                  } else {
                                                    await Future.wait([
                                                      Future(() async {
                                                        safeSetState(() {
                                                          _model
                                                              .phoneCodeTextController
                                                              ?.clear();
                                                        });
                                                      }),
                                                      Future(() async {
                                                        _model.invalidcodeState =
                                                            1;
                                                        _model.cleanPhone = '';
                                                        _model.phoneCode = '';
                                                        _model.otpCode = '';
                                                        _model.code = '';
                                                        _model.joinedCode = '';
                                                        safeSetState(() {});
                                                      }),
                                                    ]);
                                                  }
                                                }

                                                safeSetState(() {});
                                              },
                                            ),
                                            autofocus: false,
                                            obscureText: false,
                                            decoration: InputDecoration(
                                              isDense: true,
                                              labelStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .override(
                                                        fontFamily:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMediumFamily,
                                                        letterSpacing: 0.25,
                                                        useGoogleFonts:
                                                            !FlutterFlowTheme
                                                                    .of(context)
                                                                .labelMediumIsCustom,
                                                      ),
                                              hintStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .override(
                                                        fontFamily:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMediumFamily,
                                                        letterSpacing: 0.0,
                                                        useGoogleFonts:
                                                            !FlutterFlowTheme
                                                                    .of(context)
                                                                .labelMediumIsCustom,
                                                      ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  width: 1.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  width: 1.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .error,
                                                  width: 1.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              focusedErrorBorder:
                                                  OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .error,
                                                  width: 1.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              filled: true,
                                              fillColor:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMediumFamily,
                                                  fontSize: 20.0,
                                                  letterSpacing: 0.25,
                                                  fontWeight: FontWeight.bold,
                                                  useGoogleFonts:
                                                      !FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMediumIsCustom,
                                                ),
                                            textAlign: TextAlign.center,
                                            cursorColor:
                                                FlutterFlowTheme.of(context)
                                                    .primaryText,
                                            enableInteractiveSelection: true,
                                            validator: _model
                                                .phoneCodeTextControllerValidator
                                                .asValidator(context),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ].divide(SizedBox(height: 24.0)),
                        ),
                        Stack(
                          children: [
                            if (_model.invalidcodeState == 1)
                              Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Container(
                                  width: 400.0,
                                  height: 48.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).error,
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.error_outline_rounded,
                                          color:
                                              FlutterFlowTheme.of(context).info,
                                          size: 20.0,
                                        ),
                                        Text(
                                          'Invalid code. Please try again.',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMediumFamily,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .info,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w500,
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMediumIsCustom,
                                              ),
                                        ),
                                      ].divide(SizedBox(width: 8.0)),
                                    ),
                                  ),
                                ),
                              ),
                            Stack(
                              children: [
                                if (_model.invalidcodeState == 2)
                                  Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: Material(
                                      color: Colors.transparent,
                                      elevation: 3.0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      child: AnimatedContainer(
                                        duration: Duration(milliseconds: 100),
                                        curve: Curves.easeIn,
                                        width: 400.0,
                                        height: 48.0,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Verifying... Please Wait!',
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
                                                              .info,
                                                      fontSize: 16.0,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      useGoogleFonts:
                                                          !FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMediumIsCustom,
                                                    ),
                                              ),
                                            ].divide(SizedBox(width: 8.0)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        Expanded(
                          child: Align(
                            alignment: AlignmentDirectional(0.0, 1.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  'Didn\'t receive the code?',
                                  textAlign: TextAlign.center,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .bodyMediumFamily,
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        letterSpacing: 0.0,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .bodyMediumIsCustom,
                                      ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        if (_model.secondsRemaining == 0) {
                                          _model.joinedCode = '';
                                          _model.invalidcodeState = 0;
                                          _model.secondsRemaining = 60;
                                          safeSetState(() {});
                                          _model.sendResCopy =
                                              await SendVerificationCodeCall
                                                  .call(
                                            cleanPhone: widget.cleanPhone,
                                          );

                                          _model.instantTimerResend1 =
                                              InstantTimer.periodic(
                                            duration:
                                                Duration(milliseconds: 1000),
                                            callback: (timer) async {
                                              _model.secondsRemaining =
                                                  _model.secondsRemaining + -1;
                                              safeSetState(() {});
                                              if (_model.secondsRemaining ==
                                                  0) {
                                                _model.instantTimerResend1
                                                    ?.cancel();
                                              }
                                            },
                                            startImmediately: true,
                                          );
                                        }

                                        safeSetState(() {});
                                      },
                                      child: Icon(
                                        Icons.refresh_rounded,
                                        color: _model.secondsRemaining != 0
                                            ? FlutterFlowTheme.of(context)
                                                .secondaryText
                                            : FlutterFlowTheme.of(context)
                                                .primary,
                                        size: 18.0,
                                      ),
                                    ),
                                    InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        if (_model.secondsRemaining == 0) {
                                          _model.joinedCode = '';
                                          _model.invalidcodeState = 0;
                                          _model.secondsRemaining = 60;
                                          safeSetState(() {});
                                          _model.sendRes =
                                              await SendVerificationCodeCall
                                                  .call(
                                            cleanPhone: widget.cleanPhone,
                                          );

                                          _model.instantTimerResend2 =
                                              InstantTimer.periodic(
                                            duration:
                                                Duration(milliseconds: 1000),
                                            callback: (timer) async {
                                              _model.secondsRemaining =
                                                  _model.secondsRemaining + -1;
                                              safeSetState(() {});
                                              if (_model.secondsRemaining ==
                                                  0) {
                                                _model.instantTimerResend2
                                                    ?.cancel();
                                              }
                                            },
                                            startImmediately: true,
                                          );
                                        }

                                        safeSetState(() {});
                                      },
                                      child: Text(
                                        'Resend Code',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMediumFamily,
                                              color: _model.secondsRemaining !=
                                                      0
                                                  ? FlutterFlowTheme.of(context)
                                                      .secondaryText
                                                  : FlutterFlowTheme.of(context)
                                                      .primary,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w600,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .bodyMediumIsCustom,
                                            ),
                                      ),
                                    ),
                                  ].divide(SizedBox(width: 8.0)),
                                ),
                                RichText(
                                  textScaler: MediaQuery.of(context).textScaler,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'You can request a new code in ',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMediumFamily,
                                              letterSpacing: 0.0,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .bodyMediumIsCustom,
                                            ),
                                      ),
                                      TextSpan(
                                        text:
                                            _model.secondsRemaining.toString(),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMediumFamily,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.bold,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .bodyMediumIsCustom,
                                            ),
                                      ),
                                      TextSpan(
                                        text: ' seconds',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMediumFamily,
                                              letterSpacing: 0.0,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .bodyMediumIsCustom,
                                            ),
                                      )
                                    ],
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMediumFamily,
                                          letterSpacing: 0.0,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .bodyMediumIsCustom,
                                        ),
                                  ),
                                ),
                              ].divide(SizedBox(height: 16.0)),
                            ),
                          ),
                        ),
                      ]
                          .divide(SizedBox(height: 24.0))
                          .addToStart(SizedBox(height: 32.0)),
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
