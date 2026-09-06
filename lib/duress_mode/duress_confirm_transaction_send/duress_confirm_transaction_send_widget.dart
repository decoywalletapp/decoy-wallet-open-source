import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import '/utils/android_display_guard.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'duress_confirm_transaction_send_model.dart';
export 'duress_confirm_transaction_send_model.dart';

/// Create a Confirm Transaction page that shows the amount entered on the
/// last page of Bitcoin to Send.
///
/// Then below that, insert a sliding box that says, Sign and Send. Once the
/// slide bar is slide all the way to the right, that confirms the transaction
/// and initiates the send funds.  Shows a check mark next to the word "sent"
/// after the action has been made
class DuressConfirmTransactionSendWidget extends StatefulWidget {
  const DuressConfirmTransactionSendWidget({super.key});

  static String routeName = 'DuressConfirmTransactionSend';
  static String routePath = '/duressConfirmTransactionSend';

  @override
  State<DuressConfirmTransactionSendWidget> createState() =>
      _DuressConfirmTransactionSendWidgetState();
}

class _DuressConfirmTransactionSendWidgetState
    extends State<DuressConfirmTransactionSendWidget> {
  static const _pageBackground = Color(0xFF080C0D);
  static const _panelBackground = Color(0xFF121819);
  static const _panelRaised = Color(0xFF1A2224);
  static const _mutedText = Color(0xFF8C979A);
  static const _softBorder = Color(0xFF253033);
  static const _track = Color(0xFF101516);

  late DuressConfirmTransactionSendModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DuressConfirmTransactionSendModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.feeBtc = functions.estimateFeeBtc(FFAppState().feeRateSatVb, 1, 2);
      _model.orderProcessed = 0;
      safeSetState(() {});
      safeSetState(() {
        _model.sliderValue = 0.0;
      });
      _model.showSlider = false;
      safeSetState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  void _applyDuressSendBalance(String grossAmountText) {
    final nextBalance = functions.fakeBtcBalanceAfterSend(
      FFAppState().fakeBtcBalance,
      grossAmountText,
      _model.feeBtc,
    );
    FFAppState().update(() {
      FFAppState().fakeBtcBalance = nextBalance;
      FFAppState().fakeUsdValue = valueOrDefault<double>(
        functions.usdFromBtc(
          nextBalance,
          FFAppState().currentPriceMultiple,
        ),
        0.0,
      );
    });
  }

  void _resetSlider() {
    _model.slideValue = 0.0;
    _model.sliderValue = 0.0;
    _model.slidePct = 0.0;
    safeSetState(() {});
  }

  Future<void> _completeDuressSend(String sendAmountBtcForFlow) async {
    if (_model.orderProcessed == 1) {
      return;
    }

    final totalAfterFee =
        functions.totalAfterFee(sendAmountBtcForFlow, _model.feeBtc);
    if (totalAfterFee == '0') {
      _resetSlider();
      return;
    }

    _model.orderProcessed = 1;
    FFAppState().sendAmountBtc = totalAfterFee;
    _applyDuressSendBalance(sendAmountBtcForFlow);
    FFAppState().txStartAt = getCurrentTimestamp;
    FFAppState().txTotalMins = 60;
    FFAppState().txStatus = 'awaiting';
    safeSetState(() {});

    context.pushNamed(
      DuressOrderProcessedWidget.routeName,
      queryParameters: {
        'amountBtc': serializeParam(
          totalAfterFee,
          ParamType.String,
        ),
        'toAddress': serializeParam(
          FFAppState().scannedAddress,
          ParamType.String,
        ),
        'feeBtc': serializeParam(
          _model.feeBtc,
          ParamType.double,
        ),
      }.withoutNulls,
    );

    _resetSlider();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final confirmTransactionBottomPadding = decoyBottomActionPadding(context);
    final orange = FlutterFlowTheme.of(context).primary;

    final sendAmountBtcDisplayText = valueOrDefault<String>(
      formatNumber(
        functions.amountToDouble(FFAppState().sendAmountBtc),
        formatType: FormatType.decimal,
        decimalType: DecimalType.periodDecimal,
      ),
      '0',
    );
    final sendAmountBtcForFlow =
        sendAmountBtcDisplayText == '0' ? '0' : FFAppState().sendAmountBtc;
    final feeText = functions.formatBtcTrim(_model.feeBtc.toString());
    final totalText =
        functions.totalAfterFee(sendAmountBtcForFlow, _model.feeBtc);

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
            child: DecoyBottomSafeScroll(
              bottomPadding: confirmTransactionBottomPadding,
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  20.0,
                  18.0,
                  20.0,
                  0.0,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 390.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _topBar(context),
                        const SizedBox(height: 34.0),
                        _titleBlock(context, orange),
                        const SizedBox(height: 22.0),
                        _amountCard(
                          context,
                          orange: orange,
                          amountBtc: sendAmountBtcForFlow,
                        ),
                        const SizedBox(height: 16.0),
                        _detailsCard(
                          context,
                          orange: orange,
                          feeText: feeText,
                          totalText: totalText,
                        ),
                        const SizedBox(height: 18.0),
                        _slideToSendControl(
                          context,
                          orange: orange,
                          sendAmountBtcForFlow: sendAmountBtcForFlow,
                        ),
                        const SizedBox(height: 18.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Row(
      children: [
        FlutterFlowIconButton(
          borderRadius: 20.0,
          buttonSize: 40.0,
          icon: Icon(
            Icons.arrow_back_rounded,
            color: FlutterFlowTheme.of(context).info,
            size: 26.0,
          ),
          onPressed: () async {
            context.safePop();
          },
        ),
      ],
    );
  }

  Widget _titleBlock(BuildContext context, Color orange) {
    return Column(
      children: [
        Container(
          width: 62.0,
          height: 62.0,
          decoration: BoxDecoration(
            color: orange.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: orange.withValues(alpha: 0.42),
              width: 1.2,
            ),
          ),
          child: Icon(
            Icons.verified_user_outlined,
            color: orange,
            size: 32.0,
          ),
        ),
        const SizedBox(height: 18.0),
        Text(
          'Confirm Transaction',
          textAlign: TextAlign.center,
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                fontFamily: 'InterTight',
                color: FlutterFlowTheme.of(context).info,
                fontSize: 31.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 7.0),
        Text(
          'Review details before broadcast',
          textAlign: TextAlign.center,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'InterTight',
                color: _mutedText,
                fontSize: 14.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  Widget _amountCard(
    BuildContext context, {
    required Color orange,
    required String amountBtc,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18.0, 22.0, 18.0, 20.0),
      decoration: BoxDecoration(
        color: _panelBackground,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: _softBorder),
      ),
      child: Column(
        children: [
          Text(
            'Amount',
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'InterTight',
                  color: _mutedText,
                  fontSize: 12.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 10.0),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${functions.formatBtcTrim(amountBtc)} BTC',
              textAlign: TextAlign.center,
              maxLines: 1,
              style: FlutterFlowTheme.of(context).displayMedium.override(
                    fontFamily: 'InterTight',
                    color: FlutterFlowTheme.of(context).info,
                    fontSize: 56.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          const SizedBox(height: 9.0),
          Text(
            '≈ ${functions.btcToUsdDisplay(amountBtc, FFAppState().currentPriceMultiple)} USD',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: FlutterFlowTheme.of(context).bodyLarge.override(
                  fontFamily: 'InterTight',
                  color: _mutedText,
                  fontSize: 17.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(
                child: _metricPill(
                  context,
                  label: 'Network',
                  value: 'Bitcoin',
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: _metricPill(
                  context,
                  label: 'Status',
                  value: 'Ready',
                  accent: orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailsCard(
    BuildContext context, {
    required Color orange,
    required String feeText,
    required String totalText,
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
          _detailRow(context, label: 'Network Fee', value: '$feeText BTC'),
          _divider(),
          _detailRow(
            context,
            label: 'Total Amount',
            value: '$totalText BTC',
            strong: true,
          ),
          _divider(),
          _detailRow(
            context,
            label: 'To Address',
            value: functions.maskAddress(FFAppState().scannedAddress, 8, 8),
            accent: orange,
          ),
        ],
      ),
    );
  }

  Widget _slideToSendControl(
    BuildContext context, {
    required Color orange,
    required String sendAmountBtcForFlow,
  }) {
    final sliderValue = (_model.sliderValue ?? _model.slideValue).clamp(
      0.0,
      100.0,
    );
    final progress = (sliderValue / 100.0).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      height: 72.0,
      padding: const EdgeInsets.all(6.0),
      decoration: BoxDecoration(
        color: _track,
        borderRadius: BorderRadius.circular(36.0),
        border: Border.all(color: _softBorder),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  color: orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(32.0),
                ),
              ),
            ),
          ),
          Text(
            'Slide to Sign and Send',
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'InterTight',
                  color: _mutedText,
                  fontSize: 15.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w700,
                ),
          ),
          Align(
            alignment: AlignmentDirectional(
              valueOrDefault<double>(
                functions.alignXFromPercent(sliderValue),
                0.0,
              ),
              0.0,
            ),
            child: Container(
              width: 60.0,
              height: 60.0,
              decoration: BoxDecoration(
                color: orange,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: orange.withValues(alpha: 0.34),
                    blurRadius: 18.0,
                    offset: const Offset(0.0, 7.0),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: FlutterFlowTheme.of(context).info,
                size: 31.0,
              ),
            ),
          ),
          Opacity(
            opacity: 0.01,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 60.0,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 30.0,
                ),
                overlayShape: SliderComponentShape.noOverlay,
              ),
              child: Slider(
                activeColor: orange,
                inactiveColor: _softBorder,
                min: 0.0,
                max: 100.0,
                value: sliderValue,
                onChanged: (newValue) async {
                  _model.sliderValue = newValue;
                  _model.slideValue = newValue;
                  _model.slidePct = newValue;
                  safeSetState(() {});

                  if (newValue >= 100.0) {
                    await _completeDuressSend(sendAmountBtcForFlow);
                  }
                },
                onChangeEnd: (newValue) async {
                  if (newValue < 100.0) {
                    _resetSlider();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricPill(
    BuildContext context, {
    required String label,
    required String value,
    Color? accent,
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
                  color: accent ?? FlutterFlowTheme.of(context).info,
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
    BuildContext context, {
    required String label,
    required String value,
    Color? accent,
    bool strong = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11.0),
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
                    fontWeight: strong ? FontWeight.w800 : FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(width: 14.0),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'InterTight',
                    color: accent ?? FlutterFlowTheme.of(context).info,
                    fontSize: strong ? 14.0 : 13.0,
                    letterSpacing: 0.0,
                    fontWeight: strong ? FontWeight.w900 : FontWeight.w800,
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
