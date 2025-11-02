import '/flutter_flow/flutter_flow_util.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'confirm_email_route_model.dart';
export 'confirm_email_route_model.dart';

class ConfirmEmailRouteWidget extends StatefulWidget {
  const ConfirmEmailRouteWidget({
    super.key,
    this.tokenHash,
    this.type,
  });

  final String? tokenHash;
  final String? type;

  static String routeName = 'ConfirmEmailRoute';
  static String routePath = '/confirm-email';

  @override
  State<ConfirmEmailRouteWidget> createState() =>
      _ConfirmEmailRouteWidgetState();
}

class _ConfirmEmailRouteWidgetState extends State<ConfirmEmailRouteWidget> {
  late ConfirmEmailRouteModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ConfirmEmailRouteModel());

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
