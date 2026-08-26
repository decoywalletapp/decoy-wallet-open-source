import '/custom_code/actions/index.dart' as actions;
import '/build_provenance.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/utils/android_display_guard.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'import_watch_only_wallet_model.dart';
export 'import_watch_only_wallet_model.dart';

class ImportWatchOnlyWalletWidget extends StatefulWidget {
  const ImportWatchOnlyWalletWidget({super.key});

  static String routeName = 'ImportWatchOnlyWallet';
  static String routePath = '/importWatchOnlyWallet';

  @override
  State<ImportWatchOnlyWalletWidget> createState() =>
      _ImportWatchOnlyWalletWidgetState();
}

class _ImportWatchOnlyWalletWidgetState
    extends State<ImportWatchOnlyWalletWidget> {
  late ImportWatchOnlyWalletModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ImportWatchOnlyWalletModel());
    _model.watchOnlyInputTextController ??= TextEditingController();
    _model.watchOnlyInputFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  void _showImportError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: FlutterFlowTheme.of(context).primaryText,
          ),
        ),
        duration: Duration(milliseconds: 5000),
        backgroundColor: FlutterFlowTheme.of(context).secondary,
      ),
    );
  }

  Future<void> _prepareImportedWallet() async {
    final input = _model.watchOnlyInputTextController.text.trim();
    if (input.isEmpty) {
      _showImportError(
        'Paste a zpub, xpub, or one or more Bitcoin receive addresses.',
      );
      return;
    }

    _model.watchOnlyDraftOut = await actions.prepareWatchOnlyDecoyDraft(input);

    if (getJsonField(
          _model.watchOnlyDraftOut,
          r'''$.ok''',
        ) ==
        true) {
      FFAppState().decoyActiveId = getJsonField(
        _model.watchOnlyDraftOut,
        r'''$.decoyId''',
      ).toString();
      FFAppState().draftAddresses = (getJsonField(
        _model.watchOnlyDraftOut,
        r'''$.addresses''',
        true,
      ) as List?)!
          .map<String>((e) => e.toString())
          .toList()
          .cast<String>();
      FFAppState().draftDerivationPath = getJsonField(
        _model.watchOnlyDraftOut,
        r'''$.derivation_path''',
      ).toString();
      FFAppState().draftXpub = getJsonField(
        _model.watchOnlyDraftOut,
        r'''$.xpub''',
      ).toString();
      FFAppState().draftWatchPublicKey = getJsonField(
        _model.watchOnlyDraftOut,
        r'''$.watch_public_key''',
      ).toString();
      FFAppState().draftWatchPublicKeyType = getJsonField(
        _model.watchOnlyDraftOut,
        r'''$.watch_public_key_type''',
      ).toString();
      FFAppState().draftWatchSourceType = getJsonField(
        _model.watchOnlyDraftOut,
        r'''$.source_type''',
      ).toString();
      FFAppState().decoySeedArmed = false;
      safeSetState(() {});

      context.pushNamed(DecoySeedSystemValuesWidget.routeName);
      return;
    }

    final error = getJsonField(
      _model.watchOnlyDraftOut,
      r'''$.error''',
    ).toString();
    _showImportError(
      error.isNotEmpty
          ? error
          : 'Unable to validate this watch-only wallet data.',
    );
    safeSetState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = decoyBottomActionPadding(context);

    if (!DecoyBuildProvenance.watchOnlyImportEnabled) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    24.0,
                    24.0,
                    24.0,
                    24.0 + bottomPadding,
                  ),
                  child: Text(
                    'Watch-only wallet import is available in staging builds only.',
                    textAlign: TextAlign.center,
                    style: FlutterFlowTheme.of(context).bodyLarge.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).bodyLargeFamily,
                          color: FlutterFlowTheme.of(context).secondaryText,
                          letterSpacing: 0.0,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).bodyLargeIsCustom,
                        ),
                  ),
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
      );
    }

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
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            top: true,
            child: Stack(
              children: [
                DecoyBottomSafeScroll(
                  bottomPadding: bottomPadding,
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 0.0),
                    child: Form(
                      key: _model.formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Stack(
                            children: [
                              Align(
                                alignment: AlignmentDirectional(0.01, 0.0),
                                child: Icon(
                                  Icons.visibility_rounded,
                                  color: Color(0xFF001DF7),
                                  size: 76.0,
                                ),
                              ),
                              Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Icon(
                                  Icons.visibility_rounded,
                                  color: FlutterFlowTheme.of(context).primary,
                                  size: 76.0,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Monitor Existing Wallet',
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context)
                                .headlineMedium
                                .override(
                                  fontFamily: 'InterTight',
                                  letterSpacing: 0.0,
                                ),
                          ),
                          Text(
                            'Add a watch-only wallet key or specific receive addresses to monitor for outbound activity.',
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .bodyMediumFamily,
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .bodyMediumIsCustom,
                                ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFFFF4EC),
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: FlutterFlowTheme.of(context).primary,
                                width: 1.0,
                              ),
                            ),
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 14.0, 16.0, 14.0),
                            child: Text(
                              'Paste only watch-only public data. Never paste a seed phrase, private key, xprv, or zprv.',
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .bodyMediumFamily,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    fontSize: 15.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    useGoogleFonts:
                                        !FlutterFlowTheme.of(context)
                                            .bodyMediumIsCustom,
                                  ),
                            ),
                          ),
                          TextFormField(
                            controller: _model.watchOnlyInputTextController,
                            focusNode: _model.watchOnlyInputFocusNode,
                            autofocus: false,
                            obscureText: false,
                            autocorrect: false,
                            enableSuggestions: false,
                            keyboardType: TextInputType.multiline,
                            minLines: 5,
                            maxLines: 8,
                            decoration: InputDecoration(
                              labelText: 'zpub, xpub, or receive addresses',
                              labelStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .labelMediumFamily,
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    letterSpacing: 0.0,
                                    useGoogleFonts:
                                        !FlutterFlowTheme.of(context)
                                            .labelMediumIsCustom,
                                  ),
                              alignLabelWithHint: true,
                              hintText: 'zpub...\n\nor\nbc1q...\nbc1p...\n1...',
                              hintStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .labelMediumFamily,
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    letterSpacing: 0.0,
                                    useGoogleFonts:
                                        !FlutterFlowTheme.of(context)
                                            .labelMediumIsCustom,
                                  ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).primary,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).primary,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).error,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).error,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsetsDirectional.fromSTEB(
                                  16.0, 16.0, 16.0, 16.0),
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .bodyMediumFamily,
                                  fontSize: 15.0,
                                  letterSpacing: 0.0,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .bodyMediumIsCustom,
                                ),
                            validator: _model
                                .watchOnlyInputTextControllerValidator
                                .asValidator(context),
                          ),
                          Text(
                            'For xpub imports, Decoy treats the key as a native SegWit account key. If you are unsure, use a zpub or paste specific receive addresses.',
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context)
                                .bodySmall
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .bodySmallFamily,
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  letterSpacing: 0.0,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .bodySmallIsCustom,
                                ),
                          ),
                          FFButtonWidget(
                            onPressed: _prepareImportedWallet,
                            text: 'Continue',
                            options: FFButtonOptions(
                              width: double.infinity,
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
                        ].divide(SizedBox(height: 20.0)),
                      ),
                    ),
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
