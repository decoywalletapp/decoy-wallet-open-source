import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'import_watch_only_wallet_widget.dart' show ImportWatchOnlyWalletWidget;
import 'package:flutter/material.dart';

class ImportWatchOnlyWalletModel
    extends FlutterFlowModel<ImportWatchOnlyWalletWidget> {
  /// State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  FocusNode? watchOnlyInputFocusNode;
  TextEditingController? watchOnlyInputTextController;
  String? Function(BuildContext, String?)?
      watchOnlyInputTextControllerValidator;

  dynamic watchOnlyDraftOut;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    watchOnlyInputFocusNode?.dispose();
    watchOnlyInputTextController?.dispose();
  }
}
