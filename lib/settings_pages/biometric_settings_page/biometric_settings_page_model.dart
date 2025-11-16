import '/flutter_flow/flutter_flow_util.dart';
import 'biometric_settings_page_widget.dart' show BiometricSettingsPageWidget;
import 'package:flutter/material.dart';

class BiometricSettingsPageModel
    extends FlutterFlowModel<BiometricSettingsPageWidget> {
  ///  Local state fields for this page.

  bool wantsBiometrics = false;

  ///  State fields for stateful widgets in this page.

  // State field(s) for SwitchListTile widget.
  bool? switchListTileValue1;
  // State field(s) for SwitchListTile widget.
  bool? switchListTileValue2;
  bool settingsBioResult = false;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
