import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'emergency_contacts_widget.dart' show EmergencyContactsWidget;
import 'package:flutter/material.dart';

class EmergencyContactsModel extends FlutterFlowModel<EmergencyContactsWidget> {
  ///  Local state fields for this page.

  int contactIncrement = 0;

  String contactsJson = '\"\"';

  int validCount = 0;

  String dataKeyB64 = '\"\"';

  String ctB64 = '\"\"';

  String nonceB64 = '\"\"';

  String wrappedB64 = '\"\"';

  String? rowCipherB64;

  String? rowNonceB64;

  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // Stores action output result for [Backend Call - Query Rows] action in EmergencyContacts widget.
  List<DecoyWalletRow>? rows;
  // Stores action output result for [Custom Action - generateDataKeyIfMissing] action in EmergencyContacts widget.
  String? dataKeyOut;
  // Stores action output result for [Custom Action - aesGcmDecryptToMap] action in EmergencyContacts widget.
  dynamic contactsObj;
  // Stores action output result for [Custom Action - generateDataKeyIfMissing] action in EmergencyContacts widget.
  String? dataKeyOut2;
  // State field(s) for c1FirstTF widget.
  FocusNode? c1FirstTFFocusNode;
  TextEditingController? c1FirstTFTextController;
  String? Function(BuildContext, String?)? c1FirstTFTextControllerValidator;
  // State field(s) for c1LastTF widget.
  FocusNode? c1LastTFFocusNode;
  TextEditingController? c1LastTFTextController;
  String? Function(BuildContext, String?)? c1LastTFTextControllerValidator;
  // State field(s) for c1PhoneTF widget.
  FocusNode? c1PhoneTFFocusNode;
  TextEditingController? c1PhoneTFTextController;
  String? Function(BuildContext, String?)? c1PhoneTFTextControllerValidator;
  // State field(s) for c2FirstTF widget.
  FocusNode? c2FirstTFFocusNode;
  TextEditingController? c2FirstTFTextController;
  String? Function(BuildContext, String?)? c2FirstTFTextControllerValidator;
  // State field(s) for c2LastTF widget.
  FocusNode? c2LastTFFocusNode;
  TextEditingController? c2LastTFTextController;
  String? Function(BuildContext, String?)? c2LastTFTextControllerValidator;
  // State field(s) for c2PhoneTF widget.
  FocusNode? c2PhoneTFFocusNode;
  TextEditingController? c2PhoneTFTextController;
  String? Function(BuildContext, String?)? c2PhoneTFTextControllerValidator;
  // State field(s) for c3FirstTF widget.
  FocusNode? c3FirstTFFocusNode;
  TextEditingController? c3FirstTFTextController;
  String? Function(BuildContext, String?)? c3FirstTFTextControllerValidator;
  // State field(s) for c3LastTF widget.
  FocusNode? c3LastTFFocusNode;
  TextEditingController? c3LastTFTextController;
  String? Function(BuildContext, String?)? c3LastTFTextControllerValidator;
  // State field(s) for c3PhoneTF widget.
  FocusNode? c3PhoneTFFocusNode;
  TextEditingController? c3PhoneTFTextController;
  String? Function(BuildContext, String?)? c3PhoneTFTextControllerValidator;
  // State field(s) for c4FirstTF widget.
  FocusNode? c4FirstTFFocusNode;
  TextEditingController? c4FirstTFTextController;
  String? Function(BuildContext, String?)? c4FirstTFTextControllerValidator;
  // State field(s) for c4LastTF widget.
  FocusNode? c4LastTFFocusNode;
  TextEditingController? c4LastTFTextController;
  String? Function(BuildContext, String?)? c4LastTFTextControllerValidator;
  // State field(s) for c4PhoneTF widget.
  FocusNode? c4PhoneTFFocusNode;
  TextEditingController? c4PhoneTFTextController;
  String? Function(BuildContext, String?)? c4PhoneTFTextControllerValidator;
  // State field(s) for c5FirstTF widget.
  FocusNode? c5FirstTFFocusNode;
  TextEditingController? c5FirstTFTextController;
  String? Function(BuildContext, String?)? c5FirstTFTextControllerValidator;
  // State field(s) for c5LastTF widget.
  FocusNode? c5LastTFFocusNode;
  TextEditingController? c5LastTFTextController;
  String? Function(BuildContext, String?)? c5LastTFTextControllerValidator;
  // State field(s) for c5PhoneTF widget.
  FocusNode? c5PhoneTFFocusNode;
  TextEditingController? c5PhoneTFTextController;
  String? Function(BuildContext, String?)? c5PhoneTFTextControllerValidator;
  // Stores action output result for [Custom Action - buildContactsPayloadV2] action in Button widget.
  dynamic contactsPayload;
  // Stores action output result for [Custom Action - getSupabaseJwt] action in Button widget.
  String? jwtOut;
  // Stores action output result for [Custom Action - generateDataKeyIfMissing] action in Button widget.
  String? keyOut;
  // Stores action output result for [Custom Action - aesGcmEncryptString] action in Button widget.
  dynamic enc;
  // Stores action output result for [Backend Call - API (WrapDataKey)] action in Button widget.
  ApiCallResponse? wrap;
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<DecoyWalletRow>? upd;
  // Stores action output result for [Backend Call - Update Row(s)] action in Button widget.
  List<DecoyWalletRow>? updRow;
  // Stores action output result for [Backend Call - Insert Row] action in Button widget.
  DecoyWalletRow? insRow;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    c1FirstTFFocusNode?.dispose();
    c1FirstTFTextController?.dispose();

    c1LastTFFocusNode?.dispose();
    c1LastTFTextController?.dispose();

    c1PhoneTFFocusNode?.dispose();
    c1PhoneTFTextController?.dispose();

    c2FirstTFFocusNode?.dispose();
    c2FirstTFTextController?.dispose();

    c2LastTFFocusNode?.dispose();
    c2LastTFTextController?.dispose();

    c2PhoneTFFocusNode?.dispose();
    c2PhoneTFTextController?.dispose();

    c3FirstTFFocusNode?.dispose();
    c3FirstTFTextController?.dispose();

    c3LastTFFocusNode?.dispose();
    c3LastTFTextController?.dispose();

    c3PhoneTFFocusNode?.dispose();
    c3PhoneTFTextController?.dispose();

    c4FirstTFFocusNode?.dispose();
    c4FirstTFTextController?.dispose();

    c4LastTFFocusNode?.dispose();
    c4LastTFTextController?.dispose();

    c4PhoneTFFocusNode?.dispose();
    c4PhoneTFTextController?.dispose();

    c5FirstTFFocusNode?.dispose();
    c5FirstTFTextController?.dispose();

    c5LastTFFocusNode?.dispose();
    c5LastTFTextController?.dispose();

    c5PhoneTFFocusNode?.dispose();
    c5PhoneTFTextController?.dispose();
  }
}
