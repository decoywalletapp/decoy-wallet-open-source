import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'control_center_widget.dart' show ControlCenterWidget;
import 'package:flutter/material.dart';

class ControlCenterModel extends FlutterFlowModel<ControlCenterWidget> {
  ///  Local state fields for this page.

  bool wantsBiometrics = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Query Rows] action in ControlCenter widget.
  List<DecoyWalletRow>? decoyWalletRow;
  // State field(s) for PINPoliceTile widget.
  bool? pINPoliceTileValue;
  // State field(s) for PINEContactsTile widget.
  bool? pINEContactsTileValue;
  // State field(s) for SeedMonitorArmTile widget.
  bool? seedMonitorArmTileValue;
  // State field(s) for BioSwitchTile widget.
  bool? bioSwitchTileValue;
  // State field(s) for LocationSwitchTile widget.
  bool? locationSwitchTileValue;
  // Stores action output result for [Backend Call - Update Row(s)] action in Button widget.
  List<DecoyWalletRow>? saveDecoySeedSettingspt2;
  bool settingsBioResult = false;
  // Stores action output result for [Backend Call - Update Row(s)] action in Button widget.
  List<DecoyWalletRow>? saveDecoySeedSettingspt3;
  // Stores action output result for [Backend Call - Update Row(s)] action in Button widget.
  List<DecoyWalletRow>? saveDecoySeedSettingspt4;
  // Stores action output result for [Backend Call - Update Row(s)] action in Button widget.
  List<DecoyWalletRow>? saveDecoySeedSettings;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
