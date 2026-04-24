import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'emergency_contacts_widget.dart' show EmergencyContactsWidget;
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

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

  List<dynamic> contactsList = [];
  void addToContactsList(dynamic item) => contactsList.add(item);
  void removeFromContactsList(dynamic item) => contactsList.remove(item);
  void removeAtIndexFromContactsList(int index) => contactsList.removeAt(index);
  void insertAtIndexInContactsList(int index, dynamic item) =>
      contactsList.insert(index, item);
  void updateContactsListAtIndex(int index, Function(dynamic) updateFn) =>
      contactsList[index] = updateFn(contactsList[index]);

  int contactsCount = 0;

  String? c1PhoneDigits;

  String? c2PhoneDigits;

  String? c3PhoneDigits;

  String? c4PhoneDigits;

  String? c5PhoneDigits;

  String c1Status = 'not_sent';

  String c2Status = 'not_sent';

  String c3Status = 'not_sent';

  String c4Status = 'not_sent';

  String c5Status = 'not_sent';

  List<dynamic> consentSlotsList = [];
  void addToConsentSlotsList(dynamic item) => consentSlotsList.add(item);
  void removeFromConsentSlotsList(dynamic item) =>
      consentSlotsList.remove(item);
  void removeAtIndexFromConsentSlotsList(int index) =>
      consentSlotsList.removeAt(index);
  void insertAtIndexInConsentSlotsList(int index, dynamic item) =>
      consentSlotsList.insert(index, item);
  void updateConsentSlotsListAtIndex(int index, Function(dynamic) updateFn) =>
      consentSlotsList[index] = updateFn(consentSlotsList[index]);

  String c1First = '\"\"';

  String c1Last = '\"\"';

  String c1Phone = '\"\"';

  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // Stores action output result for [Backend Call - API (GetConsentStatuses)] action in EmergencyContacts widget.
  ApiCallResponse? topConsentResp;
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
  late MaskTextInputFormatter c1PhoneTFMask;
  String? Function(BuildContext, String?)? c1PhoneTFTextControllerValidator;
  // Stores action output result for [Custom Action - buildContactsPayloadV2] action in Button widget.
  String? contactsPayloadslot1;
  // Stores action output result for [Custom Action - generateDataKeyIfMissing] action in Button widget.
  String? keyOutslot1;
  // Stores action output result for [Custom Action - aesGcmEncryptString] action in Button widget.
  dynamic encslot1;
  // Stores action output result for [Backend Call - API (WrapDataKey)] action in Button widget.
  ApiCallResponse? wrapslot1;
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<DecoyWalletRow>? updslot1;
  // Stores action output result for [Backend Call - Update Row(s)] action in Button widget.
  List<DecoyWalletRow>? updRowslot1;
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<DecoyWalletRow>? decoyWalletRefresh1slot1;
  // Stores action output result for [Backend Call - Insert Row] action in Button widget.
  DecoyWalletRow? insRowslot1;
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<DecoyWalletRow>? decoyWalletRefresh2slot1;
  // Stores action output result for [Backend Call - API (SyncConsentSlots)] action in Button widget.
  ApiCallResponse? syncConsentRespslot1;
  // Stores action output result for [Backend Call - API (CreateConsentRequest)] action in Button widget.
  ApiCallResponse? createConsentResp1;
  // Stores action output result for [Backend Call - API (GetConsentStatuses)] action in Button widget.
  ApiCallResponse? ohcoolDiffslot1;
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
  late MaskTextInputFormatter c2PhoneTFMask;
  String? Function(BuildContext, String?)? c2PhoneTFTextControllerValidator;
  // Stores action output result for [Backend Call - API (CreateConsentRequest)] action in Button widget.
  ApiCallResponse? createConsentResp2;
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
  late MaskTextInputFormatter c3PhoneTFMask;
  String? Function(BuildContext, String?)? c3PhoneTFTextControllerValidator;
  // Stores action output result for [Backend Call - API (CreateConsentRequest)] action in Button widget.
  ApiCallResponse? createConsentResp3;
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
  late MaskTextInputFormatter c4PhoneTFMask;
  String? Function(BuildContext, String?)? c4PhoneTFTextControllerValidator;
  // Stores action output result for [Backend Call - API (CreateConsentRequest)] action in Button widget.
  ApiCallResponse? createConsentResp4;
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
  late MaskTextInputFormatter c5PhoneTFMask;
  String? Function(BuildContext, String?)? c5PhoneTFTextControllerValidator;
  // Stores action output result for [Backend Call - API (CreateConsentRequest)] action in Button widget.
  ApiCallResponse? createConsentResp5;
  // Stores action output result for [Custom Action - buildContactsPayloadV2] action in Button widget.
  String? contactsPayload;
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
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<DecoyWalletRow>? decoyWalletRefresh1;
  // Stores action output result for [Backend Call - Insert Row] action in Button widget.
  DecoyWalletRow? insRow;
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<DecoyWalletRow>? decoyWalletRefresh2;
  // Stores action output result for [Backend Call - API (SyncConsentSlots)] action in Button widget.
  ApiCallResponse? syncConsentResp;

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
