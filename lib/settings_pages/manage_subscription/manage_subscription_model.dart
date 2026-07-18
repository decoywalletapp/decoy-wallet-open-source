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

  DateTime? currentPeriodEnd;

  String? pendingProvider;

  DateTime? pendingStartsAt;

  String? pendingProviderCustomerId;

  String? pendingProviderSubscriptionId;

  String? stripeCheckoutSessionId;

  bool refreshingEntitlement = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Query Rows] action in ManageSubscription widget.
  List<UserEntitlementsRow>? manageQue;
  // Stores action output result for [Backend Call - API (finalizeStripeSwitch)] action in ManageSubscription widget.
  ApiCallResponse? apiResultlc3;
  // Stores action output result for [Backend Call - API (finalizeBtcpaySwitch)] action in ManageSubscription widget.
  ApiCallResponse? btcpayFinalizeResp;
  // Stores action output result for [Backend Call - Query Rows] action in ManageSubscription widget.
  List<UserEntitlementsRow>? btcpayFinalQuery;
  // Stores action output result for [Backend Call - Query Rows] action in ManageSubscription widget.
  List<UserEntitlementsRow>? trueBranchQue;
  // Stores action output result for [Backend Call - API (CreateBTCPayInvoice)] action in Button widget.
  ApiCallResponse? apiResultk1h;
  // Stores action output result for [Backend Call - API (scheduleBtcpaySwitch)] action in Button widget.
  ApiCallResponse? btcSwitchResult;
  // Stores action output result for [Backend Call - API (CreateBTCPayInvoice)] action in Button widget.
  ApiCallResponse? fBAPIresult;
  // Stores action output result for [Backend Call - API (CreateBillingPortalSession)] action in Button widget.
  ApiCallResponse? portalRespManage;
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<UserEntitlementsRow>? requery3;
  // Stores action output result for [Backend Call - Update Row(s)] action in Button widget.
  List<UserEntitlementsRow>? setPendingStripeSwitch;
  // Stores action output result for [Backend Call - API (CreateCheckoutSession)] action in Button widget.
  ApiCallResponse? apiResult5g4;
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<UserEntitlementsRow>? requery5;
  // Stores action output result for [Backend Call - API (finalizeStripeSwitch)] action after returning from Stripe checkout.
  ApiCallResponse? stripeCheckoutSyncResult;
  // Stores action output result for [Backend Call - Query Rows] action after returning from Stripe checkout.
  List<UserEntitlementsRow>? stripeCheckoutRefreshQuery;
  // Stores action output result for [Backend Call - API (CreateBillingPortalSession)] action in Button widget.
  ApiCallResponse? portalRespCancel;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
