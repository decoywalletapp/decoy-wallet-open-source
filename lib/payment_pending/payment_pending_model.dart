import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/instant_timer.dart';
import '/index.dart';
import 'payment_pending_widget.dart' show PaymentPendingWidget;
import 'package:flutter/material.dart';

class PaymentPendingModel extends FlutterFlowModel<PaymentPendingWidget> {
  ///  State fields for stateful widgets in this page.

  InstantTimer? instantTimer;
  // Stores action output result for [Backend Call - Query Rows] action in PaymentPending widget.
  List<UserEntitlementsRow>? apiResult1sf;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    instantTimer?.cancel();
  }
}
