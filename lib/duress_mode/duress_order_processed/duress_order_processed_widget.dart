import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'duress_order_processed_model.dart';
export 'duress_order_processed_model.dart';

class DuressOrderProcessedWidget extends StatefulWidget {
  const DuressOrderProcessedWidget({
    super.key,
    required this.amountBtc,
    required this.toAddress,
    required this.feeBtc,
  });

  final String? amountBtc;
  final String? toAddress;
  final double? feeBtc;

  static String routeName = 'DuressOrderProcessed';
  static String routePath = '/duressOrderProcessed';

  @override
  State<DuressOrderProcessedWidget> createState() =>
      _DuressOrderProcessedWidgetState();
}

class _DuressOrderProcessedWidgetState
    extends State<DuressOrderProcessedWidget> {
  static const _pageBackground = Color(0xFF080C0D);
  static const _panelBackground = Color(0xFF121819);
  static const _mutedText = Color(0xFF8C979A);
  static const _softBorder = Color(0xFF253033);

  late DuressOrderProcessedModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DuressOrderProcessedModel());

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(
        const Duration(milliseconds: 2500),
      );

      context.pushNamed(
        DuressProcessingTransactionWidget.routeName,
        queryParameters: {
          'amountBtc': serializeParam(
            widget.amountBtc,
            ParamType.String,
          ),
          'toAddress': serializeParam(
            widget.toAddress,
            ParamType.String,
          ),
          'feeBtc': serializeParam(
            widget.feeBtc,
            ParamType.double,
          ),
        }.withoutNulls,
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
    final orange = FlutterFlowTheme.of(context).primary;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: PopScope(
        canPop: false,
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: _pageBackground,
          body: SafeArea(
            top: true,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 390.0),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 2300),
                    curve: Curves.easeInOutCubic,
                    builder: (context, progress, _) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 92.0,
                            height: 92.0,
                            decoration: BoxDecoration(
                              color: orange.withValues(alpha: 0.14),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: orange.withValues(alpha: 0.48),
                                width: 1.2,
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 74.0,
                                  height: 74.0,
                                  child: CircularProgressIndicator(
                                    value: progress,
                                    strokeWidth: 4.0,
                                    color: orange,
                                    backgroundColor: const Color(0xFF263033),
                                  ),
                                ),
                                Icon(
                                  progress > 0.86
                                      ? Icons.check_rounded
                                      : Icons.arrow_upward_rounded,
                                  color: orange,
                                  size: 34.0,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 26.0),
                          Text(
                            progress > 0.82
                                ? 'Transaction Broadcast'
                                : 'Broadcasting Transaction',
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context)
                                .headlineMedium
                                .override(
                                  fontFamily: 'InterTight',
                                  color: FlutterFlowTheme.of(context).info,
                                  fontSize: 28.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            progress > 0.82
                                ? 'Waiting for network confirmations'
                                : 'Signing and relaying to Bitcoin peers',
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'InterTight',
                                  color: _mutedText,
                                  fontSize: 14.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 26.0),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: _panelBackground,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(color: _softBorder),
                            ),
                            child: Column(
                              children: [
                                _statusRow(
                                  context,
                                  label: 'Amount',
                                  value:
                                      '${functions.formatBtcTrim(widget.amountBtc ?? '0')} BTC',
                                ),
                                _divider(),
                                _statusRow(
                                  context,
                                  label: 'To',
                                  value: functions.maskAddress(
                                    widget.toAddress ?? '',
                                    6,
                                    6,
                                  ),
                                  accent: orange,
                                ),
                                _divider(),
                                _statusRow(
                                  context,
                                  label: 'Status',
                                  value: progress > 0.82
                                      ? 'Broadcasted'
                                      : 'Signing',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18.0),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4.0),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 5.0,
                              color: orange,
                              backgroundColor: const Color(0xFF283236),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusRow(
    BuildContext context, {
    required String label,
    required String value,
    Color? accent,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'InterTight',
                    color: _mutedText,
                    fontSize: 13.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Flexible(
            child: Text(
              value.isEmpty ? '--' : value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'InterTight',
                    color: accent ?? FlutterFlowTheme.of(context).info,
                    fontSize: 13.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      height: 1.0,
      color: _softBorder,
    );
  }
}
