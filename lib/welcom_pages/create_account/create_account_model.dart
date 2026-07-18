import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'create_account_widget.dart' show CreateAccountWidget;
import 'package:flutter/material.dart';

class CreateAccountModel extends FlutterFlowModel<CreateAccountWidget> {
  ///  Local state fields for this page.

  int notificationState = 0;

  ///  State fields for stateful widgets in this page.

  // State field(s) for EmailAddress widget.
  final emailAddressKey = GlobalKey();
  FocusNode? emailAddressFocusNode;
  TextEditingController? emailAddressTextController;
  String? emailAddressSelectedOption;
  String? Function(BuildContext, String?)? emailAddressTextControllerValidator;
  // State field(s) for PasswordCreateAccount widget.
  final passwordCreateAccountKey = GlobalKey();
  FocusNode? passwordCreateAccountFocusNode;
  TextEditingController? passwordCreateAccountTextController;
  String? passwordCreateAccountSelectedOption;
  late bool passwordCreateAccountVisibility;
  String? Function(BuildContext, String?)?
      passwordCreateAccountTextControllerValidator;
  // State field(s) for PasswordConfirm widget.
  final passwordConfirmKey = GlobalKey();
  FocusNode? passwordConfirmFocusNode;
  TextEditingController? passwordConfirmTextController;
  String? passwordConfirmSelectedOption;
  late bool passwordConfirmVisibility;
  String? Function(BuildContext, String?)?
      passwordConfirmTextControllerValidator;
  // Stores action output result for [Custom Action - supaEmailSignUp] action in Button widget.
  String? ctResult;

  @override
  void initState(BuildContext context) {
    passwordCreateAccountVisibility = false;
    passwordConfirmVisibility = false;
  }

  @override
  void dispose() {
    emailAddressFocusNode?.dispose();

    passwordCreateAccountFocusNode?.dispose();

    passwordConfirmFocusNode?.dispose();
  }
}
