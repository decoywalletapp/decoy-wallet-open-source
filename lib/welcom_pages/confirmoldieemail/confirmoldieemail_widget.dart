import '/flutter_flow/flutter_flow_util.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'confirmoldieemail_model.dart';
export 'confirmoldieemail_model.dart';

class ConfirmoldieemailWidget extends StatefulWidget {
  const ConfirmoldieemailWidget({super.key});

  static String routeName = 'confirmoldieemail';
  static String routePath = '/confirm-email';

  @override
  State<ConfirmoldieemailWidget> createState() =>
      _ConfirmoldieemailWidgetState();
}

class _ConfirmoldieemailWidgetState extends State<ConfirmoldieemailWidget> {
  late ConfirmoldieemailModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ConfirmoldieemailModel());

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
