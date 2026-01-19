import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'auth_router_widget.dart' show AuthRouterWidget;
import 'package:flutter/material.dart';

class AuthRouterModel extends FlutterFlowModel<AuthRouterWidget> {
  ///  Local state fields for this page.

  bool hasRow = false;

  bool needPhone = true;

  bool verifiedViaEmail = false;

  List<DecoyWalletRow> dwList = [];
  void addToDwList(DecoyWalletRow item) => dwList.add(item);
  void removeFromDwList(DecoyWalletRow item) => dwList.remove(item);
  void removeAtIndexFromDwList(int index) => dwList.removeAt(index);
  void insertAtIndexInDwList(int index, DecoyWalletRow item) =>
      dwList.insert(index, item);
  void updateDwListAtIndex(int index, Function(DecoyWalletRow) updateFn) =>
      dwList[index] = updateFn(dwList[index]);

  String? dbgStep;

  bool dbgApiOk = false;

  int? dgbTokenLen = -1;

  String? dbgType;

  String? dbgTokenHead;

  String? authEmail;

  String? pendingEmail;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - refreshSupabaseSession] action in AuthRouter widget.
  dynamic refreshOut;
  // Stores action output result for [Backend Call - API (GetAuthUser)] action in AuthRouter widget.
  ApiCallResponse? authUserResp;
  // Stores action output result for [Backend Call - Query Rows] action in AuthRouter widget.
  List<DecoyWalletRow>? query1;
  // Stores action output result for [Backend Call - Insert Row] action in AuthRouter widget.
  DecoyWalletRow? firstInsert;
  // Stores action output result for [Backend Call - Query Rows] action in AuthRouter widget.
  List<DecoyWalletRow>? query2;
  // Stores action output result for [Backend Call - Update Row(s)] action in AuthRouter widget.
  List<DecoyWalletRow>? updateRows;
  // Stores action output result for [Backend Call - Query Rows] action in AuthRouter widget.
  List<DecoyWalletRow>? query3;
  bool authRouterBioResult = false;
  // Stores action output result for [Backend Call - Query Rows] action in AuthRouter widget.
  List<UserEntitlementsRow>? entitlementRow1;
  // Stores action output result for [Backend Call - Query Rows] action in AuthRouter widget.
  List<UserEntitlementsRow>? entitlementRow2;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
