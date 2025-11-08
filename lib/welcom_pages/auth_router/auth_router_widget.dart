import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'auth_router_model.dart';
export 'auth_router_model.dart';

class AuthRouterWidget extends StatefulWidget {
  const AuthRouterWidget({
    super.key,
    this.type,
    this.token,
    this.tokanHash,
  });

  final String? type;
  final String? token;
  final String? tokanHash;

  static String routeName = 'AuthRouter';
  static String routePath = '/authRouter';

  @override
  State<AuthRouterWidget> createState() => _AuthRouterWidgetState();
}

class _AuthRouterWidgetState extends State<AuthRouterWidget> {
  late AuthRouterModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AuthRouterModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.type!,
            style: TextStyle(
              color: FlutterFlowTheme.of(context).primaryText,
            ),
          ),
          duration: Duration(milliseconds: 4000),
          backgroundColor: FlutterFlowTheme.of(context).secondary,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.token!,
            style: TextStyle(
              color: FlutterFlowTheme.of(context).primaryText,
            ),
          ),
          duration: Duration(milliseconds: 4000),
          backgroundColor: FlutterFlowTheme.of(context).secondary,
        ),
      );
      if (widget.type == 'email_change') {
        if (widget.token != '') {
          _model.verifyEmailResp = await SupabaseVerifyEmailChangeCall.call(
            token: widget.token,
          );

          if ((_model.verifyEmailResp?.succeeded ?? true)) {
            _model.currentRow = await DecoyWalletTable().queryRows(
              queryFn: (q) => q.eqOrNull(
                'user_id',
                currentUserUid,
              ),
            );
            await DecoyWalletTable().update(
              data: {
                'email_verified': true,
                'email_verified_at':
                    supaSerialize<DateTime>(getCurrentTimestamp),
                'email': _model.currentRow?.elementAtOrNull(0)?.pendingEmail,
                'pending_email': null,
              },
              matchingRows: (rows) => rows.eqOrNull(
                'user_id',
                currentUserUid,
              ),
            );
            _model.userRowAfterVerify = await DecoyWalletTable().queryRows(
              queryFn: (q) => q
                  .eqOrNull(
                    'user_id',
                    currentUserUid,
                  )
                  .order('created_at'),
            );
            _model.verifiedViaEmail =
                _model.userRowAfterVerify!.elementAtOrNull(0)!.emailVerified!;
            _model.needPhone = !_model.userRowAfterVerify!
                .elementAtOrNull(0)!
                .isPhoneVerified!;
            safeSetState(() {});
            if (_model.needPhone == true) {
              context.pushNamed(PhoneNumberInputWidget.routeName);
            } else {
              context.pushNamed(PINPageWidget.routeName);
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'EMAIL CHANGE VERIFICATION FAILED',
                  style: TextStyle(
                    color: FlutterFlowTheme.of(context).primaryText,
                  ),
                ),
                duration: Duration(milliseconds: 4000),
                backgroundColor: FlutterFlowTheme.of(context).secondary,
              ),
            );

            context.pushNamed(AuthRouterWidget.routeName);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'MISSING TOKEN',
                style: TextStyle(
                  color: FlutterFlowTheme.of(context).primaryText,
                ),
              ),
              duration: Duration(milliseconds: 4000),
              backgroundColor: FlutterFlowTheme.of(context).secondary,
            ),
          );
        }
      } else {
        await Future.delayed(
          Duration(
            milliseconds: 600,
          ),
        );
        _model.query1 = await DecoyWalletTable().queryRows(
          queryFn: (q) => q
              .eqOrNull(
                'user_id',
                currentUserUid,
              )
              .order('created_at'),
        );
        _model.dwList = _model.query1!.toList().cast<DecoyWalletRow>();
        _model.hasRow = _model.query1 != null && (_model.query1)!.isNotEmpty;
        safeSetState(() {});
        if (_model.hasRow == false) {
          _model.firstInsert = await DecoyWalletTable().insert({
            'user_id': currentUserUid,
            'email': currentUserEmail,
            'email_verified': false,
            'email_verified_at': supaSerialize<DateTime>(null),
            'is_phone_verified': false,
            'created_at': supaSerialize<DateTime>(getCurrentTimestamp),
          });
          _model.query2 = await DecoyWalletTable().queryRows(
            queryFn: (q) => q.eqOrNull(
              'user_id',
              currentUserUid,
            ),
          );
          _model.dwList = _model.query2!.toList().cast<DecoyWalletRow>();
          _model.hasRow = _model.query2 != null && (_model.query2)!.isNotEmpty;
          safeSetState(() {});
        } else {
          await DecoyWalletTable().update(
            data: {
              'email_verified': true,
              'email_verified_at': supaSerialize<DateTime>(getCurrentTimestamp),
              'email': currentUserEmail,
            },
            matchingRows: (rows) => rows.eqOrNull(
              'user_id',
              currentUserUid,
            ),
          );
          _model.query3 = await DecoyWalletTable().queryRows(
            queryFn: (q) => q.eqOrNull(
              'user_id',
              currentUserUid,
            ),
          );
          _model.dwList = _model.query3!.toList().cast<DecoyWalletRow>();
          _model.hasRow = _model.query3 != null && (_model.query3)!.isNotEmpty;
          safeSetState(() {});
        }

        _model.verifiedViaEmail =
            _model.dwList.elementAtOrNull(0)!.emailVerified!;
        _model.needPhone = !_model.dwList.elementAtOrNull(0)!.isPhoneVerified!;
        safeSetState(() {});
        if (_model.verifiedViaEmail == false) {
          if (Navigator.of(context).canPop()) {
            context.pop();
          }
          context.pushNamed(ConfirmEmailPageWidget.routeName);
        } else {
          if (_model.needPhone == true) {
            if (Navigator.of(context).canPop()) {
              context.pop();
            }
            context.pushNamed(PhoneNumberInputWidget.routeName);
          } else {
            if (Navigator.of(context).canPop()) {
              context.pop();
            }
            context.pushNamed(PINPageWidget.routeName);
          }
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
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).info,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Align(
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
                        alignment: Alignment(0.0, 0.47),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
