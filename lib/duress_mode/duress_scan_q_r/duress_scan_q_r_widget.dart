import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import '/utils/android_display_guard.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
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
  static const _pageBackground = Color(0xFF080C0D);
  static const _panelBackground = Color(0xFF121819);
  static const _panelRaised = Color(0xFF1A2224);
  static const _mutedText = Color(0xFF8C979A);
  static const _softBorder = Color(0xFF253033);
  static const _track = Color(0xFF101516);

  late DuressScanQRModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DuressScanQRModel());

    _model.walletAddressTextController ??= TextEditingController();
    _model.walletAddressFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Future<void> _scanQrCode() async {
    if (isiOS || isAndroid) {
      _model.scannedQR = await FlutterBarcodeScanner.scanBarcode(
        '#C62828', // scanning line color
        'Cancel', // cancel button text
        true, // whether to show the torch (camera LED) toggle icon
        ScanMode.QR,
      );

      safeSetState(() {
        _model.walletAddressTextController?.text =
            functions.extractBitcoinAddress(_model.scannedQR)!;
      });
    }

    safeSetState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final scanQrBottomPadding = decoyBottomActionPadding(context);
    final orange = FlutterFlowTheme.of(context).primary;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: PopScope(
        canPop: false,
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: _pageBackground,
          body: SafeArea(
            top: true,
            child: DecoyBottomSafeScroll(
              bottomPadding: scanQrBottomPadding,
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  20.0,
                  18.0,
                  20.0,
                  0.0,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 390.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _topBar(context),
                        const SizedBox(height: 28.0),
                        _titleBlock(context, orange),
                        const SizedBox(height: 20.0),
                        _scannerCard(context, orange),
                        const SizedBox(height: 16.0),
                        _manualAddressCard(context, orange),
                        const SizedBox(height: 18.0),
                        _sendFundsButton(context),
                        const SizedBox(height: 18.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Row(
      children: [
        FlutterFlowIconButton(
          borderRadius: 20.0,
          buttonSize: 40.0,
          icon: Icon(
            Icons.arrow_back_rounded,
            color: FlutterFlowTheme.of(context).info,
            size: 26.0,
          ),
          onPressed: () async {
            context.safePop();
          },
        ),
      ],
    );
  }

  Widget _titleBlock(BuildContext context, Color orange) {
    return Column(
      children: [
        Container(
          width: 62.0,
          height: 62.0,
          decoration: BoxDecoration(
            color: orange.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: orange.withValues(alpha: 0.42),
              width: 1.2,
            ),
          ),
          child: Icon(
            Icons.qr_code_scanner_rounded,
            color: orange,
            size: 32.0,
          ),
        ),
        const SizedBox(height: 18.0),
        Text(
          'Send Bitcoin',
          textAlign: TextAlign.center,
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                fontFamily: 'InterTight',
                color: FlutterFlowTheme.of(context).info,
                fontSize: 31.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 7.0),
        Text(
          'Scan or paste a recipient address',
          textAlign: TextAlign.center,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'InterTight',
                color: _mutedText,
                fontSize: 14.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  Widget _scannerCard(BuildContext context, Color orange) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _scanQrCode,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 18.0),
        decoration: BoxDecoration(
          color: _panelBackground,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: _softBorder),
        ),
        child: Column(
          children: [
            Row(
              children: [
                _sectionLabel(
                  context,
                  icon: Icons.center_focus_strong_rounded,
                  label: 'Recipient QR',
                ),
                const Spacer(),
                _statusPill(
                  context,
                  label: 'Scan',
                  orange: orange,
                ),
              ],
            ),
            const SizedBox(height: 22.0),
            AspectRatio(
              aspectRatio: 1.16,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _track,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: orange.withValues(alpha: 0.7),
                    width: 2.0,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              _panelRaised,
                              _track,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 116.0,
                      height: 116.0,
                      decoration: BoxDecoration(
                        color: orange.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: orange.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Icon(
                        Icons.qr_code_2_rounded,
                        color: FlutterFlowTheme.of(context)
                            .info
                            .withValues(alpha: 0.74),
                        size: 56.0,
                      ),
                    ),
                    Positioned(
                      left: 26.0,
                      right: 26.0,
                      child: Container(
                        height: 2.0,
                        decoration: BoxDecoration(
                          color: orange.withValues(alpha: 0.72),
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Tap to open QR scanner',
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyLarge.override(
                    fontFamily: 'InterTight',
                    color: FlutterFlowTheme.of(context).info,
                    fontSize: 16.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 4.0),
            Text(
              'Bitcoin address or payment URI',
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'InterTight',
                    color: _mutedText,
                    fontSize: 12.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _manualAddressCard(BuildContext context, Color orange) {
    final hasAddress =
        (_model.walletAddressTextController.text).trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: _panelBackground,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: _softBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _sectionLabel(
                context,
                icon: Icons.edit_note_rounded,
                label: 'Manual address',
              ),
              const Spacer(),
              _statusPill(
                context,
                label: hasAddress ? 'Ready' : 'Paste',
                orange: hasAddress ? orange : _mutedText,
              ),
            ],
          ),
          const SizedBox(height: 14.0),
          TextFormField(
            controller: _model.walletAddressTextController,
            focusNode: _model.walletAddressFocusNode,
            autofocus: false,
            textInputAction: TextInputAction.done,
            obscureText: false,
            onChanged: (_) => safeSetState(() {}),
            decoration: InputDecoration(
              hintText: 'Paste or enter wallet address',
              hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'InterTight',
                    color: _mutedText,
                    fontSize: 14.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: _softBorder,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: orange,
                  width: 1.2,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).error,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).error,
                  width: 1.2,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              filled: true,
              fillColor: _track,
              contentPadding: const EdgeInsetsDirectional.fromSTEB(
                14.0,
                14.0,
                12.0,
                14.0,
              ),
              suffixIcon: Icon(
                Icons.content_paste_rounded,
                color: hasAddress ? orange : _mutedText,
                size: 24.0,
              ),
            ),
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'InterTight',
                  color: FlutterFlowTheme.of(context).info,
                  fontSize: 14.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w600,
                ),
            maxLines: 3,
            minLines: 1,
            cursorColor: orange,
            validator: _model.walletAddressTextControllerValidator
                .asValidator(context),
          ),
        ],
      ),
    );
  }

  Widget _sendFundsButton(BuildContext context) {
    return FFButtonWidget(
      onPressed: () async {
        FFAppState().scannedAddress = _model.walletAddressTextController.text;
        safeSetState(() {});

        context.pushNamed(DuressSendBTCWidget.routeName);
      },
      text: 'Send Funds',
      options: FFButtonOptions(
        width: double.infinity,
        height: 58.0,
        padding: const EdgeInsets.all(8.0),
        iconPadding: const EdgeInsetsDirectional.fromSTEB(
          0.0,
          0.0,
          0.0,
          0.0,
        ),
        color: FlutterFlowTheme.of(context).primary,
        textStyle: FlutterFlowTheme.of(context).titleMedium.override(
              fontFamily: 'InterTight',
              color: FlutterFlowTheme.of(context).info,
              letterSpacing: 0.0,
              fontWeight: FontWeight.w800,
            ),
        elevation: 5.0,
        borderSide: const BorderSide(
          color: Colors.transparent,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }

  Widget _sectionLabel(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: FlutterFlowTheme.of(context).info,
          size: 20.0,
        ),
        const SizedBox(width: 8.0),
        Text(
          label,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'InterTight',
                color: FlutterFlowTheme.of(context).info,
                fontSize: 14.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }

  Widget _statusPill(
    BuildContext context, {
    required String label,
    required Color orange,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.0),
      decoration: BoxDecoration(
        color: _panelRaised,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: _softBorder),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: 'InterTight',
              color: orange,
              fontSize: 12.0,
              letterSpacing: 0.0,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}
