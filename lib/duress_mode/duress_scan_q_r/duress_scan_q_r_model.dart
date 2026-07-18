import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'duress_scan_q_r_widget.dart' show DuressScanQRWidget;
import 'package:flutter/material.dart';

class DuressScanQRModel extends FlutterFlowModel<DuressScanQRWidget> {
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
