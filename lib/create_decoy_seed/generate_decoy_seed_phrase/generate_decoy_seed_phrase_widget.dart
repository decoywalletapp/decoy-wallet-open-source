import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'generate_decoy_seed_phrase_model.dart';
export 'generate_decoy_seed_phrase_model.dart';

/// Create a page that prompts the user to generate a decoy seed phrase.
///
/// It's just going to be a page with one button on it. Or a back button on
/// it. Once they click the Generate Seed Phrase button, it moves them on to
/// the next page.
class GenerateDecoySeedPhraseWidget extends StatefulWidget {
  const GenerateDecoySeedPhraseWidget({super.key});

  static String routeName = 'GenerateDecoySeedPhrase';
  static String routePath = '/generateDecoySeedPhrase';

  @override
  State<GenerateDecoySeedPhraseWidget> createState() =>
      _GenerateDecoySeedPhraseWidgetState();
}

class _GenerateDecoySeedPhraseWidgetState
    extends State<GenerateDecoySeedPhraseWidget> {
  late GenerateDecoySeedPhraseModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GenerateDecoySeedPhraseModel());

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
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              children: [
                                Align(
                                  alignment: AlignmentDirectional(0.01, 0.0),
                                  child: Icon(
                                    Icons.security_rounded,
                                    color: Color(0xFF001DF7),
                                    size: 80.0,
                                  ),
                                ),
                                Align(
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: Icon(
                                    Icons.security_rounded,
                                    color: FlutterFlowTheme.of(context).error,
                                    size: 80.0,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  'Generate Decoy Seed Phrase',
                                  textAlign: TextAlign.center,
                                  style: FlutterFlowTheme.of(context)
                                      .headlineMedium
                                      .override(
                                        fontFamily: 'InterTight',
                                        letterSpacing: 0.0,
                                      ),
                                ),
                                Align(
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: Text(
                                    'Create a decoy seed phrase to protect your wallet. This will help secure your funds by providing an alternative phrase that can be used if compromised.',
                                    textAlign: TextAlign.center,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMediumFamily,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          letterSpacing: 0.0,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .bodyMediumIsCustom,
                                        ),
                                  ),
                                ),
                              ].divide(SizedBox(height: 16.0)),
                            ),
                            FFButtonWidget(
                              onPressed: () async {
                                _model.decoyDraftOut =
                                    await actions.generateDecoyDraft();
                                _model.tempMnemonic = getJsonField(
                                  _model.decoyDraftOut,
                                  r'''$.mnemonic''',
                                ).toString();
                                _model.tempDecoyId = getJsonField(
                                  _model.decoyDraftOut,
                                  r'''$.decoyId''',
                                ).toString();
                                safeSetState(() {});
                                if (getJsonField(
                                  _model.decoyDraftOut,
                                  r'''$.ok''',
                                )) {
                                  FFAppState().decoyActiveId = getJsonField(
                                    _model.decoyDraftOut,
                                    r'''$.decoyId''',
                                  ).toString();
                                  FFAppState().draftAddresses = (getJsonField(
                                    _model.decoyDraftOut,
                                    r'''$.addresses''',
                                    true,
                                  ) as List?)!
                                      .map<String>((e) => e.toString())
                                      .toList()
                                      .cast<String>()
                                      .toList()
                                      .cast<String>();
                                  FFAppState().draftDerivationPath =
                                      getJsonField(
                                    _model.decoyDraftOut,
                                    r'''$.derivation_path''',
                                  ).toString();
                                  FFAppState().draftXpub = getJsonField(
                                    _model.decoyDraftOut,
                                    r'''$.xpub''',
                                  ).toString();
                                  FFAppState().draftWatchPublicKey =
                                      getJsonField(
                                    _model.decoyDraftOut,
                                    r'''$.watch_public_key''',
                                  ).toString();
                                  FFAppState().draftWatchPublicKeyType =
                                      getJsonField(
                                    _model.decoyDraftOut,
                                    r'''$.watch_public_key_type''',
                                  ).toString();
                                  safeSetState(() {});
                                  FFAppState().decoySeedArmed = false;
                                  safeSetState(() {});

                                  context.pushNamed(
                                    ShowDecoySeedPhraseWidget.routeName,
                                    queryParameters: {
                                      'mnemonic': serializeParam(
                                        _model.tempMnemonic,
                                        ParamType.String,
                                      ),
                                      'decoyId': serializeParam(
                                        _model.tempDecoyId,
                                        ParamType.String,
                                      ),
                                    }.withoutNulls,
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'ERROR #001 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT',
                                        style: TextStyle(
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                        ),
                                      ),
                                      duration: Duration(milliseconds: 4000),
                                      backgroundColor:
                                          FlutterFlowTheme.of(context)
                                              .secondary,
                                    ),
                                  );
                                }

                                safeSetState(() {});
                              },
                              text: 'Generate Seed Phrase',
                              options: FFButtonOptions(
                                width: 400.0,
                                height: 56.0,
                                padding: EdgeInsets.all(8.0),
                                iconPadding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                color: FlutterFlowTheme.of(context).primary,
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .override(
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
                                  color: Colors.transparent,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ].divide(SizedBox(height: 32.0)),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 0.0, 0.0),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
