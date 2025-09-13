import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'phone_number_verification_widget.dart'
    show PhoneNumberVerificationWidget;
import 'package:flutter/material.dart';

class PhoneNumberVerificationModel
    extends FlutterFlowModel<PhoneNumberVerificationWidget> {
  ///  Local state fields for this page.
  /// JoinUserVerificationCodeEntry
  String joinedCode = '';

  int? invalidcodeState = 0;

  String code = '\"\"';

  String cleanPhone = '\"\"';

  String otpCode = '\"\"';

  dynamic checkRes;

  String errorText = '\"\"';

  String phoneCode = '\"\"';

  ///  State fields for stateful widgets in this page.

  // State field(s) for PhoneCode widget.
  FocusNode? phoneCodeFocusNode;
  TextEditingController? phoneCodeTextController;
  String? Function(BuildContext, String?)? phoneCodeTextControllerValidator;
  // Stores action output result for [Backend Call - API (CheckVerificationCode)] action in PhoneCode widget.
  ApiCallResponse? checkCodeRes;
  // Stores action output result for [Backend Call - Update Row(s)] action in PhoneCode widget.
  List<DecoyWalletRow>? verifyUpdate;
  // Stores action output result for [Backend Call - API (setPhoneAuth)] action in PhoneCode widget.
  ApiCallResponse? setPhoneRes;
  // Stores action output result for [Backend Call - API (SendVerificationCode)] action in Icon widget.
  ApiCallResponse? sendResCopy;
  // Stores action output result for [Backend Call - API (SendVerificationCode)] action in Text widget.
  ApiCallResponse? sendRes;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    phoneCodeFocusNode?.dispose();
    phoneCodeTextController?.dispose();
  }
}
