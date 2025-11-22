import '/flutter_flow/flutter_flow_util.dart';
import 'control_center_widget.dart' show ControlCenterWidget;
import 'package:flutter/material.dart';

class ControlCenterModel extends FlutterFlowModel<ControlCenterWidget> {
  ///  Local state fields for this page.

  bool wantsBiometrics = false;

  ///  State fields for stateful widgets in this page.

  // State field(s) for PINPoliceTile widget.
  bool? pINPoliceTileValue;
  // State field(s) for PINEContactsTile widget.
  bool? pINEContactsTileValue;
  // State field(s) for SeedMonitorArmTile widget.
  bool? seedMonitorArmTileValue;
  // State field(s) for SeedEMSTile widget.
  bool? seedEMSTileValue;
  // State field(s) for BioSwitchTile widget.
  bool? bioSwitchTileValue;
  bool settingsBioResult = false;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
