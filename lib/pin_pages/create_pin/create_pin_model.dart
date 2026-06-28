import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'create_pin_widget.dart' show CreatePinWidget;
import 'package:flutter/material.dart';

class CreatePinModel extends FlutterFlowModel<CreatePinWidget> {
  ///  Local state fields for this page.
  /// Accepts User PIN Inputs
  List<String> pinInput = [];
  void addToPinInput(String item) => pinInput.add(item);
  void removeFromPinInput(String item) => pinInput.remove(item);
  void removeAtIndexFromPinInput(int index) {
    if (index < 0 || index >= pinInput.length) {
      return;
    }
    pinInput.removeAt(index);
  }

  void insertAtIndexInPinInput(int index, String item) =>
      pinInput.insert(index, item);
  void updatePinInputAtIndex(int index, Function(String) updateFn) =>
      pinInput[index] = updateFn(pinInput[index]);

  /// combines the string pin digits the user inputs
  String? joinedPin;

  int? currentStep = 1;

  List<String> confirmedPinInput = [];
  void addToConfirmedPinInput(String item) => confirmedPinInput.add(item);
  void removeFromConfirmedPinInput(String item) =>
      confirmedPinInput.remove(item);
  void removeAtIndexFromConfirmedPinInput(int index) {
    if (index < 0 || index >= confirmedPinInput.length) {
      return;
    }
    confirmedPinInput.removeAt(index);
  }

  void insertAtIndexInConfirmedPinInput(int index, String item) =>
      confirmedPinInput.insert(index, item);
  void updateConfirmedPinInputAtIndex(int index, Function(String) updateFn) =>
      confirmedPinInput[index] = updateFn(confirmedPinInput[index]);

  String? joinedPinConfirm;

  int cpnotificationValue = 0;

  int cpconfirmValue = 0;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (setPIN)] action in Button widget.
  ApiCallResponse? setPinResp;
  // Stores action output result for [Backend Call - API (verifyPIN)] action in Button widget.
  ApiCallResponse? verifyResp;
  // Stores action output result for [Backend Call - Update Row(s)] action in Button widget.
  List<DecoyWalletRow>? updateSetupComplete;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
