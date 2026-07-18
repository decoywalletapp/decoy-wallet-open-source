import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'change_email_router_widget.dart' show ChangeEmailRouterWidget;
import 'package:flutter/material.dart';

class ChangeEmailRouterModel extends FlutterFlowModel<ChangeEmailRouterWidget> {
  ///  Local state fields for this page.

  List<DecoyWalletRow> dwList = [];
  void addToDwList(DecoyWalletRow item) => dwList.add(item);
  void removeFromDwList(DecoyWalletRow item) => dwList.remove(item);
  void removeAtIndexFromDwList(int index) => dwList.removeAt(index);
  void insertAtIndexInDwList(int index, DecoyWalletRow item) =>
      dwList.insert(index, item);
  void updateDwListAtIndex(int index, Function(DecoyWalletRow) updateFn) =>
      dwList[index] = updateFn(dwList[index]);

  String? authEmail;

  String? pendingEmail;

  bool hasRow = false;

  bool needPhone = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Query Rows] action in changeEmailRouter widget.
  List<DecoyWalletRow>? dwQuery;
  // Stores action output result for [Backend Call - Update Row(s)] action in changeEmailRouter widget.
  List<DecoyWalletRow>? swapEmailRows;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
