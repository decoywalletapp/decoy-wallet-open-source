import '/flutter_flow/flutter_flow_util.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'duress_scan_q_rv2_model.dart';
export 'duress_scan_q_rv2_model.dart';

/// Create a page that allows the user to scan a QR code or paste a receive
/// address in a box, and then at the bottom of the page allows the user to
/// select send funds button.
///
/// I want a big portion of the top of the screen to be what the phone camera
/// user's phone camera sees. Underneath of that, I want the box where the
/// user can paste the corresponding receive address.
class DuressScanQRv2Widget extends StatefulWidget {
  const DuressScanQRv2Widget({super.key});

  static String routeName = 'DuressScanQRv2';
  static String routePath = '/duressScanQRv2';

  @override
  State<DuressScanQRv2Widget> createState() => _DuressScanQRv2WidgetState();
}

class _DuressScanQRv2WidgetState extends State<DuressScanQRv2Widget> {
  late DuressScanQRv2Model _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DuressScanQRv2Model());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      ),
    );
  }
}
