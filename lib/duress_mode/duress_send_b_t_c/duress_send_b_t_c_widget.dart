import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import '/utils/android_display_guard.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'duress_send_b_t_c_model.dart';
export 'duress_send_b_t_c_model.dart';

/// Create a page that prompts the user to enter the amount of bitcoin they
/// are wanting to send.
///
/// Underneath the displayed amount, show the max amount that they are allowed
/// to send. Add a toggle that allows the user to send the max amount which
/// populated in the amount entry. Underneath that, make a grid view of entry
/// numbers the user can press to enter the amount they want to send.
/// Underneath that, put in a next button to go to the next page.
class DuressSendBTCWidget extends StatefulWidget {
  const DuressSendBTCWidget({super.key});

  static String routeName = 'DuressSendBTC';
  static String routePath = '/duressSendBTC';

  @override
  State<DuressSendBTCWidget> createState() => _DuressSendBTCWidgetState();
}

class _DuressSendBTCWidgetState extends State<DuressSendBTCWidget> {
  static const _pageBackground = Color(0xFF080C0D);
  static const _panelBackground = Color(0xFF121819);
  static const _panelRaised = Color(0xFF1A2224);
  static const _mutedText = Color(0xFF8C979A);
  static const _softBorder = Color(0xFF253033);

  late DuressSendBTCModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DuressSendBTCModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.notificationValue = 0;
      safeSetState(() {});
    });

    _model.switchValue = false;
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
    final sendBtcBottomPadding = decoyBottomActionPadding(context);
    final orange = FlutterFlowTheme.of(context).primary;

    final fakeBtcAvailableText = valueOrDefault<String>(
      formatNumber(
        FFAppState().fakeBtcBalance,
        formatType: FormatType.decimal,
        decimalType: DecimalType.periodDecimal,
      ),
      '0',
    );
    final fakeBtcAvailableForSend =
        fakeBtcAvailableText == '0' ? 0.0 : FFAppState().fakeBtcBalance;
    final amountValue = functions.amountToDouble(_model.amountText);
    final canContinue =
        amountValue <= fakeBtcAvailableForSend && amountValue > 0.0;

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
            child: ListView(
              primary: false,
              physics: const AlwaysScrollableScrollPhysics(
                parent: ClampingScrollPhysics(),
              ),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsetsDirectional.fromSTEB(
                20.0,
                18.0,
                20.0,
                sendBtcBottomPadding,
              ),
              children: [
                _topBar(context),
                const SizedBox(height: 8.0),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 390.0),
                    child: Transform.translate(
                      offset: const Offset(0.0, -10.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _titleBlock(context),
                          const SizedBox(height: 14.0),
                          _amountCard(
                            context,
                            orange: orange,
                            fakeBtcAvailableText: fakeBtcAvailableText,
                            fakeBtcAvailableForSend: fakeBtcAvailableForSend,
                          ),
                          const SizedBox(height: 12.0),
                          _keypadCard(context),
                          const SizedBox(height: 12.0),
                          _nextButton(
                            context,
                            canContinue: canContinue,
                            fakeBtcAvailableForSend: fakeBtcAvailableForSend,
                          ),
                          const SizedBox(height: 12.0),
                        ],
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

  Widget _titleBlock(BuildContext context) {
    return Column(
      children: [
        Text(
          'Send Amount',
          textAlign: TextAlign.center,
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                fontFamily: 'InterTight',
                color: FlutterFlowTheme.of(context).info,
                fontSize: 30.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 5.0),
        Text(
          'Enter the amount you want to send',
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
    required String fakeBtcAvailableText,
    required double fakeBtcAvailableForSend,
  }) {
    final amountExceedsAvailable =
        functions.amountToDouble(_model.amountText) > fakeBtcAvailableForSend;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18.0, 16.0, 18.0, 14.0),
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
          const SizedBox(height: 6.0),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              functions.formatBtcTrim(_model.amountText),
              textAlign: TextAlign.center,
              maxLines: 1,
              style: FlutterFlowTheme.of(context).displayMedium.override(
                    fontFamily: 'InterTight',
                    color: FlutterFlowTheme.of(context).info,
                    fontSize: 52.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          const SizedBox(height: 2.0),
          Text(
            'BTC',
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodyLarge.override(
                  fontFamily: 'InterTight',
                  color: FlutterFlowTheme.of(context).info,
                  fontSize: 18.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 12.0),
          _availabilityStatus(
            context,
            fakeBtcAvailableText: fakeBtcAvailableText,
          ),
          const SizedBox(height: 10.0),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: _panelRaised,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: _softBorder),
            ),
            child: Row(
              children: [
                Text(
                  'Send Max',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'InterTight',
                        color: amountExceedsAvailable
                            ? FlutterFlowTheme.of(context).error
                            : FlutterFlowTheme.of(context).info,
                        fontSize: 17.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const Spacer(),
                Switch.adaptive(
                  value: _model.switchValue!,
                  onChanged: (newValue) async {
                    safeSetState(() => _model.switchValue = newValue);
                    if (newValue) {
                      _model.sendMax = true;
                      _model.amountText = fakeBtcAvailableForSend.toString();
                      safeSetState(() {});
                    } else {
                      _model.sendMax = false;
                      safeSetState(() {});
                    }
                  },
                  activeThumbColor: FlutterFlowTheme.of(context).secondaryText,
                  activeTrackColor: orange,
                  inactiveTrackColor: _softBorder,
                  inactiveThumbColor: _mutedText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _availabilityStatus(
    BuildContext context, {
    required String fakeBtcAvailableText,
  }) {
    final showError = _model.notificationValue == 1;

    return AnimatedSwitcher(
      duration: 180.0.ms,
      child: Text(
        showError
            ? 'AMOUNT EXCEEDS AVAILABLE BALANCE'
            : 'Max available: $fakeBtcAvailableText',
        key: ValueKey(showError),
        textAlign: TextAlign.center,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: 'InterTight',
              color:
                  showError ? FlutterFlowTheme.of(context).primary : _mutedText,
              fontSize: 14.0,
              letterSpacing: 0.0,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }

  Widget _keypadCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: _panelBackground,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: _softBorder),
      ),
      child: Column(
        children: [
          _keypadRow(context, ['1', '2', '3']),
          const SizedBox(height: 10.0),
          _keypadRow(context, ['4', '5', '6']),
          const SizedBox(height: 10.0),
          _keypadRow(context, ['7', '8', '9']),
          const SizedBox(height: 10.0),
          Row(
            children: [
              Expanded(child: _amountKeyButton(context, '.')),
              const SizedBox(width: 10.0),
              Expanded(child: _amountKeyButton(context, '0')),
              const SizedBox(width: 10.0),
              Expanded(child: _backspaceKeyButton(context)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _keypadRow(BuildContext context, List<String> keys) {
    return Row(
      children: [
        for (final keyValue in keys) ...[
          Expanded(child: _amountKeyButton(context, keyValue)),
          if (keyValue != keys.last) const SizedBox(width: 10.0),
        ],
      ],
    );
  }

  Widget _amountKeyButton(BuildContext context, String keyValue) {
    return FFButtonWidget(
      onPressed: () async {
        _model.amountText = functions.applyKey(_model.amountText, keyValue, 8);
        safeSetState(() {});
      },
      text: keyValue,
      options: _keyButtonOptions(context),
    );
  }

  Widget _backspaceKeyButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: () async {
          _model.sendMax = false;
          safeSetState(() {});
          _model.amountText =
              functions.applyKey(_model.amountText, 'BACKSPACE', 8);
          safeSetState(() {});
        },
        child: SizedBox(
          height: 54.0,
          child: Ink(
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primary,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 4.0,
                  color: Color(0x33000000),
                  offset: Offset(0.0, 2.0),
                ),
              ],
            ),
            child: Icon(
              Icons.keyboard_backspace_rounded,
              color: FlutterFlowTheme.of(context).info,
              size: 30.0,
            ),
          ),
        ),
      ),
    );
  }

  FFButtonOptions _keyButtonOptions(BuildContext context) {
    return FFButtonOptions(
      height: 54.0,
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
      iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
      color: FlutterFlowTheme.of(context).primary,
      textStyle: FlutterFlowTheme.of(context).titleSmall.override(
            fontFamily: 'InterTight',
            color: FlutterFlowTheme.of(context).info,
            fontSize: 22.0,
            letterSpacing: 0.0,
            fontWeight: FontWeight.w800,
          ),
      elevation: 5.0,
      borderRadius: BorderRadius.circular(8.0),
    );
  }

  Widget _nextButton(
    BuildContext context, {
    required bool canContinue,
    required double fakeBtcAvailableForSend,
  }) {
    return AnimatedOpacity(
      opacity: canContinue ? 1.0 : 0.5,
      duration: 250.0.ms,
      curve: Curves.easeInOut,
      child: FFButtonWidget(
        onPressed: () async {
          if ((functions.amountToDouble(_model.amountText) > 0.0) &&
              (functions.amountToDouble(_model.amountText) <=
                  fakeBtcAvailableForSend)) {
            FFAppState().sendAmountBtc =
                functions.formatBtc(_model.amountText)!;
            safeSetState(() {});

            context.pushNamed(DuressConfirmTransactionSendWidget.routeName);
          } else {
            _model.notificationValue = 1;
            safeSetState(() {});
            await Future.delayed(
              const Duration(
                milliseconds: 2000,
              ),
            );
            _model.notificationValue = 0;
            safeSetState(() {});
          }
        },
        text: 'Next',
        options: FFButtonOptions(
          width: double.infinity,
          height: 58.0,
          padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
          iconPadding:
              const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
          color: FlutterFlowTheme.of(context).primary,
          textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                fontFamily: 'InterTight',
                color: FlutterFlowTheme.of(context).info,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w800,
              ),
          elevation: 5.0,
          borderSide: const BorderSide(
            color: Colors.transparent,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}
