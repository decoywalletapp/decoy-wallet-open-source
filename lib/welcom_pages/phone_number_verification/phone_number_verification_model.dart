import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/instant_timer.dart';
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

  int secondsLeft = 0;

  bool canResend = false;

  int secondsRemaining = 60;

  ///  State fields for stateful widgets in this page.

  InstantTimer? instantTimer;
  // State field(s) for PhoneCode widget.
  FocusNode? phoneCodeFocusNode;
  TextEditingController? phoneCodeTextController;
  String? Function(BuildContext, String?)? phoneCodeTextControllerValidator;
  // Stores action output result for [Backend Call - API (CheckVerificationCode)] action in PhoneCode widget.
  ApiCallResponse? checkCodeRes;
  // Stores action output result for [Backend Call - API (getPhoneHash)] action in PhoneCode widget.
  ApiCallResponse? phoneHashResp;
  // Stores action output result for [Backend Call - API (getEmailHash)] action in PhoneCode widget.
  ApiCallResponse? emailHashResp;
  // Stores action output result for [Custom Action - generateDataKeyIfMissing] action in PhoneCode widget.
  String? dataKeyB64;
  // Stores action output result for [Backend Call - Query Rows] action in PhoneCode widget.
  List<DecoyWalletRow>? existingPersonalRows;
  // Stores action output result for [Custom Action - aesGcmDecryptToMap] action in PhoneCode widget.
  dynamic existingPersonalObj;
  // Stores action output result for [Backend Call - API (WrapDataKey)] action in PhoneCode widget.
  ApiCallResponse? wrapResp;
  // Stores action output result for [Custom Action - buildPersonalJson] action in PhoneCode widget.
  String? personalJson;
  // Stores action output result for [Custom Action - aesGcmEncryptString] action in PhoneCode widget.
  dynamic encPersonal;
  // Stores action output result for [Backend Call - Update Row(s)] action in PhoneCode widget.
  List<DecoyWalletRow>? verifyUpdate;
  // Stores action output result for [Backend Call - Query Rows] action in PhoneCode widget.
  List<DecoyWalletRow>? dwSetupRows;
  // Stores action output result for [Backend Call - Insert Row] action in PhoneCode widget.
  DecoyWalletRow? verifyInsert;
  // Stores action output result for [Backend Call - API (SendVerificationCode)] action in Icon widget.
  ApiCallResponse? sendResCopy;
  InstantTimer? instantTimerResend1;
  // Stores action output result for [Backend Call - API (SendVerificationCode)] action in Text widget.
  ApiCallResponse? sendRes;
  InstantTimer? instantTimerResend2;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    instantTimer?.cancel();
    phoneCodeFocusNode?.dispose();
    phoneCodeTextController?.dispose();

    instantTimerResend1?.cancel();
    instantTimerResend2?.cancel();
  }
}
