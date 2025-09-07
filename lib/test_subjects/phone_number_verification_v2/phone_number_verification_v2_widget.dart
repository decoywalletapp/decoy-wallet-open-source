import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'phone_number_verification_v2_model.dart';
export 'phone_number_verification_v2_model.dart';

/// A page that prompts the user to enter in a 6 digit verification code they
/// received as a text message to verify their phone number with their
/// account.
///
/// This code will check to make sure the user entered the verification code
/// sent to their SMS matches and proceeds if correct. Has the user re-enter
/// if incorrect, and also allows the user to send a new verification code to
/// their phone number if they need to do the process again.
class PhoneNumberVerificationV2Widget extends StatefulWidget {
  const PhoneNumberVerificationV2Widget({
    super.key,
    required this.cleanPhone,
  });

  final String? cleanPhone;

  static String routeName = 'PhoneNumberVerificationV2';
  static String routePath = '/phoneNumberVerificationV2';

  @override
  State<PhoneNumberVerificationV2Widget> createState() =>
      _PhoneNumberVerificationV2WidgetState();
}

class _PhoneNumberVerificationV2WidgetState
    extends State<PhoneNumberVerificationV2Widget> {
  late PhoneNumberVerificationV2Model _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PhoneNumberVerificationV2Model());

    _model.firstDigitTextController ??= TextEditingController(text: _model.d1);
    _model.firstDigitFocusNode ??= FocusNode();

    _model.secondDigitTextController ??= TextEditingController(text: _model.d2);
    _model.secondDigitFocusNode ??= FocusNode();

    _model.thirdDigitTextController ??= TextEditingController(text: _model.d3);
    _model.thirdDigitFocusNode ??= FocusNode();

    _model.fourthDigitTextController ??= TextEditingController(text: _model.d4);
    _model.fourthDigitFocusNode ??= FocusNode();

    _model.fifthDigitTextController ??= TextEditingController(text: _model.d5);
    _model.fifthDigitFocusNode ??= FocusNode();

    _model.sixthDigitTextController ??= TextEditingController(text: _model.d6);
    _model.sixthDigitFocusNode ??= FocusNode();

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
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          appBar: AppBar(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            automaticallyImplyLeading: false,
            leading: FlutterFlowIconButton(
              borderColor: Colors.transparent,
              borderRadius: 30.0,
              borderWidth: 1.0,
              buttonSize: 60.0,
              icon: Icon(
                Icons.chevron_left_outlined,
                color: FlutterFlowTheme.of(context).primaryText,
                size: 24.0,
              ),
              onPressed: () async {
                context.safePop();
              },
            ),
            title: Text(
              'Verify Phone',
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                    font: GoogleFonts.interTight(
                      fontWeight: FontWeight.w600,
                      fontStyle:
                          FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                    ),
                    fontSize: 18.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                    fontStyle:
                        FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                  ),
            ),
            actions: [],
            centerTitle: true,
            elevation: 0.0,
          ),
          body: SafeArea(
            top: true,
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Icon(
                        Icons.phone_android_rounded,
                        color: FlutterFlowTheme.of(context).primary,
                        size: 64.0,
                      ),
                      Text(
                        'Enter Verification Code',
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context)
                            .headlineMedium
                            .override(
                              font: GoogleFonts.interTight(
                                fontWeight: FontWeight.bold,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .headlineMedium
                                    .fontStyle,
                              ),
                              fontSize: 24.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.bold,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .headlineMedium
                                  .fontStyle,
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
                              text: 'cleanPhone',
                              style: TextStyle(
                                color: FlutterFlowTheme.of(context).primaryText,
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
                                font: GoogleFonts.inter(
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                fontSize: 16.0,
                                letterSpacing: 0.0,
                                fontWeight: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ].divide(SizedBox(height: 16.0)),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            12.0, 0.0, 12.0, 0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: 48.0,
                              height: 56.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).alternate,
                                  width: 2.0,
                                ),
                              ),
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: TextFormField(
                                  controller: _model.firstDigitTextController,
                                  focusNode: _model.firstDigitFocusNode,
                                  onChanged: (_) => EasyDebounce.debounce(
                                    '_model.firstDigitTextController',
                                    Duration(milliseconds: 0),
                                    () async {
                                      _model.d1 =
                                          _model.firstDigitTextController.text;
                                      safeSetState(() {});
                                      if (_model
                                              .firstDigitTextController.text !=
                                          '\"\"') {
                                        _model.activeIndex = 2;
                                        safeSetState(() {});
                                        await actions.focusNext(
                                          context,
                                        );
                                      } else {
                                        _model.activeIndex = 1;
                                        safeSetState(() {});
                                      }
                                    },
                                  ),
                                  autofocus: _model.activeIndex == 1,
                                  textInputAction: TextInputAction.next,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedErrorBorder: InputBorder.none,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .headlineMedium
                                      .override(
                                        font: GoogleFonts.interTight(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .headlineMedium
                                                  .fontStyle,
                                        ),
                                        fontSize: 24.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .headlineMedium
                                            .fontStyle,
                                      ),
                                  textAlign: TextAlign.center,
                                  maxLength: 1,
                                  maxLengthEnforcement:
                                      MaxLengthEnforcement.enforced,
                                  buildCounter: (context,
                                          {required currentLength,
                                          required isFocused,
                                          maxLength}) =>
                                      null,
                                  keyboardType: TextInputType.number,
                                  cursorColor:
                                      FlutterFlowTheme.of(context).primary,
                                  validator: _model
                                      .firstDigitTextControllerValidator
                                      .asValidator(context),
                                ),
                              ),
                            ),
                            Container(
                              width: 48.0,
                              height: 56.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).alternate,
                                  width: 2.0,
                                ),
                              ),
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: TextFormField(
                                  controller: _model.secondDigitTextController,
                                  focusNode: _model.secondDigitFocusNode,
                                  onChanged: (_) => EasyDebounce.debounce(
                                    '_model.secondDigitTextController',
                                    Duration(milliseconds: 0),
                                    () async {
                                      _model.d2 =
                                          _model.secondDigitTextController.text;
                                      safeSetState(() {});
                                      if (_model.d2 != '\"\"') {
                                        _model.activeIndex = 3;
                                        safeSetState(() {});
                                        await actions.focusNext(
                                          context,
                                        );
                                      } else {
                                        _model.activeIndex = 1;
                                        safeSetState(() {});
                                        await actions.focusPrevious(
                                          context,
                                        );
                                      }
                                    },
                                  ),
                                  autofocus: _model.activeIndex == 2,
                                  textInputAction: TextInputAction.next,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedErrorBorder: InputBorder.none,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .headlineMedium
                                      .override(
                                        font: GoogleFonts.interTight(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .headlineMedium
                                                  .fontStyle,
                                        ),
                                        fontSize: 24.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .headlineMedium
                                            .fontStyle,
                                      ),
                                  textAlign: TextAlign.center,
                                  maxLength: 1,
                                  maxLengthEnforcement:
                                      MaxLengthEnforcement.enforced,
                                  buildCounter: (context,
                                          {required currentLength,
                                          required isFocused,
                                          maxLength}) =>
                                      null,
                                  keyboardType: TextInputType.number,
                                  cursorColor:
                                      FlutterFlowTheme.of(context).primary,
                                  validator: _model
                                      .secondDigitTextControllerValidator
                                      .asValidator(context),
                                ),
                              ),
                            ),
                            Container(
                              width: 48.0,
                              height: 56.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).alternate,
                                  width: 2.0,
                                ),
                              ),
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: TextFormField(
                                  controller: _model.thirdDigitTextController,
                                  focusNode: _model.thirdDigitFocusNode,
                                  onChanged: (_) => EasyDebounce.debounce(
                                    '_model.thirdDigitTextController',
                                    Duration(milliseconds: 0),
                                    () async {
                                      _model.d3 =
                                          _model.thirdDigitTextController.text;
                                      safeSetState(() {});
                                      if (_model.d3 != '\"\"') {
                                        _model.activeIndex = 4;
                                        safeSetState(() {});
                                        await actions.focusNext(
                                          context,
                                        );
                                      } else {
                                        _model.activeIndex = 2;
                                        safeSetState(() {});
                                        await actions.focusPrevious(
                                          context,
                                        );
                                      }
                                    },
                                  ),
                                  autofocus: _model.activeIndex == 3,
                                  textInputAction: TextInputAction.next,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedErrorBorder: InputBorder.none,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .headlineMedium
                                      .override(
                                        font: GoogleFonts.interTight(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .headlineMedium
                                                  .fontStyle,
                                        ),
                                        fontSize: 24.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .headlineMedium
                                            .fontStyle,
                                      ),
                                  textAlign: TextAlign.center,
                                  maxLength: 1,
                                  maxLengthEnforcement:
                                      MaxLengthEnforcement.enforced,
                                  buildCounter: (context,
                                          {required currentLength,
                                          required isFocused,
                                          maxLength}) =>
                                      null,
                                  keyboardType: TextInputType.number,
                                  cursorColor:
                                      FlutterFlowTheme.of(context).primary,
                                  validator: _model
                                      .thirdDigitTextControllerValidator
                                      .asValidator(context),
                                ),
                              ),
                            ),
                            Container(
                              width: 48.0,
                              height: 56.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).alternate,
                                  width: 2.0,
                                ),
                              ),
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: TextFormField(
                                  controller: _model.fourthDigitTextController,
                                  focusNode: _model.fourthDigitFocusNode,
                                  onChanged: (_) => EasyDebounce.debounce(
                                    '_model.fourthDigitTextController',
                                    Duration(milliseconds: 0),
                                    () async {
                                      _model.d4 =
                                          _model.fourthDigitTextController.text;
                                      safeSetState(() {});
                                      if (_model.d4 != '\"\"') {
                                        _model.activeIndex = 5;
                                        safeSetState(() {});
                                        await actions.focusNext(
                                          context,
                                        );
                                      } else {
                                        _model.activeIndex = 3;
                                        safeSetState(() {});
                                        await actions.focusPrevious(
                                          context,
                                        );
                                      }
                                    },
                                  ),
                                  autofocus: _model.activeIndex == 4,
                                  textInputAction: TextInputAction.next,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedErrorBorder: InputBorder.none,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .headlineMedium
                                      .override(
                                        font: GoogleFonts.interTight(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .headlineMedium
                                                  .fontStyle,
                                        ),
                                        fontSize: 24.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .headlineMedium
                                            .fontStyle,
                                      ),
                                  textAlign: TextAlign.center,
                                  maxLength: 1,
                                  maxLengthEnforcement:
                                      MaxLengthEnforcement.enforced,
                                  buildCounter: (context,
                                          {required currentLength,
                                          required isFocused,
                                          maxLength}) =>
                                      null,
                                  keyboardType: TextInputType.number,
                                  cursorColor:
                                      FlutterFlowTheme.of(context).primary,
                                  validator: _model
                                      .fourthDigitTextControllerValidator
                                      .asValidator(context),
                                ),
                              ),
                            ),
                            Container(
                              width: 48.0,
                              height: 56.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).alternate,
                                  width: 2.0,
                                ),
                              ),
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: TextFormField(
                                  controller: _model.fifthDigitTextController,
                                  focusNode: _model.fifthDigitFocusNode,
                                  onChanged: (_) => EasyDebounce.debounce(
                                    '_model.fifthDigitTextController',
                                    Duration(milliseconds: 0),
                                    () async {
                                      _model.d5 =
                                          _model.fifthDigitTextController.text;
                                      safeSetState(() {});
                                      if (_model.d5 != '\"\"') {
                                        _model.activeIndex = 6;
                                        safeSetState(() {});
                                        await actions.focusNext(
                                          context,
                                        );
                                      } else {
                                        _model.activeIndex = 4;
                                        safeSetState(() {});
                                        await actions.focusPrevious(
                                          context,
                                        );
                                      }
                                    },
                                  ),
                                  autofocus: _model.activeIndex == 5,
                                  textInputAction: TextInputAction.next,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedErrorBorder: InputBorder.none,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .headlineMedium
                                      .override(
                                        font: GoogleFonts.interTight(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .headlineMedium
                                                  .fontStyle,
                                        ),
                                        fontSize: 24.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .headlineMedium
                                            .fontStyle,
                                      ),
                                  textAlign: TextAlign.center,
                                  maxLength: 1,
                                  maxLengthEnforcement:
                                      MaxLengthEnforcement.enforced,
                                  buildCounter: (context,
                                          {required currentLength,
                                          required isFocused,
                                          maxLength}) =>
                                      null,
                                  keyboardType: TextInputType.number,
                                  cursorColor:
                                      FlutterFlowTheme.of(context).primary,
                                  validator: _model
                                      .fifthDigitTextControllerValidator
                                      .asValidator(context),
                                ),
                              ),
                            ),
                            Container(
                              width: 48.0,
                              height: 56.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).alternate,
                                  width: 2.0,
                                ),
                              ),
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: TextFormField(
                                  controller: _model.sixthDigitTextController,
                                  focusNode: _model.sixthDigitFocusNode,
                                  onChanged: (_) => EasyDebounce.debounce(
                                    '_model.sixthDigitTextController',
                                    Duration(milliseconds: 0),
                                    () async {
                                      _model.d6 = _model.d6;
                                      safeSetState(() {});
                                      if (_model.d6 != '\"\"') {
                                        _model.activeIndex = 6;
                                        safeSetState(() {});
                                      } else {
                                        _model.activeIndex = 5;
                                        safeSetState(() {});
                                        await actions.focusPrevious(
                                          context,
                                        );
                                      }

                                      if ((_model.d1 != '\"\"') &&
                                          (_model.d2 != '\"\"') &&
                                          (_model.d3 != '\"\"') &&
                                          (_model.d4 != '\"\"') &&
                                          (_model.d5 != '\"\"') &&
                                          (_model.d6 != '\"\"')) {
                                        // This dismisses the keyboard
                                        await actions.dismissKeyboard(
                                          context,
                                        );
                                        _model.joinedCode =
                                            functions.joinVerificationCode(
                                                _model.d1,
                                                _model.d2,
                                                _model.d3,
                                                _model.d4,
                                                _model.d5,
                                                _model.d6);
                                        safeSetState(() {});
                                        _model.checkResCopy =
                                            await CheckVerificationCodeCall
                                                .call(
                                          cleanPhone: widget.cleanPhone,
                                          code: _model.joinedCode,
                                        );

                                        if (((CheckVerificationCodeCall.success(
                                                      (_model.checkResCopy
                                                              ?.jsonBody ??
                                                          ''),
                                                    ) ==
                                                    true) &&
                                                (CheckVerificationCodeCall
                                                        .status(
                                                      (_model.checkResCopy
                                                              ?.jsonBody ??
                                                          ''),
                                                    ) ==
                                                    '\"approved\"')) &&
                                            (CheckVerificationCodeCall.status(
                                                  (_model.checkResCopy
                                                          ?.jsonBody ??
                                                      ''),
                                                ) ==
                                                '\"approved\"')) {
                                          _model.verifyUpdateCopy =
                                              await DecoyWalletTable().update(
                                            data: {
                                              'is_phone_verified': true,
                                              'verified_at':
                                                  supaSerialize<DateTime>(
                                                      getCurrentTimestamp),
                                              'phone_number':
                                                  widget.cleanPhone,
                                            },
                                            matchingRows: (rows) => rows
                                                .eqOrNull(
                                                  'user_id',
                                                  currentUserUid,
                                                )
                                                .eqOrNull(
                                                  'phone_number',
                                                  widget.cleanPhone,
                                                ),
                                            returnRows: true,
                                          );
                                          if (_model.verifyUpdateCopy != null &&
                                              (_model.verifyUpdateCopy)!
                                                  .isNotEmpty) {
                                            context.goNamed(
                                                CreatePinWidget.routeName);

                                            _model.d1 = '\"\"';
                                            _model.d2 = '\"\"';
                                            _model.d3 = '\"\"';
                                            _model.d4 = '\"\"';
                                            _model.d5 = '\"\"';
                                            _model.d6 = '\"\"';
                                            _model.joinedCode = '\"\"';
                                            safeSetState(() {});
                                            _model.activeIndex = 1;
                                            safeSetState(() {});

                                            safeSetState(() {});
                                          } else {
                                            _model.d1 = '';
                                            _model.d2 = '';
                                            _model.d3 = '';
                                            _model.d4 = '';
                                            _model.d5 = '';
                                            _model.d6 = '';
                                            _model.joinedCode = '';
                                            safeSetState(() {});
                                            _model.activeIndex = 1;
                                            safeSetState(() {});
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Wrong Entry. Try Again.SB3',
                                                  style: TextStyle(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                  ),
                                                ),
                                                duration: Duration(
                                                    milliseconds: 4000),
                                                backgroundColor:
                                                    FlutterFlowTheme.of(context)
                                                        .secondary,
                                              ),
                                            );
                                          }
                                        } else {
                                          safeSetState(() {
                                            _model.firstDigitTextController
                                                ?.clear();
                                            _model.secondDigitTextController
                                                ?.clear();
                                            _model.thirdDigitTextController
                                                ?.clear();
                                            _model.fourthDigitTextController
                                                ?.clear();
                                            _model.fifthDigitTextController
                                                ?.clear();
                                            _model.sixthDigitTextController
                                                ?.clear();
                                          });
                                          _model.d1 = '';
                                          _model.d2 = '';
                                          _model.d3 = '';
                                          _model.d4 = '';
                                          _model.d5 = '';
                                          _model.d6 = '';
                                          _model.joinedCode = '';
                                          safeSetState(() {});
                                          _model.activeIndex = 1;
                                          safeSetState(() {});
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Wrong Entry. Try Again.SB2',
                                                style: TextStyle(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                ),
                                              ),
                                              duration:
                                                  Duration(milliseconds: 4000),
                                              backgroundColor:
                                                  FlutterFlowTheme.of(context)
                                                      .secondary,
                                            ),
                                          );
                                          _model.invalidcodeState = 1;
                                          safeSetState(() {});
                                        }
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Wrong Entry. Try Again. SB1',
                                              style: TextStyle(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                              ),
                                            ),
                                            duration:
                                                Duration(milliseconds: 4000),
                                            backgroundColor:
                                                FlutterFlowTheme.of(context)
                                                    .secondary,
                                          ),
                                        );
                                      }

                                      safeSetState(() {});
                                    },
                                  ),
                                  autofocus: _model.activeIndex == 6,
                                  textInputAction: TextInputAction.done,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedErrorBorder: InputBorder.none,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .headlineMedium
                                      .override(
                                        font: GoogleFonts.interTight(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .headlineMedium
                                                  .fontStyle,
                                        ),
                                        fontSize: 24.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .headlineMedium
                                            .fontStyle,
                                      ),
                                  textAlign: TextAlign.center,
                                  maxLength: 1,
                                  maxLengthEnforcement:
                                      MaxLengthEnforcement.enforced,
                                  buildCounter: (context,
                                          {required currentLength,
                                          required isFocused,
                                          maxLength}) =>
                                      null,
                                  keyboardType: TextInputType.number,
                                  cursorColor:
                                      FlutterFlowTheme.of(context).primary,
                                  validator: _model
                                      .sixthDigitTextControllerValidator
                                      .asValidator(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_model.invalidcodeState == 1)
                        Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Container(
                            width: double.infinity,
                            height: 48.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).error,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline_rounded,
                                    color: FlutterFlowTheme.of(context).info,
                                    size: 20.0,
                                  ),
                                  Text(
                                    'Invalid code. Please try again.',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FontWeight.w500,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          color:
                                              FlutterFlowTheme.of(context).info,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w500,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                  ),
                                ].divide(SizedBox(width: 8.0)),
                              ),
                            ),
                          ),
                        ),
                    ].divide(SizedBox(height: 24.0)),
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
                                  font: GoogleFonts.inter(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.refresh_rounded,
                                color: FlutterFlowTheme.of(context).primary,
                                size: 18.0,
                              ),
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  _model.sendRes =
                                      await SendVerificationCodeCall.call(
                                    cleanPhone: widget.cleanPhone,
                                  );

                                  safeSetState(() {});
                                },
                                child: Text(
                                  'Resend Code',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                ),
                              ),
                            ].divide(SizedBox(width: 8.0)),
                          ),
                          Text(
                            'You can request a new code in 60 seconds',
                            textAlign: TextAlign.center,
                            style:
                                FlutterFlowTheme.of(context).bodySmall.override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodySmall
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodySmall
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .fontStyle,
                                    ),
                          ),
                        ].divide(SizedBox(height: 16.0)),
                      ),
                    ),
                  ),
                ]
                    .divide(SizedBox(height: 32.0))
                    .addToStart(SizedBox(height: 40.0)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
