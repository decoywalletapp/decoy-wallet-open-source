import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class ConfigureBitcoinBalanceWidget extends StatefulWidget {
  const ConfigureBitcoinBalanceWidget({super.key});

  static String routeName = 'ConfigureBitcoinBalance';
  static String routePath = '/configure-bitcoin-balance';

  @override
  State<ConfigureBitcoinBalanceWidget> createState() =>
      _ConfigureBitcoinBalanceWidgetState();
}

class _ConfigureBitcoinBalanceWidgetState
    extends State<ConfigureBitcoinBalanceWidget> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  static const _maximumBitcoin = 21000000.0;
  static const _maximumSliderBitcoin = 10000.0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: _formatEditableBtc(FFAppState().fakeBtcBalance),
    );
    _focusNode = FocusNode();
    _controller.addListener(_refreshPreview);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_refreshPreview)
      ..dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _refreshPreview() => setState(() {});

  double? get _enteredBtc =>
      double.tryParse(_controller.text.trim().replaceAll(',', ''));

  double get _currentPrice {
    final state = FFAppState();
    if (state.currentPriceMultiple > 0.0) return state.currentPriceMultiple;
    if (state.currentBtcPrice > 0.0) return state.currentBtcPrice;
    return 0.0;
  }

  String get _usdPreview {
    final amount = _enteredBtc;
    if (amount == null || _currentPrice <= 0.0)
      return 'USD estimate unavailable';
    return NumberFormat.currency(symbol: r'$', decimalDigits: 2)
        .format(amount * _currentPrice);
  }

  static String _formatEditableBtc(double value) {
    if (!value.isFinite) return '0';
    return value
        .toStringAsFixed(8)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  void _setAmount(double amount) {
    _controller.text = _formatEditableBtc(amount);
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
  }

  double get _sliderValue {
    final amount = (_enteredBtc ?? 0.0).clamp(0.0, _maximumSliderBitcoin);
    if (amount <= 0.0) return 0.0;
    if (amount <= 25.0) return (amount / 25.0) * 0.5;
    return (0.5 +
            0.5 *
                (math.log(amount / 25.0) /
                    math.log(_maximumSliderBitcoin / 25.0)))
        .clamp(0.0, 1.0);
  }

  void _setFromSlider(double position) {
    if (position <= 0.0) {
      _setAmount(0.0);
      return;
    }
    if (position <= 0.5) {
      _setAmount((position / 0.5) * 25.0);
      return;
    }
    final highRangePosition = (position - 0.5) / 0.5;
    _setAmount(25.0 *
        math.exp(
          highRangePosition * math.log(_maximumSliderBitcoin / 25.0),
        ));
  }

  String? _validate(String? rawValue) {
    final value = double.tryParse((rawValue ?? '').trim().replaceAll(',', ''));
    if (value == null || !value.isFinite) return 'Enter a valid BTC amount.';
    if (value < 0.0) return 'Balance cannot be negative.';
    if (value > _maximumBitcoin) return 'Enter 21,000,000 BTC or less.';
    return null;
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final value = _enteredBtc!;
    final usdValue = _currentPrice > 0.0 ? value * _currentPrice : 0.0;

    FFAppState().update(() {
      FFAppState().fakeBtcBalance = value;
      FFAppState().fakeUsdValue = usdValue;
      FFAppState().fakeBtcSeededAt = DateTime.now().toUtc();
      FFAppState().fakeSeeded = true;
    });

    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Bitcoin balance updated.'),
          duration: Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final amount = _enteredBtc;
    final preview = amount == null ? '0' : _formatEditableBtc(amount);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: ClampingScrollPhysics(),
            ),
            padding: const EdgeInsets.only(bottom: 32.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12.0, top: 6.0),
                        child: FlutterFlowIconButton(
                          borderColor: Colors.transparent,
                          borderRadius: 30.0,
                          buttonSize: 46.0,
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: Color(0xFF15161E),
                            size: 25.0,
                          ),
                          onPressed: () async => context.safePop(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    _buildTitle(context),
                    const SizedBox(height: 24.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildPreview(context, preview),
                          const SizedBox(height: 18.0),
                          _buildSlider(context),
                          const SizedBox(height: 20.0),
                          Form(
                            key: _formKey,
                            child: TextFormField(
                              controller: _controller,
                              focusNode: _focusNode,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.,]'),
                                ),
                              ],
                              validator: _validate,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              style: const TextStyle(
                                color: Color(0xFF15161E),
                                fontSize: 24.0,
                                fontWeight: FontWeight.w700,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Exact Bitcoin amount',
                                prefixText: 'BTC  ',
                                helperText:
                                    'Enter any value from 0 to 21,000,000 BTC',
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 18.0,
                                  vertical: 20.0,
                                ),
                                enabledBorder: _inputBorder(
                                  const Color(0xFFE3E6EA),
                                ),
                                focusedBorder: _inputBorder(
                                  FlutterFlowTheme.of(context).primary,
                                  width: 2.0,
                                ),
                                errorBorder: _inputBorder(
                                  const Color(0xFFD90429),
                                ),
                                focusedErrorBorder: _inputBorder(
                                  const Color(0xFFD90429),
                                  width: 2.0,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24.0),
                          SizedBox(
                            height: 54.0,
                            child: FilledButton(
                              onPressed: _save,
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    FlutterFlowTheme.of(context).primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: const Text(
                                'Set',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 19.0,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlider(BuildContext context) {
    final primary = FlutterFlowTheme.of(context).primary;
    return Container(
      padding: const EdgeInsets.fromLTRB(18.0, 17.0, 18.0, 14.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F2),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: const Color(0xFFFFD7C2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34.0,
                height: 34.0,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.tune_rounded,
                  color: Colors.white,
                  size: 19.0,
                ),
              ),
              const SizedBox(width: 11.0),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Adjust balance',
                      style: TextStyle(
                        color: Color(0xFF15161E),
                        fontSize: 16.0,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2.0),
                    Text(
                      'Slide for a quick estimate, or enter an exact amount below.',
                      style: TextStyle(
                        color: Color(0xFF6D737C),
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13.0),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: primary,
              inactiveTrackColor: const Color(0xFFFFD7C2),
              thumbColor: primary,
              overlayColor: primary.withValues(alpha: 0.14),
              trackHeight: 7.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 11.0),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 22.0),
            ),
            child: Slider(
              value: _sliderValue,
              onChanged: _setFromSlider,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0 BTC', style: _SliderLabelStyle.textStyle),
                Text('10K BTC', style: _SliderLabelStyle.textStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _inputBorder(Color color, {double width = 1.25}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final titleStyle = FlutterFlowTheme.of(context).bodyMedium.override(
          fontFamily: 'DECOY BEBAS',
          color: FlutterFlowTheme.of(context).info,
          fontSize: 52.0,
          letterSpacing: 0.0,
          fontWeight: FontWeight.normal,
          lineHeight: 1.05,
        );

    Widget titleLayer(AlignmentDirectional alignment) => Align(
          alignment: alignment,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(8.0, 12.0, 8.0, 12.0),
            child: Text(
              'Bitcoin Balance',
              textAlign: TextAlign.center,
              style: titleStyle,
            ),
          ),
        );

    return Align(
      alignment: Alignment.center,
      child: Material(
        color: Colors.transparent,
        elevation: 3.0,
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          width: 340.0,
          height: 71.0,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primary,
            borderRadius: BorderRadius.circular(8.0),
          ),
          alignment: Alignment.center,
          child: Stack(
            children: [
              titleLayer(const AlignmentDirectional(-0.01, 0.0)),
              titleLayer(const AlignmentDirectional(0.0, 0.0)),
              titleLayer(const AlignmentDirectional(0.01, 0.0)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview(BuildContext context, String preview) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFF15161E),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: const [
          BoxShadow(
            blurRadius: 16.0,
            color: Color(0x26000000),
            offset: Offset(0.0, 8.0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DECOY WALLET BALANCE',
            style: TextStyle(
              color: Color(0xFF9BA1AA),
              fontSize: 11.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10.0),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '₿ $preview',
              maxLines: 1,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'InterTight',
                fontSize: 34.0,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 5.0),
          Text(
            _usdPreview,
            style: const TextStyle(
              color: Color(0xFFFF5A00),
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

abstract final class _SliderLabelStyle {
  static const textStyle = TextStyle(
    color: Color(0xFF777D86),
    fontSize: 11.0,
    fontWeight: FontWeight.w700,
  );
}
