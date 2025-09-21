import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PINPageModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.currentStep = 1;
      _model.pinInput = [].toList().cast<String>();
      _model.joinedPin = "";
      _model.confirmedPinInput = [].toList().cast<String>();
      _model.joinedPinConfirm = "";
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
        backgroundColor: Color(0x001D2428),
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(),
                child: Padding(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(24.0, 20.0, 24.0, 40.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lock_outline,
                                color: FlutterFlowTheme.of(context).primary,
                                size: 80.0,
                              ),
                              Text(
                                'ENTER PIN',
                                textAlign: TextAlign.center,
                                style: FlutterFlowTheme.of(context)
                                    .headlineMedium
                                    .override(
                                      font: GoogleFonts.interTight(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .headlineMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .headlineMedium
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .headlineMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .headlineMedium
                                          .fontStyle,
                                    ),
                              ),
                              Stack(
                                children: [
                                  if (_model.currentStep == 1)
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 20.0, 0.0, 40.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if ((List<String> pinList) {
                                            return pinList.length >= 1;
                                          }(_model.pinInput.toList()))
                                            Align(
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: AnimatedContainer(
                                                duration:
                                                    Duration(milliseconds: 200),
                                                curve: Curves.easeInOut,
                                                width: 16.0,
                                                height: 16.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  shape: BoxShape.circle,
                                                ),
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                              ),
                                            ),
                                          if ((List<String> pinList) {
                                            return pinList.length >= 2;
                                          }(_model.pinInput.toList()))
                                            Align(
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: AnimatedContainer(
                                                duration:
                                                    Duration(milliseconds: 200),
                                                curve: Curves.easeIn,
                                                width: 16.0,
                                                height: 16.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  shape: BoxShape.circle,
                                                ),
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                              ),
                                            ),
                                          if ((List<String> pinList) {
                                            return pinList.length >= 3;
                                          }(_model.pinInput.toList()))
                                            Align(
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: AnimatedContainer(
                                                duration:
                                                    Duration(milliseconds: 200),
                                                curve: Curves.easeIn,
                                                width: 16.0,
                                                height: 16.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  shape: BoxShape.circle,
                                                ),
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                              ),
                                            ),
                                          if ((List<String> pinList) {
                                            return pinList.length >= 4;
                                          }(_model.pinInput.toList()))
                                            Align(
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: AnimatedContainer(
                                                duration:
                                                    Duration(milliseconds: 200),
                                                curve: Curves.easeIn,
                                                width: 16.0,
                                                height: 16.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  shape: BoxShape.circle,
                                                ),
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                              ),
                                            ),
                                          if ((List<String> pinList) {
                                            return pinList.length >= 5;
                                          }(_model.pinInput.toList()))
                                            Align(
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: AnimatedContainer(
                                                duration:
                                                    Duration(milliseconds: 200),
                                                curve: Curves.easeIn,
                                                width: 16.0,
                                                height: 16.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  shape: BoxShape.circle,
                                                ),
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                              ),
                                            ),
                                          if ((List<String> pinList) {
                                            return pinList.length >= 6;
                                          }(_model.pinInput.toList()))
                                            Align(
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: AnimatedContainer(
                                                duration:
                                                    Duration(milliseconds: 200),
                                                curve: Curves.easeIn,
                                                width: 16.0,
                                                height: 16.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  shape: BoxShape.circle,
                                                ),
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                              ),
                                            ),
                                          if ((List<String> pinList) {
                                            return pinList.length >= 7;
                                          }(_model.pinInput.toList()))
                                            Align(
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: AnimatedContainer(
                                                duration:
                                                    Duration(milliseconds: 200),
                                                curve: Curves.easeIn,
                                                width: 16.0,
                                                height: 16.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  shape: BoxShape.circle,
                                                ),
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                              ),
                                            ),
                                          if ((List<String> pinList) {
                                            return pinList.length >= 8;
                                          }(_model.pinInput.toList()))
                                            Align(
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: AnimatedContainer(
                                                duration:
                                                    Duration(milliseconds: 200),
                                                curve: Curves.easeIn,
                                                width: 16.0,
                                                height: 16.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  shape: BoxShape.circle,
                                                ),
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                              ),
                                            ),
                                        ].divide(SizedBox(width: 16.0)),
                                      ),
                                    ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 20.0, 0.0, 40.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Align(
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          child: AnimatedContainer(
                                            duration:
                                                Duration(milliseconds: 200),
                                            curve: Curves.easeInOut,
                                            width: 16.0,
                                            height: 16.0,
                                            decoration: BoxDecoration(
                                              color: Color(0x001D2428),
                                              shape: BoxShape.circle,
                                            ),
                                            alignment:
                                                AlignmentDirectional(0.0, 0.0),
                                          ),
                                        ),
                                        Align(
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          child: AnimatedContainer(
                                            duration:
                                                Duration(milliseconds: 200),
                                            curve: Curves.easeIn,
                                            width: 16.0,
                                            height: 16.0,
                                            decoration: BoxDecoration(
                                              color: Color(0x001D2428),
                                              shape: BoxShape.circle,
                                            ),
                                            alignment:
                                                AlignmentDirectional(0.0, 0.0),
                                          ),
                                        ),
                                        Align(
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          child: AnimatedContainer(
                                            duration:
                                                Duration(milliseconds: 200),
                                            curve: Curves.easeIn,
                                            width: 16.0,
                                            height: 16.0,
                                            decoration: BoxDecoration(
                                              color: Color(0x001D2428),
                                              shape: BoxShape.circle,
                                            ),
                                            alignment:
                                                AlignmentDirectional(0.0, 0.0),
                                          ),
                                        ),
                                        Align(
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          child: AnimatedContainer(
                                            duration:
                                                Duration(milliseconds: 200),
                                            curve: Curves.easeIn,
                                            width: 16.0,
                                            height: 16.0,
                                            decoration: BoxDecoration(
                                              color: Color(0x001D2428),
                                              shape: BoxShape.circle,
                                            ),
                                            alignment:
                                                AlignmentDirectional(0.0, 0.0),
                                          ),
                                        ),
                                        Align(
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          child: AnimatedContainer(
                                            duration:
                                                Duration(milliseconds: 200),
                                            curve: Curves.easeIn,
                                            width: 16.0,
                                            height: 16.0,
                                            decoration: BoxDecoration(
                                              color: Color(0x001D2428),
                                              shape: BoxShape.circle,
                                            ),
                                            alignment:
                                                AlignmentDirectional(0.0, 0.0),
                                          ),
                                        ),
                                        Align(
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          child: AnimatedContainer(
                                            duration:
                                                Duration(milliseconds: 200),
                                            curve: Curves.easeIn,
                                            width: 16.0,
                                            height: 16.0,
                                            decoration: BoxDecoration(
                                              color: Color(0x001D2428),
                                              shape: BoxShape.circle,
                                            ),
                                            alignment:
                                                AlignmentDirectional(0.0, 0.0),
                                          ),
                                        ),
                                        Align(
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          child: AnimatedContainer(
                                            duration:
                                                Duration(milliseconds: 200),
                                            curve: Curves.easeIn,
                                            width: 16.0,
                                            height: 16.0,
                                            decoration: BoxDecoration(
                                              color: Color(0x001D2428),
                                              shape: BoxShape.circle,
                                            ),
                                            alignment:
                                                AlignmentDirectional(0.0, 0.0),
                                          ),
                                        ),
                                        Align(
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          child: AnimatedContainer(
                                            duration:
                                                Duration(milliseconds: 200),
                                            curve: Curves.easeIn,
                                            width: 16.0,
                                            height: 16.0,
                                            decoration: BoxDecoration(
                                              color: Color(0x001D2428),
                                              shape: BoxShape.circle,
                                            ),
                                            alignment:
                                                AlignmentDirectional(0.0, 0.0),
                                          ),
                                        ),
                                      ].divide(SizedBox(width: 16.0)),
                                    ),
                                  ),
                                ],
                              ),
                            ].divide(SizedBox(height: 16.0)),
                          ),
                        ].divide(SizedBox(height: 32.0)),
                      ),
                      Expanded(
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
                                if (_model.pinInput.toList().length > 8) {
                                  _model.removeAtIndexFromPinInput(
                                      _model.pinInput.toList().length - 1);
                                  safeSetState(() {});
                                }
                              },
                              text: '1',
                              options: FFButtonOptions(
                                height: 40.0,
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 0.0, 16.0, 0.0),
                                iconPadding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                color: FlutterFlowTheme.of(context).primary,
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      font: GoogleFonts.interTight(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                elevation: 2.0,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            FFButtonWidget(
                              onPressed: () async {
                                // Add2
                                _model.addToPinInput('2');
                                safeSetState(() {});
                                if (_model.pinInput.toList().length > 8) {
                                  _model.removeAtIndexFromPinInput(
                                      _model.pinInput.toList().length - 1);
                                  safeSetState(() {});
                                }
                              },
                              text: '2',
                              options: FFButtonOptions(
                                height: 40.0,
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 0.0, 16.0, 0.0),
                                iconPadding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                color: FlutterFlowTheme.of(context).primary,
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      font: GoogleFonts.interTight(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                elevation: 2.0,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            FFButtonWidget(
                              onPressed: () async {
                                // Add3
                                _model.addToPinInput('3');
                                safeSetState(() {});
                                if (_model.pinInput.toList().length > 8) {
                                  _model.removeAtIndexFromPinInput(
                                      _model.pinInput.toList().length - 1);
                                  safeSetState(() {});
                                }
                              },
                              text: '3',
                              options: FFButtonOptions(
                                height: 40.0,
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 0.0, 16.0, 0.0),
                                iconPadding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                color: FlutterFlowTheme.of(context).primary,
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      font: GoogleFonts.interTight(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                elevation: 2.0,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            FFButtonWidget(
                              onPressed: () async {
                                // Add4
                                _model.addToPinInput('4');
                                safeSetState(() {});
                                if (_model.pinInput.toList().length > 8) {
                                  _model.removeAtIndexFromPinInput(
                                      _model.pinInput.toList().length - 1);
                                  safeSetState(() {});
                                }
                              },
                              text: '4',
                              options: FFButtonOptions(
                                height: 40.0,
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 0.0, 16.0, 0.0),
                                iconPadding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                color: FlutterFlowTheme.of(context).primary,
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      font: GoogleFonts.interTight(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                elevation: 2.0,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            FFButtonWidget(
                              onPressed: () async {
                                // Add5
                                _model.addToPinInput('5');
                                safeSetState(() {});
                                if (_model.pinInput.toList().length > 8) {
                                  _model.removeAtIndexFromPinInput(
                                      _model.pinInput.toList().length - 1);
                                  safeSetState(() {});
                                }
                              },
                              text: '5',
                              options: FFButtonOptions(
                                height: 40.0,
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 0.0, 16.0, 0.0),
                                iconPadding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                color: FlutterFlowTheme.of(context).primary,
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      font: GoogleFonts.interTight(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                elevation: 2.0,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            FFButtonWidget(
                              onPressed: () async {
                                // Add6
                                _model.addToPinInput('6');
                                safeSetState(() {});
                                if (_model.pinInput.toList().length > 8) {
                                  _model.removeAtIndexFromPinInput(
                                      _model.pinInput.toList().length - 1);
                                  safeSetState(() {});
                                }
                              },
                              text: '6',
                              options: FFButtonOptions(
                                height: 40.0,
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 0.0, 16.0, 0.0),
                                iconPadding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                color: FlutterFlowTheme.of(context).primary,
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      font: GoogleFonts.interTight(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                elevation: 2.0,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            FFButtonWidget(
                              onPressed: () async {
                                // Add7
                                _model.addToPinInput('7');
                                safeSetState(() {});
                                if (_model.pinInput.toList().length > 8) {
                                  _model.removeAtIndexFromPinInput(
                                      _model.pinInput.toList().length - 1);
                                  safeSetState(() {});
                                }
                              },
                              text: '7',
                              options: FFButtonOptions(
                                height: 40.0,
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 0.0, 16.0, 0.0),
                                iconPadding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                color: FlutterFlowTheme.of(context).primary,
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      font: GoogleFonts.interTight(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                elevation: 2.0,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            FFButtonWidget(
                              onPressed: () async {
                                // Add8
                                _model.addToPinInput('8');
                                safeSetState(() {});
                                if (_model.pinInput.toList().length > 8) {
                                  _model.removeAtIndexFromPinInput(
                                      _model.pinInput.toList().length - 1);
                                  safeSetState(() {});
                                }
                              },
                              text: '8',
                              options: FFButtonOptions(
                                height: 40.0,
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 0.0, 16.0, 0.0),
                                iconPadding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                color: FlutterFlowTheme.of(context).primary,
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      font: GoogleFonts.interTight(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                elevation: 2.0,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            FFButtonWidget(
                              onPressed: () async {
                                // Add9
                                _model.addToPinInput('9');
                                safeSetState(() {});
                                if (_model.pinInput.toList().length > 8) {
                                  _model.removeAtIndexFromPinInput(
                                      _model.pinInput.toList().length - 1);
                                  safeSetState(() {});
                                }
                              },
                              text: '9',
                              options: FFButtonOptions(
                                height: 40.0,
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 0.0, 16.0, 0.0),
                                iconPadding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                color: FlutterFlowTheme.of(context).primary,
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      font: GoogleFonts.interTight(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                elevation: 2.0,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            FFButtonWidget(
                              onPressed: () async {
                                FFAppState().fakeSeeded = false;
                                FFAppState().fakeBtcBalance = 0.0;
                                FFAppState().fakeUsdValue = 0.0;
                                safeSetState(() {});
                              },
                              text: '',
                              options: FFButtonOptions(
                                height: 40.0,
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 0.0, 16.0, 0.0),
                                iconPadding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                color: Color(0x001D2428),
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      font: GoogleFonts.interTight(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontStyle,
                                      ),
                                      color: Color(0xFF1D2428),
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                elevation: 0.0,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            FFButtonWidget(
                              onPressed: () async {
                                // Add0
                                _model.addToPinInput('0');
                                safeSetState(() {});
                                if (_model.pinInput.toList().length > 8) {
                                  _model.removeAtIndexFromPinInput(
                                      _model.pinInput.toList().length - 1);
                                  safeSetState(() {});
                                }
                              },
                              text: '0',
                              options: FFButtonOptions(
                                height: 40.0,
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 0.0, 16.0, 0.0),
                                iconPadding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                color: FlutterFlowTheme.of(context).primary,
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      font: GoogleFonts.interTight(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                elevation: 2.0,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            FlutterFlowIconButton(
                              borderRadius: 35.0,
                              buttonSize: 70.0,
                              icon: Icon(
                                Icons.backspace_outlined,
                                color: FlutterFlowTheme.of(context)
                                    .primaryBackground,
                                size: 28.0,
                              ),
                              onPressed: () async {
                                // RemoveFromList
                                _model.removeAtIndexFromPinInput(
                                    _model.pinInput.toList().length - 1);
                                safeSetState(() {});
                              },
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(0.0, 1.0),
                        child: FFButtonWidget(
                          onPressed: () async {
                            if (_model.pinInput.length >= 4) {
                              _model.joinedPin = functions
                                  .newCustomFunction(_model.pinInput.toList());
                              safeSetState(() {});
                              if (_model.joinedPin == '24715382') {
                                context.goNamed(DuressHomePageWidget.routeName);
                              } else {
                                _model.hashedLoginPIN = await actions.hashPin(
                                  _model.joinedPin!,
                                );
                                _model.matchingPINEntry =
                                    await DecoyWalletTable().queryRows(
                                  queryFn: (q) => q.eqOrNull(
                                    'encrypted_pin',
                                    _model.hashedLoginPIN,
                                  ),
                                );
                                if (_model.matchingPINEntry!.length > 0) {
                                  context.pushNamed(HomePageWidget.routeName);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Invalid PIN Entry. Please Retry.',
                                        style: GoogleFonts.roboto(
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      duration: Duration(milliseconds: 4000),
                                      backgroundColor:
                                          FlutterFlowTheme.of(context)
                                              .secondary,
                                    ),
                                  );
                                  _model.joinedPin = "";
                                  safeSetState(() {});
                                  _model.pinInput = [].toList().cast<String>();
                                  safeSetState(() {});
                                }
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Please enter at least 4 digits to continue',
                                    style: GoogleFonts.roboto(
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  duration: Duration(milliseconds: 4000),
                                  backgroundColor:
                                      FlutterFlowTheme.of(context).secondary,
                                ),
                              );
                            }

                            safeSetState(() {});
                          },
                          text: 'Enter',
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: 50.0,
                            padding: EdgeInsets.all(0.0),
                            iconPadding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: FlutterFlowTheme.of(context).primary,
                            textStyle: FlutterFlowTheme.of(context)
                                .titleMedium
                                .override(
                                  font: GoogleFonts.interTight(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .fontStyle,
                                  ),
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .fontStyle,
                                ),
                            elevation: 3.0,
                            borderSide: BorderSide(
                              color: Colors.transparent,
                            ),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
