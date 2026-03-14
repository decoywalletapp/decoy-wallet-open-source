import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'phone_number_input_model.dart';
export 'phone_number_input_model.dart';

/// This page asks the user to enter their phone number which will save to
/// their account profile in supabase
class PhoneNumberInputWidget extends StatefulWidget {
  const PhoneNumberInputWidget({super.key});

  static String routeName = 'phoneNumberInput';
  static String routePath = '/phoneNumberInput';

  @override
  State<PhoneNumberInputWidget> createState() => _PhoneNumberInputWidgetState();
}

class _PhoneNumberInputWidgetState extends State<PhoneNumberInputWidget> {
  late PhoneNumberInputModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PhoneNumberInputModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.cleanPhone =
          functions.toE164US(_model.phoneNumberFieldTextController.text);
      _model.notificationInt = 0;
      safeSetState(() {});
      if (functions.formatUSPhone(_model.phoneNumberFieldTextController.text) !=
          _model.phoneNumberFieldTextController.text) {
        safeSetState(() {
          _model.phoneNumberFieldTextController?.text = functions
              .formatUSPhone(_model.phoneNumberFieldTextController.text);
        });
      }
    });

    _model.phoneNumberFieldTextController ??= TextEditingController();
    _model.phoneNumberFieldFocusNode ??= FocusNode();

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
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          actions: [],
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                                  color: FlutterFlowTheme.of(context).primary,
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  child: Icon(
                                    Icons.phone_rounded,
                                    color: FlutterFlowTheme.of(context).info,
                                    size: 64.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Add Your Phone Number',
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
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 16.0, 0.0),
                          child: Text(
                            'We\'ll use this to keep your account secure and help you recover access if needed.',
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .bodyMediumFamily,
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  letterSpacing: 0.0,
                                  lineHeight: 1.4,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .bodyMediumIsCustom,
                                ),
                          ),
                        ),
                      ].divide(SizedBox(height: 16.0)),
                    ),
                    Align(
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: Container(
                        width: 400.0,
                        child: Form(
                          key: _model.formKey,
                          autovalidateMode: AutovalidateMode.disabled,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Container(
                                      width: 400.0,
                                      child: TextFormField(
                                        controller: _model
                                            .phoneNumberFieldTextController,
                                        focusNode:
                                            _model.phoneNumberFieldFocusNode,
                                        onChanged: (_) => EasyDebounce.debounce(
                                          '_model.phoneNumberFieldTextController',
                                          Duration(milliseconds: 1000),
                                          () async {
                                            await Future.delayed(
                                              Duration(
                                                milliseconds: 10,
                                              ),
                                            );
                                            _model.pnDigits10 = functions
                                                .normalizeToTenDigits(_model
                                                    .phoneNumberFieldTextController
                                                    .text);
                                            _model.cleanPhone =
                                                functions.toE164USpt2(_model
                                                    .phoneNumberFieldTextController
                                                    .text);
                                            safeSetState(() {});
                                            if (_model.pnDigits10 != null &&
                                                _model.pnDigits10 != '') {
                                              safeSetState(() {
                                                _model.phoneNumberFieldTextController
                                                        ?.text =
                                                    functions.formatAsUsPhone(
                                                        _model.pnDigits10!);
                                              });
                                            } else {
                                              safeSetState(() {
                                                _model
                                                    .phoneNumberFieldTextController
                                                    ?.text = '';
                                              });
                                            }
                                          },
                                        ),
                                        autofocus: true,
                                        autofillHints: [
                                          AutofillHints.telephoneNumber
                                        ],
                                        textInputAction: TextInputAction.done,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          labelText: 'Phone Number',
                                          hintText: '(555) 123-4567',
                                          hintStyle: FlutterFlowTheme.of(
                                                  context)
                                              .labelLarge
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .labelLargeFamily,
                                                letterSpacing: 0.25,
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(
                                                            context)
                                                        .labelLargeIsCustom,
                                              ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              width: 2.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              width: 2.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .error,
                                              width: 2.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .error,
                                              width: 2.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          filled: true,
                                          fillColor:
                                              FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          contentPadding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  20.0, 16.0, 20.0, 16.0),
                                          prefixIcon: Icon(
                                            Icons.phone_rounded,
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                            size: 20.0,
                                          ),
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyLarge
                                            .override(
                                              fontFamily: 'robot',
                                              fontSize: 18.0,
                                              letterSpacing: 0.25,
                                              fontWeight: FontWeight.w500,
                                            ),
                                        keyboardType: TextInputType.phone,
                                        cursorColor:
                                            FlutterFlowTheme.of(context)
                                                .primary,
                                        validator: _model
                                            .phoneNumberFieldTextControllerValidator
                                            .asValidator(context),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Align(
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Stack(
                                        children: [
                                          if (_model.notificationInt
                                                  .toString() ==
                                              '1')
                                            Align(
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: Text(
                                                'INVALID PHONE NUMBER',
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
                                                              .primary,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      useGoogleFonts:
                                                          !FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMediumIsCustom,
                                                    ),
                                              ),
                                            ),
                                          if (_model.notificationInt == 2)
                                            Align(
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: Text(
                                                'ENTER VALID PHONE NUMBER',
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
                                                              .primary,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      useGoogleFonts:
                                                          !FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMediumIsCustom,
                                                    ),
                                              ),
                                            ),
                                          if (_model.notificationInt == 3)
                                            Align(
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: Text(
                                                'PHONE NUMBER ALREADY IN USE',
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
                                                              .primary,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      useGoogleFonts:
                                                          !FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMediumIsCustom,
                                                    ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ].divide(SizedBox(height: 0.0)),
                                  ),
                                ),
                              ),
                            ].divide(SizedBox(height: 24.0)),
                          ),
                        ),
                      ),
                    ),
                  ].divide(SizedBox(height: 32.0)),
                ),
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    FFButtonWidget(
                      onPressed: () async {
                        await actions.dismissKeyboard(
                          context,
                        );
                        _model.pnDigits10 = functions.normalizeToTenDigits(
                            _model.phoneNumberFieldTextController.text);
                        _model.cleanPhone = functions.toE164USpt2(
                            _model.phoneNumberFieldTextController.text);
                        safeSetState(() {});
                        _model.phoneHashResp = await GetPhoneHashCall.call(
                          cleanPhone: _model.cleanPhone,
                          jwt: currentJwtToken,
                        );

                        _model.phoneHash = GetPhoneHashCall.phoneHash(
                          (_model.phoneHashResp?.jsonBody ?? ''),
                        );
                        safeSetState(() {});
                        _model.phoneTakenResp = await CheckPhoneTakenCall.call(
                          jwt: currentJwtToken,
                          phoneHash: _model.phoneHash,
                        );

                        if (CheckPhoneTakenCall.taken(
                              (_model.phoneTakenResp?.jsonBody ?? ''),
                            ) ==
                            true) {
                          await actions.dismissKeyboard(
                            context,
                          );
                          _model.notificationInt = 3;
                          safeSetState(() {});
                          safeSetState(() {
                            _model.phoneNumberFieldTextController?.clear();
                          });
                          _model.cleanPhone = '';
                          _model.pnDigits10 = '';
                          _model.phoneHash = '';
                          safeSetState(() {});
                        } else {
                          _model.phoneLookupRows =
                              await DecoyWalletTable().queryRows(
                            queryFn: (q) => q
                                .eqOrNull(
                                  'phone_e164_hash',
                                  _model.phoneHash,
                                )
                                .neqOrNull(
                                  'user_id',
                                  currentUserUid,
                                ),
                          );
                          if (_model.phoneLookupRows != null &&
                              (_model.phoneLookupRows)!.isNotEmpty) {
                            await actions.dismissKeyboard(
                              context,
                            );
                            _model.notificationInt = 3;
                            safeSetState(() {});
                            safeSetState(() {
                              _model.phoneNumberFieldTextController?.clear();
                            });
                            _model.cleanPhone = '';
                            _model.pnDigits10 = '';
                            _model.phoneHash = '';
                            safeSetState(() {});
                          } else {
                            if (_model.cleanPhone != '') {
                              _model.sendRes =
                                  await SendVerificationCodeCall.call(
                                cleanPhone: _model.cleanPhone,
                                jwt: currentJwtToken,
                              );

                              if ((_model.sendRes?.succeeded ?? true)) {
                                context.pushNamed(
                                  PhoneNumberVerificationWidget.routeName,
                                  queryParameters: {
                                    'cleanPhone': serializeParam(
                                      _model.cleanPhone,
                                      ParamType.String,
                                    ),
                                  }.withoutNulls,
                                );
                              } else {
                                _model.notificationInt = 2;
                                safeSetState(() {});
                                await Future.delayed(
                                  Duration(
                                    milliseconds: 3000,
                                  ),
                                );
                                _model.notificationInt = 0;
                                safeSetState(() {});
                              }
                            } else {
                              _model.notificationInt = 1;
                              safeSetState(() {});
                              await Future.delayed(
                                Duration(
                                  milliseconds: 3000,
                                ),
                              );
                              _model.notificationInt = 0;
                              safeSetState(() {});
                            }
                          }
                        }

                        safeSetState(() {});
                      },
                      text: 'Save Phone Number',
                      options: FFButtonOptions(
                        width: 400.0,
                        height: 52.0,
                        padding: EdgeInsets.all(0.0),
                        iconPadding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                        color: FlutterFlowTheme.of(context).primary,
                        textStyle:
                            FlutterFlowTheme.of(context).titleMedium.override(
                                  font: GoogleFonts.heebo(
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .fontStyle,
                                  ),
                                  color: Colors.white,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .fontStyle,
                                ),
                        elevation: 3.0,
                        borderSide: BorderSide(
                          color: Colors.transparent,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                    ),
                    if (_model.notificationInt.toString() == '3')
                      FFButtonWidget(
                        onPressed: () async {
                          GoRouter.of(context).prepareAuthEvent();
                          await authManager.signOut();
                          GoRouter.of(context).clearRedirectLocation();

                          context.goNamedAuth(
                              LoginPageWidget.routeName, context.mounted);
                        },
                        text: 'Back to Login',
                        options: FFButtonOptions(
                          width: 400.0,
                          height: 52.0,
                          padding: EdgeInsets.all(0.0),
                          iconPadding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          color: FlutterFlowTheme.of(context).primaryBackground,
                          textStyle: FlutterFlowTheme.of(context)
                              .titleMedium
                              .override(
                                font: GoogleFonts.heebo(
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .fontStyle,
                                ),
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .fontStyle,
                              ),
                          elevation: 3.0,
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                      ),
                  ].divide(SizedBox(height: 16.0)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
