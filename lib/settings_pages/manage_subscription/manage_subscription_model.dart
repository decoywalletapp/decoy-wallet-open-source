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

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Query Rows] action in ManageSubscription widget.
  List<UserEntitlementsRow>? manageQue;
  // Stores action output result for [Backend Call - API (CreateBTCPayInvoice)] action in Button widget.
  ApiCallResponse? apiResultk1h;
  // Stores action output result for [Backend Call - API (CreateBillingPortalSession)] action in Button widget.
  ApiCallResponse? checkoutResp;
  // Stores action output result for [Backend Call - API (CreateBillingPortalSession)] action in Button widget.
  ApiCallResponse? portalRespCancel;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
