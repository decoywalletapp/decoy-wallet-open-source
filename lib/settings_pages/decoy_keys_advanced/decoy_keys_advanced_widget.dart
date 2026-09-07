import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/utils/android_display_guard.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'decoy_keys_advanced_model.dart';
export 'decoy_keys_advanced_model.dart';

class DecoyKeysAdvancedWidget extends StatefulWidget {
  const DecoyKeysAdvancedWidget({super.key});

  static String routeName = 'DecoyKeysAdvanced';
  static String routePath = '/decoyKeysAdvanced';

  @override
  State<DecoyKeysAdvancedWidget> createState() =>
      _DecoyKeysAdvancedWidgetState();
}

class _DecoyKeysAdvancedWidgetState extends State<DecoyKeysAdvancedWidget> {
  late DecoyKeysAdvancedModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DecoyKeysAdvancedModel());

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await _loadMonitors();
    });
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Future<void> _loadMonitors() async {
    final jwt = currentJwtToken.trim();
    if (jwt.isEmpty) {
      safeSetState(() {
        _model.isLoading = false;
        _model.errorMessage = 'Please sign in again to manage Decoy Keys.';
      });
      return;
    }

    safeSetState(() {
      _model.isLoading = true;
      _model.errorMessage = null;
    });

    try {
      _model.loadResp = await ManageDecoyMonitorsCall.call(
        jwt: jwt,
        action: 'list',
      );
      _applyMonitorResponse(_model.loadResp);
    } catch (_) {
      safeSetState(() {
        _model.isLoading = false;
        _model.errorMessage = 'Unable to load Decoy Keys monitors.';
      });
    }
  }

  void _applyMonitorResponse(ApiCallResponse? response) {
    if (response?.succeeded != true) {
      final rawError = response == null
          ? ''
          : ManageDecoyMonitorsCall.error(response.jsonBody).toString();
      safeSetState(() {
        _model.isLoading = false;
        _model.isSaving = false;
        _model.errorMessage = rawError.isNotEmpty
            ? rawError
            : 'Unable to update Decoy Keys monitors.';
      });
      return;
    }

    final monitors = ManageDecoyMonitorsCall.monitors(response!.jsonBody) ?? [];
    final masterArmed =
        ManageDecoyMonitorsCall.masterArmed(response.jsonBody) ??
            FFAppState().decoySeedArmed;

    safeSetState(() {
      _model.monitors = List<dynamic>.from(monitors);
      _model.masterArmed = masterArmed;
      _model.isLoading = false;
      _model.isSaving = false;
      _model.errorMessage = null;
    });
  }

  Future<void> _setMonitorActive(String monitorId, bool active) async {
    final jwt = currentJwtToken.trim();
    if (jwt.isEmpty || monitorId.isEmpty) {
      _showSnack('Please sign in again to update this monitor.');
      return;
    }

    safeSetState(() {
      _model.isSaving = true;
      _model.errorMessage = null;
    });

    try {
      _model.updateResp = await ManageDecoyMonitorsCall.call(
        jwt: jwt,
        action: 'setActive',
        monitorId: monitorId,
        active: active,
      );
      _applyMonitorResponse(_model.updateResp);
    } catch (_) {
      safeSetState(() {
        _model.isSaving = false;
        _model.errorMessage = 'Unable to update this monitor.';
      });
    }
  }

  Future<void> _deleteMonitor(Map<String, dynamic> monitor) async {
    final monitorId = _text(monitor['id']);
    if (monitorId.isEmpty) {
      _showSnack('Unable to delete this monitor.');
      return;
    }

    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Delete monitor?'),
              content: Text(
                'This removes ${_monitorTitle(monitor)} from Decoy Keys monitoring.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: Text(
                    'Delete',
                    style: TextStyle(
                      color: FlutterFlowTheme.of(context).error,
                    ),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed) return;

    final jwt = currentJwtToken.trim();
    if (jwt.isEmpty) {
      _showSnack('Please sign in again to delete this monitor.');
      return;
    }

    safeSetState(() {
      _model.isSaving = true;
      _model.errorMessage = null;
    });

    try {
      _model.deleteResp = await ManageDecoyMonitorsCall.call(
        jwt: jwt,
        action: 'delete',
        monitorId: monitorId,
      );
      _applyMonitorResponse(_model.deleteResp);
    } catch (_) {
      safeSetState(() {
        _model.isSaving = false;
        _model.errorMessage = 'Unable to delete this monitor.';
      });
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Map<String, dynamic> _monitorMap(dynamic monitor) {
    if (monitor is Map<String, dynamic>) return monitor;
    if (monitor is Map) return Map<String, dynamic>.from(monitor);
    return <String, dynamic>{};
  }

  String _text(dynamic value) => value?.toString().trim() ?? '';

  String _monitorTitle(Map<String, dynamic> monitor) {
    final title = _text(monitor['title']);
    if (title.isNotEmpty) return title;

    switch (_text(monitor['type'])) {
      case 'generated-seed':
        return 'Most Recent Seed Generated';
      case 'address-list':
        return 'Receive Address Monitor';
      case 'xpub':
        return 'XPub Monitor';
      case 'zpub':
        return 'ZPub Monitor';
      default:
        return 'Wallet Activity Monitor';
    }
  }

  String _monitorDetail(Map<String, dynamic> monitor) {
    final detail = _text(monitor['detail']);
    if (detail.isNotEmpty) return detail;

    final addressCount = monitor['addressCount'];
    if (addressCount is num && addressCount > 0) {
      final label = addressCount == 1 ? 'address' : 'addresses';
      return '${addressCount.toInt()} receive $label';
    }

    return 'Wallet activity monitor';
  }

  IconData _monitorIcon(Map<String, dynamic> monitor) {
    switch (_text(monitor['type'])) {
      case 'generated-seed':
        return Icons.key_rounded;
      case 'address-list':
        return Icons.pin_drop_rounded;
      case 'xpub':
      case 'zpub':
        return Icons.account_tree_rounded;
      default:
        return Icons.visibility_rounded;
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          elevation: 3.0,
          shape: const CircleBorder(),
          child: Container(
            width: 92.0,
            height: 92.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primary,
              shape: BoxShape.circle,
            ),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Icon(
              Icons.key_rounded,
              color: FlutterFlowTheme.of(context).info,
              size: 48.0,
            ),
          ),
        ),
        Material(
          color: Colors.transparent,
          elevation: 3.0,
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 340.0),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primary,
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: EdgeInsetsDirectional.fromSTEB(18.0, 12.0, 18.0, 12.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Text(
              'DECOY KEYS',
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'DECOY BEBAS',
                    color: FlutterFlowTheme.of(context).info,
                    fontSize: 52.0,
                    letterSpacing: 0.3,
                    fontWeight: FontWeight.normal,
                    lineHeight: 1.05,
                  ),
            ),
          ),
        ),
        Text(
          'Advanced Monitor Controls',
          textAlign: TextAlign.center,
          style: FlutterFlowTheme.of(context).titleMedium.override(
                fontFamily: 'InterTight',
                color: FlutterFlowTheme.of(context).primary,
                fontSize: 24.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w600,
              ),
        ),
      ].divide(SizedBox(height: 20.0)),
    );
  }

  Widget _buildMasterStatus(BuildContext context) {
    final statusText = _model.masterArmed ? 'ACTIVATED' : 'DEACTIVATED';
    final statusColor = _model.masterArmed
        ? FlutterFlowTheme.of(context).success
        : FlutterFlowTheme.of(context).error;

    return Material(
      color: Colors.transparent,
      elevation: 2.0,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: FlutterFlowTheme.of(context).primary,
            width: 1.5,
          ),
        ),
        padding: EdgeInsets.all(18.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Master Status:',
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                      fontSize: 16.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                    ),
              ),
            ),
            Expanded(
              child: Text(
                statusText,
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                      color: statusColor,
                      fontSize: 16.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonitorTile(BuildContext context, Map<String, dynamic> monitor) {
    final active = monitor['active'] == true;
    final monitorId = _text(monitor['id']);

    return Material(
      color: Colors.transparent,
      elevation: 2.0,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: FlutterFlowTheme.of(context).primary,
            width: 1.5,
          ),
        ),
        padding: EdgeInsetsDirectional.fromSTEB(18.0, 18.0, 18.0, 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 54.0,
                  height: 54.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primary,
                    shape: BoxShape.circle,
                  ),
                  alignment: AlignmentDirectional(0.0, 0.0),
                  child: Icon(
                    _monitorIcon(monitor),
                    color: FlutterFlowTheme.of(context).info,
                    size: 30.0,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(14.0, 0.0, 8.0, 0.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _monitorTitle(monitor),
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                fontFamily: 'InterTight',
                                color: FlutterFlowTheme.of(context).primaryText,
                                fontSize: 18.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Text(
                          _monitorDetail(monitor),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: FlutterFlowTheme.of(context)
                              .bodySmall
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .bodySmallFamily,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                letterSpacing: 0.0,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .bodySmallIsCustom,
                              ),
                        ),
                      ].divide(SizedBox(height: 4.0)),
                    ),
                  ),
                ),
                Switch(
                  value: active,
                  onChanged: _model.isSaving
                      ? null
                      : (newValue) async {
                          await _setMonitorActive(monitorId, newValue);
                        },
                  activeThumbColor: FlutterFlowTheme.of(context).success,
                  activeTrackColor: FlutterFlowTheme.of(context).accent2,
                ),
              ],
            ),
            Divider(
              thickness: 0.5,
              color: FlutterFlowTheme.of(context).primary,
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Monitor Status:',
                    textAlign: TextAlign.center,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).bodyMediumFamily,
                          fontSize: 16.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                        ),
                  ),
                ),
                Expanded(
                  child: Text(
                    active ? 'ACTIVATED' : 'DEACTIVATED',
                    textAlign: TextAlign.center,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).bodyMediumFamily,
                          color: active
                              ? FlutterFlowTheme.of(context).success
                              : FlutterFlowTheme.of(context).error,
                          fontSize: 16.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                        ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: AlignmentDirectional(1.0, 0.0),
              child: TextButton.icon(
                onPressed: _model.isSaving
                    ? null
                    : () async {
                        await _deleteMonitor(monitor);
                      },
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: FlutterFlowTheme.of(context).error,
                  size: 20.0,
                ),
                label: Text(
                  'Delete',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).bodyMediumFamily,
                        color: FlutterFlowTheme.of(context).error,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                      ),
                ),
              ),
            ),
          ].divide(SizedBox(height: 12.0)),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_model.isLoading) {
      return Padding(
        padding: EdgeInsetsDirectional.fromSTEB(0.0, 60.0, 0.0, 60.0),
        child: Center(
          child: CircularProgressIndicator(
            color: FlutterFlowTheme.of(context).primary,
          ),
        ),
      );
    }

    if (_model.errorMessage != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _model.errorMessage!,
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                  color: FlutterFlowTheme.of(context).error,
                  letterSpacing: 0.0,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                ),
          ),
          FFButtonWidget(
            onPressed: () async {
              await _loadMonitors();
            },
            text: 'Retry',
            options: FFButtonOptions(
              width: 160.0,
              height: 44.0,
              color: FlutterFlowTheme.of(context).primary,
              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                    fontFamily: 'InterTight',
                    color: Colors.white,
                    letterSpacing: 0.0,
                  ),
              elevation: 2.0,
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ].divide(SizedBox(height: 18.0)),
      );
    }

    if (_model.monitors.isEmpty) {
      return Material(
        color: Colors.transparent,
        elevation: 2.0,
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: FlutterFlowTheme.of(context).primary,
              width: 1.5,
            ),
          ),
          padding: EdgeInsets.all(22.0),
          child: Text(
            'No Decoy Keys monitors found yet.',
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                  color: FlutterFlowTheme.of(context).primaryText,
                  fontSize: 16.0,
                  letterSpacing: 0.0,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildMasterStatus(context),
        for (final monitor in _model.monitors)
          _buildMonitorTile(context, _monitorMap(monitor)),
      ].divide(SizedBox(height: 18.0)),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    final bottomPadding = decoyBottomActionPadding(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: PopScope(
        canPop: false,
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
            systemNavigationBarColor: Colors.white,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: Colors.white,
            body: SafeArea(
              top: true,
              child: Stack(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Align(
                        alignment: AlignmentDirectional(-1.0, 0.0),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              10.0, 0.0, 0.0, 0.0),
                          child: FlutterFlowIconButton(
                            borderRadius: 20.0,
                            buttonSize: 40.0,
                            icon: Icon(
                              Icons.arrow_back_rounded,
                              color: FlutterFlowTheme.of(context).primaryText,
                              size: 24.0,
                            ),
                            onPressed: () async {
                              context.safePop();
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsetsDirectional.fromSTEB(
                            24.0,
                            22.0,
                            24.0,
                            bottomPadding,
                          ),
                          child: Align(
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: ConstrainedBox(
                              constraints:
                                  const BoxConstraints(maxWidth: 440.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildHeader(context),
                                  _buildBody(context),
                                ].divide(SizedBox(height: 28.0)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_model.isSaving)
                    Positioned.fill(
                      child: IgnorePointer(
                        ignoring: true,
                        child: Container(
                          color: Colors.white.withValues(alpha: 0.25),
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: CircularProgressIndicator(
                            color: FlutterFlowTheme.of(context).primary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
