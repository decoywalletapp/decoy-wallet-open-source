import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'home_address_entry_pagedonzo_widget.dart'
    show HomeAddressEntryPagedonzoWidget;
import 'package:flutter/material.dart';

class HomeAddressEntryPagedonzoModel
    extends FlutterFlowModel<HomeAddressEntryPagedonzoWidget> {
  ///  Local state fields for this page.

  String? addressJson;

  String? dataKey;

  String? ctB64;

  String? nonceB64;

  String? wrappedB64;

  String? dataKeyB64;

  String? streetPV;

  String? cityPV;

  String? statePV;

  String? zipPV;

  String? countryPV;

  String? aptPV;

  String? rowCipherB64;

  String? rowNonceB64;

  int addressSaved = 0;

  String? debugJSON;

  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // Stores action output result for [Backend Call - Query Rows] action in HomeAddressEntryPagedonzo widget.
  List<DecoyWalletRow>? rows;
  // Stores action output result for [Custom Action - generateDataKeyIfMissing] action in HomeAddressEntryPagedonzo widget.
  String? dataKeyOut;
  // Stores action output result for [Custom Action - aesGcmDecryptToMap] action in HomeAddressEntryPagedonzo widget.
  dynamic addrObj;
  // Stores action output result for [Custom Action - generateDataKeyIfMissing] action in HomeAddressEntryPagedonzo widget.
  String? dataKeyOut2;
  // Stores action output result for [Custom Action - buildAddressPayloadV1] action in IconButton widget.
  String? playload;
  // Stores action output result for [Custom Action - generateDataKeyIfMissing] action in IconButton widget.
  String? keyOut;
  // Stores action output result for [Custom Action - aesGcmEncryptString] action in IconButton widget.
  dynamic enc;
  // Stores action output result for [Backend Call - API (WrapDataKey)] action in IconButton widget.
  ApiCallResponse? wrap;
  // Stores action output result for [Backend Call - Query Rows] action in IconButton widget.
  List<DecoyWalletRow>? supaRows;
  // Stores action output result for [Backend Call - Update Row(s)] action in IconButton widget.
  List<DecoyWalletRow>? updRow;
  // Stores action output result for [Backend Call - Query Rows] action in IconButton widget.
  List<DecoyWalletRow>? decoyWalletRefresh1;
  // Stores action output result for [Backend Call - Insert Row] action in IconButton widget.
  DecoyWalletRow? insRow;
  // Stores action output result for [Backend Call - Query Rows] action in IconButton widget.
  List<DecoyWalletRow>? decoyWalletRefresh2;
  // State field(s) for StreetAddress widget.
  final streetAddressKey = GlobalKey();
  FocusNode? streetAddressFocusNode;
  TextEditingController? streetAddressTextController;
  String? streetAddressSelectedOption;
  String? Function(BuildContext, String?)? streetAddressTextControllerValidator;
  // State field(s) for City widget.
  FocusNode? cityFocusNode;
  TextEditingController? cityTextController;
  String? Function(BuildContext, String?)? cityTextControllerValidator;
  // State field(s) for State widget.
  FocusNode? stateFocusNode;
  TextEditingController? stateTextController;
  String? Function(BuildContext, String?)? stateTextControllerValidator;
  // State field(s) for Zip widget.
  FocusNode? zipFocusNode;
  TextEditingController? zipTextController;
  String? Function(BuildContext, String?)? zipTextControllerValidator;
  // State field(s) for Country widget.
  FocusNode? countryFocusNode;
  TextEditingController? countryTextController;
  String? Function(BuildContext, String?)? countryTextControllerValidator;
  // State field(s) for Apartment widget.
  FocusNode? apartmentFocusNode;
  TextEditingController? apartmentTextController;
  String? Function(BuildContext, String?)? apartmentTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    streetAddressFocusNode?.dispose();

    cityFocusNode?.dispose();
    cityTextController?.dispose();

    stateFocusNode?.dispose();
    stateTextController?.dispose();

    zipFocusNode?.dispose();
    zipTextController?.dispose();

    countryFocusNode?.dispose();
    countryTextController?.dispose();

    apartmentFocusNode?.dispose();
    apartmentTextController?.dispose();
  }
}
