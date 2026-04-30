import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'notthispage_widget.dart' show NotthispageWidget;
import 'package:flutter/material.dart';

class NotthispageModel extends FlutterFlowModel<NotthispageWidget> {
  ///  Local state fields for this page.
  /// formats the user's phone number for twilio recognition
  String cleanPhone = '\"\"';

  String rawPhoneInput = '\"\"';

  bool skipChange = false;

  String? pnDigits10;

  int notificationInt = 0;

  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // State field(s) for PhoneNumberField widget.
  FocusNode? phoneNumberFieldFocusNode;
  TextEditingController? phoneNumberFieldTextController;
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
