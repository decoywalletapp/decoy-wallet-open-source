import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'biometric_verification_widget.dart' show BiometricVerificationWidget;
import 'package:flutter/material.dart';

class BiometricVerificationModel
    extends FlutterFlowModel<BiometricVerificationWidget> {
  ///  Local state fields for this page.

  bool wantsBiometrics = false;

  ///  State fields for stateful widgets in this page.

  // State field(s) for SwitchListTile widget.
  bool? switchListTileValue;
  bool enableBioResult = false;
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<UserSettingsRow>? bioInsertRows;
  // Stores action output result for [Backend Call - Update Row(s)] action in Button widget.
  List<UserSettingsRow>? bioUpdateBE;
  // Stores action output result for [Backend Call - Insert Row] action in Button widget.
  UserSettingsRow? bioInsertBE;
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<UserSettingsRow>? bioInsertRowsFB;
  // Stores action output result for [Backend Call - Update Row(s)] action in Button widget.
  List<UserSettingsRow>? bioUpdateBEFB;
  // Stores action output result for [Backend Call - Insert Row] action in Button widget.
  UserSettingsRow? bioInsertBEFB;
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<UserSettingsRow>? bioInsertRowsFBSkipper;
  // Stores action output result for [Backend Call - Update Row(s)] action in Button widget.
  List<UserSettingsRow>? bioUpdateBEFBSkipper;
  // Stores action output result for [Backend Call - Insert Row] action in Button widget.
  UserSettingsRow? bioInsertBEFBSkipper;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
