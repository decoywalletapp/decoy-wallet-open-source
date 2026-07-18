import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'change_email_router_model.dart';
export 'change_email_router_model.dart';

class ChangeEmailRouterWidget extends StatefulWidget {
  const ChangeEmailRouterWidget({
    super.key,
    this.type,
  });

  final String? type;

  static String routeName = 'changeEmailRouter';
  static String routePath = '/changeEmailRouter';

  @override
  State<ChangeEmailRouterWidget> createState() =>
      _ChangeEmailRouterWidgetState();
}

class _ChangeEmailRouterWidgetState extends State<ChangeEmailRouterWidget> {
  late ChangeEmailRouterModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChangeEmailRouterModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(
        Duration(
          milliseconds: 400,
        ),
      );
      _model.dwQuery = await DecoyWalletTable().queryRows(
        queryFn: (q) => q
            .eqOrNull(
              'user_id',
              currentUserUid,
            )
            .order('created_at'),
      );
      _model.dwList = _model.dwQuery!.toList().cast<DecoyWalletRow>();
      _model.authEmail = currentUserEmail;
      _model.pendingEmail = _model.dwQuery?.elementAtOrNull(0)?.pendingEmail;
      _model.hasRow = _model.dwQuery != null && (_model.dwQuery)!.isNotEmpty;
      _model.needPhone = !_model.dwQuery!.elementAtOrNull(0)!.isPhoneVerified!;
      safeSetState(() {});
      if (_model.hasRow == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'ERROR #001 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT',
              style: TextStyle(
                color: FlutterFlowTheme.of(context).primaryText,
              ),
            ),
            duration: Duration(milliseconds: 4000),
            backgroundColor: FlutterFlowTheme.of(context).secondary,
          ),
        );
      } else {
        if (_model.pendingEmail != null && _model.pendingEmail != '') {
          await DecoyWalletTable().update(
            data: {
              'pending_email': null,
              'email_verified': true,
              'email_verified_at': supaSerialize<DateTime>(getCurrentTimestamp),
            },
            matchingRows: (rows) => rows.eqOrNull(
              'user_id',
              currentUserUid,
            ),
          );
          _model.authEmail = _model.pendingEmail;
          _model.pendingEmail = null;
          safeSetState(() {});
        }
        if (_model.needPhone == true) {
          context.goNamed(PhoneNumberInputWidget.routeName);
        } else {
          context.goNamed(HomePageWidget.routeName);
        }
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: PopScope(
        canPop: false,
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).info,
          body: SafeArea(
            top: true,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: AlignmentDirectional(0.0, 0.0),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(2.0, 0.0, 0.0, 0.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: Image.asset(
                        'assets/images/DecoyLogo1-WOHiRes.jpg',
                        width: 500.0,
                        height: 200.0,
                        fit: BoxFit.cover,
                        alignment: Alignment(0.0, 0.0),
                      ),
                    ),
                  ),
                ),
              ].addToEnd(SizedBox(height: 64.0)),
            ),
          ),
        ),
      ),
    );
  }
}
