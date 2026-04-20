import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'decoy_pin_acknowledgements_widget.dart'
    show DecoyPinAcknowledgementsWidget;
import 'package:flutter/material.dart';

class DecoyPinAcknowledgementsModel
    extends FlutterFlowModel<DecoyPinAcknowledgementsWidget> {
  ///  Local state fields for this page.

  bool boxesSelected = false;

  ///  State fields for stateful widgets in this page.

  // State field(s) for Checkbox widget.
  bool? checkboxValue1;
  // State field(s) for Checkbox widget.
  bool? checkboxValue2;
  // State field(s) for Checkbox widget.
  bool? checkboxValue3;
  // Stores action output result for [Backend Call - Insert Row] action in Button widget.
  UserConsentsRow? ins1;
  // Stores action output result for [Backend Call - Update Row(s)] action in Button widget.
  List<DecoyWalletRow>? up1;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
