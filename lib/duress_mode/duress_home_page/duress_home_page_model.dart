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

  double? pctChange24h;

  DateTime? lastUpdatedAt;

  bool? pricePulseUp;

  List<dynamic> prices1y = [];
  void addToPrices1y(dynamic item) => prices1y.add(item);
  void removeFromPrices1y(dynamic item) => prices1y.remove(item);
  void removeAtIndexFromPrices1y(int index) => prices1y.removeAt(index);
  void insertAtIndexInPrices1y(int index, dynamic item) =>
      prices1y.insert(index, item);
  void updatePrices1yAtIndex(int index, Function(dynamic) updateFn) =>
      prices1y[index] = updateFn(prices1y[index]);

  List<dynamic> btcDates = [];
  void addToBtcDates(dynamic item) => btcDates.add(item);
  void removeFromBtcDates(dynamic item) => btcDates.remove(item);
  void removeAtIndexFromBtcDates(int index) => btcDates.removeAt(index);
  void insertAtIndexInBtcDates(int index, dynamic item) =>
      btcDates.insert(index, item);
  void updateBtcDatesAtIndex(int index, Function(dynamic) updateFn) =>
      btcDates[index] = updateFn(btcDates[index]);

  bool chartReady = false;

  int retryCount = 0;

  int refreshChart = 0;

  bool isLoadingChart = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (btcChartOneYear)] action in DuressHomePage widget.
  ApiCallResponse? btcResp;
  // Stores action output result for [Backend Call - API (btcChartOneYear)] action in DuressHomePage widget.
  ApiCallResponse? btcResp2;
  // Stores action output result for [Backend Call - API (btcChartOneYear)] action in DuressHomePage widget.
  ApiCallResponse? btcResp3;
  // Stores action output result for [Backend Call - API (btcChartOneYear)] action in IconButton widget.
  ApiCallResponse? btcResp4;
  // Stores action output result for [Backend Call - API (btcChartOneYear)] action in IconButton widget.
  ApiCallResponse? btcResp5;
  // Stores action output result for [Backend Call - API (btcCurrentPrice)] action in DuressHomePage widget.
  ApiCallResponse? currentPriceResp;
  // Stores action output result for [Backend Call - API (btcCurrentPrice)] action in live refresh timer.
  ApiCallResponse? currentPriceRefreshResp;
  // Stores action output result for [Backend Call - API (btcCoinbaseStats)] action in live refresh timer.
  ApiCallResponse? currentPriceStatsResp;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
