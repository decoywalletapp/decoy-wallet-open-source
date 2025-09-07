import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'duress_home_page_widget.dart' show DuressHomePageWidget;
import 'package:flutter/material.dart';

class DuressHomePageModel extends FlutterFlowModel<DuressHomePageWidget> {
  ///  Local state fields for this page.

  List<double> btcPrices = [];
  void addToBtcPrices(double item) => btcPrices.add(item);
  void removeFromBtcPrices(double item) => btcPrices.remove(item);
  void removeAtIndexFromBtcPrices(int index) => btcPrices.removeAt(index);
  void insertAtIndexInBtcPrices(int index, double item) =>
      btcPrices.insert(index, item);
  void updateBtcPricesAtIndex(int index, Function(double) updateFn) =>
      btcPrices[index] = updateFn(btcPrices[index]);

  List<double> btcEpochMs = [];
  void addToBtcEpochMs(double item) => btcEpochMs.add(item);
  void removeFromBtcEpochMs(double item) => btcEpochMs.remove(item);
  void removeAtIndexFromBtcEpochMs(int index) => btcEpochMs.removeAt(index);
  void insertAtIndexInBtcEpochMs(int index, double item) =>
      btcEpochMs.insert(index, item);
  void updateBtcEpochMsAtIndex(int index, Function(double) updateFn) =>
      btcEpochMs[index] = updateFn(btcEpochMs[index]);

  double? currentPrice;

  double? firstPrice;

  double? pctChange1y;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (btcChartOneYear)] action in DuressHomePage widget.
  ApiCallResponse? priceResult;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
