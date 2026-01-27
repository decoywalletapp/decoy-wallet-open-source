import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import 'emergency_contacts_model.dart';
export 'emergency_contacts_model.dart';

/// generate a page that allows the user to add up to five emergency
/// contacts...
///
/// the emergency contacts will have first name last name and phone number...
/// save button at the bottom
class EmergencyContactsWidget extends StatefulWidget {
  const EmergencyContactsWidget({super.key});

  static String routeName = 'EmergencyContacts';
  static String routePath = '/emergencyContacts';

  @override
  State<EmergencyContactsWidget> createState() =>
      _EmergencyContactsWidgetState();
}

class _EmergencyContactsWidgetState extends State<EmergencyContactsWidget> {
  late EmergencyContactsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EmergencyContactsModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.rows = await DecoyWalletTable().queryRows(
        queryFn: (q) => q
            .eqOrNull(
              'user_id',
              currentUserUid,
            )
            .order('updated_at'),
      );
      if (_model.rows != null && (_model.rows)!.isNotEmpty) {
        _model.rowCipherB64 =
            _model.rows?.elementAtOrNull(0)?.contactsCiphertext;
        _model.rowNonceB64 = _model.rows?.elementAtOrNull(0)?.contactsNonce;
        _model.wrappedB64 = _model.rows!.elementAtOrNull(0)!.wrappedDatakey!;
        safeSetState(() {});
        if (_model.wrappedB64 != '') {
          _model.dataKeyOut = await actions.generateDataKeyIfMissing();
          _model.dataKeyB64 = _model.dataKeyOut!;
          safeSetState(() {});
          _model.contactsObj = await actions.aesGcmDecryptToMap(
            _model.rowCipherB64!,
            _model.rowNonceB64!,
            _model.dataKeyB64,
          );
          _model.contactsJson = _model.contactsObj!.toString();
          safeSetState(() {});
          _model.contactsCount = () {
            if (getJsonField(
                  _model.contactsObj,
                  r'''$.contacts[4].first''',
                ) !=
                null) {
              return (5);
            } else if (getJsonField(
                  _model.contactsObj,
                  r'''$.contacts[3].first''',
                ) !=
                null) {
              return (4);
            } else if (getJsonField(
                  _model.contactsObj,
                  r'''$.contacts[2].first''',
                ) !=
                null) {
              return (3);
            } else if (getJsonField(
                  _model.contactsObj,
                  r'''$.contacts[1].first''',
                ) !=
                null) {
              return (2);
            } else if (getJsonField(
                  _model.contactsObj,
                  r'''$.contacts[0].first''',
                ) !=
                null) {
              return (1);
            } else {
              return 0;
            }
          }();
          safeSetState(() {});
          if (getJsonField(
                _model.contactsObj,
                r'''$.contacts[0].first''',
              ) ==
              null) {
            safeSetState(() {
              _model.c1FirstTFTextController?.text = '';
            });
          } else {
            safeSetState(() {
              _model.c1FirstTFTextController?.text = getJsonField(
                _model.contactsObj,
                r'''$.contacts[0].first''',
              ).toString();
            });
          }

          if (getJsonField(
                _model.contactsObj,
                r'''$.contacts[0].last''',
              ) ==
              null) {
            safeSetState(() {
              _model.c1LastTFTextController?.text = '';
            });
          } else {
            safeSetState(() {
              _model.c1LastTFTextController?.text = getJsonField(
                _model.contactsObj,
                r'''$.contacts[0].last''',
              ).toString();
            });
          }

          if (getJsonField(
                _model.contactsObj,
                r'''$.contacts[0].phone''',
              ) ==
              null) {
            safeSetState(() {
              _model.c1PhoneTFTextController?.text = '';
              _model.c1PhoneTFMask.updateMask(
                newValue: TextEditingValue(
                  text: _model.c1PhoneTFTextController!.text,
                ),
              );
            });
          } else {
            safeSetState(() {
              _model.c1PhoneTFTextController?.text =
                  functions.displayUSPhone(getJsonField(
                _model.contactsObj,
                r'''$.contacts[0].phone''',
              ).toString());
              _model.c1PhoneTFMask.updateMask(
                newValue: TextEditingValue(
                  text: _model.c1PhoneTFTextController!.text,
                ),
              );
            });
          }

          if (getJsonField(
                _model.contactsObj,
                r'''$.contacts[1].first''',
              ) ==
              null) {
            safeSetState(() {
              _model.c2FirstTFTextController?.text = '';
            });
          } else {
            safeSetState(() {
              _model.c2FirstTFTextController?.text = getJsonField(
                _model.contactsObj,
                r'''$.contacts[1].first''',
              ).toString();
            });
          }

          if (getJsonField(
                _model.contactsObj,
                r'''$.contacts[1].last''',
              ) ==
              null) {
            safeSetState(() {
              _model.c2LastTFTextController?.text = '';
            });
          } else {
            safeSetState(() {
              _model.c2LastTFTextController?.text = getJsonField(
                _model.contactsObj,
                r'''$.contacts[1].last''',
              ).toString();
            });
          }

          if (getJsonField(
                _model.contactsObj,
                r'''$.contacts[1].phone''',
              ) ==
              null) {
            safeSetState(() {
              _model.c2PhoneTFTextController?.text = '';
              _model.c2PhoneTFMask.updateMask(
                newValue: TextEditingValue(
                  text: _model.c2PhoneTFTextController!.text,
                ),
              );
            });
          } else {
            safeSetState(() {
              _model.c2PhoneTFTextController?.text =
                  functions.displayUSPhone(getJsonField(
                _model.contactsObj,
                r'''$.contacts[1].phone''',
              ).toString());
              _model.c2PhoneTFMask.updateMask(
                newValue: TextEditingValue(
                  text: _model.c2PhoneTFTextController!.text,
                ),
              );
            });
          }

          if (getJsonField(
                _model.contactsObj,
                r'''$.contacts[2].first''',
              ) ==
              null) {
            safeSetState(() {
              _model.c3FirstTFTextController?.text = '';
            });
          } else {
            safeSetState(() {
              _model.c3FirstTFTextController?.text = getJsonField(
                _model.contactsObj,
                r'''$.contacts[2].first''',
              ).toString();
            });
          }

          if (getJsonField(
                _model.contactsObj,
                r'''$.contacts[2].last''',
              ) ==
              null) {
            safeSetState(() {
              _model.c3LastTFTextController?.text = '';
            });
          } else {
            safeSetState(() {
              _model.c3LastTFTextController?.text = getJsonField(
                _model.contactsObj,
                r'''$.contacts[2].last''',
              ).toString();
            });
          }

          if (getJsonField(
                _model.contactsObj,
                r'''$.contacts[2].phone''',
              ) ==
              null) {
            safeSetState(() {
              _model.c3PhoneTFTextController?.text = '';
              _model.c3PhoneTFMask.updateMask(
                newValue: TextEditingValue(
                  text: _model.c3PhoneTFTextController!.text,
                ),
              );
            });
          } else {
            safeSetState(() {
              _model.c3PhoneTFTextController?.text =
                  functions.displayUSPhone(getJsonField(
                _model.contactsObj,
                r'''$.contacts[2].phone''',
              ).toString());
              _model.c3PhoneTFMask.updateMask(
                newValue: TextEditingValue(
                  text: _model.c3PhoneTFTextController!.text,
                ),
              );
            });
          }

          if (getJsonField(
                _model.contactsObj,
                r'''$.contacts[3].first''',
              ) ==
              null) {
            safeSetState(() {
              _model.c4FirstTFTextController?.text = '';
            });
          } else {
            safeSetState(() {
              _model.c4FirstTFTextController?.text = getJsonField(
                _model.contactsObj,
                r'''$.contacts[3].first''',
              ).toString();
            });
          }

          if (getJsonField(
                _model.contactsObj,
                r'''$.contacts[3].last''',
              ) ==
              null) {
            safeSetState(() {
              _model.c4LastTFTextController?.text = '';
            });
          } else {
            safeSetState(() {
              _model.c4LastTFTextController?.text = getJsonField(
                _model.contactsObj,
                r'''$.contacts[3].last''',
              ).toString();
            });
          }

          if (getJsonField(
                _model.contactsObj,
                r'''$.contacts[3].phone''',
              ) ==
              null) {
            safeSetState(() {
              _model.c4PhoneTFTextController?.text = '';
              _model.c4PhoneTFMask.updateMask(
                newValue: TextEditingValue(
                  text: _model.c4PhoneTFTextController!.text,
                ),
              );
            });
          } else {
            safeSetState(() {
              _model.c4PhoneTFTextController?.text =
                  functions.displayUSPhone(getJsonField(
                _model.contactsObj,
                r'''$.contacts[3].phone''',
              ).toString());
              _model.c4PhoneTFMask.updateMask(
                newValue: TextEditingValue(
                  text: _model.c4PhoneTFTextController!.text,
                ),
              );
            });
          }

          if (getJsonField(
                _model.contactsObj,
                r'''$.contacts[4].first''',
              ) ==
              null) {
            safeSetState(() {
              _model.c5FirstTFTextController?.text = '';
            });
          } else {
            safeSetState(() {
              _model.c5FirstTFTextController?.text = getJsonField(
                _model.contactsObj,
                r'''$.contacts[4].first''',
              ).toString();
            });
          }

          if (getJsonField(
                _model.contactsObj,
                r'''$.contacts[4].last''',
              ) ==
              null) {
            safeSetState(() {
              _model.c5LastTFTextController?.text = '';
            });
          } else {
            safeSetState(() {
              _model.c5LastTFTextController?.text = getJsonField(
                _model.contactsObj,
                r'''$.contacts[4].last''',
              ).toString();
            });
          }

          if (getJsonField(
                _model.contactsObj,
                r'''$.contacts[4].phone''',
              ) ==
              null) {
            safeSetState(() {
              _model.c5PhoneTFTextController?.text = '';
              _model.c5PhoneTFMask.updateMask(
                newValue: TextEditingValue(
                  text: _model.c5PhoneTFTextController!.text,
                ),
              );
            });
          } else {
            safeSetState(() {
              _model.c5PhoneTFTextController?.text =
                  functions.displayUSPhone(getJsonField(
                _model.contactsObj,
                r'''$.contacts[4].phone''',
              ).toString());
              _model.c5PhoneTFMask.updateMask(
                newValue: TextEditingValue(
                  text: _model.c5PhoneTFTextController!.text,
                ),
              );
            });
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'ERROR #008 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT',
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
        _model.dataKeyOut2 = await actions.generateDataKeyIfMissing();
        _model.dataKeyB64 = _model.dataKeyOut2!;
        safeSetState(() {});
        safeSetState(() {
          _model.c1FirstTFTextController?.clear();
          _model.c1LastTFTextController?.clear();
          _model.c1PhoneTFTextController?.clear();
          _model.c1PhoneTFMask.clear();
          _model.c2FirstTFTextController?.clear();
          _model.c2LastTFTextController?.clear();
          _model.c2PhoneTFTextController?.clear();
          _model.c2PhoneTFMask.clear();
          _model.c3FirstTFTextController?.clear();
          _model.c3LastTFTextController?.clear();
          _model.c3PhoneTFTextController?.clear();
          _model.c3PhoneTFMask.clear();
          _model.c4FirstTFTextController?.clear();
          _model.c4LastTFTextController?.clear();
          _model.c4PhoneTFTextController?.clear();
          _model.c4PhoneTFMask.clear();
          _model.c5FirstTFTextController?.clear();
          _model.c5LastTFTextController?.clear();
          _model.c5PhoneTFTextController?.clear();
          _model.c5PhoneTFMask.clear();
        });
      }
    });

    _model.c1FirstTFTextController ??= TextEditingController();
    _model.c1FirstTFFocusNode ??= FocusNode();

    _model.c1LastTFTextController ??= TextEditingController();
    _model.c1LastTFFocusNode ??= FocusNode();

    _model.c1PhoneTFTextController ??= TextEditingController();
    _model.c1PhoneTFFocusNode ??= FocusNode();

    _model.c1PhoneTFMask = MaskTextInputFormatter(mask: '(###) ###-####');
    _model.c2FirstTFTextController ??= TextEditingController();
    _model.c2FirstTFFocusNode ??= FocusNode();

    _model.c2LastTFTextController ??= TextEditingController();
    _model.c2LastTFFocusNode ??= FocusNode();

    _model.c2PhoneTFTextController ??= TextEditingController();
    _model.c2PhoneTFFocusNode ??= FocusNode();

    _model.c2PhoneTFMask = MaskTextInputFormatter(mask: '(###) ###-####');
    _model.c3FirstTFTextController ??= TextEditingController();
    _model.c3FirstTFFocusNode ??= FocusNode();

    _model.c3LastTFTextController ??= TextEditingController();
    _model.c3LastTFFocusNode ??= FocusNode();

    _model.c3PhoneTFTextController ??= TextEditingController();
    _model.c3PhoneTFFocusNode ??= FocusNode();

    _model.c3PhoneTFMask = MaskTextInputFormatter(mask: '(###) ###-####');
    _model.c4FirstTFTextController ??= TextEditingController();
    _model.c4FirstTFFocusNode ??= FocusNode();

    _model.c4LastTFTextController ??= TextEditingController();
    _model.c4LastTFFocusNode ??= FocusNode();

    _model.c4PhoneTFTextController ??= TextEditingController();
    _model.c4PhoneTFFocusNode ??= FocusNode();

    _model.c4PhoneTFMask = MaskTextInputFormatter(mask: '(###) ###-####');
    _model.c5FirstTFTextController ??= TextEditingController();
    _model.c5FirstTFFocusNode ??= FocusNode();

    _model.c5LastTFTextController ??= TextEditingController();
    _model.c5LastTFFocusNode ??= FocusNode();

    _model.c5PhoneTFTextController ??= TextEditingController();
    _model.c5PhoneTFFocusNode ??= FocusNode();

    _model.c5PhoneTFMask = MaskTextInputFormatter(mask: '(###) ###-####');
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
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Align(
                    alignment: AlignmentDirectional(-1.0, 0.0),
                    child: Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 0.0, 0.0),
                      child: FlutterFlowIconButton(
                        borderColor: Colors.transparent,
                        borderRadius: 20.0,
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
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 20.0),
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
                      color: FlutterFlowTheme.of(context).primary,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    alignment: AlignmentDirectional(0.0, 0.0),
                    child: Stack(
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              8.0, 12.0, 8.0, 12.0),
                          child: Text(
                            'Emergency Contacts',
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'DECOY BEBAS',
                                  color: FlutterFlowTheme.of(context).info,
                                  fontSize: 48.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.normal,
                                  lineHeight: 1.0,
                                ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              8.0, 12.0, 8.0, 12.0),
                          child: Text(
                            'Emergency Contacts',
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'DECOY BEBAS',
                                  color: FlutterFlowTheme.of(context).info,
                                  fontSize: 48.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.normal,
                                  lineHeight: 1.0,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Form(
                          key: _model.formKey,
                          autovalidateMode: AutovalidateMode.disabled,
                          child: Align(
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  16.0, 0.0, 16.0, 0.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_model.contactsCount >= 1)
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          16.0, 16.0, 16.0, 0.0),
                                      child: Material(
                                        color: Colors.transparent,
                                        elevation: 3.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            border: Border.all(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              width: 2.5,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Contact 1',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .titleMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleMediumFamily,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleMediumIsCustom,
                                                          ),
                                                    ),
                                                    FlutterFlowIconButton(
                                                      borderRadius: 16.0,
                                                      buttonSize: 32.0,
                                                      fillColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                      icon: Icon(
                                                        Icons.delete_outline,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .info,
                                                        size: 16.0,
                                                      ),
                                                      onPressed: () async {
                                                        safeSetState(() {
                                                          _model.c1FirstTFTextController
                                                                  ?.text =
                                                              _model
                                                                  .c2FirstTFTextController
                                                                  .text;
                                                        });
                                                        safeSetState(() {
                                                          _model.c1LastTFTextController
                                                                  ?.text =
                                                              _model
                                                                  .c2LastTFTextController
                                                                  .text;
                                                        });
                                                        safeSetState(() {
                                                          _model.c1PhoneTFTextController
                                                                  ?.text =
                                                              functions.sanitizePhoneDigits(
                                                                  _model
                                                                      .c2PhoneTFTextController
                                                                      .text);
                                                          _model.c1PhoneTFMask
                                                              .updateMask(
                                                            newValue:
                                                                TextEditingValue(
                                                              text: _model
                                                                  .c1PhoneTFTextController!
                                                                  .text,
                                                            ),
                                                          );
                                                        });
                                                        safeSetState(() {
                                                          _model.c2FirstTFTextController
                                                                  ?.text =
                                                              _model
                                                                  .c3FirstTFTextController
                                                                  .text;
                                                        });
                                                        safeSetState(() {
                                                          _model.c2LastTFTextController
                                                                  ?.text =
                                                              _model
                                                                  .c3LastTFTextController
                                                                  .text;
                                                        });
                                                        safeSetState(() {
                                                          _model.c2PhoneTFTextController
                                                                  ?.text =
                                                              functions.sanitizePhoneDigits(
                                                                  _model
                                                                      .c3PhoneTFTextController
                                                                      .text);
                                                          _model.c2PhoneTFMask
                                                              .updateMask(
                                                            newValue:
                                                                TextEditingValue(
                                                              text: _model
                                                                  .c2PhoneTFTextController!
                                                                  .text,
                                                            ),
                                                          );
                                                        });
                                                        safeSetState(() {
                                                          _model.c3FirstTFTextController
                                                                  ?.text =
                                                              _model
                                                                  .c4FirstTFTextController
                                                                  .text;
                                                        });
                                                        safeSetState(() {
                                                          _model.c3LastTFTextController
                                                                  ?.text =
                                                              _model
                                                                  .c4LastTFTextController
                                                                  .text;
                                                        });
                                                        safeSetState(() {
                                                          _model.c3PhoneTFTextController
                                                                  ?.text =
                                                              functions.sanitizePhoneDigits(
                                                                  _model
                                                                      .c4PhoneTFTextController
                                                                      .text);
                                                          _model.c3PhoneTFMask
                                                              .updateMask(
                                                            newValue:
                                                                TextEditingValue(
                                                              text: _model
                                                                  .c3PhoneTFTextController!
                                                                  .text,
                                                            ),
                                                          );
                                                        });
                                                        safeSetState(() {
                                                          _model.c4FirstTFTextController
                                                                  ?.text =
                                                              _model
                                                                  .c5FirstTFTextController
                                                                  .text;
                                                        });
                                                        safeSetState(() {
                                                          _model.c4LastTFTextController
                                                                  ?.text =
                                                              _model
                                                                  .c5LastTFTextController
                                                                  .text;
                                                        });
                                                        safeSetState(() {
                                                          _model.c4PhoneTFTextController
                                                                  ?.text =
                                                              functions.sanitizePhoneDigits(
                                                                  functions.sanitizePhoneDigits(_model
                                                                      .c5PhoneTFTextController
                                                                      .text));
                                                          _model.c4PhoneTFMask
                                                              .updateMask(
                                                            newValue:
                                                                TextEditingValue(
                                                              text: _model
                                                                  .c4PhoneTFTextController!
                                                                  .text,
                                                            ),
                                                          );
                                                        });
                                                        safeSetState(() {
                                                          _model
                                                              .c5PhoneTFTextController
                                                              ?.clear();
                                                          _model.c5PhoneTFMask
                                                              .clear();
                                                          _model
                                                              .c5LastTFTextController
                                                              ?.clear();
                                                          _model
                                                              .c5FirstTFTextController
                                                              ?.clear();
                                                        });
                                                        _model.contactsCount =
                                                            _model.contactsCount -
                                                                1;
                                                        safeSetState(() {});
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                TextFormField(
                                                  controller: _model
                                                      .c1FirstTFTextController,
                                                  focusNode:
                                                      _model.c1FirstTFFocusNode,
                                                  autofocus: false,
                                                  textCapitalization:
                                                      TextCapitalization.words,
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  obscureText: false,
                                                  decoration: InputDecoration(
                                                    hintText: 'First Name',
                                                    hintStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .override(
                                                              fontFamily:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                              letterSpacing:
                                                                  0.0,
                                                              useGoogleFonts:
                                                                  !FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumIsCustom,
                                                            ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            Color(0x00000000),
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            Color(0x00000000),
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                  ),
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
                                                  keyboardType:
                                                      TextInputType.name,
                                                  cursorColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .primaryText,
                                                  validator: _model
                                                      .c1FirstTFTextControllerValidator
                                                      .asValidator(context),
                                                  inputFormatters: [
                                                    if (!isAndroid && !isiOS)
                                                      TextInputFormatter
                                                          .withFunction(
                                                              (oldValue,
                                                                  newValue) {
                                                        return TextEditingValue(
                                                          selection: newValue
                                                              .selection,
                                                          text: newValue.text
                                                              .toCapitalization(
                                                                  TextCapitalization
                                                                      .words),
                                                        );
                                                      }),
                                                  ],
                                                ),
                                                TextFormField(
                                                  controller: _model
                                                      .c1LastTFTextController,
                                                  focusNode:
                                                      _model.c1LastTFFocusNode,
                                                  autofocus: false,
                                                  textCapitalization:
                                                      TextCapitalization.words,
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  obscureText: false,
                                                  decoration: InputDecoration(
                                                    hintText: 'Last Name',
                                                    hintStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .override(
                                                              fontFamily:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                              letterSpacing:
                                                                  0.0,
                                                              useGoogleFonts:
                                                                  !FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumIsCustom,
                                                            ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            Color(0x00000000),
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            Color(0x00000000),
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                  ),
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
                                                  keyboardType:
                                                      TextInputType.name,
                                                  cursorColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .primaryText,
                                                  validator: _model
                                                      .c1LastTFTextControllerValidator
                                                      .asValidator(context),
                                                  inputFormatters: [
                                                    if (!isAndroid && !isiOS)
                                                      TextInputFormatter
                                                          .withFunction(
                                                              (oldValue,
                                                                  newValue) {
                                                        return TextEditingValue(
                                                          selection: newValue
                                                              .selection,
                                                          text: newValue.text
                                                              .toCapitalization(
                                                                  TextCapitalization
                                                                      .words),
                                                        );
                                                      }),
                                                  ],
                                                ),
                                                TextFormField(
                                                  controller: _model
                                                      .c1PhoneTFTextController,
                                                  focusNode:
                                                      _model.c1PhoneTFFocusNode,
                                                  onChanged: (_) =>
                                                      EasyDebounce.debounce(
                                                    '_model.c1PhoneTFTextController',
                                                    Duration(
                                                        milliseconds: 2000),
                                                    () async {
                                                      _model.c1PhoneDigits = functions
                                                          .sanitizePhoneDigits(
                                                              _model
                                                                  .c1PhoneTFTextController
                                                                  .text);
                                                      safeSetState(() {});
                                                      if ((_model.c1PhoneDigits !=
                                                                  null &&
                                                              _model.c1PhoneDigits !=
                                                                  '') &&
                                                          ((_model.c1PhoneDigits!)
                                                                  .length ==
                                                              10)) {
                                                        safeSetState(() {
                                                          _model.c1PhoneTFTextController
                                                                  ?.text =
                                                              functions
                                                                  .formatAsUsPhone(
                                                                      _model
                                                                          .c1PhoneDigits!);
                                                          _model.c1PhoneTFMask
                                                              .updateMask(
                                                            newValue:
                                                                TextEditingValue(
                                                              text: _model
                                                                  .c1PhoneTFTextController!
                                                                  .text,
                                                            ),
                                                          );
                                                        });
                                                      }
                                                    },
                                                  ),
                                                  autofocus: false,
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  obscureText: false,
                                                  decoration: InputDecoration(
                                                    hintText: 'Phone Number',
                                                    hintStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .override(
                                                              fontFamily:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                              letterSpacing:
                                                                  0.0,
                                                              useGoogleFonts:
                                                                  !FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumIsCustom,
                                                            ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            Color(0x00000000),
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            Color(0x00000000),
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                  ),
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
                                                  keyboardType:
                                                      TextInputType.phone,
                                                  cursorColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .primaryText,
                                                  validator: _model
                                                      .c1PhoneTFTextControllerValidator
                                                      .asValidator(context),
                                                  inputFormatters: [
                                                    _model.c1PhoneTFMask
                                                  ],
                                                ),
                                              ].divide(SizedBox(height: 12.0)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (_model.contactsCount >= 2)
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          16.0, 16.0, 16.0, 0.0),
                                      child: Material(
                                        color: Colors.transparent,
                                        elevation: 3.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        child: AnimatedContainer(
                                          duration:
                                              Duration(milliseconds: 2000),
                                          curve: Curves.easeInOut,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            border: Border.all(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              width: 2.5,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Contact 2',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .titleMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleMediumFamily,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleMediumIsCustom,
                                                          ),
                                                    ),
                                                    FlutterFlowIconButton(
                                                      borderRadius: 16.0,
                                                      buttonSize: 32.0,
                                                      fillColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                      icon: Icon(
                                                        Icons.delete_outline,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .info,
                                                        size: 16.0,
                                                      ),
                                                      onPressed: () async {
                                                        safeSetState(() {
                                                          _model.c2FirstTFTextController
                                                                  ?.text =
                                                              _model
                                                                  .c3FirstTFTextController
                                                                  .text;
                                                        });
                                                        safeSetState(() {
                                                          _model.c2LastTFTextController
                                                                  ?.text =
                                                              _model
                                                                  .c3LastTFTextController
                                                                  .text;
                                                        });
                                                        safeSetState(() {
                                                          _model.c2PhoneTFTextController
                                                                  ?.text =
                                                              functions.sanitizePhoneDigits(
                                                                  _model
                                                                      .c3PhoneTFTextController
                                                                      .text);
                                                          _model.c2PhoneTFMask
                                                              .updateMask(
                                                            newValue:
                                                                TextEditingValue(
                                                              text: _model
                                                                  .c2PhoneTFTextController!
                                                                  .text,
                                                            ),
                                                          );
                                                        });
                                                        safeSetState(() {
                                                          _model.c3FirstTFTextController
                                                                  ?.text =
                                                              _model
                                                                  .c4FirstTFTextController
                                                                  .text;
                                                        });
                                                        safeSetState(() {
                                                          _model.c3LastTFTextController
                                                                  ?.text =
                                                              _model
                                                                  .c4LastTFTextController
                                                                  .text;
                                                        });
                                                        safeSetState(() {
                                                          _model.c3PhoneTFTextController
                                                                  ?.text =
                                                              functions.sanitizePhoneDigits(
                                                                  _model
                                                                      .c4PhoneTFTextController
                                                                      .text);
                                                          _model.c3PhoneTFMask
                                                              .updateMask(
                                                            newValue:
                                                                TextEditingValue(
                                                              text: _model
                                                                  .c3PhoneTFTextController!
                                                                  .text,
                                                            ),
                                                          );
                                                        });
                                                        safeSetState(() {
                                                          _model.c4FirstTFTextController
                                                                  ?.text =
                                                              _model
                                                                  .c5FirstTFTextController
                                                                  .text;
                                                        });
                                                        safeSetState(() {
                                                          _model.c4LastTFTextController
                                                                  ?.text =
                                                              _model
                                                                  .c5LastTFTextController
                                                                  .text;
                                                        });
                                                        safeSetState(() {
                                                          _model.c4PhoneTFTextController
                                                                  ?.text =
                                                              functions.sanitizePhoneDigits(
                                                                  _model
                                                                      .c5PhoneTFTextController
                                                                      .text);
                                                          _model.c4PhoneTFMask
                                                              .updateMask(
                                                            newValue:
                                                                TextEditingValue(
                                                              text: _model
                                                                  .c4PhoneTFTextController!
                                                                  .text,
                                                            ),
                                                          );
                                                        });
                                                        safeSetState(() {
                                                          _model
                                                              .c5PhoneTFTextController
                                                              ?.clear();
                                                          _model.c5PhoneTFMask
                                                              .clear();
                                                          _model
                                                              .c5LastTFTextController
                                                              ?.clear();
                                                          _model
                                                              .c5FirstTFTextController
                                                              ?.clear();
                                                        });
                                                        _model.contactsCount =
                                                            _model.contactsCount -
                                                                1;
                                                        safeSetState(() {});
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                TextFormField(
                                                  controller: _model
                                                      .c2FirstTFTextController,
                                                  focusNode:
                                                      _model.c2FirstTFFocusNode,
                                                  autofocus: false,
                                                  textCapitalization:
                                                      TextCapitalization.words,
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  obscureText: false,
                                                  decoration: InputDecoration(
                                                    hintText: 'First Name',
                                                    hintStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .override(
                                                              fontFamily:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                              letterSpacing:
                                                                  0.0,
                                                              useGoogleFonts:
                                                                  !FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumIsCustom,
                                                            ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            Color(0x00000000),
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            Color(0x00000000),
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                  ),
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
                                                  keyboardType:
                                                      TextInputType.name,
                                                  cursorColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .primaryText,
                                                  validator: _model
                                                      .c2FirstTFTextControllerValidator
                                                      .asValidator(context),
                                                  inputFormatters: [
                                                    if (!isAndroid && !isiOS)
                                                      TextInputFormatter
                                                          .withFunction(
                                                              (oldValue,
                                                                  newValue) {
                                                        return TextEditingValue(
                                                          selection: newValue
                                                              .selection,
                                                          text: newValue.text
                                                              .toCapitalization(
                                                                  TextCapitalization
                                                                      .words),
                                                        );
                                                      }),
                                                  ],
                                                ),
                                                TextFormField(
                                                  controller: _model
                                                      .c2LastTFTextController,
                                                  focusNode:
                                                      _model.c2LastTFFocusNode,
                                                  autofocus: false,
                                                  textCapitalization:
                                                      TextCapitalization.words,
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  obscureText: false,
                                                  decoration: InputDecoration(
                                                    hintText: 'Last Name',
                                                    hintStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .override(
                                                              fontFamily:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                              letterSpacing:
                                                                  0.0,
                                                              useGoogleFonts:
                                                                  !FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumIsCustom,
                                                            ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            Color(0x00000000),
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            Color(0x00000000),
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                  ),
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
                                                  keyboardType:
                                                      TextInputType.name,
                                                  cursorColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .primaryText,
                                                  validator: _model
                                                      .c2LastTFTextControllerValidator
                                                      .asValidator(context),
                                                  inputFormatters: [
                                                    if (!isAndroid && !isiOS)
                                                      TextInputFormatter
                                                          .withFunction(
                                                              (oldValue,
                                                                  newValue) {
                                                        return TextEditingValue(
                                                          selection: newValue
                                                              .selection,
                                                          text: newValue.text
                                                              .toCapitalization(
                                                                  TextCapitalization
                                                                      .words),
                                                        );
                                                      }),
                                                  ],
                                                ),
                                                TextFormField(
                                                  controller: _model
                                                      .c2PhoneTFTextController,
                                                  focusNode:
                                                      _model.c2PhoneTFFocusNode,
                                                  onChanged: (_) =>
                                                      EasyDebounce.debounce(
                                                    '_model.c2PhoneTFTextController',
                                                    Duration(
                                                        milliseconds: 2000),
                                                    () async {
                                                      _model.c2PhoneDigits = functions
                                                          .sanitizePhoneDigits(
                                                              _model
                                                                  .c2PhoneTFTextController
                                                                  .text);
                                                      safeSetState(() {});
                                                      if ((_model.c2PhoneDigits !=
                                                                  null &&
                                                              _model.c2PhoneDigits !=
                                                                  '') &&
                                                          ((_model.c2PhoneDigits!)
                                                                  .length ==
                                                              10)) {
                                                        safeSetState(() {
                                                          _model.c2PhoneTFTextController
                                                                  ?.text =
                                                              functions
                                                                  .formatAsUsPhone(
                                                                      _model
                                                                          .c2PhoneDigits!);
                                                          _model.c2PhoneTFMask
                                                              .updateMask(
                                                            newValue:
                                                                TextEditingValue(
                                                              text: _model
                                                                  .c2PhoneTFTextController!
                                                                  .text,
                                                            ),
                                                          );
                                                        });
                                                      }
                                                    },
                                                  ),
                                                  autofocus: false,
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  obscureText: false,
                                                  decoration: InputDecoration(
                                                    hintText: 'Phone Number',
                                                    hintStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .override(
                                                              fontFamily:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                              letterSpacing:
                                                                  0.0,
                                                              useGoogleFonts:
                                                                  !FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumIsCustom,
                                                            ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            Color(0x00000000),
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            Color(0x00000000),
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                  ),
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
                                                  keyboardType:
                                                      TextInputType.phone,
                                                  cursorColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .primaryText,
                                                  validator: _model
                                                      .c2PhoneTFTextControllerValidator
                                                      .asValidator(context),
                                                  inputFormatters: [
                                                    _model.c2PhoneTFMask
                                                  ],
                                                ),
                                              ].divide(SizedBox(height: 12.0)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (_model.contactsCount >= 3)
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          16.0, 16.0, 16.0, 0.0),
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          border: Border.all(
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                            width: 2.5,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Contact 3',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .titleMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleMediumFamily,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .titleMediumIsCustom,
                                                        ),
                                                  ),
                                                  FlutterFlowIconButton(
                                                    borderRadius: 16.0,
                                                    buttonSize: 32.0,
                                                    fillColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primary,
                                                    icon: Icon(
                                                      Icons.delete_outline,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .info,
                                                      size: 16.0,
                                                    ),
                                                    onPressed: () async {
                                                      safeSetState(() {
                                                        _model.c3FirstTFTextController
                                                                ?.text =
                                                            _model
                                                                .c4FirstTFTextController
                                                                .text;
                                                      });
                                                      safeSetState(() {
                                                        _model.c3LastTFTextController
                                                                ?.text =
                                                            _model
                                                                .c4LastTFTextController
                                                                .text;
                                                      });
                                                      safeSetState(() {
                                                        _model.c3PhoneTFTextController
                                                                ?.text =
                                                            functions
                                                                .sanitizePhoneDigits(
                                                                    _model
                                                                        .c4PhoneTFTextController
                                                                        .text);
                                                        _model.c3PhoneTFMask
                                                            .updateMask(
                                                          newValue:
                                                              TextEditingValue(
                                                            text: _model
                                                                .c3PhoneTFTextController!
                                                                .text,
                                                          ),
                                                        );
                                                      });
                                                      safeSetState(() {
                                                        _model.c4FirstTFTextController
                                                                ?.text =
                                                            _model
                                                                .c5FirstTFTextController
                                                                .text;
                                                      });
                                                      safeSetState(() {
                                                        _model.c4LastTFTextController
                                                                ?.text =
                                                            _model
                                                                .c5LastTFTextController
                                                                .text;
                                                      });
                                                      safeSetState(() {
                                                        _model.c4PhoneTFTextController
                                                                ?.text =
                                                            functions
                                                                .sanitizePhoneDigits(
                                                                    _model
                                                                        .c5PhoneTFTextController
                                                                        .text);
                                                        _model.c4PhoneTFMask
                                                            .updateMask(
                                                          newValue:
                                                              TextEditingValue(
                                                            text: _model
                                                                .c4PhoneTFTextController!
                                                                .text,
                                                          ),
                                                        );
                                                      });
                                                      safeSetState(() {
                                                        _model
                                                            .c5PhoneTFTextController
                                                            ?.clear();
                                                        _model.c5PhoneTFMask
                                                            .clear();
                                                        _model
                                                            .c5LastTFTextController
                                                            ?.clear();
                                                        _model
                                                            .c5FirstTFTextController
                                                            ?.clear();
                                                      });
                                                      _model.contactsCount =
                                                          _model.contactsCount -
                                                              1;
                                                      safeSetState(() {});
                                                    },
                                                  ),
                                                ],
                                              ),
                                              TextFormField(
                                                controller: _model
                                                    .c3FirstTFTextController,
                                                focusNode:
                                                    _model.c3FirstTFFocusNode,
                                                autofocus: false,
                                                textCapitalization:
                                                    TextCapitalization.words,
                                                textInputAction:
                                                    TextInputAction.next,
                                                obscureText: false,
                                                decoration: InputDecoration(
                                                  hintText: 'First Name',
                                                  hintStyle:
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
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                      width: 1.5,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                      width: 1.5,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  errorBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Color(0x00000000),
                                                      width: 1.5,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  focusedErrorBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Color(0x00000000),
                                                      width: 1.5,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                ),
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMediumFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMediumIsCustom,
                                                        ),
                                                keyboardType:
                                                    TextInputType.name,
                                                cursorColor:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                validator: _model
                                                    .c3FirstTFTextControllerValidator
                                                    .asValidator(context),
                                                inputFormatters: [
                                                  if (!isAndroid && !isiOS)
                                                    TextInputFormatter
                                                        .withFunction((oldValue,
                                                            newValue) {
                                                      return TextEditingValue(
                                                        selection:
                                                            newValue.selection,
                                                        text: newValue.text
                                                            .toCapitalization(
                                                                TextCapitalization
                                                                    .words),
                                                      );
                                                    }),
                                                ],
                                              ),
                                              TextFormField(
                                                controller: _model
                                                    .c3LastTFTextController,
                                                focusNode:
                                                    _model.c3LastTFFocusNode,
                                                autofocus: false,
                                                textCapitalization:
                                                    TextCapitalization.words,
                                                textInputAction:
                                                    TextInputAction.next,
                                                obscureText: false,
                                                decoration: InputDecoration(
                                                  hintText: 'Last Name',
                                                  hintStyle:
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
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                      width: 1.5,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                      width: 1.5,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  errorBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Color(0x00000000),
                                                      width: 1.5,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  focusedErrorBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Color(0x00000000),
                                                      width: 1.5,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                ),
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMediumFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMediumIsCustom,
                                                        ),
                                                keyboardType:
                                                    TextInputType.name,
                                                cursorColor:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                validator: _model
                                                    .c3LastTFTextControllerValidator
                                                    .asValidator(context),
                                                inputFormatters: [
                                                  if (!isAndroid && !isiOS)
                                                    TextInputFormatter
                                                        .withFunction((oldValue,
                                                            newValue) {
                                                      return TextEditingValue(
                                                        selection:
                                                            newValue.selection,
                                                        text: newValue.text
                                                            .toCapitalization(
                                                                TextCapitalization
                                                                    .words),
                                                      );
                                                    }),
                                                ],
                                              ),
                                              TextFormField(
                                                controller: _model
                                                    .c3PhoneTFTextController,
                                                focusNode:
                                                    _model.c3PhoneTFFocusNode,
                                                onChanged: (_) =>
                                                    EasyDebounce.debounce(
                                                  '_model.c3PhoneTFTextController',
                                                  Duration(milliseconds: 2000),
                                                  () async {
                                                    _model.c3PhoneDigits = functions
                                                        .sanitizePhoneDigits(_model
                                                            .c3PhoneTFTextController
                                                            .text);
                                                    safeSetState(() {});
                                                    if ((_model.c3PhoneDigits !=
                                                                null &&
                                                            _model.c3PhoneDigits !=
                                                                '') &&
                                                        ((_model.c3PhoneDigits!)
                                                                .length ==
                                                            10)) {
                                                      safeSetState(() {
                                                        _model.c3PhoneTFTextController
                                                                ?.text =
                                                            functions
                                                                .formatAsUsPhone(
                                                                    _model
                                                                        .c3PhoneDigits!);
                                                        _model.c3PhoneTFMask
                                                            .updateMask(
                                                          newValue:
                                                              TextEditingValue(
                                                            text: _model
                                                                .c3PhoneTFTextController!
                                                                .text,
                                                          ),
                                                        );
                                                      });
                                                    }
                                                  },
                                                ),
                                                autofocus: false,
                                                textInputAction:
                                                    TextInputAction.next,
                                                obscureText: false,
                                                decoration: InputDecoration(
                                                  hintText: 'Phone Number',
                                                  hintStyle:
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
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                      width: 1.5,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                      width: 1.5,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  errorBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Color(0x00000000),
                                                      width: 1.5,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  focusedErrorBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Color(0x00000000),
                                                      width: 1.5,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                ),
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMediumFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMediumIsCustom,
                                                        ),
                                                keyboardType:
                                                    TextInputType.phone,
                                                cursorColor:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                validator: _model
                                                    .c3PhoneTFTextControllerValidator
                                                    .asValidator(context),
                                                inputFormatters: [
                                                  _model.c3PhoneTFMask
                                                ],
                                              ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (_model.contactsCount >= 4)
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          16.0, 16.0, 16.0, 0.0),
                                      child: Material(
                                        color: Colors.transparent,
                                        elevation: 3.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            border: Border.all(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              width: 2.5,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Contact 4',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .titleMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleMediumFamily,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleMediumIsCustom,
                                                          ),
                                                    ),
                                                    FlutterFlowIconButton(
                                                      borderRadius: 16.0,
                                                      buttonSize: 32.0,
                                                      fillColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                      icon: Icon(
                                                        Icons.delete_outline,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .info,
                                                        size: 16.0,
                                                      ),
                                                      onPressed: () async {
                                                        safeSetState(() {
                                                          _model.c4FirstTFTextController
                                                                  ?.text =
                                                              _model
                                                                  .c5FirstTFTextController
                                                                  .text;
                                                        });
                                                        safeSetState(() {
                                                          _model.c4LastTFTextController
                                                                  ?.text =
                                                              _model
                                                                  .c5LastTFTextController
                                                                  .text;
                                                        });
                                                        safeSetState(() {
                                                          _model.c4PhoneTFTextController
                                                                  ?.text =
                                                              functions.sanitizePhoneDigits(
                                                                  _model
                                                                      .c5PhoneTFTextController
                                                                      .text);
                                                          _model.c4PhoneTFMask
                                                              .updateMask(
                                                            newValue:
                                                                TextEditingValue(
                                                              text: _model
                                                                  .c4PhoneTFTextController!
                                                                  .text,
                                                            ),
                                                          );
                                                        });
                                                        safeSetState(() {
                                                          _model
                                                              .c5PhoneTFTextController
                                                              ?.clear();
                                                          _model.c5PhoneTFMask
                                                              .clear();
                                                          _model
                                                              .c5LastTFTextController
                                                              ?.clear();
                                                          _model
                                                              .c5FirstTFTextController
                                                              ?.clear();
                                                        });
                                                        _model.contactsCount =
                                                            _model.contactsCount -
                                                                1;
                                                        safeSetState(() {});
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                TextFormField(
                                                  controller: _model
                                                      .c4FirstTFTextController,
                                                  focusNode:
                                                      _model.c4FirstTFFocusNode,
                                                  autofocus: false,
                                                  textCapitalization:
                                                      TextCapitalization.words,
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  obscureText: false,
                                                  decoration: InputDecoration(
                                                    hintText: 'First Name',
                                                    hintStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .override(
                                                              fontFamily:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                              letterSpacing:
                                                                  0.0,
                                                              useGoogleFonts:
                                                                  !FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumIsCustom,
                                                            ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            Color(0x00000000),
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            Color(0x00000000),
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                  ),
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
                                                  keyboardType:
                                                      TextInputType.name,
                                                  cursorColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .primaryText,
                                                  validator: _model
                                                      .c4FirstTFTextControllerValidator
                                                      .asValidator(context),
                                                  inputFormatters: [
                                                    if (!isAndroid && !isiOS)
                                                      TextInputFormatter
                                                          .withFunction(
                                                              (oldValue,
                                                                  newValue) {
                                                        return TextEditingValue(
                                                          selection: newValue
                                                              .selection,
                                                          text: newValue.text
                                                              .toCapitalization(
                                                                  TextCapitalization
                                                                      .words),
                                                        );
                                                      }),
                                                  ],
                                                ),
                                                TextFormField(
                                                  controller: _model
                                                      .c4LastTFTextController,
                                                  focusNode:
                                                      _model.c4LastTFFocusNode,
                                                  autofocus: false,
                                                  textCapitalization:
                                                      TextCapitalization.words,
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  obscureText: false,
                                                  decoration: InputDecoration(
                                                    hintText: 'Last Name',
                                                    hintStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .override(
                                                              fontFamily:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                              letterSpacing:
                                                                  0.0,
                                                              useGoogleFonts:
                                                                  !FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumIsCustom,
                                                            ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            Color(0x00000000),
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            Color(0x00000000),
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                  ),
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
                                                  keyboardType:
                                                      TextInputType.name,
                                                  cursorColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .primaryText,
                                                  validator: _model
                                                      .c4LastTFTextControllerValidator
                                                      .asValidator(context),
                                                  inputFormatters: [
                                                    if (!isAndroid && !isiOS)
                                                      TextInputFormatter
                                                          .withFunction(
                                                              (oldValue,
                                                                  newValue) {
                                                        return TextEditingValue(
                                                          selection: newValue
                                                              .selection,
                                                          text: newValue.text
                                                              .toCapitalization(
                                                                  TextCapitalization
                                                                      .words),
                                                        );
                                                      }),
                                                  ],
                                                ),
                                                TextFormField(
                                                  controller: _model
                                                      .c4PhoneTFTextController,
                                                  focusNode:
                                                      _model.c4PhoneTFFocusNode,
                                                  onChanged: (_) =>
                                                      EasyDebounce.debounce(
                                                    '_model.c4PhoneTFTextController',
                                                    Duration(
                                                        milliseconds: 2000),
                                                    () async {
                                                      _model.c4PhoneDigits = functions
                                                          .sanitizePhoneDigits(
                                                              _model
                                                                  .c4PhoneTFTextController
                                                                  .text);
                                                      safeSetState(() {});
                                                      if ((_model.c4PhoneDigits !=
                                                                  null &&
                                                              _model.c4PhoneDigits !=
                                                                  '') &&
                                                          ((_model.c4PhoneDigits!)
                                                                  .length ==
                                                              10)) {
                                                        safeSetState(() {
                                                          _model.c4PhoneTFTextController
                                                                  ?.text =
                                                              functions
                                                                  .formatAsUsPhone(
                                                                      _model
                                                                          .c4PhoneDigits!);
                                                          _model.c4PhoneTFMask
                                                              .updateMask(
                                                            newValue:
                                                                TextEditingValue(
                                                              text: _model
                                                                  .c4PhoneTFTextController!
                                                                  .text,
                                                            ),
                                                          );
                                                        });
                                                      }
                                                    },
                                                  ),
                                                  autofocus: false,
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  obscureText: false,
                                                  decoration: InputDecoration(
                                                    hintText: 'Phone Number',
                                                    hintStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .override(
                                                              fontFamily:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                              letterSpacing:
                                                                  0.0,
                                                              useGoogleFonts:
                                                                  !FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumIsCustom,
                                                            ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            Color(0x00000000),
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            Color(0x00000000),
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                  ),
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
                                                  keyboardType:
                                                      TextInputType.phone,
                                                  cursorColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .primaryText,
                                                  validator: _model
                                                      .c4PhoneTFTextControllerValidator
                                                      .asValidator(context),
                                                  inputFormatters: [
                                                    _model.c4PhoneTFMask
                                                  ],
                                                ),
                                              ].divide(SizedBox(height: 12.0)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (_model.contactsCount >= 5)
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          16.0, 16.0, 16.0, 0.0),
                                      child: Material(
                                        color: Colors.transparent,
                                        elevation: 3.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            border: Border.all(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              width: 2.5,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Contact 5',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .titleMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleMediumFamily,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleMediumIsCustom,
                                                          ),
                                                    ),
                                                    FlutterFlowIconButton(
                                                      borderRadius: 16.0,
                                                      buttonSize: 32.0,
                                                      fillColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                      icon: Icon(
                                                        Icons.delete_outline,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .info,
                                                        size: 16.0,
                                                      ),
                                                      onPressed: () async {
                                                        safeSetState(() {
                                                          _model
                                                              .c5FirstTFTextController
                                                              ?.clear();
                                                          _model
                                                              .c5LastTFTextController
                                                              ?.clear();
                                                          _model
                                                              .c5PhoneTFTextController
                                                              ?.clear();
                                                          _model.c5PhoneTFMask
                                                              .clear();
                                                        });
                                                        _model.contactsCount =
                                                            _model.contactsCount -
                                                                1;
                                                        safeSetState(() {});
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                TextFormField(
                                                  controller: _model
                                                      .c5FirstTFTextController,
                                                  focusNode:
                                                      _model.c5FirstTFFocusNode,
                                                  autofocus: false,
                                                  textCapitalization:
                                                      TextCapitalization.words,
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  obscureText: false,
                                                  decoration: InputDecoration(
                                                    hintText: 'First Name',
                                                    hintStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .override(
                                                              fontFamily:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                              letterSpacing:
                                                                  0.0,
                                                              useGoogleFonts:
                                                                  !FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumIsCustom,
                                                            ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            Color(0x00000000),
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            Color(0x00000000),
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                  ),
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
                                                  keyboardType:
                                                      TextInputType.name,
                                                  cursorColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .primaryText,
                                                  validator: _model
                                                      .c5FirstTFTextControllerValidator
                                                      .asValidator(context),
                                                  inputFormatters: [
                                                    if (!isAndroid && !isiOS)
                                                      TextInputFormatter
                                                          .withFunction(
                                                              (oldValue,
                                                                  newValue) {
                                                        return TextEditingValue(
                                                          selection: newValue
                                                              .selection,
                                                          text: newValue.text
                                                              .toCapitalization(
                                                                  TextCapitalization
                                                                      .words),
                                                        );
                                                      }),
                                                  ],
                                                ),
                                                TextFormField(
                                                  controller: _model
                                                      .c5LastTFTextController,
                                                  focusNode:
                                                      _model.c5LastTFFocusNode,
                                                  autofocus: false,
                                                  textCapitalization:
                                                      TextCapitalization.words,
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  obscureText: false,
                                                  decoration: InputDecoration(
                                                    hintText: 'Last Name',
                                                    hintStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .override(
                                                              fontFamily:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                              letterSpacing:
                                                                  0.0,
                                                              useGoogleFonts:
                                                                  !FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumIsCustom,
                                                            ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            Color(0x00000000),
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            Color(0x00000000),
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                  ),
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
                                                  keyboardType:
                                                      TextInputType.name,
                                                  cursorColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .primaryText,
                                                  validator: _model
                                                      .c5LastTFTextControllerValidator
                                                      .asValidator(context),
                                                  inputFormatters: [
                                                    if (!isAndroid && !isiOS)
                                                      TextInputFormatter
                                                          .withFunction(
                                                              (oldValue,
                                                                  newValue) {
                                                        return TextEditingValue(
                                                          selection: newValue
                                                              .selection,
                                                          text: newValue.text
                                                              .toCapitalization(
                                                                  TextCapitalization
                                                                      .words),
                                                        );
                                                      }),
                                                  ],
                                                ),
                                                TextFormField(
                                                  controller: _model
                                                      .c5PhoneTFTextController,
                                                  focusNode:
                                                      _model.c5PhoneTFFocusNode,
                                                  onChanged: (_) =>
                                                      EasyDebounce.debounce(
                                                    '_model.c5PhoneTFTextController',
                                                    Duration(
                                                        milliseconds: 2000),
                                                    () async {
                                                      _model.c5PhoneDigits = functions
                                                          .sanitizePhoneDigits(
                                                              _model
                                                                  .c5PhoneTFTextController
                                                                  .text);
                                                      safeSetState(() {});
                                                      if ((_model.c5PhoneDigits !=
                                                                  null &&
                                                              _model.c5PhoneDigits !=
                                                                  '') &&
                                                          ((_model.c5PhoneDigits!)
                                                                  .length ==
                                                              10)) {
                                                        safeSetState(() {
                                                          _model.c4PhoneTFTextController
                                                                  ?.text =
                                                              functions
                                                                  .formatAsUsPhone(
                                                                      _model
                                                                          .c4PhoneDigits!);
                                                          _model.c4PhoneTFMask
                                                              .updateMask(
                                                            newValue:
                                                                TextEditingValue(
                                                              text: _model
                                                                  .c4PhoneTFTextController!
                                                                  .text,
                                                            ),
                                                          );
                                                        });
                                                      }
                                                    },
                                                  ),
                                                  autofocus: false,
                                                  textInputAction:
                                                      TextInputAction.done,
                                                  obscureText: false,
                                                  decoration: InputDecoration(
                                                    hintText: 'Phone Number',
                                                    hintStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .override(
                                                              fontFamily:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                              letterSpacing:
                                                                  0.0,
                                                              useGoogleFonts:
                                                                  !FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumIsCustom,
                                                            ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            Color(0x00000000),
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            Color(0x00000000),
                                                        width: 1.5,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                  ),
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
                                                  keyboardType:
                                                      TextInputType.phone,
                                                  cursorColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .primaryText,
                                                  validator: _model
                                                      .c5PhoneTFTextControllerValidator
                                                      .asValidator(context),
                                                  inputFormatters: [
                                                    _model.c5PhoneTFMask
                                                  ],
                                                ),
                                              ].divide(SizedBox(height: 12.0)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  FlutterFlowIconButton(
                                    borderRadius: 0.0,
                                    fillColor: Colors.white,
                                    icon: Icon(
                                      Icons.add_circle_rounded,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      size: 35.0,
                                    ),
                                    onPressed: () async {
                                      _model.contactsCount =
                                          _model.contactsCount + 1;
                                      safeSetState(() {});
                                    },
                                  ),
                                  FFButtonWidget(
                                    onPressed: () async {
                                      await actions.dismissKeyboard(
                                        context,
                                      );
                                      _model.contactsPayload =
                                          await actions.buildContactsPayloadV2(
                                        _model.c1FirstTFTextController.text,
                                        _model.c1LastTFTextController.text,
                                        _model.c1PhoneTFTextController.text,
                                        _model.c2FirstTFTextController.text,
                                        _model.c2LastTFTextController.text,
                                        _model.c2PhoneTFTextController.text,
                                        _model.c3FirstTFTextController.text,
                                        _model.c3LastTFTextController.text,
                                        _model.c3PhoneTFTextController.text,
                                        _model.c4FirstTFTextController.text,
                                        _model.c4LastTFTextController.text,
                                        _model.c4PhoneTFTextController.text,
                                        _model.c5FirstTFTextController.text,
                                        _model.c5LastTFTextController.text,
                                        _model.c5PhoneTFTextController.text,
                                        _model.contactsCount,
                                      );
                                      _model.contactsJson =
                                          _model.contactsPayload!;
                                      safeSetState(() {});
                                      if (loggedIn == true) {
                                        _model.keyOut = await actions
                                            .generateDataKeyIfMissing();
                                        _model.dataKeyB64 = _model.keyOut!;
                                        safeSetState(() {});
                                        _model.enc =
                                            await actions.aesGcmEncryptString(
                                          _model.contactsJson,
                                          _model.dataKeyB64,
                                        );
                                        _model.ctB64 = getJsonField(
                                          _model.enc,
                                          r'''$.ciphertextB64''',
                                        ).toString();
                                        _model.nonceB64 = getJsonField(
                                          _model.enc,
                                          r'''$.nonceB64''',
                                        ).toString();
                                        safeSetState(() {});
                                        _model.wrap =
                                            await WrapDataKeyCall.call(
                                          dataKeyB64: _model.dataKeyB64,
                                          jwt: currentJwtToken,
                                        );

                                        if ((_model.wrap?.succeeded ?? true)) {
                                          _model.wrappedB64 = getJsonField(
                                            (_model.wrap?.jsonBody ?? ''),
                                            r'''$.wrappedB64''',
                                          ).toString();
                                          safeSetState(() {});
                                          _model.upd = await DecoyWalletTable()
                                              .queryRows(
                                            queryFn: (q) => q.eqOrNull(
                                              'user_id',
                                              currentUserUid,
                                            ),
                                          );
                                          if (_model.upd != null &&
                                              (_model.upd)!.isNotEmpty) {
                                            await DecoyWalletTable().update(
                                              data: {
                                                'wrapped_datakey':
                                                    _model.wrappedB64,
                                                'updated_at':
                                                    supaSerialize<DateTime>(
                                                        getCurrentTimestamp),
                                                'contacts_ciphertext':
                                                    _model.ctB64,
                                                'contacts_nonce':
                                                    _model.nonceB64,
                                                'contacts_version': 1,
                                                'created_at':
                                                    supaSerialize<DateTime>(
                                                        getCurrentTimestamp),
                                                'contacts_complete': (_model.c1PhoneTFTextController
                                                                    .text !=
                                                                '') ||
                                                        (_model
                                                                    .c2PhoneTFTextController
                                                                    .text !=
                                                                '') ||
                                                        (_model
                                                                    .c3PhoneTFTextController
                                                                    .text !=
                                                                '') ||
                                                        (_model.c4PhoneTFTextController
                                                                    .text !=
                                                                '') ||
                                                        (_model.c5PhoneTFTextController
                                                                    .text !=
                                                                '')
                                                    ? true
                                                    : false,
                                              },
                                              matchingRows: (rows) =>
                                                  rows.eqOrNull(
                                                'user_id',
                                                currentUserUid,
                                              ),
                                            );
                                            if (_model.updRow
                                                    ?.elementAtOrNull(0)
                                                    ?.contactsComplete ==
                                                true) {
                                              FFAppState().contactsDoneInc =
                                                  FFAppState().contactsDoneInc +
                                                      1;
                                              safeSetState(() {});
                                            } else {
                                              if (FFAppState().contactsDoneInc >
                                                  0) {
                                                FFAppState().contactsDoneInc =
                                                    FFAppState()
                                                            .contactsDoneInc +
                                                        -1;
                                                safeSetState(() {});
                                              }
                                            }

                                            FFAppState()
                                                    .emergencyContactsIncrement =
                                                _model.contactsCount;
                                            safeSetState(() {});
                                            context.safePop();
                                          } else {
                                            _model.insRow =
                                                await DecoyWalletTable()
                                                    .insert({
                                              'wrapped_datakey':
                                                  _model.wrappedB64,
                                              'updated_at':
                                                  supaSerialize<DateTime>(
                                                      getCurrentTimestamp),
                                              'contacts_ciphertext':
                                                  _model.ctB64,
                                              'contacts_nonce': _model.nonceB64,
                                              'contacts_version': 1,
                                              'user_id': currentUserUid,
                                              'contacts_complete': (_model.c1PhoneTFTextController
                                                                  .text !=
                                                              '') ||
                                                      (_model
                                                                  .c2PhoneTFTextController
                                                                  .text !=
                                                              '') ||
                                                      (_model.c3PhoneTFTextController
                                                                  .text !=
                                                              '') ||
                                                      (_model.c4PhoneTFTextController
                                                                  .text !=
                                                              '') ||
                                                      (_model.c5PhoneTFTextController
                                                                  .text !=
                                                              '')
                                                  ? true
                                                  : false,
                                            });
                                            if (_model
                                                    .insRow?.contactsComplete ==
                                                true) {
                                              FFAppState().contactsDoneInc =
                                                  FFAppState().contactsDoneInc +
                                                      1;
                                              safeSetState(() {});
                                            } else {
                                              if (FFAppState().contactsDoneInc >
                                                  0) {
                                                FFAppState().contactsDoneInc =
                                                    FFAppState()
                                                            .contactsDoneInc +
                                                        -1;
                                                safeSetState(() {});
                                              }
                                            }

                                            FFAppState()
                                                    .emergencyContactsIncrement =
                                                _model.contactsCount;
                                            safeSetState(() {});
                                            context.safePop();
                                          }
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'ERROR #009 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT',
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
                                        }
                                      } else {
                                        context
                                            .goNamed(LoginPageWidget.routeName);
                                      }

                                      safeSetState(() {});
                                    },
                                    text: 'Save',
                                    options: FFButtonOptions(
                                      width: 280.0,
                                      height: 56.0,
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          16.0, 0.0, 16.0, 0.0),
                                      iconPadding:
                                          EdgeInsetsDirectional.fromSTEB(
                                              0.0, 0.0, 0.0, 0.0),
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      textStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmallFamily,
                                            color: FlutterFlowTheme.of(context)
                                                .info,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .titleSmallIsCustom,
                                          ),
                                      elevation: 3.0,
                                      borderSide: BorderSide(
                                        color: Colors.transparent,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                ]
                                    .divide(SizedBox(height: 12.0))
                                    .addToStart(SizedBox(height: 0.0))
                                    .addToEnd(SizedBox(height: 32.0)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
