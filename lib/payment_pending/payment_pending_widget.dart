import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/instant_timer.dart';
import '/index.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'payment_pending_model.dart';
export 'payment_pending_model.dart';

class PaymentPendingWidget extends StatefulWidget {
  const PaymentPendingWidget({super.key});

  static String routeName = 'PaymentPending';
  static String routePath = '/paymentPending';

  @override
  State<PaymentPendingWidget> createState() => _PaymentPendingWidgetState();
}

class _PaymentPendingWidgetState extends State<PaymentPendingWidget> {
  late PaymentPendingModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PaymentPendingModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      FFAppState().isCheckingEntitlement = true;
      safeSetState(() {});
      _model.instantTimer = InstantTimer.periodic(
        duration: Duration(milliseconds: 2000),
        callback: (timer) async {
          _model.apiResult1sf = await UserEntitlementsTable().queryRows(
            queryFn: (q) => q
                .eqOrNull(
                  'user_id',
                  currentUserUid,
                )
                .eqOrNull(
                  'entitlement',
                  'decoy_wallet',
                )
                .eqOrNull(
                  'is_active',
                  true,
                ),
          );
          if (_model.apiResult1sf != null &&
              (_model.apiResult1sf)!.isNotEmpty) {
            FFAppState().isCheckingEntitlement = false;
            safeSetState(() {});
            _model.instantTimer?.cancel();

            context.pushNamed(HomePageWidget.routeName);
          }
        },
        startImmediately: true,
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

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
