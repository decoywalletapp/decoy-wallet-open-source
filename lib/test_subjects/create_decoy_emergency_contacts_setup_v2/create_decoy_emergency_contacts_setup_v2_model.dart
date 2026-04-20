import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'create_decoy_emergency_contacts_setup_v2_widget.dart'
    show CreateDecoyEmergencyContactsSetupV2Widget;
import 'package:flutter/material.dart';

class CreateDecoyEmergencyContactsSetupV2Model
    extends FlutterFlowModel<CreateDecoyEmergencyContactsSetupV2Widget> {
  ///  Local state fields for this page.

  bool personalDone = false;

  bool addressDone = false;

  bool contactsDone = false;

  int completedCount = 0;

  double? progressValue = 0.0;

  int progressPercent = 0;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Query Rows] action in CreateDecoyEmergencyContactsSetupV2 widget.
  List<DecoyWalletRow>? numberQue;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
