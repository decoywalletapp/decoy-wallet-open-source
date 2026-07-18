import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'change_pin_widget.dart' show ChangePinWidget;
import 'package:flutter/material.dart';

class ChangePinModel extends FlutterFlowModel<ChangePinWidget> {
  ///  Local state fields for this page.
  /// Accepts User PIN Inputs
  List<String> newPinInput = [];
  void addToNewPinInput(String item) => newPinInput.add(item);
  void removeFromNewPinInput(String item) => newPinInput.remove(item);
  void removeAtIndexFromNewPinInput(int index) {
    if (index < 0 || index >= newPinInput.length) {
      return;
    }
    newPinInput.removeAt(index);
  }

  void insertAtIndexInNewPinInput(int index, String item) =>
      newPinInput.insert(index, item);
  void updateNewPinInputAtIndex(int index, Function(String) updateFn) =>
      newPinInput[index] = updateFn(newPinInput[index]);

  /// combines the string pin digits the user inputs
  String? joinedNewPin;

  int? currentStep = 1;

  List<String> confirmedNewPinInput = [];
  void addToConfirmedNewPinInput(String item) => confirmedNewPinInput.add(item);
  void removeFromConfirmedNewPinInput(String item) =>
      confirmedNewPinInput.remove(item);
  void removeAtIndexFromConfirmedNewPinInput(int index) {
    if (index < 0 || index >= confirmedNewPinInput.length) {
      return;
    }
    confirmedNewPinInput.removeAt(index);
  }

  void insertAtIndexInConfirmedNewPinInput(int index, String item) =>
      confirmedNewPinInput.insert(index, item);
  void updateConfirmedNewPinInputAtIndex(
          int index, Function(String) updateFn) =>
      confirmedNewPinInput[index] = updateFn(confirmedNewPinInput[index]);

  String? joinedConfirmNewPin;

  List<String> oldPinInput = [];
  void addToOldPinInput(String item) => oldPinInput.add(item);
  void removeFromOldPinInput(String item) => oldPinInput.remove(item);
  void removeAtIndexFromOldPinInput(int index) {
    if (index < 0 || index >= oldPinInput.length) {
      return;
    }
    oldPinInput.removeAt(index);
  }

  void insertAtIndexInOldPinInput(int index, String item) =>
      oldPinInput.insert(index, item);
  void updateOldPinInputAtIndex(int index, Function(String) updateFn) =>
      oldPinInput[index] = updateFn(oldPinInput[index]);

  String? joinedOldPin;

  int oldpNotificationValue = 0;

  int chngpNotifValue = 0;

  int? chngpConfirmValue = 0;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (setPIN)] action in Button widget.
  ApiCallResponse? setPinResp;
  // Stores action output result for [Backend Call - API (verifyPIN)] action in Button widget.
  ApiCallResponse? verifyResp;
  // Stores action output result for [Backend Call - API (verifyPIN)] action in Button widget.
  ApiCallResponse? verifyNewPIN;
  // Stores action output result for [Backend Call - API (verifyPIN)] action in Button widget.
  ApiCallResponse? verifyOldPinResp;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
