import '/flutter_flow/flutter_flow_util.dart';
import 'duress_scan_q_rv2_widget.dart' show DuressScanQRv2Widget;
import 'package:flutter/material.dart';

class DuressScanQRv2Model extends FlutterFlowModel<DuressScanQRv2Widget> {
  ///  Local state fields for this page.

  bool isScanning = true;

  ///  State fields for stateful widgets in this page.

  var scannedQR = '';
  // State field(s) for WalletAddress widget.
  FocusNode? walletAddressFocusNode;
  TextEditingController? walletAddressTextController;
  String? Function(BuildContext, String?)? walletAddressTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    walletAddressFocusNode?.dispose();
    walletAddressTextController?.dispose();
  }
}
