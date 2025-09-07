import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'phone_number_input_widget.dart' show PhoneNumberInputWidget;
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class PhoneNumberInputModel extends FlutterFlowModel<PhoneNumberInputWidget> {
  ///  Local state fields for this page.
  /// formats the user's phone number for twilio recognition
  String cleanPhone = '\"\"';

  String rawPhoneInput = '\"\"';

  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // State field(s) for PhoneNumberField widget.
  FocusNode? phoneNumberFieldFocusNode;
  TextEditingController? phoneNumberFieldTextController;
  late MaskTextInputFormatter phoneNumberFieldMask;
  String? Function(BuildContext, String?)?
      phoneNumberFieldTextControllerValidator;
  // Stores action output result for [Backend Call - API (SendVerificationCode)] action in Button widget.
  ApiCallResponse? sendRes;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    phoneNumberFieldFocusNode?.dispose();
    phoneNumberFieldTextController?.dispose();
  }
}
