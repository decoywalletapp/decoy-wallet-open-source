import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'payment_return_model.dart';
export 'payment_return_model.dart';

class PaymentReturnWidget extends StatefulWidget {
  const PaymentReturnWidget({super.key});

  static String routeName = 'PaymentReturn';
  static String routePath = '/paymentreturn';

  @override
  State<PaymentReturnWidget> createState() => _PaymentReturnWidgetState();
}

class _PaymentReturnWidgetState extends State<PaymentReturnWidget> {
  late PaymentReturnModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PaymentReturnModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      FFAppState().entitlementCheckCompleted = false;
      FFAppState().hasActiveSubscription = false;
      safeSetState(() {});
      _model.entitlementsQuery = await UserEntitlementsTable().queryRows(
        queryFn: (q) => q
            .eqOrNull(
              'user_id',
              currentUserUid,
            )
            .eqOrNull(
              'entitlement',
              'decoy_wallet',
            ),
      );
      FFAppState().entitlementCheckCompleted = true;
      safeSetState(() {});
      if ((_model.entitlementsQuery != null &&
              (_model.entitlementsQuery)!.isNotEmpty) &&
          (_model.entitlementsQuery?.elementAtOrNull(0)?.isActive == true)) {
        FFAppState().hasActiveSubscription = true;
        safeSetState(() {});
        if (Navigator.of(context).canPop()) {
          context.pop();
        }
        context.pushNamed(HomePageWidget.routeName);
      } else {
        FFAppState().hasActiveSubscription = false;
        safeSetState(() {});
        if (Navigator.of(context).canPop()) {
          context.pop();
        }
        context.pushNamed(SubscriptionOptionsWidget.routeName);
      }
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
        body: SafeArea(
          top: true,
          child: Align(
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional(0.0, 0.0),
                    child: Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 30.0),
                      child: Text(
                        '₿itcoin Wallet',
                        textAlign: TextAlign.start,
                        style:
                            FlutterFlowTheme.of(context).displayMedium.override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .displayMediumFamily,
                                  color: FlutterFlowTheme.of(context).primary,
                                  letterSpacing: 0.0,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .displayMediumIsCustom,
                                ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
