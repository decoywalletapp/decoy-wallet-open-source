import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'create_decoy_emergency_contacts_setup_copy_widget.dart'
    show CreateDecoyEmergencyContactsSetupCopyWidget;
import 'package:flutter/material.dart';

class CreateDecoyEmergencyContactsSetupCopyModel
    extends FlutterFlowModel<CreateDecoyEmergencyContactsSetupCopyWidget> {
  ///  Local state fields for this page.

  bool personalDone = false;

  bool addressDone = false;

  bool contactsDone = false;

  int completedCount = 0;

  double? progressValue = 0.0;

  int progressPercent = 0;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Query Rows] action in CreateDecoyEmergencyContactsSetupCopy widget.
  List<DecoyWalletRow>? numberQue;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
