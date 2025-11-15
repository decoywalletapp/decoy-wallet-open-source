import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'dup_auth_model.dart';
export 'dup_auth_model.dart';

class DupAuthWidget extends StatefulWidget {
  const DupAuthWidget({
    super.key,
    this.type,
  });

  final String? type;

  static String routeName = 'DupAuth';
  static String routePath = '/dupAuth';

  @override
  State<DupAuthWidget> createState() => _DupAuthWidgetState();
}

class _DupAuthWidgetState extends State<DupAuthWidget> {
  late DupAuthModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DupAuthModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      FFAppState().isLocked = true;
      safeSetState(() {});
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
      _model.authEmail = _model.query1?.elementAtOrNull(0)?.email;
      _model.pendingEmail = _model.query1?.elementAtOrNull(0)?.pendingEmail;
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
        if (_model.pendingEmail != null && _model.pendingEmail != '') {
          await DecoyWalletTable().update(
            data: {
              'email_verified': true,
              'email_verified_at': supaSerialize<DateTime>(getCurrentTimestamp),
              'email': _model.pendingEmail,
              'pending_email': null,
            },
            matchingRows: (rows) => rows.eqOrNull(
              'user_id',
              currentUserUid,
            ),
          );
          _model.dbgStep = 'promotedPendingEmail';
          safeSetState(() {});
          _model.authEmail = _model.pendingEmail;
          _model.pendingEmail = null;
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
      }

      _model.verifiedViaEmail =
          _model.dwList.elementAtOrNull(0)!.emailVerified!;
      _model.needPhone = !_model.dwList.elementAtOrNull(0)!.isPhoneVerified!;
      safeSetState(() {});
      if (_model.verifiedViaEmail == false) {
        if (Navigator.of(context).canPop()) {
          context.pop();
        }
        context.pushNamedAuth(
            ConfirmEmailPageWidget.routeName, context.mounted);
      } else {
        if (_model.needPhone == true) {
          if (Navigator.of(context).canPop()) {
            context.pop();
          }
          context.pushNamedAuth(
              PhoneNumberInputWidget.routeName, context.mounted);
        } else {
          if (FFAppState().biometricsEnabled == true) {
            final _localAuth = LocalAuthentication();
            bool _isBiometricSupported = await _localAuth.isDeviceSupported();

            if (_isBiometricSupported) {
              try {
                _model.authRouterBioResult = await _localAuth.authenticate(
                    localizedReason:
                        'Please authenticate to unlock your wallet');
              } on PlatformException {
                _model.authRouterBioResult = false;
              }
              safeSetState(() {});
            }

            if (_model.authRouterBioResult == true) {
              FFAppState().isLocked = false;
              safeSetState(() {});

              context.pushNamedAuth(PINPageWidget.routeName, context.mounted);
            } else {
              GoRouter.of(context).prepareAuthEvent();
              await authManager.signOut();
              GoRouter.of(context).clearRedirectLocation();

              FFAppState().isLocked = false;
              safeSetState(() {});

              context.pushNamedAuth(LoginPageWidget.routeName, context.mounted);
            }
          } else {
            FFAppState().isLocked = false;
            safeSetState(() {});
            if (Navigator.of(context).canPop()) {
              context.pop();
            }
            context.pushNamedAuth(PINPageWidget.routeName, context.mounted);
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
    context.watch<FFAppState>();

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
              Container(
                width: 264.17,
                height: 317.8,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                ),
                child: Align(
                  alignment: AlignmentDirectional(0.0, -1.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Align(
                            alignment: AlignmentDirectional(-1.0, 0.0),
                            child: Text(
                              'auth router',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
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
