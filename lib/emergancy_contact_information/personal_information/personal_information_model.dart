import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'personal_information_widget.dart' show PersonalInformationWidget;
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class PersonalInformationModel
    extends FlutterFlowModel<PersonalInformationWidget> {
  ///  Local state fields for this page.

  String? dataKeyB64;

  String? personalJson;

  String? ctB64;

  String? nonceB64;

  String? wrappedB64;

  int personalSaved = 0;

  String? rowCipherB64;

  String? rowNonceB64;

  String? origEmail;

  String? origPhone;

  String? cleanEmail;

  String? cleanPhone;

  String? changedEmail;

  String? changedPhone;

  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // Stores action output result for [Backend Call - Query Rows] action in PersonalInformation widget.
  List<DecoyWalletRow>? rows;
  // Stores action output result for [Custom Action - generateDataKeyIfMissing] action in PersonalInformation widget.
  String? dataKeyOut;
  // Stores action output result for [Custom Action - aesGcmDecryptToMap] action in PersonalInformation widget.
  dynamic personalObj;
  // Stores action output result for [Custom Action - generateDataKeyIfMissing] action in PersonalInformation widget.
  String? dataKeyOut2;
  // State field(s) for firstName widget.
  FocusNode? firstNameFocusNode;
  TextEditingController? firstNameTextController;
  String? Function(BuildContext, String?)? firstNameTextControllerValidator;
  // State field(s) for lastName widget.
  final lastNameKey = GlobalKey();
  FocusNode? lastNameFocusNode;
  TextEditingController? lastNameTextController;
  String? lastNameSelectedOption;
  String? Function(BuildContext, String?)? lastNameTextControllerValidator;
  // State field(s) for phone widget.
  FocusNode? phoneFocusNode;
  TextEditingController? phoneTextController;
  late MaskTextInputFormatter phoneMask;
  String? Function(BuildContext, String?)? phoneTextControllerValidator;
  // State field(s) for email widget.
  FocusNode? emailFocusNode;
  TextEditingController? emailTextController;
  String? Function(BuildContext, String?)? emailTextControllerValidator;
  // Stores action output result for [Custom Action - buildPersonalJson] action in Button widget.
  String? personalJsonOut;
  // Stores action output result for [Custom Action - generateDataKeyIfMissing] action in Button widget.
  String? keyOut;
  // Stores action output result for [Custom Action - aesGcmEncryptString] action in Button widget.
  dynamic enc;
  // Stores action output result for [Backend Call - API (WrapDataKey)] action in Button widget.
  ApiCallResponse? wrap;
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<DecoyWalletRow>? supaRows;
  // Stores action output result for [Backend Call - Update Row(s)] action in Button widget.
  List<DecoyWalletRow>? supaNameUpdate;
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<DecoyWalletRow>? refreshedDecoyWallet1;
  // Stores action output result for [Backend Call - API (getEmailHash)] action in Button widget.
  ApiCallResponse? changedEmailHash;
  // Stores action output result for [Backend Call - Update Row(s)] action in Button widget.
  List<DecoyWalletRow>? cngEmail;
  // Stores action output result for [Backend Call - Insert Row] action in Button widget.
  DecoyWalletRow? supaNameInserts;
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<DecoyWalletRow>? refreshedDecoyWallet2;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    firstNameFocusNode?.dispose();
    firstNameTextController?.dispose();

    lastNameFocusNode?.dispose();

    phoneFocusNode?.dispose();
    phoneTextController?.dispose();

    emailFocusNode?.dispose();
    emailTextController?.dispose();
  }
}
