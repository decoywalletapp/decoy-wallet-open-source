import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'create_decoy_emergency_contacts_setup_widget.dart'
    show CreateDecoyEmergencyContactsSetupWidget;
import 'package:flutter/material.dart';

class CreateDecoyEmergencyContactsSetupModel
    extends FlutterFlowModel<CreateDecoyEmergencyContactsSetupWidget> {
  ///  Local state fields for this page.

  bool personalDone = false;

  bool addressDone = false;

  bool contactsDone = false;

  int completedCount = 0;

  double? progressValue = 0.0;

  int progressPercent = 0;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Query Rows] action in CreateDecoyEmergencyContactsSetup widget.
  List<DecoyWalletRow>? numberQue;

  // Stores action output result for [Backend Call - API (GetConsentStatuses)] action in CreateDecoyEmergencyContactsSetup widget.
  ApiCallResponse? consentStatusesResp;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
