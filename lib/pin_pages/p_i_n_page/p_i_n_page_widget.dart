import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'p_i_n_page_model.dart';
export 'p_i_n_page_model.dart';

/// I want a PIN code page where the user is propted to create a pin to enter
/// to the home page.
///
/// I want the pin to be custom built
class PINPageWidget extends StatefulWidget {
  const PINPageWidget({super.key});

  static String routeName = 'PINPage';
  static String routePath = '/PINPage';

  @override
  State<PINPageWidget> createState() => _PINPageWidgetState();
}

class _PINPageWidgetState extends State<PINPageWidget> {
  late PINPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  LatLng? currentUserLocationValue;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PINPageModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (FFAppState().hasActiveSubscription == false) {
        context.pushNamed(HomePageWidget.routeName);
      } else {
        _model.currentStep = 1;
        _model.pinInput = [].toList().cast<String>();
        _model.joinedPin = "";
        _model.confirmedPinInput = [].toList().cast<String>();
        _model.joinedPinConfirm = "";
        _model.ppNotificationValue = 0;
        safeSetState(() {});
      }
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
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: PopScope(
        canPop: false,
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: Color(0x001D2428),
          body: SafeArea(
            top: true,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Align(
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: Container(
                        width: 400.0,
                        decoration: BoxDecoration(),
                        child: Align(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                18.0, 20.0, 18.0, 40.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Align(
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.lock_outline,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              size: 80.0,
                                            ),
                                            Container(
                                              width: double.infinity,
                                              height: 70.0,
                                              decoration: BoxDecoration(),
                                              child: Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: Text(
                                                  'ENTER PIN',
                                                  textAlign: TextAlign.center,
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .headlineMedium
                                                      .override(
                                                        fontFamily:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .headlineMediumFamily,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .info,
                                                        letterSpacing: 0.0,
                                                        useGoogleFonts:
                                                            !FlutterFlowTheme
                                                                    .of(context)
                                                                .headlineMediumIsCustom,
                                                      ),
                                                ),
                                              ),
                                            ),
                                            Column(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Stack(
                                                  children: [
                                                    if (_model.currentStep == 1)
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
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
                                                                      0.0, 0.0),
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
                                                                      0.0, 0.0),
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
                                                                      0.0, 0.0),
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
                                                                      0.0, 0.0),
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
                                                                      0.0, 0.0),
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
                                                                      0.0, 0.0),
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
                                                                      0.0, 0.0),
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
                                                              color: Color(
                                                                  0x001D2428),
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
                                                              color: Color(
                                                                  0x001D2428),
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
                                                              color: Color(
                                                                  0x001D2428),
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
                                                              color: Color(
                                                                  0x001D2428),
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
                                                              color: Color(
                                                                  0x001D2428),
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
                                                              color: Color(
                                                                  0x001D2428),
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
                                                              color: Color(
                                                                  0x001D2428),
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
                                                              color: Color(
                                                                  0x001D2428),
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
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Expanded(
                                              child: Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 34.0,
                                                  decoration: BoxDecoration(),
                                                  child: Stack(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, 0.0),
                                                    children: [
                                                      if (_model
                                                              .ppNotificationValue
                                                              .toString() ==
                                                          '1')
                                                        Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0.0, 0.0),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        0.0,
                                                                        0.0,
                                                                        20.0),
                                                            child: Text(
                                                              'PLEASE ENTER AT LEAST FOUR DIGITS',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        FlutterFlowTheme.of(context)
                                                                            .bodyMediumFamily,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    useGoogleFonts:
                                                                        !FlutterFlowTheme.of(context)
                                                                            .bodyMediumIsCustom,
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                      if (_model
                                                              .ppNotificationValue
                                                              .toString() ==
                                                          '2')
                                                        Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0.0, 0.0),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        0.0,
                                                                        0.0,
                                                                        20.0),
                                                            child: Text(
                                                              'INVALID PIN - TRY AGAIN',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        FlutterFlowTheme.of(context)
                                                                            .bodyMediumFamily,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    useGoogleFonts:
                                                                        !FlutterFlowTheme.of(context)
                                                                            .bodyMediumIsCustom,
                                                                  ),
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
                                    ].divide(SizedBox(height: 32.0)),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: AlignmentDirectional(0.0, -1.0),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          6.0, 0.0, 6.0, 36.0),
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
                                                _model
                                                    .removeAtIndexFromPinInput(
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
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      16.0, 0.0, 16.0, 0.0),
                                              iconPadding: EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 0.0, 0.0, 0.0),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              textStyle: FlutterFlowTheme.of(
                                                      context)
                                                  .titleSmall
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmallFamily,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    letterSpacing: 0.0,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmallIsCustom,
                                                  ),
                                              elevation: 2.0,
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
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
                                                _model
                                                    .removeAtIndexFromPinInput(
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
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      16.0, 0.0, 16.0, 0.0),
                                              iconPadding: EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 0.0, 0.0, 0.0),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              textStyle: FlutterFlowTheme.of(
                                                      context)
                                                  .titleSmall
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmallFamily,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    letterSpacing: 0.0,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmallIsCustom,
                                                  ),
                                              elevation: 2.0,
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
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
                                                _model
                                                    .removeAtIndexFromPinInput(
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
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      16.0, 0.0, 16.0, 0.0),
                                              iconPadding: EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 0.0, 0.0, 0.0),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              textStyle: FlutterFlowTheme.of(
                                                      context)
                                                  .titleSmall
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmallFamily,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    letterSpacing: 0.0,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmallIsCustom,
                                                  ),
                                              elevation: 2.0,
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
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
                                                _model
                                                    .removeAtIndexFromPinInput(
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
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      16.0, 0.0, 16.0, 0.0),
                                              iconPadding: EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 0.0, 0.0, 0.0),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              textStyle: FlutterFlowTheme.of(
                                                      context)
                                                  .titleSmall
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmallFamily,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    letterSpacing: 0.0,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmallIsCustom,
                                                  ),
                                              elevation: 2.0,
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
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
                                                _model
                                                    .removeAtIndexFromPinInput(
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
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      16.0, 0.0, 16.0, 0.0),
                                              iconPadding: EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 0.0, 0.0, 0.0),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              textStyle: FlutterFlowTheme.of(
                                                      context)
                                                  .titleSmall
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmallFamily,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    letterSpacing: 0.0,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmallIsCustom,
                                                  ),
                                              elevation: 2.0,
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
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
                                                _model
                                                    .removeAtIndexFromPinInput(
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
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      16.0, 0.0, 16.0, 0.0),
                                              iconPadding: EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 0.0, 0.0, 0.0),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              textStyle: FlutterFlowTheme.of(
                                                      context)
                                                  .titleSmall
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmallFamily,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    letterSpacing: 0.0,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmallIsCustom,
                                                  ),
                                              elevation: 2.0,
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
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
                                                _model
                                                    .removeAtIndexFromPinInput(
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
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      16.0, 0.0, 16.0, 0.0),
                                              iconPadding: EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 0.0, 0.0, 0.0),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              textStyle: FlutterFlowTheme.of(
                                                      context)
                                                  .titleSmall
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmallFamily,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    letterSpacing: 0.0,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmallIsCustom,
                                                  ),
                                              elevation: 2.0,
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
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
                                                _model
                                                    .removeAtIndexFromPinInput(
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
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      16.0, 0.0, 16.0, 0.0),
                                              iconPadding: EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 0.0, 0.0, 0.0),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              textStyle: FlutterFlowTheme.of(
                                                      context)
                                                  .titleSmall
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmallFamily,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    letterSpacing: 0.0,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmallIsCustom,
                                                  ),
                                              elevation: 2.0,
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
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
                                                _model
                                                    .removeAtIndexFromPinInput(
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
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      16.0, 0.0, 16.0, 0.0),
                                              iconPadding: EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 0.0, 0.0, 0.0),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              textStyle: FlutterFlowTheme.of(
                                                      context)
                                                  .titleSmall
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmallFamily,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    letterSpacing: 0.0,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmallIsCustom,
                                                  ),
                                              elevation: 2.0,
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                          ),
                                          FFButtonWidget(
                                            onPressed: () async {
                                              safeSetState(() {});
                                            },
                                            text: '',
                                            options: FFButtonOptions(
                                              height: 40.0,
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      16.0, 0.0, 16.0, 0.0),
                                              iconPadding: EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 0.0, 0.0, 0.0),
                                              color: Color(0x001D2428),
                                              textStyle: FlutterFlowTheme.of(
                                                      context)
                                                  .titleSmall
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmallFamily,
                                                    color: Color(0xFF1D2428),
                                                    letterSpacing: 0.0,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmallIsCustom,
                                                  ),
                                              elevation: 0.0,
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
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
                                                _model
                                                    .removeAtIndexFromPinInput(
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
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      16.0, 0.0, 16.0, 0.0),
                                              iconPadding: EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 0.0, 0.0, 0.0),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              textStyle: FlutterFlowTheme.of(
                                                      context)
                                                  .titleSmall
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmallFamily,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    letterSpacing: 0.0,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmallIsCustom,
                                                  ),
                                              elevation: 2.0,
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                          ),
                                          FlutterFlowIconButton(
                                            borderRadius: 35.0,
                                            buttonSize: 70.0,
                                            icon: Icon(
                                              Icons.backspace_outlined,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                              size: 28.0,
                                            ),
                                            onPressed: () async {
                                              // RemoveFromList
                                              _model.removeAtIndexFromPinInput(
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
                                ),
                                Align(
                                  alignment: AlignmentDirectional(0.0, 1.0),
                                  child: FutureBuilder<List<DecoyWalletRow>>(
                                    future: DecoyWalletTable().querySingleRow(
                                      queryFn: (q) => q.eqOrNull(
                                        'user_id',
                                        currentUserUid,
                                      ),
                                    ),
                                    builder: (context, snapshot) {
                                      // Customize what your widget looks like when it's loading.
                                      if (!snapshot.hasData) {
                                        return Center(
                                          child: LinearProgressIndicator(
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                          ),
                                        );
                                      }
                                      List<DecoyWalletRow>
                                          buttonDecoyWalletRowList =
                                          snapshot.data!;

                                      final buttonDecoyWalletRow =
                                          buttonDecoyWalletRowList.isNotEmpty
                                              ? buttonDecoyWalletRowList.first
                                              : null;

                                      return FFButtonWidget(
                                        onPressed: () async {
                                          currentUserLocationValue =
                                              await getCurrentUserLocation(
                                                  defaultLocation:
                                                      LatLng(0.0, 0.0));
                                          if (_model.pinInput.length >= 4) {
                                            _model.joinedPin =
                                                functions.newCustomFunction(
                                                    _model.pinInput.toList());
                                            safeSetState(() {});
                                            _model.verifyResp =
                                                await VerifyPINCall.call(
                                              pin: _model.joinedPin,
                                              jwt: currentJwtToken,
                                            );

                                            if (VerifyPINCall.ok(
                                                  (_model.verifyResp
                                                          ?.jsonBody ??
                                                      ''),
                                                ) ==
                                                true) {
                                              if (VerifyPINCall.isDecoy(
                                                    (_model.verifyResp
                                                            ?.jsonBody ??
                                                        ''),
                                                  ) ==
                                                  true) {
                                                if (buttonDecoyWalletRow
                                                        ?.useCurrentLocation ==
                                                    true) {
                                                  _model.emergencyLocation =
                                                      currentUserLocationValue;
                                                  safeSetState(() {});
                                                }
                                                _model.joinedPin = "";
                                                safeSetState(() {});
                                                _model.pinInput =
                                                    [].toList().cast<String>();
                                                safeSetState(() {});
                                                _model.walletRow =
                                                    await DecoyWalletTable()
                                                        .queryRows(
                                                  queryFn: (q) => q
                                                      .eqOrNull(
                                                        'user_id',
                                                        currentUserUid,
                                                      )
                                                      .order('updated_at'),
                                                );
                                                _model.dataKeyB64 = await actions
                                                    .generateDataKeyIfMissing();
                                                _model.keyOut =
                                                    _model.dataKeyB64;
                                                safeSetState(() {});
                                                _model.contactObj =
                                                    await actions
                                                        .aesGcmDecryptToMap(
                                                  _model.walletRow!
                                                      .elementAtOrNull(0)!
                                                      .contactsCiphertext!,
                                                  _model.walletRow!
                                                      .elementAtOrNull(0)!
                                                      .contactsNonce!,
                                                  _model.dataKeyB64!,
                                                );
                                                _model.personalObj =
                                                    await actions
                                                        .aesGcmDecryptToMap(
                                                  _model.walletRow!
                                                      .elementAtOrNull(0)!
                                                      .personalCiphertext!,
                                                  _model.walletRow!
                                                      .elementAtOrNull(0)!
                                                      .personalNonce!,
                                                  _model.dataKeyB64!,
                                                );
                                                if (FFAppState()
                                                        .hasActiveSubscription ==
                                                    false) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Bitcoin payment confirming. Full protection activates after confirmation.',
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
                                                  if ((FFAppState()
                                                              .fakeSeeded ==
                                                          false) ||
                                                      (FFAppState()
                                                              .fakeBtcBalance <=
                                                          0.0)) {
                                                    FFAppState()
                                                            .fakeBtcBalance =
                                                        functions.randomBtc(
                                                            1.0, 5.0, 8);
                                                    FFAppState().fakeSeeded =
                                                        true;
                                                    safeSetState(() {});
                                                  }

                                                  context.goNamed(
                                                      DuressHomePageWidget
                                                          .routeName);
                                                } else {
                                                  if (FFAppState()
                                                          .decoyPinContactsEnabled ==
                                                      true) {
                                                    if (FFAppState()
                                                            .hasActiveSubscription ==
                                                        true) {
                                                      if (_model.walletRow
                                                              ?.elementAtOrNull(
                                                                  0)
                                                              ?.contactsComplete ==
                                                          true) {
                                                        unawaited(
                                                          () async {
                                                            _model.alertResult1 =
                                                                await DecoyAlertGroup
                                                                    .sendEmergencyAlertsCall
                                                                    .call(
                                                              userId:
                                                                  currentUserUid,
                                                              triggerId:
                                                                  'PIN_DECOY',
                                                              lat: functions
                                                                  .latFromLatLng(
                                                                      _model
                                                                          .emergencyLocation),
                                                              lng: functions
                                                                  .lngFromLatLng(
                                                                      _model
                                                                          .emergencyLocation),
                                                              contactsJson:
                                                                  getJsonField(
                                                                _model
                                                                    .contactObj,
                                                                r'''$.contacts''',
                                                              ),
                                                              ownerName: (String
                                                                          firstName,
                                                                      String
                                                                          lastName) {
                                                                return firstName +
                                                                    " " +
                                                                    lastName;
                                                              }(
                                                                  getJsonField(
                                                                    _model
                                                                        .personalObj,
                                                                    r'''$.firstName''',
                                                                  ).toString(),
                                                                  getJsonField(
                                                                    _model
                                                                        .personalObj,
                                                                    r'''$.lastName''',
                                                                  ).toString()),
                                                              jwt:
                                                                  currentJwtToken,
                                                            );
                                                          }(),
                                                        );
                                                      }
                                                    } else {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            'Bitcoin payment confirming. Full protection activates after confirmation.',
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
                                                  if ((FFAppState()
                                                              .fakeSeeded ==
                                                          false) ||
                                                      (FFAppState()
                                                              .fakeBtcBalance <=
                                                          0.0)) {
                                                    FFAppState()
                                                            .fakeBtcBalance =
                                                        functions.randomBtc(
                                                            1.0, 5.0, 8);
                                                    FFAppState().fakeSeeded =
                                                        true;
                                                    safeSetState(() {});
                                                  }

                                                  context.goNamed(
                                                      DuressHomePageWidget
                                                          .routeName);
                                                }
                                              } else {
                                                if (VerifyPINCall.isAccount(
                                                      (_model.verifyResp
                                                              ?.jsonBody ??
                                                          ''),
                                                    ) ==
                                                    true) {
                                                  _model.joinedPin = "";
                                                  safeSetState(() {});
                                                  _model.pinInput = []
                                                      .toList()
                                                      .cast<String>();
                                                  safeSetState(() {});

                                                  context.goNamed(
                                                      HomePageWidget.routeName);
                                                } else {
                                                  _model.joinedPin = "";
                                                  safeSetState(() {});
                                                  _model.pinInput = []
                                                      .toList()
                                                      .cast<String>();
                                                  safeSetState(() {});
                                                  _model.ppNotificationValue =
                                                      2;
                                                  safeSetState(() {});
                                                  await Future.delayed(
                                                    Duration(
                                                      milliseconds: 2000,
                                                    ),
                                                  );
                                                  _model.ppNotificationValue =
                                                      0;
                                                  safeSetState(() {});
                                                }
                                              }
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'ERROR #006 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT',
                                                    style: TextStyle(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
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
                                          } else {
                                            _model.joinedPin = "";
                                            safeSetState(() {});
                                            _model.pinInput =
                                                [].toList().cast<String>();
                                            safeSetState(() {});
                                            _model.ppNotificationValue = 1;
                                            safeSetState(() {});
                                            await Future.delayed(
                                              Duration(
                                                milliseconds: 2000,
                                              ),
                                            );
                                            _model.ppNotificationValue = 0;
                                            safeSetState(() {});
                                          }

                                          safeSetState(() {});
                                        },
                                        text: 'Enter',
                                        options: FFButtonOptions(
                                          width: 400.0,
                                          height: 50.0,
                                          padding: EdgeInsets.all(0.0),
                                          iconPadding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 0.0, 0.0),
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          textStyle: FlutterFlowTheme.of(
                                                  context)
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
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                letterSpacing: 0.0,
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .titleMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleMedium
                                                        .fontStyle,
                                              ),
                                          elevation: 3.0,
                                          borderSide: BorderSide(
                                            color: Colors.transparent,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ].addToStart(SizedBox(height: 12.0)),
            ),
          ),
        ),
      ),
    );
  }
}
