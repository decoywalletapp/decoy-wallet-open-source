import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'create_account_b4_change_widget.dart' show CreateAccountB4ChangeWidget;
import 'package:flutter/material.dart';

class CreateAccountB4ChangeModel
    extends FlutterFlowModel<CreateAccountB4ChangeWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for EmailAddress widget.
  FocusNode? emailAddressFocusNode;
  TextEditingController? emailAddressTextController;
  String? Function(BuildContext, String?)? emailAddressTextControllerValidator;
  // State field(s) for PasswordCreateAccount widget.
  FocusNode? passwordCreateAccountFocusNode;
  TextEditingController? passwordCreateAccountTextController;
  late bool passwordCreateAccountVisibility;
  String? Function(BuildContext, String?)?
      passwordCreateAccountTextControllerValidator;
  // State field(s) for PasswordConfirm widget.
  FocusNode? passwordConfirmFocusNode;
  TextEditingController? passwordConfirmTextController;
  late bool passwordConfirmVisibility;
  String? Function(BuildContext, String?)?
      passwordConfirmTextControllerValidator;

  @override
  void initState(BuildContext context) {
    passwordCreateAccountVisibility = false;
    passwordConfirmVisibility = false;
  }

  @override
  void dispose() {
    emailAddressFocusNode?.dispose();
    emailAddressTextController?.dispose();

    passwordCreateAccountFocusNode?.dispose();
    passwordCreateAccountTextController?.dispose();

    passwordConfirmFocusNode?.dispose();
    passwordConfirmTextController?.dispose();
  }
}
