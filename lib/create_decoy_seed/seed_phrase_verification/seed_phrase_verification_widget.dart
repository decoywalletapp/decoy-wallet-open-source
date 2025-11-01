import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'seed_phrase_verification_model.dart';
export 'seed_phrase_verification_model.dart';

/// Create a “Seed Phrase Quiz” page that verifies 3 random words from a
/// 12-word mnemonic.
///
/// The page receives a mnemonic string (space-separated words). On load,
/// split it into a list words, choose 3 unique random indices (0–11), and set
/// quizStep = 0, currentIndex = first index, and options = 3 shuffled words
/// (1 correct, 2 random). The layout: title “Seed Phrase Verification”, text
/// “Question ${quizStep+1} of 3”, and “Choose word #${currentIndex+1}”. Show
/// 3 ChoiceChips or Buttons from options. When a choice is tapped, mark it
/// selected. Verify button is disabled until one is chosen. On Verify: if
/// correct and quizStep < 2, increment quizStep, load next index, rebuild
/// options, reset selection. If all 3 correct, show success and navigate to
/// the next page. If wrong, show error and restart quiz with new random
/// indices. Clean, centered layout, mobile-friendly, modern design.
class SeedPhraseVerificationWidget extends StatefulWidget {
  const SeedPhraseVerificationWidget({
    super.key,
    required this.mnemonic,
  });

  final String? mnemonic;

  static String routeName = 'SeedPhraseVerification';
  static String routePath = '/seedPhraseVerification';

  @override
  State<SeedPhraseVerificationWidget> createState() =>
      _SeedPhraseVerificationWidgetState();
}

class _SeedPhraseVerificationWidgetState
    extends State<SeedPhraseVerificationWidget> {
  late SeedPhraseVerificationModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SeedPhraseVerificationModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.splitOut = await actions.splitMnemonicAction(
        widget.mnemonic!,
      );
      _model.words = _model.splitOut!.toList().cast<String>();
      _model.quizIndices = [];
      _model.currentQuestion = 0;
      _model.chosenWords = [];
      _model.attemptCount = 0;
      _model.selectedIndex = -1;
      _model.verifyEnabled = false;
      safeSetState(() {});
      _model.indicesOut = await actions.makeQuizIndicesAction(
        _model.words.length,
      );
      _model.quizIndices = _model.indicesOut!.toList().cast<int>();
      safeSetState(() {});
      _model.stepOut = await actions.buildQuizStepAction(
        _model.words.toList(),
        _model.quizIndices.toList(),
        _model.currentQuestion,
      );
      _model.options = (getJsonField(
        _model.stepOut,
        r'''$.options''',
        true,
      ) as List?)!
          .map<String>((e) => e.toString())
          .toList()
          .cast<String>()
          .toList()
          .cast<String>();
      _model.correctWord = getJsonField(
        _model.stepOut,
        r'''$.correctWord''',
      ).toString();
      _model.displayIndex = getJsonField(
        _model.stepOut,
        r'''$.displayIndex''',
      );
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
        backgroundColor: FlutterFlowTheme.of(context).info,
        body: SafeArea(
          top: true,
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(24.0, 32.0, 24.0, 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Seed Phrase Verification',
                          textAlign: TextAlign.center,
                          style: FlutterFlowTheme.of(context)
                              .headlineMedium
                              .override(
                                font: GoogleFonts.interTight(
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .headlineMedium
                                      .fontStyle,
                                ),
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .headlineMedium
                                    .fontStyle,
                              ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Align(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 20.0, 0.0, 0.0),
                                child: Text(
                                  'Question ',
                                  textAlign: TextAlign.center,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
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
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 20.0, 0.0, 0.0),
                              child: Text(
                                functions
                                    .plusOneToString(_model.currentQuestion),
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
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 20.0, 0.0, 0.0),
                              child: Text(
                                ' of 3',
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
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ].divide(SizedBox(height: 8.0)),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  borderRadius: BorderRadius.circular(16.0),
                                  border: Border.all(
                                    color: FlutterFlowTheme.of(context).primary,
                                    width: 4.0,
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Choose word ',
                                            textAlign: TextAlign.center,
                                            style: FlutterFlowTheme.of(context)
                                                .titleLarge
                                                .override(
                                                  font: GoogleFonts.interTight(
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleLarge
                                                            .fontStyle,
                                                  ),
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleLarge
                                                          .fontStyle,
                                                ),
                                          ),
                                          Text(
                                            _model.displayIndex.toString(),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight: FontWeight.bold,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  fontSize: 20.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                        ],
                                      ),
                                      Stack(
                                        children: [
                                          Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              FFButtonWidget(
                                                onPressed: () async {
                                                  _model.addToChosenWords(_model
                                                      .options
                                                      .elementAtOrNull(0)!);
                                                  safeSetState(() {});
                                                  _model.selectedIndex = 0;
                                                  safeSetState(() {});
                                                  if (_model.currentQuestion <
                                                      2) {
                                                    _model.currentQuestion =
                                                        _model.currentQuestion +
                                                            1;
                                                    safeSetState(() {});
                                                    _model.quizStep =
                                                        await actions
                                                            .buildQuizStepAction(
                                                      _model.words.toList(),
                                                      _model.quizIndices
                                                          .toList(),
                                                      _model.currentQuestion,
                                                    );
                                                    _model.options =
                                                        (getJsonField(
                                                      _model.quizStep,
                                                      r'''$.options''',
                                                      true,
                                                    ) as List?)!
                                                            .map<String>((e) =>
                                                                e.toString())
                                                            .toList()
                                                            .cast<String>()
                                                            .toList()
                                                            .cast<String>();
                                                    _model.correctWord =
                                                        getJsonField(
                                                      _model.quizStep,
                                                      r'''$.correctWord''',
                                                    ).toString();
                                                    _model.displayIndex =
                                                        getJsonField(
                                                      _model.quizStep,
                                                      r'''$.displayIndex''',
                                                    );
                                                    _model.selectedIndex = -1;
                                                    safeSetState(() {});
                                                  } else {
                                                    _model.verifyResult =
                                                        await actions
                                                            .verifyAllSelectionsAction(
                                                      _model.words.toList(),
                                                      _model.quizIndices
                                                          .toList(),
                                                      _model.chosenWords
                                                          .toList(),
                                                    );
                                                    if (_model.verifyResult ==
                                                        true) {
                                                      context.pushNamed(
                                                          DecoySeedActiveWidget
                                                              .routeName);
                                                    } else {
                                                      _model.attemptCount =
                                                          _model.attemptCount +
                                                              1;
                                                      _model.currentQuestion =
                                                          0;
                                                      _model.chosenWords = [];
                                                      _model.selectedIndex = -1;
                                                      safeSetState(() {});
                                                      if (_model.attemptCount <
                                                          3) {
                                                        _model.indicesOutRetry =
                                                            await actions
                                                                .makeQuizIndicesAction(
                                                          _model.words.length,
                                                        );
                                                        _model.quizIndices =
                                                            _model
                                                                .indicesOutRetry!
                                                                .toList()
                                                                .cast<int>();
                                                        safeSetState(() {});
                                                        _model.quizStepRetry =
                                                            await actions
                                                                .buildQuizStepAction(
                                                          _model.words.toList(),
                                                          _model.quizIndices
                                                              .toList(),
                                                          0,
                                                        );
                                                        _model.options =
                                                            (getJsonField(
                                                          _model.quizStepRetry,
                                                          r'''$.options''',
                                                          true,
                                                        ) as List?)!
                                                                .map<String>((e) =>
                                                                    e.toString())
                                                                .toList()
                                                                .cast<String>()
                                                                .toList()
                                                                .cast<String>();
                                                        _model.correctWord =
                                                            getJsonField(
                                                          _model.quizStepRetry,
                                                          r'''$.correctWord''',
                                                        ).toString();
                                                        _model.displayIndex =
                                                            getJsonField(
                                                          _model.quizStepRetry,
                                                          r'''$.displayIndex''',
                                                        );
                                                        safeSetState(() {});
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              'NOT QUITE - TRY AGAIN',
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
                                                      } else {
                                                        context.pushNamed(
                                                          ShowDecoySeedPhraseWidget
                                                              .routeName,
                                                          queryParameters: {
                                                            'mnemonic':
                                                                serializeParam(
                                                              widget.mnemonic,
                                                              ParamType.String,
                                                            ),
                                                          }.withoutNulls,
                                                          extra: <String,
                                                              dynamic>{
                                                            kTransitionInfoKey:
                                                                TransitionInfo(
                                                              hasTransition:
                                                                  true,
                                                              transitionType:
                                                                  PageTransitionType
                                                                      .rightToLeft,
                                                            ),
                                                          },
                                                        );
                                                      }
                                                    }
                                                  }

                                                  safeSetState(() {});
                                                },
                                                text: _model.options
                                                    .elementAtOrNull(0)!,
                                                options: FFButtonOptions(
                                                  width: double.infinity,
                                                  height: 56.0,
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(24.0, 16.0,
                                                          24.0, 16.0),
                                                  iconPadding:
                                                      EdgeInsetsDirectional
                                                          .fromSTEB(0.0, 0.0,
                                                              0.0, 0.0),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryBackground,
                                                  textStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .titleSmall
                                                      .override(
                                                        font: GoogleFonts
                                                            .interTight(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmall
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmall
                                                                  .fontStyle,
                                                        ),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primaryText,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleSmall
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleSmall
                                                                .fontStyle,
                                                      ),
                                                  elevation: 0.0,
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    width: 2.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                ),
                                              ),
                                              FFButtonWidget(
                                                onPressed: () async {
                                                  _model.addToChosenWords(_model
                                                      .options
                                                      .elementAtOrNull(1)!);
                                                  safeSetState(() {});
                                                  _model.selectedIndex = 0;
                                                  safeSetState(() {});
                                                  if (_model.currentQuestion <
                                                      2) {
                                                    _model.currentQuestion =
                                                        _model.currentQuestion +
                                                            1;
                                                    safeSetState(() {});
                                                    _model.quizStepMid =
                                                        await actions
                                                            .buildQuizStepAction(
                                                      _model.words.toList(),
                                                      _model.quizIndices
                                                          .toList(),
                                                      _model.currentQuestion,
                                                    );
                                                    _model.options =
                                                        (getJsonField(
                                                      _model.quizStepMid,
                                                      r'''$.options''',
                                                      true,
                                                    ) as List?)!
                                                            .map<String>((e) =>
                                                                e.toString())
                                                            .toList()
                                                            .cast<String>()
                                                            .toList()
                                                            .cast<String>();
                                                    _model.correctWord =
                                                        getJsonField(
                                                      _model.quizStepMid,
                                                      r'''$.correctWord''',
                                                    ).toString();
                                                    _model.displayIndex =
                                                        getJsonField(
                                                      _model.quizStepMid,
                                                      r'''$.displayIndex''',
                                                    );
                                                    _model.selectedIndex = -1;
                                                    safeSetState(() {});
                                                  } else {
                                                    _model.verifyResultMid =
                                                        await actions
                                                            .verifyAllSelectionsAction(
                                                      _model.words.toList(),
                                                      _model.quizIndices
                                                          .toList(),
                                                      _model.chosenWords
                                                          .toList(),
                                                    );
                                                    if (_model
                                                            .verifyResultMid ==
                                                        true) {
                                                      context.pushNamed(
                                                          DecoySeedActiveWidget
                                                              .routeName);
                                                    } else {
                                                      _model.attemptCount =
                                                          _model.attemptCount +
                                                              1;
                                                      _model.currentQuestion =
                                                          0;
                                                      _model.chosenWords = [];
                                                      _model.selectedIndex = -1;
                                                      safeSetState(() {});
                                                      if (_model.attemptCount <
                                                          3) {
                                                        _model.indicesOutRetryMid =
                                                            await actions
                                                                .makeQuizIndicesAction(
                                                          _model.words.length,
                                                        );
                                                        _model.quizIndices = _model
                                                            .indicesOutRetryMid!
                                                            .toList()
                                                            .cast<int>();
                                                        safeSetState(() {});
                                                        _model.quizStepRetryMid =
                                                            await actions
                                                                .buildQuizStepAction(
                                                          _model.words.toList(),
                                                          _model.quizIndices
                                                              .toList(),
                                                          0,
                                                        );
                                                        _model.options =
                                                            (getJsonField(
                                                          _model
                                                              .quizStepRetryMid,
                                                          r'''$.options''',
                                                          true,
                                                        ) as List?)!
                                                                .map<String>((e) =>
                                                                    e.toString())
                                                                .toList()
                                                                .cast<String>()
                                                                .toList()
                                                                .cast<String>();
                                                        _model.correctWord =
                                                            getJsonField(
                                                          _model
                                                              .quizStepRetryMid,
                                                          r'''$.correctWord''',
                                                        ).toString();
                                                        _model.displayIndex =
                                                            getJsonField(
                                                          _model
                                                              .quizStepRetryMid,
                                                          r'''$.displayIndex''',
                                                        );
                                                        safeSetState(() {});
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              'NOT QUITE - TRY AGAIN',
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
                                                      } else {
                                                        context.pushNamed(
                                                          ShowDecoySeedPhraseWidget
                                                              .routeName,
                                                          queryParameters: {
                                                            'mnemonic':
                                                                serializeParam(
                                                              widget.mnemonic,
                                                              ParamType.String,
                                                            ),
                                                          }.withoutNulls,
                                                          extra: <String,
                                                              dynamic>{
                                                            kTransitionInfoKey:
                                                                TransitionInfo(
                                                              hasTransition:
                                                                  true,
                                                              transitionType:
                                                                  PageTransitionType
                                                                      .rightToLeft,
                                                            ),
                                                          },
                                                        );
                                                      }
                                                    }
                                                  }

                                                  safeSetState(() {});
                                                },
                                                text: _model.options
                                                    .elementAtOrNull(1)!,
                                                options: FFButtonOptions(
                                                  width: double.infinity,
                                                  height: 56.0,
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(24.0, 16.0,
                                                          24.0, 16.0),
                                                  iconPadding:
                                                      EdgeInsetsDirectional
                                                          .fromSTEB(0.0, 0.0,
                                                              0.0, 0.0),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryBackground,
                                                  textStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .titleSmall
                                                      .override(
                                                        font: GoogleFonts
                                                            .interTight(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmall
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmall
                                                                  .fontStyle,
                                                        ),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primaryText,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleSmall
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleSmall
                                                                .fontStyle,
                                                      ),
                                                  elevation: 0.0,
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    width: 2.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                ),
                                              ),
                                              FFButtonWidget(
                                                onPressed: () async {
                                                  _model.addToChosenWords(_model
                                                      .options
                                                      .elementAtOrNull(2)!);
                                                  safeSetState(() {});
                                                  _model.selectedIndex = 0;
                                                  safeSetState(() {});
                                                  if (_model.currentQuestion <
                                                      2) {
                                                    _model.currentQuestion =
                                                        _model.currentQuestion +
                                                            1;
                                                    safeSetState(() {});
                                                    _model.quizStepBot =
                                                        await actions
                                                            .buildQuizStepAction(
                                                      _model.words.toList(),
                                                      _model.quizIndices
                                                          .toList(),
                                                      _model.currentQuestion,
                                                    );
                                                    _model.options =
                                                        (getJsonField(
                                                      _model.quizStepBot,
                                                      r'''$.options''',
                                                      true,
                                                    ) as List?)!
                                                            .map<String>((e) =>
                                                                e.toString())
                                                            .toList()
                                                            .cast<String>()
                                                            .toList()
                                                            .cast<String>();
                                                    _model.correctWord =
                                                        getJsonField(
                                                      _model.quizStepBot,
                                                      r'''$.correctWord''',
                                                    ).toString();
                                                    _model.displayIndex =
                                                        getJsonField(
                                                      _model.quizStepBot,
                                                      r'''$.displayIndex''',
                                                    );
                                                    _model.selectedIndex = -1;
                                                    safeSetState(() {});
                                                  } else {
                                                    _model.verifyResultBot =
                                                        await actions
                                                            .verifyAllSelectionsAction(
                                                      _model.words.toList(),
                                                      _model.quizIndices
                                                          .toList(),
                                                      _model.chosenWords
                                                          .toList(),
                                                    );
                                                    if (_model
                                                            .verifyResultBot ==
                                                        true) {
                                                      context.pushNamed(
                                                          DecoySeedActiveWidget
                                                              .routeName);
                                                    } else {
                                                      _model.attemptCount =
                                                          _model.attemptCount +
                                                              1;
                                                      _model.currentQuestion =
                                                          0;
                                                      _model.chosenWords = [];
                                                      _model.selectedIndex = -1;
                                                      safeSetState(() {});
                                                      if (_model.attemptCount <
                                                          3) {
                                                        _model.indicesOutRetryBot =
                                                            await actions
                                                                .makeQuizIndicesAction(
                                                          _model.words.length,
                                                        );
                                                        _model.quizIndices = _model
                                                            .indicesOutRetryBot!
                                                            .toList()
                                                            .cast<int>();
                                                        safeSetState(() {});
                                                        _model.quizStepRetryBot =
                                                            await actions
                                                                .buildQuizStepAction(
                                                          _model.words.toList(),
                                                          _model.quizIndices
                                                              .toList(),
                                                          0,
                                                        );
                                                        _model.options =
                                                            (getJsonField(
                                                          _model
                                                              .quizStepRetryBot,
                                                          r'''$.options''',
                                                          true,
                                                        ) as List?)!
                                                                .map<String>((e) =>
                                                                    e.toString())
                                                                .toList()
                                                                .cast<String>()
                                                                .toList()
                                                                .cast<String>();
                                                        _model.correctWord =
                                                            getJsonField(
                                                          _model
                                                              .quizStepRetryBot,
                                                          r'''$.correctWord''',
                                                        ).toString();
                                                        _model.displayIndex =
                                                            getJsonField(
                                                          _model
                                                              .quizStepRetryBot,
                                                          r'''$.displayIndex''',
                                                        );
                                                        safeSetState(() {});
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              'NOT QUITE - TRY AGAIN',
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
                                                      } else {
                                                        context.pushNamed(
                                                          ShowDecoySeedPhraseWidget
                                                              .routeName,
                                                          queryParameters: {
                                                            'mnemonic':
                                                                serializeParam(
                                                              widget.mnemonic,
                                                              ParamType.String,
                                                            ),
                                                          }.withoutNulls,
                                                          extra: <String,
                                                              dynamic>{
                                                            kTransitionInfoKey:
                                                                TransitionInfo(
                                                              hasTransition:
                                                                  true,
                                                              transitionType:
                                                                  PageTransitionType
                                                                      .rightToLeft,
                                                            ),
                                                          },
                                                        );
                                                      }
                                                    }
                                                  }

                                                  safeSetState(() {});
                                                },
                                                text: _model.options
                                                    .elementAtOrNull(2)!,
                                                options: FFButtonOptions(
                                                  width: double.infinity,
                                                  height: 56.0,
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(24.0, 16.0,
                                                          24.0, 16.0),
                                                  iconPadding:
                                                      EdgeInsetsDirectional
                                                          .fromSTEB(0.0, 0.0,
                                                              0.0, 0.0),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryBackground,
                                                  textStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .titleSmall
                                                      .override(
                                                        font: GoogleFonts
                                                            .interTight(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmall
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmall
                                                                  .fontStyle,
                                                        ),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primaryText,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleSmall
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleSmall
                                                                .fontStyle,
                                                      ),
                                                  elevation: 0.0,
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    width: 2.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                        ],
                                      ),
                                    ].divide(SizedBox(height: 20.0)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ].divide(SizedBox(height: 24.0)),
                    ),
                  ].divide(SizedBox(height: 32.0)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
