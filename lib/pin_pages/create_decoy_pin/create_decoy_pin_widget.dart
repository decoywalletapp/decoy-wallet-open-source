import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'create_decoy_pin_model.dart';
export 'create_decoy_pin_model.dart';

/// I want a PIN code page where the user is propted to create a pin to enter
/// to the home page.
///
/// I want the pin to be custom built
class CreateDecoyPinWidget extends StatefulWidget {
  const CreateDecoyPinWidget({super.key});

  static String routeName = 'CreateDecoyPin';
  static String routePath = '/createDecoyPin';

  @override
  State<CreateDecoyPinWidget> createState() => _CreateDecoyPinWidgetState();
}

class _CreateDecoyPinWidgetState extends State<CreateDecoyPinWidget> {
  late CreateDecoyPinModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CreateDecoyPinModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.currentStep = 1;
      _model.pinDecoyInput = [].toList().cast<String>();
      _model.joinedPin = "";
      _model.confirmedDecoyPinInput = [].toList().cast<String>();
      _model.joinedPinConfirm = "";
      _model.notificationValue = 0;
      _model.confirmNotificationValue = 0;
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
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF1D2428),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: PopScope(
        canPop: false,
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: Color(0xFF1D2428),
          body: SafeArea(
            top: true,
            child: Align(
              alignment: AlignmentDirectional(0.0, 0.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Stack(
                          children: [
                            Stack(
                              children: [
                                Stack(
                                  children: [
                                    if (_model.currentStep == 1)
                                      Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Container(
                                          width: 400.0,
                                          height: double.infinity,
                                          decoration: BoxDecoration(),
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    18.0, 20.0, 18.0, 40.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Stack(
                                                          children: [
                                                            Align(
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.01,
                                                                      0.0),
                                                              child: Icon(
                                                                Icons
                                                                    .lock_outline,
                                                                color: Color(
                                                                    0xFF001DF7),
                                                                size: 80.0,
                                                              ),
                                                            ),
                                                            Align(
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                              child: Icon(
                                                                Icons
                                                                    .lock_outline,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .error,
                                                                size: 80.0,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0.0, 0.0),
                                                          child: Text(
                                                            'Create a DECOY PIN for Emergency Services',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .headlineMedium
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .headlineMediumFamily,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryBackground,
                                                                  letterSpacing:
                                                                      0.0,
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
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
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
                                                                    height:
                                                                        16.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Color(
                                                                          0x001D2428),
                                                                      shape: BoxShape
                                                                          .circle,
                                                                    ),
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                  ),
                                                                ),
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
                                                                    height:
                                                                        16.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Color(
                                                                          0x001D2428),
                                                                      shape: BoxShape
                                                                          .circle,
                                                                    ),
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                  ),
                                                                ),
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
                                                                    height:
                                                                        16.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Color(
                                                                          0x001D2428),
                                                                      shape: BoxShape
                                                                          .circle,
                                                                    ),
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                  ),
                                                                ),
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
                                                                    height:
                                                                        16.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Color(
                                                                          0x001D2428),
                                                                      shape: BoxShape
                                                                          .circle,
                                                                    ),
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                  ),
                                                                ),
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
                                                                    height:
                                                                        16.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Color(
                                                                          0x001D2428),
                                                                      shape: BoxShape
                                                                          .circle,
                                                                    ),
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                  ),
                                                                ),
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
                                                                    height:
                                                                        16.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Color(
                                                                          0x001D2428),
                                                                      shape: BoxShape
                                                                          .circle,
                                                                    ),
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                  ),
                                                                ),
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
                                                                    height:
                                                                        16.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Color(
                                                                          0x001D2428),
                                                                      shape: BoxShape
                                                                          .circle,
                                                                    ),
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                  ),
                                                                ),
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
                                                                    height:
                                                                        16.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Color(
                                                                          0x001D2428),
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
                                                            if (_model
                                                                    .currentStep ==
                                                                1)
                                                              Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  if ((List<
                                                                          String>
                                                                      pinList) {
                                                                    return pinList
                                                                            .length >=
                                                                        1;
                                                                  }(_model
                                                                      .pinDecoyInput
                                                                      .toList()))
                                                                    Align(
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              0.0,
                                                                              0.0),
                                                                      child:
                                                                          AnimatedContainer(
                                                                        duration:
                                                                            Duration(milliseconds: 200),
                                                                        curve: Curves
                                                                            .easeInOut,
                                                                        width:
                                                                            16.0,
                                                                        height:
                                                                            16.0,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primary,
                                                                          shape:
                                                                              BoxShape.circle,
                                                                        ),
                                                                        alignment: AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                      ),
                                                                    ),
                                                                  if ((List<
                                                                          String>
                                                                      pinList) {
                                                                    return pinList
                                                                            .length >=
                                                                        2;
                                                                  }(_model
                                                                      .pinDecoyInput
                                                                      .toList()))
                                                                    Align(
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              0.0,
                                                                              0.0),
                                                                      child:
                                                                          AnimatedContainer(
                                                                        duration:
                                                                            Duration(milliseconds: 200),
                                                                        curve: Curves
                                                                            .easeIn,
                                                                        width:
                                                                            16.0,
                                                                        height:
                                                                            16.0,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primary,
                                                                          shape:
                                                                              BoxShape.circle,
                                                                        ),
                                                                        alignment: AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                      ),
                                                                    ),
                                                                  if ((List<
                                                                          String>
                                                                      pinList) {
                                                                    return pinList
                                                                            .length >=
                                                                        3;
                                                                  }(_model
                                                                      .pinDecoyInput
                                                                      .toList()))
                                                                    Align(
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              0.0,
                                                                              0.0),
                                                                      child:
                                                                          AnimatedContainer(
                                                                        duration:
                                                                            Duration(milliseconds: 200),
                                                                        curve: Curves
                                                                            .easeIn,
                                                                        width:
                                                                            16.0,
                                                                        height:
                                                                            16.0,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primary,
                                                                          shape:
                                                                              BoxShape.circle,
                                                                        ),
                                                                        alignment: AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                      ),
                                                                    ),
                                                                  if ((List<
                                                                          String>
                                                                      pinList) {
                                                                    return pinList
                                                                            .length >=
                                                                        4;
                                                                  }(_model
                                                                      .pinDecoyInput
                                                                      .toList()))
                                                                    Align(
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              0.0,
                                                                              0.0),
                                                                      child:
                                                                          AnimatedContainer(
                                                                        duration:
                                                                            Duration(milliseconds: 200),
                                                                        curve: Curves
                                                                            .easeIn,
                                                                        width:
                                                                            16.0,
                                                                        height:
                                                                            16.0,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primary,
                                                                          shape:
                                                                              BoxShape.circle,
                                                                        ),
                                                                        alignment: AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                      ),
                                                                    ),
                                                                  if ((List<
                                                                          String>
                                                                      pinList) {
                                                                    return pinList
                                                                            .length >=
                                                                        5;
                                                                  }(_model
                                                                      .pinDecoyInput
                                                                      .toList()))
                                                                    Align(
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              0.0,
                                                                              0.0),
                                                                      child:
                                                                          AnimatedContainer(
                                                                        duration:
                                                                            Duration(milliseconds: 200),
                                                                        curve: Curves
                                                                            .easeIn,
                                                                        width:
                                                                            16.0,
                                                                        height:
                                                                            16.0,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primary,
                                                                          shape:
                                                                              BoxShape.circle,
                                                                        ),
                                                                        alignment: AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                      ),
                                                                    ),
                                                                  if ((List<
                                                                          String>
                                                                      pinList) {
                                                                    return pinList
                                                                            .length >=
                                                                        6;
                                                                  }(_model
                                                                      .pinDecoyInput
                                                                      .toList()))
                                                                    Align(
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              0.0,
                                                                              0.0),
                                                                      child:
                                                                          AnimatedContainer(
                                                                        duration:
                                                                            Duration(milliseconds: 200),
                                                                        curve: Curves
                                                                            .easeIn,
                                                                        width:
                                                                            16.0,
                                                                        height:
                                                                            16.0,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primary,
                                                                          shape:
                                                                              BoxShape.circle,
                                                                        ),
                                                                        alignment: AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                      ),
                                                                    ),
                                                                  if ((List<
                                                                          String>
                                                                      pinList) {
                                                                    return pinList
                                                                            .length >=
                                                                        7;
                                                                  }(_model
                                                                      .pinDecoyInput
                                                                      .toList()))
                                                                    Align(
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              0.0,
                                                                              0.0),
                                                                      child:
                                                                          AnimatedContainer(
                                                                        duration:
                                                                            Duration(milliseconds: 200),
                                                                        curve: Curves
                                                                            .easeIn,
                                                                        width:
                                                                            16.0,
                                                                        height:
                                                                            16.0,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primary,
                                                                          shape:
                                                                              BoxShape.circle,
                                                                        ),
                                                                        alignment: AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                      ),
                                                                    ),
                                                                  if ((List<
                                                                          String>
                                                                      pinList) {
                                                                    return pinList
                                                                            .length >=
                                                                        8;
                                                                  }(_model
                                                                      .pinDecoyInput
                                                                      .toList()))
                                                                    Align(
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              0.0,
                                                                              0.0),
                                                                      child:
                                                                          AnimatedContainer(
                                                                        duration:
                                                                            Duration(milliseconds: 200),
                                                                        curve: Curves
                                                                            .easeIn,
                                                                        width:
                                                                            16.0,
                                                                        height:
                                                                            16.0,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primary,
                                                                          shape:
                                                                              BoxShape.circle,
                                                                        ),
                                                                        alignment: AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                      ),
                                                                    ),
                                                                ].divide(SizedBox(
                                                                    width:
                                                                        16.0)),
                                                              ),
                                                          ],
                                                        ),
                                                        Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          children: [
                                                            Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Stack(
                                                                  children: [
                                                                    if (_model
                                                                            .notificationValue
                                                                            .toString() ==
                                                                        '0')
                                                                      Align(
                                                                        alignment: AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                        child:
                                                                            Padding(
                                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                                              0.0,
                                                                              0.0,
                                                                              0.0,
                                                                              20.0),
                                                                          child:
                                                                              Text(
                                                                            'Enter a 4 - 8 digit DECOY PIN ',
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style: FlutterFlowTheme.of(context).bodySmall.override(
                                                                                  fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                                                                                  color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FontWeight.w500,
                                                                                  useGoogleFonts: !FlutterFlowTheme.of(context).bodySmallIsCustom,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    if (_model
                                                                            .notificationValue
                                                                            .toString() ==
                                                                        '1')
                                                                      Align(
                                                                        alignment: AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                        child:
                                                                            Padding(
                                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                                              0.0,
                                                                              0.0,
                                                                              0.0,
                                                                              20.0),
                                                                          child:
                                                                              Text(
                                                                            'DECOY PIN CANNOT BE THE SAME AS ACCOUNT ENTRY PIN',
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style: FlutterFlowTheme.of(context).bodySmall.override(
                                                                                  fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                                                                                  color: FlutterFlowTheme.of(context).primary,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FontWeight.w500,
                                                                                  useGoogleFonts: !FlutterFlowTheme.of(context).bodySmallIsCustom,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    if (_model
                                                                            .notificationValue
                                                                            .toString() ==
                                                                        '2')
                                                                      Align(
                                                                        alignment: AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                        child:
                                                                            Padding(
                                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                                              0.0,
                                                                              0.0,
                                                                              0.0,
                                                                              20.0),
                                                                          child:
                                                                              Text(
                                                                            'PLEASE ENTER AT LEAST 4 DIGITS TO CONTINUE',
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style: FlutterFlowTheme.of(context).bodySmall.override(
                                                                                  fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                                                                                  color: FlutterFlowTheme.of(context).primary,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FontWeight.w500,
                                                                                  useGoogleFonts: !FlutterFlowTheme.of(context).bodySmallIsCustom,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    if (_model
                                                                            .confirmNotificationValue ==
                                                                        3)
                                                                      Align(
                                                                        alignment: AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                        child:
                                                                            Padding(
                                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                                              0.0,
                                                                              0.0,
                                                                              0.0,
                                                                              20.0),
                                                                          child:
                                                                              Text(
                                                                            'PINS DO NOT MATCH - PLEASE TRY AGAIN',
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style: FlutterFlowTheme.of(context).bodySmall.override(
                                                                                  fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                                                                                  color: FlutterFlowTheme.of(context).primary,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FontWeight.w500,
                                                                                  useGoogleFonts: !FlutterFlowTheme.of(context).bodySmallIsCustom,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                  ],
                                                                ),
                                                              ].divide(SizedBox(
                                                                  height:
                                                                      24.0)),
                                                            ),
                                                          ],
                                                        ),
                                                      ].divide(SizedBox(
                                                          height: 16.0)),
                                                    ),
                                                  ].divide(
                                                      SizedBox(height: 32.0)),
                                                ),
                                                SizedBox(
                                                  height: 405.0,
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(6.0, 0.0,
                                                                6.0, 0.0),
                                                    child: GridView(
                                                      padding: EdgeInsets.zero,
                                                      physics:
                                                          NeverScrollableScrollPhysics(),
                                                      gridDelegate:
                                                          SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount: 3,
                                                        crossAxisSpacing: 10.0,
                                                        mainAxisSpacing: 10.0,
                                                        childAspectRatio: 1.25,
                                                      ),
                                                      shrinkWrap: true,
                                                      scrollDirection:
                                                          Axis.vertical,
                                                      children: [
                                                        FFButtonWidget(
                                                          onPressed: () async {
                                                            // Add1
                                                            _model
                                                                .addToPinDecoyInput(
                                                                    '1');
                                                            safeSetState(() {});
                                                            if (_model
                                                                    .pinDecoyInput
                                                                    .toList()
                                                                    .length >
                                                                8) {
                                                              _model.removeAtIndexFromPinDecoyInput(_model
                                                                      .pinDecoyInput
                                                                      .toList()
                                                                      .length -
                                                                  1);
                                                              safeSetState(
                                                                  () {});
                                                            }
                                                          },
                                                          text: '1',
                                                          options:
                                                              FFButtonOptions(
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
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            textStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .titleSmallFamily,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryText,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .titleSmallIsCustom,
                                                                    ),
                                                            elevation: 2.0,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12.0),
                                                          ),
                                                        ),
                                                        FFButtonWidget(
                                                          onPressed: () async {
                                                            // Add2
                                                            _model
                                                                .addToPinDecoyInput(
                                                                    '2');
                                                            safeSetState(() {});
                                                            if (_model
                                                                    .pinDecoyInput
                                                                    .toList()
                                                                    .length >
                                                                8) {
                                                              _model.removeAtIndexFromPinDecoyInput(_model
                                                                      .pinDecoyInput
                                                                      .toList()
                                                                      .length -
                                                                  1);
                                                              safeSetState(
                                                                  () {});
                                                            }
                                                          },
                                                          text: '2',
                                                          options:
                                                              FFButtonOptions(
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
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            textStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .titleSmallFamily,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryText,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .titleSmallIsCustom,
                                                                    ),
                                                            elevation: 2.0,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12.0),
                                                          ),
                                                        ),
                                                        FFButtonWidget(
                                                          onPressed: () async {
                                                            // Add3
                                                            _model
                                                                .addToPinDecoyInput(
                                                                    '3');
                                                            safeSetState(() {});
                                                            if (_model
                                                                    .pinDecoyInput
                                                                    .toList()
                                                                    .length >
                                                                8) {
                                                              _model.removeAtIndexFromPinDecoyInput(_model
                                                                      .pinDecoyInput
                                                                      .toList()
                                                                      .length -
                                                                  1);
                                                              safeSetState(
                                                                  () {});
                                                            }
                                                          },
                                                          text: '3',
                                                          options:
                                                              FFButtonOptions(
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
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            textStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .titleSmallFamily,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryText,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .titleSmallIsCustom,
                                                                    ),
                                                            elevation: 2.0,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12.0),
                                                          ),
                                                        ),
                                                        FFButtonWidget(
                                                          onPressed: () async {
                                                            // Add4
                                                            _model
                                                                .addToPinDecoyInput(
                                                                    '4');
                                                            safeSetState(() {});
                                                            if (_model
                                                                    .pinDecoyInput
                                                                    .toList()
                                                                    .length >
                                                                8) {
                                                              _model.removeAtIndexFromPinDecoyInput(_model
                                                                      .pinDecoyInput
                                                                      .toList()
                                                                      .length -
                                                                  1);
                                                              safeSetState(
                                                                  () {});
                                                            }
                                                          },
                                                          text: '4',
                                                          options:
                                                              FFButtonOptions(
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
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            textStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .titleSmallFamily,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryText,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .titleSmallIsCustom,
                                                                    ),
                                                            elevation: 2.0,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                          ),
                                                        ),
                                                        FFButtonWidget(
                                                          onPressed: () async {
                                                            // Add5
                                                            _model
                                                                .addToPinDecoyInput(
                                                                    '5');
                                                            safeSetState(() {});
                                                            if (_model
                                                                    .pinDecoyInput
                                                                    .toList()
                                                                    .length >
                                                                8) {
                                                              _model.removeAtIndexFromPinDecoyInput(_model
                                                                      .pinDecoyInput
                                                                      .toList()
                                                                      .length -
                                                                  1);
                                                              safeSetState(
                                                                  () {});
                                                            }
                                                          },
                                                          text: '5',
                                                          options:
                                                              FFButtonOptions(
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
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            textStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .titleSmallFamily,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryText,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .titleSmallIsCustom,
                                                                    ),
                                                            elevation: 2.0,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                          ),
                                                        ),
                                                        FFButtonWidget(
                                                          onPressed: () async {
                                                            // Add6
                                                            _model
                                                                .addToPinDecoyInput(
                                                                    '6');
                                                            safeSetState(() {});
                                                            if (_model
                                                                    .pinDecoyInput
                                                                    .toList()
                                                                    .length >
                                                                8) {
                                                              _model.removeAtIndexFromPinDecoyInput(_model
                                                                      .pinDecoyInput
                                                                      .toList()
                                                                      .length -
                                                                  1);
                                                              safeSetState(
                                                                  () {});
                                                            }
                                                          },
                                                          text: '6',
                                                          options:
                                                              FFButtonOptions(
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
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            textStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .titleSmallFamily,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryText,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .titleSmallIsCustom,
                                                                    ),
                                                            elevation: 2.0,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                          ),
                                                        ),
                                                        FFButtonWidget(
                                                          onPressed: () async {
                                                            // Add7
                                                            _model
                                                                .addToPinDecoyInput(
                                                                    '7');
                                                            safeSetState(() {});
                                                            if (_model
                                                                    .pinDecoyInput
                                                                    .toList()
                                                                    .length >
                                                                8) {
                                                              _model.removeAtIndexFromPinDecoyInput(_model
                                                                      .pinDecoyInput
                                                                      .toList()
                                                                      .length -
                                                                  1);
                                                              safeSetState(
                                                                  () {});
                                                            }
                                                          },
                                                          text: '7',
                                                          options:
                                                              FFButtonOptions(
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
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            textStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .titleSmallFamily,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryText,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .titleSmallIsCustom,
                                                                    ),
                                                            elevation: 2.0,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                          ),
                                                        ),
                                                        FFButtonWidget(
                                                          onPressed: () async {
                                                            // Add8
                                                            _model
                                                                .addToPinDecoyInput(
                                                                    '8');
                                                            safeSetState(() {});
                                                            if (_model
                                                                    .pinDecoyInput
                                                                    .toList()
                                                                    .length >
                                                                8) {
                                                              _model.removeAtIndexFromPinDecoyInput(_model
                                                                      .pinDecoyInput
                                                                      .toList()
                                                                      .length -
                                                                  1);
                                                              safeSetState(
                                                                  () {});
                                                            }
                                                          },
                                                          text: '8',
                                                          options:
                                                              FFButtonOptions(
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
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            textStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .titleSmallFamily,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryText,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .titleSmallIsCustom,
                                                                    ),
                                                            elevation: 2.0,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                          ),
                                                        ),
                                                        FFButtonWidget(
                                                          onPressed: () async {
                                                            // Add9
                                                            _model
                                                                .addToPinDecoyInput(
                                                                    '9');
                                                            safeSetState(() {});
                                                            if (_model
                                                                    .pinDecoyInput
                                                                    .toList()
                                                                    .length >
                                                                8) {
                                                              _model.removeAtIndexFromPinDecoyInput(_model
                                                                      .pinDecoyInput
                                                                      .toList()
                                                                      .length -
                                                                  1);
                                                              safeSetState(
                                                                  () {});
                                                            }
                                                          },
                                                          text: '9',
                                                          options:
                                                              FFButtonOptions(
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
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            textStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .titleSmallFamily,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryText,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .titleSmallIsCustom,
                                                                    ),
                                                            elevation: 2.0,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                          ),
                                                        ),
                                                        Container(
                                                          width: 100.0,
                                                          height: 100.0,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Color(
                                                                0x001D2428),
                                                          ),
                                                        ),
                                                        FFButtonWidget(
                                                          onPressed: () async {
                                                            // Add0
                                                            _model
                                                                .addToPinDecoyInput(
                                                                    '0');
                                                            safeSetState(() {});
                                                            if (_model
                                                                    .pinDecoyInput
                                                                    .toList()
                                                                    .length >
                                                                8) {
                                                              _model.removeAtIndexFromPinDecoyInput(_model
                                                                      .pinDecoyInput
                                                                      .toList()
                                                                      .length -
                                                                  1);
                                                              safeSetState(
                                                                  () {});
                                                            }
                                                          },
                                                          text: '0',
                                                          options:
                                                              FFButtonOptions(
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
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            textStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .titleSmallFamily,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryText,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .titleSmallIsCustom,
                                                                    ),
                                                            elevation: 2.0,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                          ),
                                                        ),
                                                        FlutterFlowIconButton(
                                                          borderRadius: 35.0,
                                                          buttonSize: 70.0,
                                                          icon: Icon(
                                                            Icons
                                                                .backspace_outlined,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryBackground,
                                                            size: 28.0,
                                                          ),
                                                          onPressed: () async {
                                                            // RemoveFromList
                                                            _model.removeAtIndexFromPinDecoyInput(
                                                                _model.pinDecoyInput
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
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, 1.0),
                                                    child: FFButtonWidget(
                                                      onPressed: () async {
                                                        if (_model.pinDecoyInput
                                                                .length >=
                                                            4) {
                                                          _model.joinedPin = functions
                                                              .newCustomFunction(
                                                                  _model
                                                                      .pinDecoyInput
                                                                      .toList());
                                                          safeSetState(() {});
                                                          _model.verifyMe =
                                                              await VerifyPINCall
                                                                  .call(
                                                            pin: _model
                                                                .joinedPin,
                                                            jwt:
                                                                currentJwtToken,
                                                          );

                                                          if (VerifyPINCall
                                                                  .isAccount(
                                                                (_model.verifyMe
                                                                        ?.jsonBody ??
                                                                    ''),
                                                              ) ==
                                                              true) {
                                                            _model.pinDecoyInput =
                                                                [].toList().cast<
                                                                    String>();
                                                            _model.joinedPin =
                                                                "";
                                                            safeSetState(() {});
                                                            _model.notificationValue =
                                                                1;
                                                            safeSetState(() {});
                                                            await Future
                                                                .delayed(
                                                              Duration(
                                                                milliseconds:
                                                                    2000,
                                                              ),
                                                            );
                                                            _model.notificationValue =
                                                                0;
                                                            safeSetState(() {});
                                                          } else {
                                                            _model.currentStep =
                                                                2;
                                                            safeSetState(() {});
                                                          }
                                                        } else {
                                                          _model.pinDecoyInput =
                                                              [].toList().cast<
                                                                  String>();
                                                          _model.joinedPin = "";
                                                          safeSetState(() {});
                                                          _model.notificationValue =
                                                              2;
                                                          safeSetState(() {});
                                                          await Future.delayed(
                                                            Duration(
                                                              milliseconds:
                                                                  2000,
                                                            ),
                                                          );
                                                          _model.notificationValue =
                                                              0;
                                                          safeSetState(() {});
                                                        }

                                                        safeSetState(() {});
                                                      },
                                                      text: 'Continue',
                                                      options: FFButtonOptions(
                                                        width: double.infinity,
                                                        height: 50.0,
                                                        padding:
                                                            EdgeInsets.all(0.0),
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
                                                                .titleMedium
                                                                .override(
                                                                  font:
                                                                      GoogleFonts
                                                                          .heebo(
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleMedium
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleMedium
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleMedium
                                                                      .fontStyle,
                                                                ),
                                                        elevation: 3.0,
                                                        borderSide: BorderSide(
                                                          color: Colors
                                                              .transparent,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12.0),
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
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Container(
                                          width: 400.0,
                                          height: double.infinity,
                                          decoration: BoxDecoration(),
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    18.0, 20.0, 18.0, 40.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Stack(
                                                          children: [
                                                            Align(
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.01,
                                                                      0.0),
                                                              child: Icon(
                                                                Icons
                                                                    .lock_outline,
                                                                color: Color(
                                                                    0xFF001DF7),
                                                                size: 80.0,
                                                              ),
                                                            ),
                                                            Align(
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                              child: Icon(
                                                                Icons
                                                                    .lock_outline,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .error,
                                                                size: 80.0,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  17.0),
                                                          child: Text(
                                                            'Confirm DECOY PIN',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .headlineMedium
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .headlineMediumFamily,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryBackground,
                                                                  letterSpacing:
                                                                      0.0,
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
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
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
                                                                    height:
                                                                        16.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Color(
                                                                          0x001D2428),
                                                                      shape: BoxShape
                                                                          .circle,
                                                                    ),
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                  ),
                                                                ),
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
                                                                    height:
                                                                        16.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Color(
                                                                          0x001D2428),
                                                                      shape: BoxShape
                                                                          .circle,
                                                                    ),
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                  ),
                                                                ),
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
                                                                    height:
                                                                        16.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Color(
                                                                          0x001D2428),
                                                                      shape: BoxShape
                                                                          .circle,
                                                                    ),
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                  ),
                                                                ),
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
                                                                    height:
                                                                        16.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Color(
                                                                          0x001D2428),
                                                                      shape: BoxShape
                                                                          .circle,
                                                                    ),
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                  ),
                                                                ),
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
                                                                    height:
                                                                        16.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Color(
                                                                          0x001D2428),
                                                                      shape: BoxShape
                                                                          .circle,
                                                                    ),
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                  ),
                                                                ),
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
                                                                    height:
                                                                        16.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Color(
                                                                          0x001D2428),
                                                                      shape: BoxShape
                                                                          .circle,
                                                                    ),
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                  ),
                                                                ),
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
                                                                    height:
                                                                        16.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Color(
                                                                          0x001D2428),
                                                                      shape: BoxShape
                                                                          .circle,
                                                                    ),
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                  ),
                                                                ),
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
                                                                    height:
                                                                        16.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Color(
                                                                          0x001D2428),
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
                                                            if (_model
                                                                    .currentStep ==
                                                                2)
                                                              Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  if ((List<
                                                                          String>
                                                                      pinList2) {
                                                                    return pinList2
                                                                            .length >=
                                                                        1;
                                                                  }(_model
                                                                      .confirmedDecoyPinInput
                                                                      .toList()))
                                                                    Align(
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              0.0,
                                                                              0.0),
                                                                      child:
                                                                          AnimatedContainer(
                                                                        duration:
                                                                            Duration(milliseconds: 200),
                                                                        curve: Curves
                                                                            .easeInOut,
                                                                        width:
                                                                            16.0,
                                                                        height:
                                                                            16.0,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primary,
                                                                          shape:
                                                                              BoxShape.circle,
                                                                        ),
                                                                        alignment: AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                      ),
                                                                    ),
                                                                  if ((List<
                                                                          String>
                                                                      pinList2) {
                                                                    return pinList2
                                                                            .length >=
                                                                        2;
                                                                  }(_model
                                                                      .confirmedDecoyPinInput
                                                                      .toList()))
                                                                    Align(
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              0.0,
                                                                              0.0),
                                                                      child:
                                                                          AnimatedContainer(
                                                                        duration:
                                                                            Duration(milliseconds: 200),
                                                                        curve: Curves
                                                                            .easeIn,
                                                                        width:
                                                                            16.0,
                                                                        height:
                                                                            16.0,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primary,
                                                                          shape:
                                                                              BoxShape.circle,
                                                                        ),
                                                                        alignment: AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                      ),
                                                                    ),
                                                                  if ((List<
                                                                          String>
                                                                      pinList2) {
                                                                    return pinList2
                                                                            .length >=
                                                                        3;
                                                                  }(_model
                                                                      .confirmedDecoyPinInput
                                                                      .toList()))
                                                                    Align(
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              0.0,
                                                                              0.0),
                                                                      child:
                                                                          AnimatedContainer(
                                                                        duration:
                                                                            Duration(milliseconds: 200),
                                                                        curve: Curves
                                                                            .easeIn,
                                                                        width:
                                                                            16.0,
                                                                        height:
                                                                            16.0,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primary,
                                                                          shape:
                                                                              BoxShape.circle,
                                                                        ),
                                                                        alignment: AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                      ),
                                                                    ),
                                                                  if ((List<
                                                                          String>
                                                                      pinList2) {
                                                                    return pinList2
                                                                            .length >=
                                                                        4;
                                                                  }(_model
                                                                      .confirmedDecoyPinInput
                                                                      .toList()))
                                                                    Align(
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              0.0,
                                                                              0.0),
                                                                      child:
                                                                          AnimatedContainer(
                                                                        duration:
                                                                            Duration(milliseconds: 200),
                                                                        curve: Curves
                                                                            .easeIn,
                                                                        width:
                                                                            16.0,
                                                                        height:
                                                                            16.0,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primary,
                                                                          shape:
                                                                              BoxShape.circle,
                                                                        ),
                                                                        alignment: AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                      ),
                                                                    ),
                                                                  if ((List<
                                                                          String>
                                                                      pinList2) {
                                                                    return pinList2
                                                                            .length >=
                                                                        5;
                                                                  }(_model
                                                                      .confirmedDecoyPinInput
                                                                      .toList()))
                                                                    Align(
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              0.0,
                                                                              0.0),
                                                                      child:
                                                                          AnimatedContainer(
                                                                        duration:
                                                                            Duration(milliseconds: 200),
                                                                        curve: Curves
                                                                            .easeIn,
                                                                        width:
                                                                            16.0,
                                                                        height:
                                                                            16.0,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primary,
                                                                          shape:
                                                                              BoxShape.circle,
                                                                        ),
                                                                        alignment: AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                      ),
                                                                    ),
                                                                  if ((List<
                                                                          String>
                                                                      pinList2) {
                                                                    return pinList2
                                                                            .length >=
                                                                        6;
                                                                  }(_model
                                                                      .confirmedDecoyPinInput
                                                                      .toList()))
                                                                    Align(
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              0.0,
                                                                              0.0),
                                                                      child:
                                                                          AnimatedContainer(
                                                                        duration:
                                                                            Duration(milliseconds: 200),
                                                                        curve: Curves
                                                                            .easeIn,
                                                                        width:
                                                                            16.0,
                                                                        height:
                                                                            16.0,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primary,
                                                                          shape:
                                                                              BoxShape.circle,
                                                                        ),
                                                                        alignment: AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                      ),
                                                                    ),
                                                                  if ((List<
                                                                          String>
                                                                      pinList2) {
                                                                    return pinList2
                                                                            .length >=
                                                                        7;
                                                                  }(_model
                                                                      .confirmedDecoyPinInput
                                                                      .toList()))
                                                                    Align(
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              0.0,
                                                                              0.0),
                                                                      child:
                                                                          AnimatedContainer(
                                                                        duration:
                                                                            Duration(milliseconds: 200),
                                                                        curve: Curves
                                                                            .easeIn,
                                                                        width:
                                                                            16.0,
                                                                        height:
                                                                            16.0,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primary,
                                                                          shape:
                                                                              BoxShape.circle,
                                                                        ),
                                                                        alignment: AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                      ),
                                                                    ),
                                                                  if ((List<
                                                                          String>
                                                                      pinList2) {
                                                                    return pinList2
                                                                            .length >=
                                                                        8;
                                                                  }(_model
                                                                      .confirmedDecoyPinInput
                                                                      .toList()))
                                                                    Align(
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              0.0,
                                                                              0.0),
                                                                      child:
                                                                          AnimatedContainer(
                                                                        duration:
                                                                            Duration(milliseconds: 200),
                                                                        curve: Curves
                                                                            .easeIn,
                                                                        width:
                                                                            16.0,
                                                                        height:
                                                                            16.0,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primary,
                                                                          shape:
                                                                              BoxShape.circle,
                                                                        ),
                                                                        alignment: AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                      ),
                                                                    ),
                                                                ].divide(SizedBox(
                                                                    width:
                                                                        16.0)),
                                                              ),
                                                          ],
                                                        ),
                                                        Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          children: [
                                                            Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Stack(
                                                                  children: [
                                                                    if (_model
                                                                            .confirmNotificationValue
                                                                            .toString() ==
                                                                        '0')
                                                                      Align(
                                                                        alignment: AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                        child:
                                                                            Padding(
                                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                                              0.0,
                                                                              0.0,
                                                                              0.0,
                                                                              20.0),
                                                                          child:
                                                                              Text(
                                                                            'Enter the same 4 - 8 digits to confirm your DECOY PIN',
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style: FlutterFlowTheme.of(context).bodySmall.override(
                                                                                  fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                                                                                  color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FontWeight.w500,
                                                                                  useGoogleFonts: !FlutterFlowTheme.of(context).bodySmallIsCustom,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    if (_model
                                                                            .confirmNotificationValue
                                                                            .toString() ==
                                                                        '2')
                                                                      Align(
                                                                        alignment: AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                        child:
                                                                            Padding(
                                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                                              0.0,
                                                                              0.0,
                                                                              0.0,
                                                                              20.0),
                                                                          child:
                                                                              Text(
                                                                            'PIN MUST BE AT LEAST 4 DIGITS',
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style: FlutterFlowTheme.of(context).bodySmall.override(
                                                                                  fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                                                                                  color: FlutterFlowTheme.of(context).primary,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FontWeight.w500,
                                                                                  useGoogleFonts: !FlutterFlowTheme.of(context).bodySmallIsCustom,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                  ],
                                                                ),
                                                              ].divide(SizedBox(
                                                                  height:
                                                                      24.0)),
                                                            ),
                                                          ],
                                                        ),
                                                      ].divide(SizedBox(
                                                          height: 16.0)),
                                                    ),
                                                  ].divide(
                                                      SizedBox(height: 32.0)),
                                                ),
                                                SizedBox(
                                                  height: 405.0,
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(6.0, 0.0,
                                                                6.0, 0.0),
                                                    child: GridView(
                                                      padding: EdgeInsets.zero,
                                                      physics:
                                                          NeverScrollableScrollPhysics(),
                                                      gridDelegate:
                                                          SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount: 3,
                                                        crossAxisSpacing: 10.0,
                                                        mainAxisSpacing: 10.0,
                                                        childAspectRatio: 1.25,
                                                      ),
                                                      shrinkWrap: true,
                                                      scrollDirection:
                                                          Axis.vertical,
                                                      children: [
                                                        FFButtonWidget(
                                                          onPressed: () async {
                                                            // Add1
                                                            _model
                                                                .addToConfirmedDecoyPinInput(
                                                                    '1');
                                                            safeSetState(() {});
                                                            if (_model
                                                                    .confirmedDecoyPinInput
                                                                    .toList()
                                                                    .length >
                                                                8) {
                                                              _model.removeAtIndexFromConfirmedDecoyPinInput(_model
                                                                      .confirmedDecoyPinInput
                                                                      .toList()
                                                                      .length -
                                                                  1);
                                                              safeSetState(
                                                                  () {});
                                                            }
                                                          },
                                                          text: '1',
                                                          options:
                                                              FFButtonOptions(
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
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            textStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .titleSmallFamily,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryText,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .titleSmallIsCustom,
                                                                    ),
                                                            elevation: 2.0,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12.0),
                                                          ),
                                                        ),
                                                        FFButtonWidget(
                                                          onPressed: () async {
                                                            // Add2
                                                            _model
                                                                .addToConfirmedDecoyPinInput(
                                                                    '2');
                                                            safeSetState(() {});
                                                            if (_model
                                                                    .confirmedDecoyPinInput
                                                                    .toList()
                                                                    .length >
                                                                8) {
                                                              _model.removeAtIndexFromConfirmedDecoyPinInput(_model
                                                                      .confirmedDecoyPinInput
                                                                      .toList()
                                                                      .length -
                                                                  1);
                                                              safeSetState(
                                                                  () {});
                                                            }
                                                          },
                                                          text: '2',
                                                          options:
                                                              FFButtonOptions(
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
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            textStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .titleSmallFamily,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryText,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .titleSmallIsCustom,
                                                                    ),
                                                            elevation: 2.0,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12.0),
                                                          ),
                                                        ),
                                                        FFButtonWidget(
                                                          onPressed: () async {
                                                            // Add3
                                                            _model
                                                                .addToConfirmedDecoyPinInput(
                                                                    '3');
                                                            safeSetState(() {});
                                                            if (_model
                                                                    .pinDecoyInput
                                                                    .toList()
                                                                    .length >
                                                                8) {
                                                              _model.removeAtIndexFromConfirmedDecoyPinInput(_model
                                                                      .confirmedDecoyPinInput
                                                                      .toList()
                                                                      .length -
                                                                  1);
                                                              safeSetState(
                                                                  () {});
                                                            }
                                                          },
                                                          text: '3',
                                                          options:
                                                              FFButtonOptions(
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
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            textStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .titleSmallFamily,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryText,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .titleSmallIsCustom,
                                                                    ),
                                                            elevation: 2.0,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12.0),
                                                          ),
                                                        ),
                                                        FFButtonWidget(
                                                          onPressed: () async {
                                                            // Add4
                                                            _model
                                                                .addToConfirmedDecoyPinInput(
                                                                    '4');
                                                            safeSetState(() {});
                                                            if (_model
                                                                    .confirmedDecoyPinInput
                                                                    .toList()
                                                                    .length >
                                                                8) {
                                                              _model.removeAtIndexFromConfirmedDecoyPinInput(_model
                                                                      .confirmedDecoyPinInput
                                                                      .toList()
                                                                      .length -
                                                                  1);
                                                              safeSetState(
                                                                  () {});
                                                            }
                                                          },
                                                          text: '4',
                                                          options:
                                                              FFButtonOptions(
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
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            textStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .titleSmallFamily,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryText,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .titleSmallIsCustom,
                                                                    ),
                                                            elevation: 2.0,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                          ),
                                                        ),
                                                        FFButtonWidget(
                                                          onPressed: () async {
                                                            // Add5
                                                            _model
                                                                .addToConfirmedDecoyPinInput(
                                                                    '5');
                                                            safeSetState(() {});
                                                            if (_model
                                                                    .confirmedDecoyPinInput
                                                                    .toList()
                                                                    .length >
                                                                8) {
                                                              _model.removeAtIndexFromConfirmedDecoyPinInput(_model
                                                                      .confirmedDecoyPinInput
                                                                      .toList()
                                                                      .length -
                                                                  1);
                                                              safeSetState(
                                                                  () {});
                                                            }
                                                          },
                                                          text: '5',
                                                          options:
                                                              FFButtonOptions(
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
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            textStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .titleSmallFamily,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryText,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .titleSmallIsCustom,
                                                                    ),
                                                            elevation: 2.0,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                          ),
                                                        ),
                                                        FFButtonWidget(
                                                          onPressed: () async {
                                                            // Add6
                                                            _model
                                                                .addToConfirmedDecoyPinInput(
                                                                    '6');
                                                            safeSetState(() {});
                                                            if (_model
                                                                    .confirmedDecoyPinInput
                                                                    .toList()
                                                                    .length >
                                                                8) {
                                                              _model.removeAtIndexFromConfirmedDecoyPinInput(_model
                                                                      .confirmedDecoyPinInput
                                                                      .toList()
                                                                      .length -
                                                                  1);
                                                              safeSetState(
                                                                  () {});
                                                            }
                                                          },
                                                          text: '6',
                                                          options:
                                                              FFButtonOptions(
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
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            textStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .titleSmallFamily,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryText,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .titleSmallIsCustom,
                                                                    ),
                                                            elevation: 2.0,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                          ),
                                                        ),
                                                        FFButtonWidget(
                                                          onPressed: () async {
                                                            // Add7
                                                            _model
                                                                .addToConfirmedDecoyPinInput(
                                                                    '7');
                                                            safeSetState(() {});
                                                            if (_model
                                                                    .confirmedDecoyPinInput
                                                                    .toList()
                                                                    .length >
                                                                8) {
                                                              _model.removeAtIndexFromConfirmedDecoyPinInput(_model
                                                                      .confirmedDecoyPinInput
                                                                      .toList()
                                                                      .length -
                                                                  1);
                                                              safeSetState(
                                                                  () {});
                                                            }
                                                          },
                                                          text: '7',
                                                          options:
                                                              FFButtonOptions(
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
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            textStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .titleSmallFamily,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryText,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .titleSmallIsCustom,
                                                                    ),
                                                            elevation: 2.0,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                          ),
                                                        ),
                                                        FFButtonWidget(
                                                          onPressed: () async {
                                                            // Add8
                                                            _model
                                                                .addToConfirmedDecoyPinInput(
                                                                    '8');
                                                            safeSetState(() {});
                                                            if (_model
                                                                    .confirmedDecoyPinInput
                                                                    .toList()
                                                                    .length >
                                                                8) {
                                                              _model.removeAtIndexFromConfirmedDecoyPinInput(_model
                                                                      .confirmedDecoyPinInput
                                                                      .toList()
                                                                      .length -
                                                                  1);
                                                              safeSetState(
                                                                  () {});
                                                            }
                                                          },
                                                          text: '8',
                                                          options:
                                                              FFButtonOptions(
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
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            textStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .titleSmallFamily,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryText,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .titleSmallIsCustom,
                                                                    ),
                                                            elevation: 2.0,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                          ),
                                                        ),
                                                        FFButtonWidget(
                                                          onPressed: () async {
                                                            // Add9
                                                            _model
                                                                .addToConfirmedDecoyPinInput(
                                                                    '9');
                                                            safeSetState(() {});
                                                            if (_model
                                                                    .confirmedDecoyPinInput
                                                                    .toList()
                                                                    .length >
                                                                8) {
                                                              _model.removeAtIndexFromConfirmedDecoyPinInput(_model
                                                                      .confirmedDecoyPinInput
                                                                      .toList()
                                                                      .length -
                                                                  1);
                                                              safeSetState(
                                                                  () {});
                                                            }
                                                          },
                                                          text: '9',
                                                          options:
                                                              FFButtonOptions(
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
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            textStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .titleSmallFamily,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryText,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .titleSmallIsCustom,
                                                                    ),
                                                            elevation: 2.0,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                          ),
                                                        ),
                                                        Container(
                                                          width: 100.0,
                                                          height: 100.0,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Color(
                                                                0x001D2428),
                                                          ),
                                                        ),
                                                        FFButtonWidget(
                                                          onPressed: () async {
                                                            // Add0
                                                            _model
                                                                .addToConfirmedDecoyPinInput(
                                                                    '0');
                                                            safeSetState(() {});
                                                            // Buttons make sure no enteries are greater than 8
                                                            if (_model
                                                                    .confirmedDecoyPinInput
                                                                    .toList()
                                                                    .length >
                                                                8) {
                                                              _model.removeAtIndexFromConfirmedDecoyPinInput(_model
                                                                      .confirmedDecoyPinInput
                                                                      .toList()
                                                                      .length -
                                                                  1);
                                                              safeSetState(
                                                                  () {});
                                                            }
                                                          },
                                                          text: '0',
                                                          options:
                                                              FFButtonOptions(
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
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            textStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .titleSmallFamily,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryText,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .titleSmallIsCustom,
                                                                    ),
                                                            elevation: 2.0,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                          ),
                                                        ),
                                                        FlutterFlowIconButton(
                                                          borderRadius: 35.0,
                                                          buttonSize: 70.0,
                                                          icon: Icon(
                                                            Icons
                                                                .backspace_outlined,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryBackground,
                                                            size: 28.0,
                                                          ),
                                                          onPressed: () async {
                                                            // RemoveFromList
                                                            _model.removeAtIndexFromConfirmedDecoyPinInput(
                                                                _model.confirmedDecoyPinInput
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
                                                      _model.joinedDecoyPin =
                                                          functions.newCustomFunction(
                                                              _model
                                                                  .pinDecoyInput
                                                                  .toList());
                                                      safeSetState(() {});
                                                      _model.joinedDecoyConfirm =
                                                          functions.newCustomFunction(
                                                              _model
                                                                  .confirmedDecoyPinInput
                                                                  .toList());
                                                      safeSetState(() {});
                                                      if (_model
                                                              .confirmedDecoyPinInput
                                                              .length >=
                                                          4) {
                                                        if (_model
                                                                .joinedDecoyPin ==
                                                            _model
                                                                .joinedDecoyConfirm) {
                                                          _model.setPinResp =
                                                              await SetPINCall
                                                                  .call(
                                                            type: 'decoy',
                                                            pin: _model
                                                                .joinedDecoyConfirm,
                                                            jwt:
                                                                currentJwtToken,
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
                                                              pin: _model
                                                                  .joinedDecoyPin,
                                                              jwt:
                                                                  currentJwtToken,
                                                            );

                                                            if (VerifyPINCall
                                                                    .isDecoy(
                                                                  (_model.verifyResp
                                                                          ?.jsonBody ??
                                                                      ''),
                                                                ) ==
                                                                true) {
                                                              FFAppState()
                                                                      .decoyPin911Enabled =
                                                                  false;
                                                              FFAppState()
                                                                      .decoyPinContactsEnabled =
                                                                  false;
                                                              safeSetState(
                                                                  () {});

                                                              context.pushNamed(
                                                                DecoyPinSystemValuesWidget
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
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                SnackBar(
                                                                  content: Text(
                                                                    'ERROR #003 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT',
                                                                    style:
                                                                        TextStyle(
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

                                                            _model.confirmedDecoyPinInput =
                                                                [].toList().cast<
                                                                    String>();
                                                            _model.pinDecoyInput =
                                                                [].toList().cast<
                                                                    String>();
                                                            safeSetState(() {});
                                                            _model.currentStep =
                                                                1;
                                                            safeSetState(() {});
                                                          } else {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                  'ERROR #002 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT',
                                                                  style:
                                                                      TextStyle(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
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
                                                          _model.confirmedDecoyPinInput =
                                                              [].toList().cast<
                                                                  String>();
                                                          _model.pinDecoyInput =
                                                              [].toList().cast<
                                                                  String>();
                                                          safeSetState(() {});
                                                          _model.currentStep =
                                                              1;
                                                          safeSetState(() {});
                                                          _model.notificationValue =
                                                              9;
                                                          _model.confirmNotificationValue =
                                                              3;
                                                          safeSetState(() {});
                                                          await Future.delayed(
                                                            Duration(
                                                              milliseconds:
                                                                  2000,
                                                            ),
                                                          );
                                                          _model.confirmNotificationValue =
                                                              0;
                                                          _model.notificationValue =
                                                              0;
                                                          safeSetState(() {});
                                                        }
                                                      } else {
                                                        _model.confirmedDecoyPinInput =
                                                            []
                                                                .toList()
                                                                .cast<String>();
                                                        _model.joinedDecoyConfirm =
                                                            '';
                                                        safeSetState(() {});
                                                        _model.confirmNotificationValue =
                                                            2;
                                                        safeSetState(() {});
                                                        await Future.delayed(
                                                          Duration(
                                                            milliseconds: 2000,
                                                          ),
                                                        );
                                                        _model.confirmNotificationValue =
                                                            0;
                                                        safeSetState(() {});
                                                      }

                                                      safeSetState(() {});
                                                    },
                                                    text: 'Confirm',
                                                    options: FFButtonOptions(
                                                      width: 400.0,
                                                      height: 50.0,
                                                      padding:
                                                          EdgeInsets.all(0.0),
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
                                                              .titleMedium
                                                              .override(
                                                                font:
                                                                    GoogleFonts
                                                                        .heebo(
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleMedium
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleMedium
                                                                      .fontStyle,
                                                                ),
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryText,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleMedium
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleMedium
                                                                    .fontStyle,
                                                              ),
                                                      elevation: 3.0,
                                                      borderSide: BorderSide(
                                                        color:
                                                            Colors.transparent,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              14.0),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (_model.currentStep == 2)
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            20.0, 32.0, 0.0, 0.0),
                                        child: FlutterFlowIconButton(
                                          borderRadius: 30.0,
                                          borderWidth: 1.0,
                                          buttonSize: 60.0,
                                          icon: Icon(
                                            Icons.arrow_back_rounded,
                                            color: FlutterFlowTheme.of(context)
                                                .primaryBackground,
                                            size: 30.0,
                                          ),
                                          onPressed: () async {
                                            _model.currentStep = 1;
                                            safeSetState(() {});
                                          },
                                        ),
                                      ),
                                    if (_model.currentStep == 1)
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            20.0, 32.0, 0.0, 0.0),
                                        child: FlutterFlowIconButton(
                                          borderRadius: 30.0,
                                          borderWidth: 1.0,
                                          buttonSize: 60.0,
                                          icon: Icon(
                                            Icons.arrow_back_rounded,
                                            color: FlutterFlowTheme.of(context)
                                                .primaryBackground,
                                            size: 30.0,
                                          ),
                                          onPressed: () async {
                                            context.safePop();
                                          },
                                        ),
                                      ),
                                  ],
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
      ),
    );
  }
}
