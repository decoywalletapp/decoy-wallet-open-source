import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'personal_information_widget.dart' show PersonalInformationWidget;
import 'package:flutter/material.dart';

class PersonalInformationModel
    extends FlutterFlowModel<PersonalInformationWidget> {
  ///  Local state fields for this page.

  String? dataKeyB64;

  String? personalJson;

  String? ctB64;

  String? nonceB64;

  String? wrappedB64;

  int personalSaved = 0;

  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // State field(s) for firstName widget.
  FocusNode? firstNameFocusNode;
  TextEditingController? firstNameTextController;
  String? Function(BuildContext, String?)? firstNameTextControllerValidator;
  // State field(s) for lastName widget.
  FocusNode? lastNameFocusNode;
  TextEditingController? lastNameTextController;
  String? Function(BuildContext, String?)? lastNameTextControllerValidator;
  // State field(s) for phone widget.
  FocusNode? phoneFocusNode;
  TextEditingController? phoneTextController;
  String? Function(BuildContext, String?)? phoneTextControllerValidator;
  // State field(s) for email widget.
  FocusNode? emailFocusNode;
  TextEditingController? emailTextController;
  String? Function(BuildContext, String?)? emailTextControllerValidator;
  // Stores action output result for [Custom Action - buildPersonalJson] action in Button widget.
  String? personalJsonOut;
  // Stores action output result for [Custom Action - generateDataKeyIfMissing] action in Button widget.
  String? dek;
  // Stores action output result for [Custom Action - aesGcmEncryptString] action in Button widget.
  dynamic enc;
  // Stores action output result for [Backend Call - API (WrapDataKey)] action in Button widget.
  ApiCallResponse? wrap;
  // Stores action output result for [Backend Call - Insert Row] action in Button widget.
  DecoyWalletRow? supaNameInserts;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    firstNameFocusNode?.dispose();
    firstNameTextController?.dispose();

    lastNameFocusNode?.dispose();
    lastNameTextController?.dispose();

    phoneFocusNode?.dispose();
    phoneTextController?.dispose();

    emailFocusNode?.dispose();
    emailTextController?.dispose();
  }
}
