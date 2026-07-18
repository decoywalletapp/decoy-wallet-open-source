import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'decoy_pin_system_values_widget.dart' show DecoyPinSystemValuesWidget;
import 'package:flutter/material.dart';

class DecoyPinSystemValuesModel
    extends FlutterFlowModel<DecoyPinSystemValuesWidget> {
  ///  Local state fields for this page.

  String? entProvider;

  String? entProviderStatus;

  bool? entIsActive;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Query Rows] action in DecoyPinSystemValues widget.
  List<UserEntitlementsRow>? entitlementRowDPINVal;
  // State field(s) for PINPoliceTile widget.
  bool? pINPoliceTileValue;
  // State field(s) for PINEContactsTile widget.
  bool? pINEContactsTileValue;
  // Stores action output result for [Backend Call - Update Row(s)] action in Button widget.
  List<DecoyWalletRow>? upSysVals;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
