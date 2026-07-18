import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'update_password_page_widget.dart' show UpdatePasswordPageWidget;
import 'package:flutter/material.dart';

class UpdatePasswordPageModel
    extends FlutterFlowModel<UpdatePasswordPageWidget> {
  ///  Local state fields for this page.

  int notificationState = 0;

  ///  State fields for stateful widgets in this page.

  // State field(s) for Password widget.
  FocusNode? passwordFocusNode;
  TextEditingController? passwordTextController;
  late bool passwordVisibility;
  String? Function(BuildContext, String?)? passwordTextControllerValidator;
  // State field(s) for ConfirmUpdatedPassword widget.
  FocusNode? confirmUpdatedPasswordFocusNode;
  TextEditingController? confirmUpdatedPasswordTextController;
  late bool confirmUpdatedPasswordVisibility;
  String? Function(BuildContext, String?)?
      confirmUpdatedPasswordTextControllerValidator;
  // Stores action output result for [Custom Action - supaUpdatePassword] action in UpdatePassword widget.
  bool? passUpdate;

  @override
  void initState(BuildContext context) {
    passwordVisibility = false;
    confirmUpdatedPasswordVisibility = false;
  }

  @override
  void dispose() {
    passwordFocusNode?.dispose();
    passwordTextController?.dispose();

    confirmUpdatedPasswordFocusNode?.dispose();
    confirmUpdatedPasswordTextController?.dispose();
  }
}
