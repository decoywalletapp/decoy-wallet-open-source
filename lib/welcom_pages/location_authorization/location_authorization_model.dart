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
  List<DecoyWalletRow>? falseQue;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
