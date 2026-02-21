import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'enable_notifications_widget.dart' show EnableNotificationsWidget;
import 'package:flutter/material.dart';

class EnableNotificationsModel
    extends FlutterFlowModel<EnableNotificationsWidget> {
  ///  Local state fields for this page.

  String pushTokenResultPS = '0';

  bool pushEnabledDraft = false;

  ///  State fields for stateful widgets in this page.

  // State field(s) for SwitchListTile widget.
  bool? switchListTileValue;
  // Stores action output result for [Custom Action - requestPushPermissionAndGetToken] action in SwitchListTile widget.
  String? pushTokenResult;
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<UserSettingsRow>? userSettingsRows;
  // Stores action output result for [Backend Call - Insert Row] action in Button widget.
  UserSettingsRow? userSettingsInsertResp;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
