import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/instant_timer.dart';
import '/index.dart';
import 'duress_processing_transaction_widget.dart'
    show DuressProcessingTransactionWidget;
import 'package:flutter/material.dart';

class DuressProcessingTransactionModel
    extends FlutterFlowModel<DuressProcessingTransactionWidget> {
  ///  Local state fields for this page.

  int totalMins = 60;

  DateTime? startAt;

  int elapsedMins = 0;

  int remainingMins = 60;

  double progress01 = 0.0;

  bool isCounting = false;

  ///  State fields for stateful widgets in this page.

  InstantTimer? pagetimers;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    pagetimers?.cancel();
  }
}
