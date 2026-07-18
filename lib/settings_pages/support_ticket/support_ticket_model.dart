import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'support_ticket_widget.dart' show SupportTicketWidget;
import 'package:flutter/material.dart';

class SupportTicketModel extends FlutterFlowModel<SupportTicketWidget> {
  ///  Local state fields for this page.

  int ticketSaved = 1;

  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // State field(s) for subjectField widget.
  FocusNode? subjectFieldFocusNode;
  TextEditingController? subjectFieldTextController;
  String? Function(BuildContext, String?)? subjectFieldTextControllerValidator;
  // State field(s) for messageField widget.
  FocusNode? messageFieldFocusNode;
  TextEditingController? messageFieldTextController;
  String? Function(BuildContext, String?)? messageFieldTextControllerValidator;
  // Stores action output result for [Backend Call - API (sendSupportTicket)] action in Button widget.
  ApiCallResponse? sendTicket;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    subjectFieldFocusNode?.dispose();
    subjectFieldTextController?.dispose();

    messageFieldFocusNode?.dispose();
    messageFieldTextController?.dispose();
  }
}
