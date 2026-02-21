import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'location_authorization_widget.dart' show LocationAuthorizationWidget;
import 'package:flutter/material.dart';

class LocationAuthorizationModel
    extends FlutterFlowModel<LocationAuthorizationWidget> {
  ///  Local state fields for this page.

  bool wantsLocation = false;

  ///  State fields for stateful widgets in this page.

  // State field(s) for SwitchListTile widget.
  bool? switchListTileValue;
  // Stores action output result for [Backend Call - Update Row(s)] action in Button widget.
  List<DecoyWalletRow>? trueQue;
  // Stores action output result for [Backend Call - Update Row(s)] action in Button widget.
  List<UserSettingsRow>? updateLocalTB;
  // Stores action output result for [Backend Call - Update Row(s)] action in Button widget.
  List<DecoyWalletRow>? falseQue;
  // Stores action output result for [Backend Call - Update Row(s)] action in Button widget.
  List<UserSettingsRow>? updateLocalFB;
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<UserSettingsRow>? queLocal;
  // Stores action output result for [Backend Call - Update Row(s)] action in Button widget.
  List<UserSettingsRow>? updaterTB;
  // Stores action output result for [Backend Call - Insert Row] action in Button widget.
  UserSettingsRow? insertoFB;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
