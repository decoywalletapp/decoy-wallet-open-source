import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'payment_return_widget.dart' show PaymentReturnWidget;
import 'package:flutter/material.dart';

class PaymentReturnModel extends FlutterFlowModel<PaymentReturnWidget> {
  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (finalizeStripeSwitch)] action in PaymentReturn widget.
  ApiCallResponse? stripeSwitchSyncResult;
  // Stores action output result for [Backend Call - Query Rows] action in PaymentReturn widget.
  List<UserEntitlementsRow>? entitlementsQuery;
  // Stores action output result for [Backend Call - Query Rows] action in Text widget.
  List<UserEntitlementsRow>? entitlementsQueryRefresh;
  // Stores action output result for [Backend Call - Query Rows] action in Icon widget.
  List<UserEntitlementsRow>? entitlementsQueryRefreshButton;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
