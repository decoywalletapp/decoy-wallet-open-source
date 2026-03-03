import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'manage_subscription_widget.dart' show ManageSubscriptionWidget;
import 'package:flutter/material.dart';

class ManageSubscriptionModel
    extends FlutterFlowModel<ManageSubscriptionWidget> {
  ///  Local state fields for this page.

  String? provider;

  String? providerCustomerId;

  bool? isActive;

  String? providerSubscriptionId;

  bool pendingSwitchToStripe = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Query Rows] action in ManageSubscription widget.
  List<UserEntitlementsRow>? manageQue;
  // Stores action output result for [Backend Call - API (CreateBTCPayInvoice)] action in Button widget.
  ApiCallResponse? apiResultk1h;
  // Stores action output result for [Backend Call - API (CreateBillingPortalSession)] action in Button widget.
  ApiCallResponse? portalRespManage;
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<UserEntitlementsRow>? requery3;
  // Stores action output result for [Backend Call - API (CreateCheckoutSession)] action in Button widget.
  ApiCallResponse? apiResult5g4;
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<UserEntitlementsRow>? requery5;
  // Stores action output result for [Backend Call - API (CreateBillingPortalSession)] action in Button widget.
  ApiCallResponse? portalRespCancel;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
