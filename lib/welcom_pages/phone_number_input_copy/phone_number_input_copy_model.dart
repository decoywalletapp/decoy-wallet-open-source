import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'phone_number_input_copy_widget.dart' show PhoneNumberInputCopyWidget;
import 'package:flutter/material.dart';

class PhoneNumberInputCopyModel
    extends FlutterFlowModel<PhoneNumberInputCopyWidget> {
  ///  Local state fields for this page.
  /// formats the user's phone number for twilio recognition
  String cleanPhone = '\"\"';

  String rawPhoneInput = '\"\"';

  bool skipChange = false;

  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // Stores action output result for [Custom Action - getSupabaseJwt] action in phoneNumberInputCopy widget.
  String? soResult;
  // State field(s) for PhoneNumberField widget.
  FocusNode? phoneNumberFieldFocusNode;
  TextEditingController? phoneNumberFieldTextController;
  String? Function(BuildContext, String?)?
      phoneNumberFieldTextControllerValidator;
  // State field(s) for FocusTrapTF widget.
  FocusNode? focusTrapTFFocusNode;
  TextEditingController? focusTrapTFTextController;
  String? Function(BuildContext, String?)? focusTrapTFTextControllerValidator;
  // Stores action output result for [Backend Call - API (SendVerificationCode)] action in Button widget.
  ApiCallResponse? sendRes;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    phoneNumberFieldFocusNode?.dispose();
    phoneNumberFieldTextController?.dispose();

    focusTrapTFFocusNode?.dispose();
    focusTrapTFTextController?.dispose();
  }
}
