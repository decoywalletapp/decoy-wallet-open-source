import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'phone_number_input_widget.dart' show PhoneNumberInputWidget;
import 'package:flutter/material.dart';

class PhoneNumberInputModel extends FlutterFlowModel<PhoneNumberInputWidget> {
  ///  Local state fields for this page.
  /// formats the user's phone number for twilio recognition
  String cleanPhone = '\"\"';

  String rawPhoneInput = '\"\"';

  bool skipChange = false;

  String? pnDigits10;

  int notificationInt = 0;

  String? phoneHash;

  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // State field(s) for PhoneNumberField widget.
  final phoneNumberFieldKey = GlobalKey();
  FocusNode? phoneNumberFieldFocusNode;
  TextEditingController? phoneNumberFieldTextController;
  String? phoneNumberFieldSelectedOption;
  String? Function(BuildContext, String?)?
      phoneNumberFieldTextControllerValidator;
  // Stores action output result for [Backend Call - API (getPhoneHash)] action in Button widget.
  ApiCallResponse? phoneHashResp;
  // Stores action output result for [Backend Call - API (checkPhoneTaken)] action in Button widget.
  ApiCallResponse? phoneTakenResp;
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<DecoyWalletRow>? phoneLookupRows;
  // Stores action output result for [Backend Call - API (SendVerificationCode)] action in Button widget.
  ApiCallResponse? sendRes;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    phoneNumberFieldFocusNode?.dispose();
  }
}
