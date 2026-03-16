import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'bitcoin_payment_options_widget.dart' show BitcoinPaymentOptionsWidget;
import 'package:flutter/material.dart';

class BitcoinPaymentOptionsModel
    extends FlutterFlowModel<BitcoinPaymentOptionsWidget> {
  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (CreateBTCPayInvoice)] action in Button widget.
  ApiCallResponse? apiResultk1h;
  // Stores action output result for [Backend Call - API (CreateCheckoutSession)] action in Button widget.
  ApiCallResponse? checkoutResp;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
