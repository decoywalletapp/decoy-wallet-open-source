import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'create_decoy_pin_widget.dart' show CreateDecoyPinWidget;
import 'package:flutter/material.dart';

class CreateDecoyPinModel extends FlutterFlowModel<CreateDecoyPinWidget> {
  ///  Local state fields for this page.
  /// Accepts User PIN Inputs
  List<String> pinDecoyInput = [];
  void addToPinDecoyInput(String item) => pinDecoyInput.add(item);
  void removeFromPinDecoyInput(String item) => pinDecoyInput.remove(item);
  void removeAtIndexFromPinDecoyInput(int index) {
    if (index < 0 || index >= pinDecoyInput.length) {
      return;
    }
    pinDecoyInput.removeAt(index);
  }

  void insertAtIndexInPinDecoyInput(int index, String item) =>
      pinDecoyInput.insert(index, item);
  void updatePinDecoyInputAtIndex(int index, Function(String) updateFn) =>
      pinDecoyInput[index] = updateFn(pinDecoyInput[index]);

  /// combines the string pin digits the user inputs
  String? joinedPin;

  int? currentStep = 1;

  List<String> confirmedDecoyPinInput = [];
  void addToConfirmedDecoyPinInput(String item) =>
      confirmedDecoyPinInput.add(item);
  void removeFromConfirmedDecoyPinInput(String item) =>
      confirmedDecoyPinInput.remove(item);
  void removeAtIndexFromConfirmedDecoyPinInput(int index) {
    if (index < 0 || index >= confirmedDecoyPinInput.length) {
      return;
    }
    confirmedDecoyPinInput.removeAt(index);
  }

  void insertAtIndexInConfirmedDecoyPinInput(int index, String item) =>
      confirmedDecoyPinInput.insert(index, item);
  void updateConfirmedDecoyPinInputAtIndex(
          int index, Function(String) updateFn) =>
      confirmedDecoyPinInput[index] = updateFn(confirmedDecoyPinInput[index]);

  String? joinedPinConfirm;

  String? joinedDecoyPin;

  String? joinedDecoyConfirm;

  String? hashedDecoyPIN;

  int notificationValue = 0;

  int confirmNotificationValue = 0;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (verifyPIN)] action in Button widget.
  ApiCallResponse? verifyMe;
  // Stores action output result for [Backend Call - API (setPIN)] action in Button widget.
  ApiCallResponse? setPinResp;
  // Stores action output result for [Backend Call - API (verifyPIN)] action in Button widget.
  ApiCallResponse? verifyResp;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
