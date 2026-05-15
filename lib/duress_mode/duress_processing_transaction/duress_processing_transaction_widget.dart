import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/instant_timer.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'duress_processing_transaction_model.dart';
export 'duress_processing_transaction_model.dart';

class DuressProcessingTransactionWidget extends StatefulWidget {
  const DuressProcessingTransactionWidget({
    super.key,
    required this.amountBtc,
    required this.toAddress,
    required this.feeBtc,
  });

  final String? amountBtc;
  final String? toAddress;
  final double? feeBtc;

  static String routeName = 'DuressProcessingTransaction';
  static String routePath = '/duressProcessingTransaction';

  @override
  State<DuressProcessingTransactionWidget> createState() =>
      _DuressProcessingTransactionWidgetState();
}

class _DuressProcessingTransactionWidgetState
    extends State<DuressProcessingTransactionWidget> {
  static const _pageBackground = Color(0xFF080C0D);
  static const _panelBackground = Color(0xFF121819);
  static const _panelRaised = Color(0xFF1A2224);
  static const _mutedText = Color(0xFF8C979A);
  static const _softBorder = Color(0xFF253033);
  static const _track = Color(0xFF283236);
  static const _success = Color(0xFF29D17D);

  late DuressProcessingTransactionModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DuressProcessingTransactionModel());

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.pagetimers?.cancel();
      if (FFAppState().txStatus == 'complete') {
        _model.remainingMins = 0;
        _model.progress01 = 1.0;
        safeSetState(() {});
      } else {
        _model.elapsedMins = functions.incElapsedFromStart(
            FFAppState().txStartAt!, getCurrentTimestamp);
        _model.remainingMins = functions.remainingForm(
            FFAppState().txTotalMins, _model.elapsedMins);
        _model.progress01 = functions.progressForm(
            _model.elapsedMins, FFAppState().txTotalMins);
        safeSetState(() {});
        if ((_model.remainingMins > 0) &&
            (FFAppState().txStatus == 'awaiting')) {
          _model.pagetimers = InstantTimer.periodic(
            duration: const Duration(milliseconds: 60000),
            callback: (timer) async {
              _model.elapsedMins = functions.incElapsedFromStart(
                  FFAppState().txStartAt!, getCurrentTimestamp);
              _model.remainingMins = functions.remainingForm(
                  FFAppState().txTotalMins, _model.elapsedMins);
              _model.progress01 = functions.progressForm(
                  _model.elapsedMins, FFAppState().txTotalMins);
              safeSetState(() {});
              if (_model.remainingMins <= 0) {
                _model.pagetimers?.cancel();
                _model.progress01 = 1.0;
                safeSetState(() {});
              }
            },
            startImmediately: true,
          );
        } else {
          _model.pagetimers?.cancel();
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

  String get _statusTitle {
    if (_model.progress01 >= 1.0) {
      return 'Transaction Confirmed';
    }
    if (_model.progress01 >= 0.5) {
      return 'Awaiting Confirmation';
    }
    if (_model.progress01 >= 0.05) {
      return 'In Mempool';
    }
    return 'Broadcasting';
  }

  String get _statusSubtitle {
    if (_model.progress01 >= 1.0) {
      return 'Confirmed on the Bitcoin network';
    }
    if (_model.progress01 >= 0.5) {
      return 'Seen by peers and waiting for the next block';
    }
    if (_model.progress01 >= 0.05) {
      return 'Transaction relayed and pending inclusion';
    }
    return 'Relaying transaction to Bitcoin peers';
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    final orange = FlutterFlowTheme.of(context).primary;
    final progress = _model.progress01.clamp(0.0, 1.0);
    final isComplete = progress >= 1.0;
    final amountText =
        '${functions.formatBtcTrim(widget.amountBtc ?? '0')} BTC';
    final feeText = '${functions.formatBtcTrim(
      (widget.feeBtc ?? 0.0).toString(),
    )} BTC';

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
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 34.0),
                shrinkWrap: true,
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 390.0),
                      child: Column(
                        children: [
                          _statusHeader(context, orange, progress, isComplete),
                          const SizedBox(height: 18.0),
                          _detailCard(
                            context,
                            orange: orange,
                            amountText: amountText,
                            feeText: feeText,
                          ),
                          const SizedBox(height: 16.0),
                          _progressCard(context, orange, progress, isComplete),
                          const SizedBox(height: 16.0),
                          _timelineCard(context, orange, progress),
                          const SizedBox(height: 22.0),
                          FFButtonWidget(
                            onPressed: () async {
                              context.goNamed(DuressHomePageWidget.routeName);
                            },
                            text: 'Return to Home',
                            options: FFButtonOptions(
                              width: double.infinity,
                              height: 56.0,
                              padding: const EdgeInsets.all(8.0),
                              iconPadding: EdgeInsetsDirectional.zero,
                              color: orange,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    fontFamily: 'InterTight',
                                    color: FlutterFlowTheme.of(context).info,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w800,
                                  ),
                              elevation: 0.0,
                              borderSide: const BorderSide(
                                color: Colors.transparent,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ],
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

  Widget _statusHeader(
    BuildContext context,
    Color orange,
    double progress,
    bool isComplete,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18.0, 20.0, 18.0, 18.0),
      decoration: BoxDecoration(
        color: _panelBackground,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: _softBorder),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CircularPercentIndicator(
                radius: 66.0,
                lineWidth: 7.0,
                percent: progress,
                animation: true,
                animateFromLastPercent: true,
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: isComplete ? _success : orange,
                backgroundColor: _track,
              ),
              SizedBox(
                width: 82.0,
                height: 82.0,
                child: isComplete
                    ? DecoratedBox(
                        decoration: BoxDecoration(
                          color: _success.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: _success,
                          size: 34.0,
                        ),
                      )
                    : CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: orange.withValues(alpha: 0.78),
                        backgroundColor: Colors.transparent,
                      ),
              ),
            ],
          ),
          const SizedBox(height: 18.0),
          Text(
            _statusTitle,
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'InterTight',
                  color: FlutterFlowTheme.of(context).info,
                  fontSize: 27.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 7.0),
          Text(
            _statusSubtitle,
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'InterTight',
                  color: _mutedText,
                  fontSize: 14.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w600,
                  lineHeight: 1.35,
                ),
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(
                child: _metricPill(
                  context,
                  label: 'ETA',
                  value: isComplete ? 'Complete' : '${_model.remainingMins}m',
                  color: isComplete ? _success : orange,
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: _metricPill(
                  context,
                  label: 'Confirmations',
                  value: isComplete ? '1 / 1' : '0 / 1',
                  color: isComplete ? _success : orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailCard(
    BuildContext context, {
    required Color orange,
    required String amountText,
    required String feeText,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: _panelBackground,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: _softBorder),
      ),
      child: Column(
        children: [
          _detailRow(context, 'Amount', amountText),
          _divider(),
          _detailRow(
            context,
            'To',
            functions.maskAddress(widget.toAddress ?? '', 8, 8),
            accent: orange,
          ),
          _divider(),
          _detailRow(context, 'Network', 'Bitcoin'),
          _divider(),
          _detailRow(context, 'Network Fee', feeText),
          _divider(),
          _detailRow(
            context,
            'Tx ID',
            'b38f6a2d...e91c0b77',
            accent: orange,
          ),
        ],
      ),
    );
  }

  Widget _progressCard(
    BuildContext context,
    Color orange,
    double progress,
    bool isComplete,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: _panelBackground,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: _softBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Network Progress',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'InterTight',
                        color: FlutterFlowTheme.of(context).info,
                        fontSize: 14.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              Text(
                formatNumber(
                  progress,
                  formatType: FormatType.percent,
                ),
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'InterTight',
                      color: isComplete ? _success : orange,
                      fontSize: 14.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 13.0),
          LinearPercentIndicator(
            percent: progress,
            lineHeight: 8.0,
            animation: true,
            animateFromLastPercent: true,
            progressColor: isComplete ? _success : orange,
            backgroundColor: _track,
            barRadius: const Radius.circular(4.0),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _smallLabel(context, 'Broadcast'),
              _smallLabel(context, 'Mempool'),
              _smallLabel(context, 'Block'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timelineCard(BuildContext context, Color orange, double progress) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: _panelBackground,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: _softBorder),
      ),
      child: Column(
        children: [
          _timelineRow(
            context,
            label: 'Transaction initiated',
            active: progress >= 0.0,
            color: orange,
          ),
          _timelineConnector(progress >= 0.05 ? orange : _track),
          _timelineRow(
            context,
            label: 'Broadcasted to network',
            active: progress >= 0.05,
            color: orange,
          ),
          _timelineConnector(progress >= 0.5 ? orange : _track),
          _timelineRow(
            context,
            label: 'Awaiting confirmations',
            active: progress >= 0.5,
            color: orange,
          ),
          _timelineConnector(progress >= 1.0 ? _success : _track),
          _timelineRow(
            context,
            label: 'Transaction complete',
            active: progress >= 1.0,
            color: _success,
          ),
        ],
      ),
    );
  }

  Widget _metricPill(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: _panelRaised,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: _softBorder),
      ),
      child: Column(
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'InterTight',
                  color: _mutedText,
                  fontSize: 11.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4.0),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'InterTight',
                  color: color,
                  fontSize: 15.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(
    BuildContext context,
    String label,
    String value, {
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

  Widget _timelineRow(
    BuildContext context, {
    required String label,
    required bool active,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 24.0,
          height: 24.0,
          decoration: BoxDecoration(
            color: active ? color.withValues(alpha: 0.16) : _panelRaised,
            shape: BoxShape.circle,
            border: Border.all(color: active ? color : _track),
          ),
          child: Icon(
            active ? Icons.check_rounded : Icons.more_horiz_rounded,
            color: active ? color : _mutedText,
            size: 15.0,
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: Text(
            label,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'InterTight',
                  color:
                      active ? FlutterFlowTheme.of(context).info : _mutedText,
                  fontSize: 13.0,
                  letterSpacing: 0.0,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }

  Widget _timelineConnector(Color color) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 1.0,
        height: 18.0,
        margin: const EdgeInsets.only(left: 12.0),
        color: color,
      ),
    );
  }

  Widget _smallLabel(BuildContext context, String value) {
    return Text(
      value,
      style: FlutterFlowTheme.of(context).bodyMedium.override(
            fontFamily: 'InterTight',
            color: _mutedText,
            fontSize: 11.0,
            letterSpacing: 0.0,
            fontWeight: FontWeight.w700,
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
