import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'control_center_widget.dart' show ControlCenterWidget;
import 'package:flutter/material.dart';

class ControlCenterModel extends FlutterFlowModel<ControlCenterWidget> {
  ///  Local state fields for this page.

  bool wantsBiometrics = false;

  bool? entIsActive;

  bool? pushPermissionGranted;

  bool? locationPermissionGranted;

  bool? biometricPermissionGranted;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Query Rows] action in ControlCenter widget.
  List<DecoyWalletRow>? decoyWalletRow;
  // Stores action output result for [Backend Call - Query Rows] action in ControlCenter widget.
  List<UserEntitlementsRow>? ctrlOutputEntitlements;
  // Stores action output result for [Custom Action - getBiometricPermissionStatus] action in ControlCenter widget.
  bool? getBioPermissionResult;
  // Stores action output result for [Custom Action - getPushPermissionStatus] action in ControlCenter widget.
  bool? pushStatusResult;
  // Stores action output result for [Custom Action - requestPushPermissionAndGetToken] action in ControlCenter widget.
  String? pushTokenSyncResult;
  // Stores action output result for [Custom Action - getPushPermissionStatus] action in ControlCenter widget.
  bool? pushPermissionRefreshResult;
  // Stores action output result for [Custom Action - getLocationPermissionStatus] action in ControlCenter widget.
  bool? getLocationPremissionResults;
  // State field(s) for PINPoliceTile widget.
  bool? pINPoliceTileValue;
  // State field(s) for PINEContactsTile widget.
  bool? pINEContactsTileValue;
  // State field(s) for SeedMonitorArmTile widget.
  bool? seedMonitorArmTileValue;
  // State field(s) for BioSwitchTile widget.
  bool? bioSwitchTileValue;
  // State field(s) for PushNotifTile widget.
  bool? pushNotifTileValue;
  // State field(s) for LocationSwitchTile widget.
  bool? locationSwitchTileValue;
  // Stores action output result for [Backend Call - Update Row(s)] action in Button widget.
  List<DecoyWalletRow>? saveDecoySeedSettingspt2;
  // Stores action output result for [Backend Call - Update Row(s)] action in Button widget.
  List<UserSettingsRow>? bioValuesTrueBranch;
  bool settingsBioResult = false;
  // Stores action output result for [Backend Call - Update Row(s)] action in Button widget.
  List<DecoyWalletRow>? saveDecoySeedSettingspt3;
  // Stores action output result for [Backend Call - Update Row(s)] action in Button widget.
  List<UserSettingsRow>? bioValuesBETrueBranch;
  // Stores action output result for [Backend Call - Update Row(s)] action in Button widget.
  List<DecoyWalletRow>? saveDecoySeedSettingspt4;
  // Stores action output result for [Backend Call - Update Row(s)] action in Button widget.
  List<UserSettingsRow>? bioValuesSetBEFB;
  // Stores action output result for [Backend Call - Update Row(s)] action in Button widget.
  List<DecoyWalletRow>? saveDecoySeedSettings;
  // Stores action output result for [Backend Call - Update Row(s)] action in Button widget.
  List<UserSettingsRow>? bioValuesBEFalseBranch;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
