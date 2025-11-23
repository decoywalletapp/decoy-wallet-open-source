import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'confirm_email_page_widget.dart' show ConfirmEmailPageWidget;
import 'package:flutter/material.dart';

class ConfirmEmailPageModel extends FlutterFlowModel<ConfirmEmailPageWidget> {
  ///  Local state fields for this page.

  int? emailResubmitted = 0;

  bool resendLocked = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (supabaseResendSignupEmail)] action in Button widget.
  ApiCallResponse? apiResulte1h;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
