import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'auth_router_copy_widget.dart' show AuthRouterCopyWidget;
import 'package:flutter/material.dart';

class AuthRouterCopyModel extends FlutterFlowModel<AuthRouterCopyWidget> {
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

  // Stores action output result for [Custom Action - refreshSupabaseSession2] action in AuthRouterCopy widget.
  bool? refreshingOuuu;
  // Stores action output result for [Custom Action - refreshSupabaseSession] action in AuthRouterCopy widget.
  dynamic refreshOut;
  // Stores action output result for [Backend Call - API (GetAuthUser)] action in AuthRouterCopy widget.
  ApiCallResponse? authUserResp;
  // Stores action output result for [Backend Call - API (getEmailHash)] action in AuthRouterCopy widget.
  ApiCallResponse? emailHashResp;
  // Stores action output result for [Backend Call - Query Rows] action in AuthRouterCopy widget.
  List<DecoyWalletRow>? query1;
  // Stores action output result for [Backend Call - Insert Row] action in AuthRouterCopy widget.
  DecoyWalletRow? firstInsert;
  // Stores action output result for [Backend Call - Query Rows] action in AuthRouterCopy widget.
  List<DecoyWalletRow>? query2;
  // Stores action output result for [Backend Call - Update Row(s)] action in AuthRouterCopy widget.
  List<DecoyWalletRow>? updateRows;
  // Stores action output result for [Backend Call - Query Rows] action in AuthRouterCopy widget.
  List<DecoyWalletRow>? query3;
  bool authRouterBioResult = false;
  // Stores action output result for [Backend Call - Query Rows] action in AuthRouterCopy widget.
  List<UserEntitlementsRow>? entitlementRow1;
  // Stores action output result for [Backend Call - Query Rows] action in AuthRouterCopy widget.
  List<UserEntitlementsRow>? entitlementRow2;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
