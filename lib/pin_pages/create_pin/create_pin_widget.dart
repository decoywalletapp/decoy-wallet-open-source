import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'create_pin_model.dart';
export 'create_pin_model.dart';

/// I want a PIN code page where the user is propted to create a pin to enter
/// to the home page.
///
/// I want the pin to be custom built
class CreatePinWidget extends StatefulWidget {
  const CreatePinWidget({super.key});

  static String routeName = 'CreatePin';
  static String routePath = '/createPin';

  @override
  State<CreatePinWidget> createState() => _CreatePinWidgetState();
}

class _CreatePinWidgetState extends State<CreatePinWidget> {
  late CreatePinModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CreatePinModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.currentStep = 1;
      _model.pinInput = [].toList().cast<String>();
      _model.joinedPin = "";
      _model.confirmedPinInput = [].toList().cast<String>();
      _model.joinedPinConfirm = "";
      _model.cpnotificationValue = 0;
      _model.cpconfirmValue = 0;
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
      child: PopScope(
        canPop: false,
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).info,
          body: SafeArea(
            top: true,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Stack(
                        fit: StackFit.expand,
                        children: [
                          Stack(
                            fit: StackFit.expand,
                            children: [
                              if (_model.currentStep == 1)
                                Align(
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: Container(
                                    width: 400.0,
                                    height: double.infinity,
                                    decoration: BoxDecoration(),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          18.0, 20.0, 18.0, 40.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.lock_outline,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    size: 80.0,
                                                  ),
                                                  Text(
                                                    'Create Your PIN to Access Your Dashboard',
                                                    textAlign: TextAlign.center,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .headlineMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .headlineMediumFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .headlineMediumIsCustom,
                                                        ),
                                                  ),
                                                  Stack(
                                                    children: [
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child:
                                                                AnimatedContainer(
                                                              duration: Duration(
                                                                  milliseconds:
                                                                      200),
                                                              curve: Curves
                                                                  .easeInOut,
                                                              width: 16.0,
                                                              height: 16.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .info,
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                            ),
                                                          ),
                                                          Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child:
                                                                AnimatedContainer(
                                                              duration: Duration(
                                                                  milliseconds:
                                                                      200),
                                                              curve:
                                                                  Curves.easeIn,
                                                              width: 16.0,
                                                              height: 16.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .info,
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                            ),
                                                          ),
                                                          Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child:
                                                                AnimatedContainer(
                                                              duration: Duration(
                                                                  milliseconds:
                                                                      200),
                                                              curve:
                                                                  Curves.easeIn,
                                                              width: 16.0,
                                                              height: 16.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .info,
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                            ),
                                                          ),
                                                          Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child:
                                                                AnimatedContainer(
                                                              duration: Duration(
                                                                  milliseconds:
                                                                      200),
                                                              curve:
                                                                  Curves.easeIn,
                                                              width: 16.0,
                                                              height: 16.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .info,
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                            ),
                                                          ),
                                                          Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child:
                                                                AnimatedContainer(
                                                              duration: Duration(
                                                                  milliseconds:
                                                                      200),
                                                              curve:
                                                                  Curves.easeIn,
                                                              width: 16.0,
                                                              height: 16.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .info,
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                            ),
                                                          ),
                                                          Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child:
                                                                AnimatedContainer(
                                                              duration: Duration(
                                                                  milliseconds:
                                                                      200),
                                                              curve:
                                                                  Curves.easeIn,
                                                              width: 16.0,
                                                              height: 16.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .info,
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                            ),
                                                          ),
                                                          Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child:
                                                                AnimatedContainer(
                                                              duration: Duration(
                                                                  milliseconds:
                                                                      200),
                                                              curve:
                                                                  Curves.easeIn,
                                                              width: 16.0,
                                                              height: 16.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .info,
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                            ),
                                                          ),
                                                          Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child:
                                                                AnimatedContainer(
                                                              duration: Duration(
                                                                  milliseconds:
                                                                      200),
                                                              curve:
                                                                  Curves.easeIn,
                                                              width: 16.0,
                                                              height: 16.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .info,
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                            ),
                                                          ),
                                                        ].divide(SizedBox(
                                                            width: 16.0)),
                                                      ),
                                                      if (_model.currentStep ==
                                                          1)
                                                        Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            if ((List<String>
                                                                pinList) {
                                                              return pinList
                                                                      .length >=
                                                                  1;
                                                            }(_model.pinInput
                                                                .toList()))
                                                              Align(
                                                                alignment:
                                                                    AlignmentDirectional(
                                                                        0.0,
                                                                        0.0),
                                                                child:
                                                                    AnimatedContainer(
                                                                  duration: Duration(
                                                                      milliseconds:
                                                                          200),
                                                                  curve: Curves
                                                                      .easeInOut,
                                                                  width: 16.0,
                                                                  height: 16.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          0.0),
                                                                ),
                                                              ),
                                                            if ((List<String>
                                                                pinList) {
                                                              return pinList
                                                                      .length >=
                                                                  2;
                                                            }(_model.pinInput
                                                                .toList()))
                                                              Align(
                                                                alignment:
                                                                    AlignmentDirectional(
                                                                        0.0,
                                                                        0.0),
                                                                child:
                                                                    AnimatedContainer(
                                                                  duration: Duration(
                                                                      milliseconds:
                                                                          200),
                                                                  curve: Curves
                                                                      .easeIn,
                                                                  width: 16.0,
                                                                  height: 16.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          0.0),
                                                                ),
                                                              ),
                                                            if ((List<String>
                                                                pinList) {
                                                              return pinList
                                                                      .length >=
                                                                  3;
                                                            }(_model.pinInput
                                                                .toList()))
                                                              Align(
                                                                alignment:
                                                                    AlignmentDirectional(
                                                                        0.0,
                                                                        0.0),
                                                                child:
                                                                    AnimatedContainer(
                                                                  duration: Duration(
                                                                      milliseconds:
                                                                          200),
                                                                  curve: Curves
                                                                      .easeIn,
                                                                  width: 16.0,
                                                                  height: 16.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          0.0),
                                                                ),
                                                              ),
                                                            if ((List<String>
                                                                pinList) {
                                                              return pinList
                                                                      .length >=
                                                                  4;
                                                            }(_model.pinInput
                                                                .toList()))
                                                              Align(
                                                                alignment:
                                                                    AlignmentDirectional(
                                                                        0.0,
                                                                        0.0),
                                                                child:
                                                                    AnimatedContainer(
                                                                  duration: Duration(
                                                                      milliseconds:
                                                                          200),
                                                                  curve: Curves
                                                                      .easeIn,
                                                                  width: 16.0,
                                                                  height: 16.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          0.0),
                                                                ),
                                                              ),
                                                            if ((List<String>
                                                                pinList) {
                                                              return pinList
                                                                      .length >=
                                                                  5;
                                                            }(_model.pinInput
                                                                .toList()))
                                                              Align(
                                                                alignment:
                                                                    AlignmentDirectional(
                                                                        0.0,
                                                                        0.0),
                                                                child:
                                                                    AnimatedContainer(
                                                                  duration: Duration(
                                                                      milliseconds:
                                                                          200),
                                                                  curve: Curves
                                                                      .easeIn,
                                                                  width: 16.0,
                                                                  height: 16.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          0.0),
                                                                ),
                                                              ),
                                                            if ((List<String>
                                                                pinList) {
                                                              return pinList
                                                                      .length >=
                                                                  6;
                                                            }(_model.pinInput
                                                                .toList()))
                                                              Align(
                                                                alignment:
                                                                    AlignmentDirectional(
                                                                        0.0,
                                                                        0.0),
                                                                child:
                                                                    AnimatedContainer(
                                                                  duration: Duration(
                                                                      milliseconds:
                                                                          200),
                                                                  curve: Curves
                                                                      .easeIn,
                                                                  width: 16.0,
                                                                  height: 16.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          0.0),
                                                                ),
                                                              ),
                                                            if ((List<String>
                                                                pinList) {
                                                              return pinList
                                                                      .length >=
                                                                  7;
                                                            }(_model.pinInput
                                                                .toList()))
                                                              Align(
                                                                alignment:
                                                                    AlignmentDirectional(
                                                                        0.0,
                                                                        0.0),
                                                                child:
                                                                    AnimatedContainer(
                                                                  duration: Duration(
                                                                      milliseconds:
                                                                          200),
                                                                  curve: Curves
                                                                      .easeIn,
                                                                  width: 16.0,
                                                                  height: 16.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          0.0),
                                                                ),
                                                              ),
                                                            if ((List<String>
                                                                pinList) {
                                                              return pinList
                                                                      .length >=
                                                                  8;
                                                            }(_model.pinInput
                                                                .toList()))
                                                              Align(
                                                                alignment:
                                                                    AlignmentDirectional(
                                                                        0.0,
                                                                        0.0),
                                                                child:
                                                                    AnimatedContainer(
                                                                  duration: Duration(
                                                                      milliseconds:
                                                                          200),
                                                                  curve: Curves
                                                                      .easeIn,
                                                                  width: 16.0,
                                                                  height: 16.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          0.0),
                                                                ),
                                                              ),
                                                          ].divide(SizedBox(
                                                              width: 16.0)),
                                                        ),
                                                    ],
                                                  ),
                                                  Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Stack(
                                                            children: [
                                                              if (_model
                                                                      .cpnotificationValue
                                                                      .toString() ==
                                                                  '0')
                                                                Align(
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          0.0),
                                                                  child:
                                                                      Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            20.0),
                                                                    child: Text(
                                                                      'Enter a 4 - 8 digit PIN to secure your account',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodySmall
                                                                          .override(
                                                                            fontFamily:
                                                                                FlutterFlowTheme.of(context).bodySmallFamily,
                                                                            color:
                                                                                FlutterFlowTheme.of(context).secondaryText,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            useGoogleFonts:
                                                                                !FlutterFlowTheme.of(context).bodySmallIsCustom,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              if (_model
                                                                      .cpnotificationValue
                                                                      .toString() ==
                                                                  '1')
                                                                Align(
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          0.0),
                                                                  child:
                                                                      Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            20.0),
                                                                    child: Text(
                                                                      'PLEASE ENTER AT LEAST 4 DIGITS',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodySmall
                                                                          .override(
                                                                            fontFamily:
                                                                                FlutterFlowTheme.of(context).bodySmallFamily,
                                                                            color:
                                                                                FlutterFlowTheme.of(context).primary,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            useGoogleFonts:
                                                                                !FlutterFlowTheme.of(context).bodySmallIsCustom,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              if (_model
                                                                      .cpnotificationValue
                                                                      .toString() ==
                                                                  '2')
                                                                Align(
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          0.0),
                                                                  child:
                                                                      Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            20.0),
                                                                    child: Text(
                                                                      'PINS DO NOT MATCH - PLEASE TRY AGAIN',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodySmall
                                                                          .override(
                                                                            fontFamily:
                                                                                FlutterFlowTheme.of(context).bodySmallFamily,
                                                                            color:
                                                                                FlutterFlowTheme.of(context).primary,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            useGoogleFonts:
                                                                                !FlutterFlowTheme.of(context).bodySmallIsCustom,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        ].divide(SizedBox(
                                                            height: 24.0)),
                                                      ),
                                                    ],
                                                  ),
                                                ].divide(
                                                    SizedBox(height: 16.0)),
                                              ),
                                            ].divide(SizedBox(height: 32.0)),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      0.0, 0.0, 0.0, 24.0),
                                              child: GridView(
                                                padding: EdgeInsets.zero,
                                                gridDelegate:
                                                    SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 3,
                                                  crossAxisSpacing: 10.0,
                                                  mainAxisSpacing: 10.0,
                                                  childAspectRatio: 1.25,
                                                ),
                                                shrinkWrap: true,
                                                scrollDirection: Axis.vertical,
                                                children: [
                                                  FFButtonWidget(
                                                    onPressed: () async {
                                                      // Add1
                                                      _model.addToPinInput('1');
                                                      safeSetState(() {});
                                                      if (_model.pinInput
                                                              .toList()
                                                              .length >
                                                          8) {
                                                        _model.removeAtIndexFromPinInput(
                                                            _model.pinInput
                                                                    .toList()
                                                                    .length -
                                                                1);
                                                        safeSetState(() {});
                                                      }
                                                    },
                                                    text: '1',
                                                    options: FFButtonOptions(
                                                      height: 40.0,
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  16.0,
                                                                  0.0,
                                                                  16.0,
                                                                  0.0),
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
                                                              .titleSmall
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmallFamily,
                                                                color: Colors
                                                                    .white,
                                                                letterSpacing:
                                                                    0.0,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmallIsCustom,
                                                              ),
                                                      elevation: 2.0,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12.0),
                                                    ),
                                                  ),
                                                  FFButtonWidget(
                                                    onPressed: () async {
                                                      // Add2
                                                      _model.addToPinInput('2');
                                                      safeSetState(() {});
                                                      if (_model.pinInput
                                                              .toList()
                                                              .length >
                                                          8) {
                                                        _model.removeAtIndexFromPinInput(
                                                            _model.pinInput
                                                                    .toList()
                                                                    .length -
                                                                1);
                                                        safeSetState(() {});
                                                      }
                                                    },
                                                    text: '2',
                                                    options: FFButtonOptions(
                                                      height: 40.0,
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  16.0,
                                                                  0.0,
                                                                  16.0,
                                                                  0.0),
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
                                                              .titleSmall
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmallFamily,
                                                                color: Colors
                                                                    .white,
                                                                letterSpacing:
                                                                    0.0,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmallIsCustom,
                                                              ),
                                                      elevation: 2.0,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12.0),
                                                    ),
                                                  ),
                                                  FFButtonWidget(
                                                    onPressed: () async {
                                                      // Add3
                                                      _model.addToPinInput('3');
                                                      safeSetState(() {});
                                                      if (_model.pinInput
                                                              .toList()
                                                              .length >
                                                          8) {
                                                        _model.removeAtIndexFromPinInput(
                                                            _model.pinInput
                                                                    .toList()
                                                                    .length -
                                                                1);
                                                        safeSetState(() {});
                                                      }
                                                    },
                                                    text: '3',
                                                    options: FFButtonOptions(
                                                      height: 40.0,
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  16.0,
                                                                  0.0,
                                                                  16.0,
                                                                  0.0),
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
                                                              .titleSmall
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmallFamily,
                                                                color: Colors
                                                                    .white,
                                                                letterSpacing:
                                                                    0.0,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmallIsCustom,
                                                              ),
                                                      elevation: 2.0,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12.0),
                                                    ),
                                                  ),
                                                  FFButtonWidget(
                                                    onPressed: () async {
                                                      // Add4
                                                      _model.addToPinInput('4');
                                                      safeSetState(() {});
                                                      if (_model.pinInput
                                                              .toList()
                                                              .length >
                                                          8) {
                                                        _model.removeAtIndexFromPinInput(
                                                            _model.pinInput
                                                                    .toList()
                                                                    .length -
                                                                1);
                                                        safeSetState(() {});
                                                      }
                                                    },
                                                    text: '4',
                                                    options: FFButtonOptions(
                                                      height: 40.0,
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  16.0,
                                                                  0.0,
                                                                  16.0,
                                                                  0.0),
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
                                                              .titleSmall
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmallFamily,
                                                                color: Colors
                                                                    .white,
                                                                letterSpacing:
                                                                    0.0,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmallIsCustom,
                                                              ),
                                                      elevation: 2.0,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                  ),
                                                  FFButtonWidget(
                                                    onPressed: () async {
                                                      // Add5
                                                      _model.addToPinInput('5');
                                                      safeSetState(() {});
                                                      if (_model.pinInput
                                                              .toList()
                                                              .length >
                                                          8) {
                                                        _model.removeAtIndexFromPinInput(
                                                            _model.pinInput
                                                                    .toList()
                                                                    .length -
                                                                1);
                                                        safeSetState(() {});
                                                      }
                                                    },
                                                    text: '5',
                                                    options: FFButtonOptions(
                                                      height: 40.0,
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  16.0,
                                                                  0.0,
                                                                  16.0,
                                                                  0.0),
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
                                                              .titleSmall
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmallFamily,
                                                                color: Colors
                                                                    .white,
                                                                letterSpacing:
                                                                    0.0,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmallIsCustom,
                                                              ),
                                                      elevation: 2.0,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                  ),
                                                  FFButtonWidget(
                                                    onPressed: () async {
                                                      // Add6
                                                      _model.addToPinInput('6');
                                                      safeSetState(() {});
                                                      if (_model.pinInput
                                                              .toList()
                                                              .length >
                                                          8) {
                                                        _model.removeAtIndexFromPinInput(
                                                            _model.pinInput
                                                                    .toList()
                                                                    .length -
                                                                1);
                                                        safeSetState(() {});
                                                      }
                                                    },
                                                    text: '6',
                                                    options: FFButtonOptions(
                                                      height: 40.0,
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  16.0,
                                                                  0.0,
                                                                  16.0,
                                                                  0.0),
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
                                                              .titleSmall
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmallFamily,
                                                                color: Colors
                                                                    .white,
                                                                letterSpacing:
                                                                    0.0,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmallIsCustom,
                                                              ),
                                                      elevation: 2.0,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                  ),
                                                  FFButtonWidget(
                                                    onPressed: () async {
                                                      // Add7
                                                      _model.addToPinInput('7');
                                                      safeSetState(() {});
                                                      if (_model.pinInput
                                                              .toList()
                                                              .length >
                                                          8) {
                                                        _model.removeAtIndexFromPinInput(
                                                            _model.pinInput
                                                                    .toList()
                                                                    .length -
                                                                1);
                                                        safeSetState(() {});
                                                      }
                                                    },
                                                    text: '7',
                                                    options: FFButtonOptions(
                                                      height: 40.0,
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  16.0,
                                                                  0.0,
                                                                  16.0,
                                                                  0.0),
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
                                                              .titleSmall
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmallFamily,
                                                                color: Colors
                                                                    .white,
                                                                letterSpacing:
                                                                    0.0,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmallIsCustom,
                                                              ),
                                                      elevation: 2.0,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                  ),
                                                  FFButtonWidget(
                                                    onPressed: () async {
                                                      // Add8
                                                      _model.addToPinInput('8');
                                                      safeSetState(() {});
                                                      if (_model.pinInput
                                                              .toList()
                                                              .length >
                                                          8) {
                                                        _model.removeAtIndexFromPinInput(
                                                            _model.pinInput
                                                                    .toList()
                                                                    .length -
                                                                1);
                                                        safeSetState(() {});
                                                      }
                                                    },
                                                    text: '8',
                                                    options: FFButtonOptions(
                                                      height: 40.0,
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  16.0,
                                                                  0.0,
                                                                  16.0,
                                                                  0.0),
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
                                                              .titleSmall
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmallFamily,
                                                                color: Colors
                                                                    .white,
                                                                letterSpacing:
                                                                    0.0,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmallIsCustom,
                                                              ),
                                                      elevation: 2.0,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                  ),
                                                  FFButtonWidget(
                                                    onPressed: () async {
                                                      // Add9
                                                      _model.addToPinInput('9');
                                                      safeSetState(() {});
                                                      if (_model.pinInput
                                                              .toList()
                                                              .length >
                                                          8) {
                                                        _model.removeAtIndexFromPinInput(
                                                            _model.pinInput
                                                                    .toList()
                                                                    .length -
                                                                1);
                                                        safeSetState(() {});
                                                      }
                                                    },
                                                    text: '9',
                                                    options: FFButtonOptions(
                                                      height: 40.0,
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  16.0,
                                                                  0.0,
                                                                  16.0,
                                                                  0.0),
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
                                                              .titleSmall
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmallFamily,
                                                                color: Colors
                                                                    .white,
                                                                letterSpacing:
                                                                    0.0,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmallIsCustom,
                                                              ),
                                                      elevation: 2.0,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                  ),
                                                  Container(
                                                    width: 100.0,
                                                    height: 100.0,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .info,
                                                    ),
                                                  ),
                                                  FFButtonWidget(
                                                    onPressed: () async {
                                                      // Add0
                                                      _model.addToPinInput('0');
                                                      safeSetState(() {});
                                                      if (_model.pinInput
                                                              .toList()
                                                              .length >
                                                          8) {
                                                        _model.removeAtIndexFromPinInput(
                                                            _model.pinInput
                                                                    .toList()
                                                                    .length -
                                                                1);
                                                        safeSetState(() {});
                                                      }
                                                    },
                                                    text: '0',
                                                    options: FFButtonOptions(
                                                      height: 40.0,
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  16.0,
                                                                  0.0,
                                                                  16.0,
                                                                  0.0),
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
                                                              .titleSmall
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmallFamily,
                                                                color: Colors
                                                                    .white,
                                                                letterSpacing:
                                                                    0.0,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmallIsCustom,
                                                              ),
                                                      elevation: 2.0,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                  ),
                                                  FlutterFlowIconButton(
                                                    borderRadius: 35.0,
                                                    buttonSize: 70.0,
                                                    icon: Icon(
                                                      Icons.backspace_outlined,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                      size: 28.0,
                                                    ),
                                                    onPressed: () async {
                                                      // RemoveFromList
                                                      _model
                                                          .removeAtIndexFromPinInput(
                                                              _model.pinInput
                                                                      .toList()
                                                                      .length -
                                                                  1);
                                                      safeSetState(() {});
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          if (_model.currentStep == 1)
                                            Align(
                                              alignment: AlignmentDirectional(
                                                  0.0, 1.0),
                                              child: FFButtonWidget(
                                                onPressed: () async {
                                                  if (_model.pinInput.length >=
                                                      4) {
                                                    _model.joinedPin = functions
                                                        .newCustomFunction(
                                                            _model.pinInput
                                                                .toList());
                                                    safeSetState(() {});
                                                    _model.currentStep = 2;
                                                    safeSetState(() {});
                                                  } else {
                                                    _model.joinedPin = '';
                                                    _model.pinInput = []
                                                        .toList()
                                                        .cast<String>();
                                                    safeSetState(() {});
                                                    _model.cpnotificationValue =
                                                        1;
                                                    safeSetState(() {});
                                                    await Future.delayed(
                                                      Duration(
                                                        milliseconds: 2000,
                                                      ),
                                                    );
                                                    _model.cpnotificationValue =
                                                        0;
                                                    safeSetState(() {});
                                                  }
                                                },
                                                text: 'Continue',
                                                options: FFButtonOptions(
                                                  width: double.infinity,
                                                  height: 50.0,
                                                  padding: EdgeInsets.all(0.0),
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
                                                        font: GoogleFonts.heebo(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleMedium
                                                                  .fontStyle,
                                                        ),
                                                        color: Colors.white,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleMedium
                                                                .fontStyle,
                                                      ),
                                                  elevation: 3.0,
                                                  borderSide: BorderSide(
                                                    color: Colors.transparent,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16.0),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              if (_model.currentStep == 2)
                                Align(
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: Container(
                                    width: 400.0,
                                    height: double.infinity,
                                    decoration: BoxDecoration(),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          18.0, 20.0, 18.0, 40.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.lock_outline,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    size: 80.0,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.all(17.0),
                                                    child: Text(
                                                      'Confirm PIN',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .headlineMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .headlineMediumFamily,
                                                            letterSpacing: 0.0,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .headlineMediumIsCustom,
                                                          ),
                                                    ),
                                                  ),
                                                  Stack(
                                                    children: [
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child:
                                                                AnimatedContainer(
                                                              duration: Duration(
                                                                  milliseconds:
                                                                      200),
                                                              curve: Curves
                                                                  .easeInOut,
                                                              width: 16.0,
                                                              height: 16.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .info,
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                            ),
                                                          ),
                                                          Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child:
                                                                AnimatedContainer(
                                                              duration: Duration(
                                                                  milliseconds:
                                                                      200),
                                                              curve:
                                                                  Curves.easeIn,
                                                              width: 16.0,
                                                              height: 16.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .info,
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                            ),
                                                          ),
                                                          Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child:
                                                                AnimatedContainer(
                                                              duration: Duration(
                                                                  milliseconds:
                                                                      200),
                                                              curve:
                                                                  Curves.easeIn,
                                                              width: 16.0,
                                                              height: 16.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .info,
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                            ),
                                                          ),
                                                          Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child:
                                                                AnimatedContainer(
                                                              duration: Duration(
                                                                  milliseconds:
                                                                      200),
                                                              curve:
                                                                  Curves.easeIn,
                                                              width: 16.0,
                                                              height: 16.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .info,
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                            ),
                                                          ),
                                                          Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child:
                                                                AnimatedContainer(
                                                              duration: Duration(
                                                                  milliseconds:
                                                                      200),
                                                              curve:
                                                                  Curves.easeIn,
                                                              width: 16.0,
                                                              height: 16.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .info,
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                            ),
                                                          ),
                                                          Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child:
                                                                AnimatedContainer(
                                                              duration: Duration(
                                                                  milliseconds:
                                                                      200),
                                                              curve:
                                                                  Curves.easeIn,
                                                              width: 16.0,
                                                              height: 16.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .info,
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                            ),
                                                          ),
                                                          Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child:
                                                                AnimatedContainer(
                                                              duration: Duration(
                                                                  milliseconds:
                                                                      200),
                                                              curve:
                                                                  Curves.easeIn,
                                                              width: 16.0,
                                                              height: 16.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .info,
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                            ),
                                                          ),
                                                          Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child:
                                                                AnimatedContainer(
                                                              duration: Duration(
                                                                  milliseconds:
                                                                      200),
                                                              curve:
                                                                  Curves.easeIn,
                                                              width: 16.0,
                                                              height: 16.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .info,
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                            ),
                                                          ),
                                                        ].divide(SizedBox(
                                                            width: 16.0)),
                                                      ),
                                                      if (_model.currentStep ==
                                                          2)
                                                        Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            if ((List<String>
                                                                pinList2) {
                                                              return pinList2
                                                                      .length >=
                                                                  1;
                                                            }(_model
                                                                .confirmedPinInput
                                                                .toList()))
                                                              Align(
                                                                alignment:
                                                                    AlignmentDirectional(
                                                                        0.0,
                                                                        0.0),
                                                                child:
                                                                    AnimatedContainer(
                                                                  duration: Duration(
                                                                      milliseconds:
                                                                          200),
                                                                  curve: Curves
                                                                      .easeInOut,
                                                                  width: 16.0,
                                                                  height: 16.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          0.0),
                                                                ),
                                                              ),
                                                            if ((List<String>
                                                                pinList2) {
                                                              return pinList2
                                                                      .length >=
                                                                  2;
                                                            }(_model
                                                                .confirmedPinInput
                                                                .toList()))
                                                              Align(
                                                                alignment:
                                                                    AlignmentDirectional(
                                                                        0.0,
                                                                        0.0),
                                                                child:
                                                                    AnimatedContainer(
                                                                  duration: Duration(
                                                                      milliseconds:
                                                                          200),
                                                                  curve: Curves
                                                                      .easeIn,
                                                                  width: 16.0,
                                                                  height: 16.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          0.0),
                                                                ),
                                                              ),
                                                            if ((List<String>
                                                                pinList2) {
                                                              return pinList2
                                                                      .length >=
                                                                  3;
                                                            }(_model
                                                                .confirmedPinInput
                                                                .toList()))
                                                              Align(
                                                                alignment:
                                                                    AlignmentDirectional(
                                                                        0.0,
                                                                        0.0),
                                                                child:
                                                                    AnimatedContainer(
                                                                  duration: Duration(
                                                                      milliseconds:
                                                                          200),
                                                                  curve: Curves
                                                                      .easeIn,
                                                                  width: 16.0,
                                                                  height: 16.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          0.0),
                                                                ),
                                                              ),
                                                            if ((List<String>
                                                                pinList2) {
                                                              return pinList2
                                                                      .length >=
                                                                  4;
                                                            }(_model
                                                                .confirmedPinInput
                                                                .toList()))
                                                              Align(
                                                                alignment:
                                                                    AlignmentDirectional(
                                                                        0.0,
                                                                        0.0),
                                                                child:
                                                                    AnimatedContainer(
                                                                  duration: Duration(
                                                                      milliseconds:
                                                                          200),
                                                                  curve: Curves
                                                                      .easeIn,
                                                                  width: 16.0,
                                                                  height: 16.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          0.0),
                                                                ),
                                                              ),
                                                            if ((List<String>
                                                                pinList2) {
                                                              return pinList2
                                                                      .length >=
                                                                  5;
                                                            }(_model
                                                                .confirmedPinInput
                                                                .toList()))
                                                              Align(
                                                                alignment:
                                                                    AlignmentDirectional(
                                                                        0.0,
                                                                        0.0),
                                                                child:
                                                                    AnimatedContainer(
                                                                  duration: Duration(
                                                                      milliseconds:
                                                                          200),
                                                                  curve: Curves
                                                                      .easeIn,
                                                                  width: 16.0,
                                                                  height: 16.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          0.0),
                                                                ),
                                                              ),
                                                            if ((List<String>
                                                                pinList2) {
                                                              return pinList2
                                                                      .length >=
                                                                  6;
                                                            }(_model
                                                                .confirmedPinInput
                                                                .toList()))
                                                              Align(
                                                                alignment:
                                                                    AlignmentDirectional(
                                                                        0.0,
                                                                        0.0),
                                                                child:
                                                                    AnimatedContainer(
                                                                  duration: Duration(
                                                                      milliseconds:
                                                                          200),
                                                                  curve: Curves
                                                                      .easeIn,
                                                                  width: 16.0,
                                                                  height: 16.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          0.0),
                                                                ),
                                                              ),
                                                            if ((List<String>
                                                                pinList2) {
                                                              return pinList2
                                                                      .length >=
                                                                  7;
                                                            }(_model
                                                                .confirmedPinInput
                                                                .toList()))
                                                              Align(
                                                                alignment:
                                                                    AlignmentDirectional(
                                                                        0.0,
                                                                        0.0),
                                                                child:
                                                                    AnimatedContainer(
                                                                  duration: Duration(
                                                                      milliseconds:
                                                                          200),
                                                                  curve: Curves
                                                                      .easeIn,
                                                                  width: 16.0,
                                                                  height: 16.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          0.0),
                                                                ),
                                                              ),
                                                            if ((List<String>
                                                                pinList2) {
                                                              return pinList2
                                                                      .length >=
                                                                  8;
                                                            }(_model
                                                                .confirmedPinInput
                                                                .toList()))
                                                              Align(
                                                                alignment:
                                                                    AlignmentDirectional(
                                                                        0.0,
                                                                        0.0),
                                                                child:
                                                                    AnimatedContainer(
                                                                  duration: Duration(
                                                                      milliseconds:
                                                                          200),
                                                                  curve: Curves
                                                                      .easeIn,
                                                                  width: 16.0,
                                                                  height: 16.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          0.0),
                                                                ),
                                                              ),
                                                          ].divide(SizedBox(
                                                              width: 16.0)),
                                                        ),
                                                    ],
                                                  ),
                                                  Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Stack(
                                                            children: [
                                                              if (_model
                                                                      .cpconfirmValue
                                                                      .toString() ==
                                                                  '0')
                                                                Align(
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          0.0),
                                                                  child:
                                                                      Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            20.0),
                                                                    child: Text(
                                                                      'Enter the same 4 - 8 digits to confirm your access PIN',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodySmall
                                                                          .override(
                                                                            fontFamily:
                                                                                FlutterFlowTheme.of(context).bodySmallFamily,
                                                                            color:
                                                                                FlutterFlowTheme.of(context).secondaryText,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            useGoogleFonts:
                                                                                !FlutterFlowTheme.of(context).bodySmallIsCustom,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              if (_model
                                                                      .cpconfirmValue
                                                                      .toString() ==
                                                                  '1')
                                                                Align(
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          0.0),
                                                                  child:
                                                                      Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            20.0),
                                                                    child: Text(
                                                                      'PIN MUST BE AT LEAST 4 DIGITS',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodySmall
                                                                          .override(
                                                                            fontFamily:
                                                                                FlutterFlowTheme.of(context).bodySmallFamily,
                                                                            color:
                                                                                FlutterFlowTheme.of(context).primary,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            useGoogleFonts:
                                                                                !FlutterFlowTheme.of(context).bodySmallIsCustom,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        ].divide(SizedBox(
                                                            height: 24.0)),
                                                      ),
                                                    ],
                                                  ),
                                                ].divide(
                                                    SizedBox(height: 16.0)),
                                              ),
                                            ].divide(SizedBox(height: 32.0)),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      0.0, 0.0, 0.0, 24.0),
                                              child: GridView(
                                                padding: EdgeInsets.zero,
                                                gridDelegate:
                                                    SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 3,
                                                  crossAxisSpacing: 10.0,
                                                  mainAxisSpacing: 10.0,
                                                  childAspectRatio: 1.25,
                                                ),
                                                shrinkWrap: true,
                                                scrollDirection: Axis.vertical,
                                                children: [
                                                  FFButtonWidget(
                                                    onPressed: () async {
                                                      // Add1
                                                      _model
                                                          .addToConfirmedPinInput(
                                                              '1');
                                                      safeSetState(() {});
                                                      if (_model
                                                              .confirmedPinInput
                                                              .toList()
                                                              .length >
                                                          8) {
                                                        _model.removeAtIndexFromConfirmedPinInput(
                                                            _model.confirmedPinInput
                                                                    .toList()
                                                                    .length -
                                                                1);
                                                        safeSetState(() {});
                                                      }
                                                    },
                                                    text: '1',
                                                    options: FFButtonOptions(
                                                      height: 40.0,
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  16.0,
                                                                  0.0,
                                                                  16.0,
                                                                  0.0),
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
                                                              .titleSmall
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmallFamily,
                                                                color: Colors
                                                                    .white,
                                                                letterSpacing:
                                                                    0.0,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmallIsCustom,
                                                              ),
                                                      elevation: 2.0,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12.0),
                                                    ),
                                                  ),
                                                  FFButtonWidget(
                                                    onPressed: () async {
                                                      // Add2
                                                      _model
                                                          .addToConfirmedPinInput(
                                                              '2');
                                                      safeSetState(() {});
                                                      if (_model
                                                              .confirmedPinInput
                                                              .toList()
                                                              .length >
                                                          8) {
                                                        _model.removeAtIndexFromConfirmedPinInput(
                                                            _model.confirmedPinInput
                                                                    .toList()
                                                                    .length -
                                                                1);
                                                        safeSetState(() {});
                                                      }
                                                    },
                                                    text: '2',
                                                    options: FFButtonOptions(
                                                      height: 40.0,
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  16.0,
                                                                  0.0,
                                                                  16.0,
                                                                  0.0),
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
                                                              .titleSmall
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmallFamily,
                                                                color: Colors
                                                                    .white,
                                                                letterSpacing:
                                                                    0.0,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmallIsCustom,
                                                              ),
                                                      elevation: 2.0,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12.0),
                                                    ),
                                                  ),
                                                  FFButtonWidget(
                                                    onPressed: () async {
                                                      // Add3
                                                      _model
                                                          .addToConfirmedPinInput(
                                                              '3');
                                                      safeSetState(() {});
                                                      if (_model.pinInput
                                                              .toList()
                                                              .length >
                                                          8) {
                                                        _model.removeAtIndexFromConfirmedPinInput(
                                                            _model.confirmedPinInput
                                                                    .toList()
                                                                    .length -
                                                                1);
                                                        safeSetState(() {});
                                                      }
                                                    },
                                                    text: '3',
                                                    options: FFButtonOptions(
                                                      height: 40.0,
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  16.0,
                                                                  0.0,
                                                                  16.0,
                                                                  0.0),
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
                                                              .titleSmall
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmallFamily,
                                                                color: Colors
                                                                    .white,
                                                                letterSpacing:
                                                                    0.0,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmallIsCustom,
                                                              ),
                                                      elevation: 2.0,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12.0),
                                                    ),
                                                  ),
                                                  FFButtonWidget(
                                                    onPressed: () async {
                                                      // Add4
                                                      _model
                                                          .addToConfirmedPinInput(
                                                              '4');
                                                      safeSetState(() {});
                                                      if (_model
                                                              .confirmedPinInput
                                                              .toList()
                                                              .length >
                                                          8) {
                                                        _model.removeAtIndexFromConfirmedPinInput(
                                                            _model.confirmedPinInput
                                                                    .toList()
                                                                    .length -
                                                                1);
                                                        safeSetState(() {});
                                                      }
                                                    },
                                                    text: '4',
                                                    options: FFButtonOptions(
                                                      height: 40.0,
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  16.0,
                                                                  0.0,
                                                                  16.0,
                                                                  0.0),
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
                                                              .titleSmall
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmallFamily,
                                                                color: Colors
                                                                    .white,
                                                                letterSpacing:
                                                                    0.0,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmallIsCustom,
                                                              ),
                                                      elevation: 2.0,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                  ),
                                                  FFButtonWidget(
                                                    onPressed: () async {
                                                      // Add5
                                                      _model
                                                          .addToConfirmedPinInput(
                                                              '5');
                                                      safeSetState(() {});
                                                      if (_model
                                                              .confirmedPinInput
                                                              .toList()
                                                              .length >
                                                          8) {
                                                        _model.removeAtIndexFromConfirmedPinInput(
                                                            _model.confirmedPinInput
                                                                    .toList()
                                                                    .length -
                                                                1);
                                                        safeSetState(() {});
                                                      }
                                                    },
                                                    text: '5',
                                                    options: FFButtonOptions(
                                                      height: 40.0,
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  16.0,
                                                                  0.0,
                                                                  16.0,
                                                                  0.0),
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
                                                              .titleSmall
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmallFamily,
                                                                color: Colors
                                                                    .white,
                                                                letterSpacing:
                                                                    0.0,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmallIsCustom,
                                                              ),
                                                      elevation: 2.0,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                  ),
                                                  FFButtonWidget(
                                                    onPressed: () async {
                                                      // Add6
                                                      _model
                                                          .addToConfirmedPinInput(
                                                              '6');
                                                      safeSetState(() {});
                                                      if (_model
                                                              .confirmedPinInput
                                                              .toList()
                                                              .length >
                                                          8) {
                                                        _model.removeAtIndexFromConfirmedPinInput(
                                                            _model.confirmedPinInput
                                                                    .toList()
                                                                    .length -
                                                                1);
                                                        safeSetState(() {});
                                                      }
                                                    },
                                                    text: '6',
                                                    options: FFButtonOptions(
                                                      height: 40.0,
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  16.0,
                                                                  0.0,
                                                                  16.0,
                                                                  0.0),
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
                                                              .titleSmall
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmallFamily,
                                                                color: Colors
                                                                    .white,
                                                                letterSpacing:
                                                                    0.0,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmallIsCustom,
                                                              ),
                                                      elevation: 2.0,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                  ),
                                                  FFButtonWidget(
                                                    onPressed: () async {
                                                      // Add7
                                                      _model
                                                          .addToConfirmedPinInput(
                                                              '7');
                                                      safeSetState(() {});
                                                      if (_model
                                                              .confirmedPinInput
                                                              .toList()
                                                              .length >
                                                          8) {
                                                        _model.removeAtIndexFromConfirmedPinInput(
                                                            _model.confirmedPinInput
                                                                    .toList()
                                                                    .length -
                                                                1);
                                                        safeSetState(() {});
                                                      }
                                                    },
                                                    text: '7',
                                                    options: FFButtonOptions(
                                                      height: 40.0,
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  16.0,
                                                                  0.0,
                                                                  16.0,
                                                                  0.0),
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
                                                              .titleSmall
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmallFamily,
                                                                color: Colors
                                                                    .white,
                                                                letterSpacing:
                                                                    0.0,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmallIsCustom,
                                                              ),
                                                      elevation: 2.0,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                  ),
                                                  FFButtonWidget(
                                                    onPressed: () async {
                                                      // Add8
                                                      _model
                                                          .addToConfirmedPinInput(
                                                              '8');
                                                      safeSetState(() {});
                                                      if (_model
                                                              .confirmedPinInput
                                                              .toList()
                                                              .length >
                                                          8) {
                                                        _model.removeAtIndexFromConfirmedPinInput(
                                                            _model.confirmedPinInput
                                                                    .toList()
                                                                    .length -
                                                                1);
                                                        safeSetState(() {});
                                                      }
                                                    },
                                                    text: '8',
                                                    options: FFButtonOptions(
                                                      height: 40.0,
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  16.0,
                                                                  0.0,
                                                                  16.0,
                                                                  0.0),
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
                                                              .titleSmall
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmallFamily,
                                                                color: Colors
                                                                    .white,
                                                                letterSpacing:
                                                                    0.0,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmallIsCustom,
                                                              ),
                                                      elevation: 2.0,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                  ),
                                                  FFButtonWidget(
                                                    onPressed: () async {
                                                      // Add9
                                                      _model
                                                          .addToConfirmedPinInput(
                                                              '9');
                                                      safeSetState(() {});
                                                      if (_model
                                                              .confirmedPinInput
                                                              .toList()
                                                              .length >
                                                          8) {
                                                        _model.removeAtIndexFromConfirmedPinInput(
                                                            _model.confirmedPinInput
                                                                    .toList()
                                                                    .length -
                                                                1);
                                                        safeSetState(() {});
                                                      }
                                                    },
                                                    text: '9',
                                                    options: FFButtonOptions(
                                                      height: 40.0,
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  16.0,
                                                                  0.0,
                                                                  16.0,
                                                                  0.0),
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
                                                              .titleSmall
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmallFamily,
                                                                color: Colors
                                                                    .white,
                                                                letterSpacing:
                                                                    0.0,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmallIsCustom,
                                                              ),
                                                      elevation: 2.0,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                  ),
                                                  Container(
                                                    width: 100.0,
                                                    height: 100.0,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .info,
                                                    ),
                                                  ),
                                                  FFButtonWidget(
                                                    onPressed: () async {
                                                      // Add0
                                                      _model
                                                          .addToConfirmedPinInput(
                                                              '0');
                                                      safeSetState(() {});
                                                      // Buttons make sure no enteries are greater than 8
                                                      if (_model
                                                              .confirmedPinInput
                                                              .toList()
                                                              .length >
                                                          8) {
                                                        _model.removeAtIndexFromConfirmedPinInput(
                                                            _model.confirmedPinInput
                                                                    .toList()
                                                                    .length -
                                                                1);
                                                        safeSetState(() {});
                                                      }
                                                    },
                                                    text: '0',
                                                    options: FFButtonOptions(
                                                      height: 40.0,
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  16.0,
                                                                  0.0,
                                                                  16.0,
                                                                  0.0),
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
                                                              .titleSmall
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmallFamily,
                                                                color: Colors
                                                                    .white,
                                                                letterSpacing:
                                                                    0.0,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmallIsCustom,
                                                              ),
                                                      elevation: 2.0,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                  ),
                                                  FlutterFlowIconButton(
                                                    borderRadius: 35.0,
                                                    buttonSize: 70.0,
                                                    icon: Icon(
                                                      Icons.backspace_outlined,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                      size: 28.0,
                                                    ),
                                                    onPressed: () async {
                                                      // RemoveFromList
                                                      _model.removeAtIndexFromConfirmedPinInput(
                                                          _model.confirmedPinInput
                                                                  .toList()
                                                                  .length -
                                                              1);
                                                      safeSetState(() {});
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          if (_model.currentStep == 2)
                                            FFButtonWidget(
                                              onPressed: () async {
                                                _model.joinedPin =
                                                    functions.newCustomFunction(
                                                        _model.pinInput
                                                            .toList());
                                                safeSetState(() {});
                                                _model.joinedPinConfirm =
                                                    functions.newCustomFunction(
                                                        _model.confirmedPinInput
                                                            .toList());
                                                safeSetState(() {});
                                                if (_model.confirmedPinInput
                                                        .length >=
                                                    4) {
                                                  if (_model.joinedPin ==
                                                      _model.joinedPinConfirm) {
                                                    _model.setPinResp =
                                                        await SetPINCall.call(
                                                      type: 'account',
                                                      pin: _model.joinedPin,
                                                      jwt: currentJwtToken,
                                                    );

                                                    if (SetPINCall.ok(
                                                          (_model.setPinResp
                                                                  ?.jsonBody ??
                                                              ''),
                                                        ) ==
                                                        true) {
                                                      _model.verifyResp =
                                                          await VerifyPINCall
                                                              .call(
                                                        pin: _model.joinedPin,
                                                        jwt: currentJwtToken,
                                                      );

                                                      if (VerifyPINCall
                                                              .isAccount(
                                                            (_model.verifyResp
                                                                    ?.jsonBody ??
                                                                ''),
                                                          ) ==
                                                          true) {
                                                        await DecoyWalletTable()
                                                            .update(
                                                          data: {
                                                            'setup_complete':
                                                                true,
                                                            'setup_completed_at':
                                                                supaSerialize<
                                                                        DateTime>(
                                                                    getCurrentTimestamp),
                                                          },
                                                          matchingRows:
                                                              (rows) =>
                                                                  rows.eqOrNull(
                                                            'user_id',
                                                            currentUserUid,
                                                          ),
                                                        );

                                                        context.goNamed(
                                                          HomePageWidget
                                                              .routeName,
                                                          extra: <String,
                                                              dynamic>{
                                                            '__transition_info__':
                                                                TransitionInfo(
                                                              hasTransition:
                                                                  true,
                                                              transitionType:
                                                                  PageTransitionType
                                                                      .fade,
                                                            ),
                                                          },
                                                        );
                                                      } else {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              'ERROR #005 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT',
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

                                                      _model.confirmedPinInput =
                                                          []
                                                              .toList()
                                                              .cast<String>();
                                                      _model.pinInput = []
                                                          .toList()
                                                          .cast<String>();
                                                      safeSetState(() {});
                                                      _model.currentStep = 1;
                                                      safeSetState(() {});
                                                    } else {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            'ERROR #004 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT',
                                                            style: TextStyle(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primaryText,
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
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
                                                    _model.confirmedPinInput =
                                                        []
                                                            .toList()
                                                            .cast<String>();
                                                    _model.pinInput = []
                                                        .toList()
                                                        .cast<String>();
                                                    safeSetState(() {});
                                                    _model.currentStep = 1;
                                                    safeSetState(() {});
                                                    _model.cpnotificationValue =
                                                        2;
                                                    safeSetState(() {});
                                                    await Future.delayed(
                                                      Duration(
                                                        milliseconds: 2000,
                                                      ),
                                                    );
                                                    _model.cpnotificationValue =
                                                        0;
                                                    safeSetState(() {});
                                                  }
                                                } else {
                                                  _model.confirmedPinInput = []
                                                      .toList()
                                                      .cast<String>();
                                                  _model.joinedPinConfirm = '';
                                                  safeSetState(() {});
                                                  _model.cpconfirmValue = 1;
                                                  safeSetState(() {});
                                                  await Future.delayed(
                                                    Duration(
                                                      milliseconds: 2000,
                                                    ),
                                                  );
                                                  _model.cpconfirmValue = 0;
                                                  safeSetState(() {});
                                                }

                                                safeSetState(() {});
                                              },
                                              text: 'Confirm',
                                              options: FFButtonOptions(
                                                width: double.infinity,
                                                height: 50.0,
                                                padding: EdgeInsets.all(0.0),
                                                iconPadding:
                                                    EdgeInsetsDirectional
                                                        .fromSTEB(
                                                            0.0, 0.0, 0.0, 0.0),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                textStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.heebo(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleMedium
                                                                    .fontStyle,
                                                          ),
                                                          color: Colors.white,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleMedium
                                                                  .fontStyle,
                                                        ),
                                                elevation: 3.0,
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(14.0),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              if (_model.currentStep == 2)
                                PositionedDirectional(
                                  start: 20.0,
                                  top: 32.0,
                                  child: SizedBox(
                                    width: 60.0,
                                    height: 60.0,
                                    child: FlutterFlowIconButton(
                                      borderColor: Colors.transparent,
                                      borderRadius: 30.0,
                                      borderWidth: 1.0,
                                      buttonSize: 60.0,
                                      icon: Icon(
                                        Icons.arrow_back_rounded,
                                        color: Color(0xFF15161E),
                                        size: 30.0,
                                      ),
                                      onPressed: () async {
                                        _model.currentStep = 1;
                                        safeSetState(() {});
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ].addToStart(SizedBox(height: 12.0)),
            ),
          ),
        ),
      ),
    );
  }
}
