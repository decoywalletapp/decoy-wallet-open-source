import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'p_i_n_page_widget.dart' show PINPageWidget;
import 'package:flutter/material.dart';

class PINPageModel extends FlutterFlowModel<PINPageWidget> {
  ///  Local state fields for this page.
  /// Accepts User PIN Inputs
  List<String> pinInput = [];
  void addToPinInput(String item) => pinInput.add(item);
  void removeFromPinInput(String item) => pinInput.remove(item);
  void removeAtIndexFromPinInput(int index) => pinInput.removeAt(index);
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
  void removeAtIndexFromConfirmedPinInput(int index) =>
      confirmedPinInput.removeAt(index);
  void insertAtIndexInConfirmedPinInput(int index, String item) =>
      confirmedPinInput.insert(index, item);
  void updateConfirmedPinInputAtIndex(int index, Function(String) updateFn) =>
      confirmedPinInput[index] = updateFn(confirmedPinInput[index]);

  String? joinedPinConfirm;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - hashPin] action in Button widget.
  String? hashedLoginPIN;
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<DecoyWalletRow>? matchingPINEntry;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
