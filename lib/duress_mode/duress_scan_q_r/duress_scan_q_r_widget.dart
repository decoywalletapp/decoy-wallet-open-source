import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'duress_scan_q_r_model.dart';
export 'duress_scan_q_r_model.dart';

/// Create a page that allows the user to scan a QR code or paste a receive
/// address in a box, and then at the bottom of the page allows the user to
/// select send funds button.
///
/// I want a big portion of the top of the screen to be what the phone camera
/// user's phone camera sees. Underneath of that, I want the box where the
/// user can paste the corresponding receive address.
class DuressScanQRWidget extends StatefulWidget {
  const DuressScanQRWidget({super.key});

  static String routeName = 'DuressScanQR';
  static String routePath = '/duressScanQR';

  @override
  State<DuressScanQRWidget> createState() => _DuressScanQRWidgetState();
}

class _DuressScanQRWidgetState extends State<DuressScanQRWidget> {
  late DuressScanQRModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DuressScanQRModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (isiOS || isAndroid) {
        _model.scannedQR = await FlutterBarcodeScanner.scanBarcode(
          '#C62828', // scanning line color
          'Cancel', // cancel button text
          true, // whether to show the flash icon
          ScanMode.QR,
        );

        safeSetState(() {
          _model.walletAddressTextController?.text =
              functions.extractBitcoinAddress(_model.scannedQR)!;
        });
      }
    });

    _model.walletAddressTextController ??= TextEditingController();
    _model.walletAddressFocusNode ??= FocusNode();

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
        backgroundColor: FlutterFlowTheme.of(context).primaryText,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primaryText,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderRadius: 20.0,
            buttonSize: 40.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: FlutterFlowTheme.of(context).primaryBackground,
              size: 24.0,
            ),
            onPressed: () async {
              context.pop();
            },
          ),
          title: Align(
            alignment: AlignmentDirectional(-1.0, 0.0),
            child: Text(
              'Send Bitcoin',
              textAlign: TextAlign.start,
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                    font: GoogleFonts.interTight(
                      fontWeight: FontWeight.w600,
                      fontStyle:
                          FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                    ),
                    color: FlutterFlowTheme.of(context).primaryBackground,
                    fontSize: 20.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                    fontStyle:
                        FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                  ),
            ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  height: 400.0,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.qr_code_scanner,
                                color: Color(0xFF666666),
                                size: 64.0,
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 16.0, 0.0, 0.0),
                                child: Text(
                                  'Position QR code within frame',
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
                                        color: Color(0xFF999999),
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
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: Container(
                          width: 200.0,
                          height: 200.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: FlutterFlowTheme.of(context).primary,
                              width: 3.0,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(1.0, -1.0),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 16.0, 16.0, 0.0),
                          child: Container(
                            width: 40.0,
                            height: 40.0,
                            decoration: BoxDecoration(
                              color: Color(0x80000000),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Align(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: Icon(
                                Icons.flash_on,
                                color: Colors.white,
                                size: 24.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 16.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0x1D000000),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Or enter address manually',
                          style:
                              FlutterFlowTheme.of(context).titleMedium.override(
                                    font: GoogleFonts.interTight(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .primaryBackground,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .fontStyle,
                                  ),
                        ),
                        TextFormField(
                          controller: _model.walletAddressTextController,
                          focusNode: _model.walletAddressFocusNode,
                          autofocus: false,
                          textInputAction: TextInputAction.done,
                          obscureText: false,
                          decoration: InputDecoration(
                            hintText: 'Paste or enter wallet address',
                            hintStyle: FlutterFlowTheme.of(context)
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
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).alternate,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).primary,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0x00000000),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0x00000000),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            filled: true,
                            fillColor:
                                FlutterFlowTheme.of(context).primaryBackground,
                            suffixIcon: Icon(
                              Icons.content_paste,
                              color: FlutterFlowTheme.of(context).secondaryText,
                              size: 24.0,
                            ),
                          ),
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
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
                          maxLines: 3,
                          minLines: 1,
                          cursorColor: FlutterFlowTheme.of(context).primary,
                          validator: _model.walletAddressTextControllerValidator
                              .asValidator(context),
                        ),
                      ].divide(SizedBox(height: 16.0)),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 24.0),
                child: FFButtonWidget(
                  onPressed: () async {
                    FFAppState().scannedAddress =
                        _model.walletAddressTextController.text;
                    safeSetState(() {});

                    context.pushNamed(DuressSendBTCWidget.routeName);
                  },
                  text: 'Send Funds',
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 56.0,
                    padding: EdgeInsets.all(8.0),
                    iconPadding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                    color: FlutterFlowTheme.of(context).primary,
                    textStyle:
                        FlutterFlowTheme.of(context).titleMedium.override(
                              font: GoogleFonts.interTight(
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
                    elevation: 5.0,
                    borderSide: BorderSide(
                      color: Colors.transparent,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(12.0),
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
