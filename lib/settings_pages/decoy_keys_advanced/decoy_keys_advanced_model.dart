import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'decoy_keys_advanced_widget.dart' show DecoyKeysAdvancedWidget;
import 'package:flutter/material.dart';

class DecoyKeysAdvancedModel extends FlutterFlowModel<DecoyKeysAdvancedWidget> {
  /// Local state fields for this page.

  bool isLoading = true;

  bool isSaving = false;

  String? errorMessage;

  bool masterArmed = false;

  List<dynamic> monitors = [];

  List<dynamic> originalMonitors = [];

  Set<String> changedMonitorIds = {};

  Set<String> deletedMonitorIds = {};

  /// Stores action output result for [Backend Call - API] actions.
  ApiCallResponse? loadResp;
  ApiCallResponse? updateResp;
  ApiCallResponse? deleteResp;
  ApiCallResponse? bulkSaveResp;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
