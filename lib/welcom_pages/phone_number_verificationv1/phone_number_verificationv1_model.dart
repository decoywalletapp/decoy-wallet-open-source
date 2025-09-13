import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'phone_number_verificationv1_widget.dart'
    show PhoneNumberVerificationv1Widget;
import 'package:flutter/material.dart';

class PhoneNumberVerificationv1Model
    extends FlutterFlowModel<PhoneNumberVerificationv1Widget> {
  ///  Local state fields for this page.
  /// JoinUserVerificationCodeEntry
  String joinedCode = '';

  String d1 = '';

  String d2 = '';

  String d3 = '';

  String d4 = '';

  String d5 = '';

  String d6 = '';

  int? activeIndex = 1;

  int? invalidcodeState = 0;

  ///  State fields for stateful widgets in this page.

  // State field(s) for FirstDigit widget.
  FocusNode? firstDigitFocusNode;
  TextEditingController? firstDigitTextController;
  String? Function(BuildContext, String?)? firstDigitTextControllerValidator;
  // State field(s) for SecondDigit widget.
  FocusNode? secondDigitFocusNode;
  TextEditingController? secondDigitTextController;
  String? Function(BuildContext, String?)? secondDigitTextControllerValidator;
  // State field(s) for ThirdDigit widget.
  FocusNode? thirdDigitFocusNode;
  TextEditingController? thirdDigitTextController;
  String? Function(BuildContext, String?)? thirdDigitTextControllerValidator;
  // State field(s) for FourthDigit widget.
  FocusNode? fourthDigitFocusNode;
  TextEditingController? fourthDigitTextController;
  String? Function(BuildContext, String?)? fourthDigitTextControllerValidator;
  // State field(s) for FifthDigit widget.
  FocusNode? fifthDigitFocusNode;
  TextEditingController? fifthDigitTextController;
  String? Function(BuildContext, String?)? fifthDigitTextControllerValidator;
  // State field(s) for SixthDigit widget.
  FocusNode? sixthDigitFocusNode;
  TextEditingController? sixthDigitTextController;
  String? Function(BuildContext, String?)? sixthDigitTextControllerValidator;
  // Stores action output result for [Backend Call - API (CheckVerificationCode)] action in SixthDigit widget.
  ApiCallResponse? checkRes;
  // Stores action output result for [Backend Call - Update Row(s)] action in SixthDigit widget.
  List<DecoyWalletRow>? verifyUpdate;
  // Stores action output result for [Backend Call - API (setPhoneAuth)] action in SixthDigit widget.
  ApiCallResponse? setPhoneRes;
  // Stores action output result for [Backend Call - API (SendVerificationCode)] action in Icon widget.
  ApiCallResponse? sendResCopy;
  // Stores action output result for [Backend Call - API (SendVerificationCode)] action in Text widget.
  ApiCallResponse? sendRes;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    firstDigitFocusNode?.dispose();
    firstDigitTextController?.dispose();

    secondDigitFocusNode?.dispose();
    secondDigitTextController?.dispose();

    thirdDigitFocusNode?.dispose();
    thirdDigitTextController?.dispose();

    fourthDigitFocusNode?.dispose();
    fourthDigitTextController?.dispose();

    fifthDigitFocusNode?.dispose();
    fifthDigitTextController?.dispose();

    sixthDigitFocusNode?.dispose();
    sixthDigitTextController?.dispose();
  }
}
