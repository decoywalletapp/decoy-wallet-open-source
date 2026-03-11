import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'decoy_seed_system_values_widget.dart' show DecoySeedSystemValuesWidget;
import 'package:flutter/material.dart';

class DecoySeedSystemValuesModel
    extends FlutterFlowModel<DecoySeedSystemValuesWidget> {
  ///  Local state fields for this page.

  String? entDSprovider;

  String? entDSProviderStatus;

  bool? entDSactive;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Query Rows] action in DecoySeedSystemValues widget.
  List<UserEntitlementsRow>? entitlementSeedVal;
  // State field(s) for SeedMonitorArmTile widget.
  bool? seedMonitorArmTileValue;
  // Stores action output result for [Backend Call - API (commitDecoy)] action in Button widget.
  ApiCallResponse? commitResp;
  // Stores action output result for [Backend Call - Update Row(s)] action in Button widget.
  List<DecoyWalletRow>? saveDecoySeedSettings;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
