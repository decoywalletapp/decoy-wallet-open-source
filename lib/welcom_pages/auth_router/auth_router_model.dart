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

  bool? setupComplete;

  bool? agreementsComplete;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - refreshSupabaseSession2] action in AuthRouter widget.
  bool? refreshingOuuu;
  // Stores action output result for [Custom Action - initPushTapListener] action in AuthRouter widget.
  String? pushRoute;
  // Stores action output result for [Custom Action - refreshSupabaseSession] action in AuthRouter widget.
  dynamic refreshOut;
  // Stores action output result for [Backend Call - API (GetAuthUser)] action in AuthRouter widget.
  ApiCallResponse? authUserResp;
  // Stores action output result for [Backend Call - API (getEmailHash)] action in AuthRouter widget.
  ApiCallResponse? emailHashResp;
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
  // Stores action output result for [Backend Call - Query Rows] action in AuthRouter widget.
  List<UserSettingsRow>? pushSettingsRows;
  // Stores action output result for [Custom Action - requestPushPermissionAndGetToken] action in AuthRouter widget.
  String? pushTokenRefreshResult;
  // Stores action output result for [Custom Action - getPushPermissionStatus] action in AuthRouter widget.
  bool? pushPermissionRefreshResult;
  bool authRouterBioResult = false;
  // Stores action output result for [Backend Call - Query Rows] action in AuthRouter widget.
  List<UserEntitlementsRow>? entitlementRow1;
  // Stores action output result for [Backend Call - API (RepairStripeEntitlement)] action in AuthRouter widget.
  ApiCallResponse? apiResultRSE;
  // Stores action output result for [Backend Call - Query Rows] action in AuthRouter widget.
  List<UserEntitlementsRow>? secondEntitlementQue;
  // Stores action output result for [Backend Call - Query Rows] action in AuthRouter widget.
  List<UserEntitlementsRow>? entitlementRow2;
  // Stores action output result for [Backend Call - API (RepairStripeEntitlement)] action in AuthRouter widget.
  ApiCallResponse? api2Result2RSE;
  // Stores action output result for [Backend Call - Query Rows] action in AuthRouter widget.
  List<UserEntitlementsRow>? thirdEntitlementQue;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
