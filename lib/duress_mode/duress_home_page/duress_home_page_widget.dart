import 'dart:async';
import 'dart:math' as math;

import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_charts.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'duress_home_page_model.dart';
export 'duress_home_page_model.dart';

class DuressHomePageWidget extends StatefulWidget {
  const DuressHomePageWidget({super.key});

  static String routeName = 'DuressHomePage';
  static String routePath = '/duressHomePage';

  @override
  State<DuressHomePageWidget> createState() => _DuressHomePageWidgetState();
}

class _DuressHomePageWidgetState extends State<DuressHomePageWidget> {
  static const _priceRefreshInterval = Duration(seconds: 5);
  static const _statsRefreshInterval = Duration(seconds: 30);
  static const _pageBackground = Color(0xFF080C0D);
  static const _panelBackground = Color(0xFF121819);
  static const _panelRaised = Color(0xFF1A2224);
  static const _lineGreen = Color(0xFF29D17D);
  static const _lineRed = Color(0xFFFF6B6B);
  static const _mutedText = Color(0xFF8C979A);
  static const _softBorder = Color(0xFF253033);
  static const _bitcoinOrange = Color(0xFFF7931A);

  late DuressHomePageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  Timer? _priceRefreshTimer;
  DateTime? _lastStatsRefreshAt;
  bool _startedMarketLoop = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DuressHomePageModel());

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _startMarketLoop();
    });
  }

  @override
  void dispose() {
    _priceRefreshTimer?.cancel();
    _model.dispose();
    super.dispose();
  }

  void _startMarketLoop() {
    if (_startedMarketLoop) {
      return;
    }
    _startedMarketLoop = true;
    _seedFromStoredPrice();
    unawaited(_refreshCurrentPrice(initial: true));
    unawaited(_loadChart());
    _priceRefreshTimer = Timer.periodic(_priceRefreshInterval, (_) {
      unawaited(_refreshCurrentPrice());
    });
  }

  void _seedFromStoredPrice() {
    final storedPrice = FFAppState().currentPriceMultiple;
    if (storedPrice <= 0) {
      return;
    }
    _model.currentPrice = storedPrice;
    _model.lastUpdatedAt = DateTime.now();
    _syncPortfolioValue(storedPrice);
    safeSetState(() {});
  }

  Future<void> _refreshCurrentPrice({bool initial = false}) async {
    final response = await BtcCurrentPriceCall.call();
    if (!mounted) {
      return;
    }

    if (initial) {
      _model.currentPriceResp = response;
    } else {
      _model.currentPriceRefreshResp = response;
    }

    if (response.succeeded != true) {
      safeSetState(() {});
      return;
    }

    final jsonBody = response.jsonBody ?? '';
    final price = _asDouble(getJsonField(jsonBody, r'''$.price''')) ??
        _asDouble(getJsonField(jsonBody, r'''$.data.amount''')) ??
        _asDouble(getJsonField(jsonBody, r'''$.bitcoin.usd'''));
    if (price == null || price <= 0) {
      safeSetState(() {});
      return;
    }

    final updatedAt =
        _asDateTime(getJsonField(jsonBody, r'''$.time''')) ?? DateTime.now();

    _applyCurrentPrice(
      price,
      updatedAt: updatedAt,
    );

    final shouldRefreshStats = initial ||
        _lastStatsRefreshAt == null ||
        DateTime.now().difference(_lastStatsRefreshAt!) >=
            _statsRefreshInterval;
    if (shouldRefreshStats) {
      _lastStatsRefreshAt = DateTime.now();
      await _refresh24hStats(price);
    }
  }

  Future<void> _refresh24hStats(double livePrice) async {
    final response = await BtcCoinbaseStatsCall.call();
    if (!mounted) {
      return;
    }
    _model.currentPriceStatsResp = response;
    if (response.succeeded != true) {
      safeSetState(() {});
      return;
    }

    final jsonBody = response.jsonBody ?? '';
    final open = _asDouble(getJsonField(jsonBody, r'''$.open'''));
    if (open == null || open <= 0) {
      safeSetState(() {});
      return;
    }

    _model.pctChange24h = functions.percentageChange(open, livePrice);
    safeSetState(() {});
  }

  Future<void> _loadChart() async {
    _model.isLoadingChart = true;
    safeSetState(() {});

    for (var attempt = 0; attempt < 3; attempt++) {
      final response = await BtcChartOneYearCall.call();
      if (!mounted) {
        return;
      }

      if (attempt == 0) {
        _model.btcResp = response;
      } else if (attempt == 1) {
        _model.btcResp2 = response;
      } else {
        _model.btcResp3 = response;
      }

      if (response.succeeded == true) {
        final rows = getJsonField(
          response.jsonBody ?? '',
          r'''$.prices''',
          true,
        );
        if (rows is List && _applyChartRows(rows)) {
          return;
        }
      }
    }

    _model.isLoadingChart = false;
    _model.chartReady = _model.btcPrices.length > 1;
    safeSetState(() {});
  }

  bool _applyChartRows(List<dynamic> rows) {
    final prices = functions
        .extractPriceList(rows)
        .where((price) => price.isFinite && price > 0)
        .toList();
    if (prices.length < 2) {
      return false;
    }

    _model.btcPrices = prices;
    _model.btcEpochMs = List<double>.generate(
      prices.length,
      (index) => index.toDouble(),
    );
    _model.firstPrice = prices.first;
    _model.currentPrice ??= prices.last;
    _model.pctChange1y =
        functions.percentageChange(_model.firstPrice, _model.currentPrice);
    _model.chartReady = true;
    _model.isLoadingChart = false;

    if ((FFAppState().currentPriceMultiple <= 0) ||
        (_model.currentPrice == prices.last)) {
      _applyCurrentPrice(prices.last, updatedAt: DateTime.now());
    } else {
      _syncPortfolioValue(_model.currentPrice!);
      safeSetState(() {});
    }

    return true;
  }

  void _applyCurrentPrice(
    double price, {
    double? pct24h,
    DateTime? updatedAt,
  }) {
    final previousPrice = _model.currentPrice;
    _model.currentPrice = price;
    _model.pricePulseUp =
        previousPrice == null ? null : price >= previousPrice.toDouble();
    _model.pctChange24h = pct24h ?? _model.pctChange24h;
    _model.lastUpdatedAt = updatedAt ?? DateTime.now();
    if (_model.firstPrice != null) {
      _model.pctChange1y =
          functions.percentageChange(_model.firstPrice, _model.currentPrice);
    }
    _syncPortfolioValue(price);
    safeSetState(() {});
  }

  void _syncPortfolioValue(double price) {
    if (price <= 0) {
      return;
    }
    FFAppState().update(() {
      FFAppState().currentPriceMultiple = price;
      FFAppState().fakeUsdValue = valueOrDefault<double>(
        functions.usdFromBtc(FFAppState().fakeBtcBalance, price),
        0.0,
      );
      FFAppState().fakeSeeded = true;
    });
  }

  Future<void> _manualRefresh() async {
    if (_model.isLoadingChart == true) {
      return;
    }
    await Future.wait([
      _refreshCurrentPrice(),
      _loadChart(),
    ]);
  }

  double? _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '');
  }

  DateTime? _asDateTime(dynamic value) {
    final text = value?.toString();
    if (text == null || text.isEmpty) {
      return null;
    }
    return DateTime.tryParse(text);
  }

  String _formatUsd(double? value, {int decimalDigits = 2}) {
    if (value == null || !value.isFinite || value <= 0) {
      return '--';
    }
    return NumberFormat.currency(
      symbol: '\$',
      decimalDigits: decimalDigits,
    ).format(value);
  }

  String _formatBtc(double value) {
    if (!value.isFinite || value <= 0) {
      return '0.00000000';
    }
    return value.toStringAsFixed(8);
  }

  String _changeLabel(double? value) {
    if (value == null || !value.isFinite) {
      return '--';
    }
    return functions.formatpctLabel(value);
  }

  String _lastUpdatedLabel() {
    final lastUpdatedAt = _model.lastUpdatedAt;
    if (lastUpdatedAt == null) {
      return 'Syncing';
    }
    final age = DateTime.now().difference(lastUpdatedAt);
    if (age.inSeconds < 75) {
      return 'Live';
    }
    if (age.inMinutes < 60) {
      return '${age.inMinutes}m ago';
    }
    return DateFormat('h:mm a').format(lastUpdatedAt);
  }

  Color _changeColor(double? value) {
    if ((value ?? 0) < 0) {
      return _lineRed;
    }
    return _lineGreen;
  }

  double? get _chartMinY {
    if (_model.btcPrices.isEmpty) {
      return null;
    }
    return _model.btcPrices.reduce(math.min) * 0.985;
  }

  double? get _chartMaxY {
    if (_model.btcPrices.isEmpty) {
      return null;
    }
    return _model.btcPrices.reduce(math.max) * 1.015;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    final btcBalance = FFAppState().fakeBtcBalance;
    final usdBalance = FFAppState().fakeUsdValue;

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
            child: Column(
              children: [
                _buildTopBar(context),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20.0, 22.0, 20.0, 34.0),
                    children: [
                      _centered(
                        _buildBalanceHeader(context, btcBalance, usdBalance),
                      ),
                      const SizedBox(height: 22.0),
                      _centered(_buildMarketCard(context)),
                      const SizedBox(height: 16.0),
                      _centered(_buildActionRow(context)),
                      const SizedBox(height: 16.0),
                      _centered(_buildMonthlyCard(context)),
                      const SizedBox(height: 24.0),
                      _centered(_buildDiscoverList(context)),
                      const SizedBox(height: 28.0),
                      Text(
                        'Fix the money, fix the world.',
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'InterTight',
                              color: _mutedText,
                              fontSize: 13.0,
                              letterSpacing: 0.0,
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
    );
  }

  Widget _centered(Widget child) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390.0),
        child: child,
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _iconButton(
            context,
            icon: Icons.menu_rounded,
            onPressed: () async {
              context.pushNamed(DuressSettingsPageWidget.routeName);
            },
          ),
          Text(
            'Wallet',
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  fontFamily: 'InterTight',
                  color: FlutterFlowTheme.of(context).info,
                  fontSize: 17.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w700,
                ),
          ),
          Row(
            children: [
              _iconButton(
                context,
                icon: Icons.sync_rounded,
                onPressed: _manualRefresh,
              ),
              const SizedBox(width: 10.0),
              _iconButton(
                context,
                icon: Icons.person_rounded,
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: BoxDecoration(
        color: _panelRaised,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: _softBorder),
      ),
      child: FlutterFlowIconButton(
        borderRadius: 8.0,
        buttonSize: 40.0,
        icon: Icon(
          icon,
          color: FlutterFlowTheme.of(context).info,
          size: 21.0,
        ),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildBalanceHeader(
    BuildContext context,
    double btcBalance,
    double usdBalance,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Bitcoin Balance',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'InterTight',
                    color: _mutedText,
                    fontSize: 13.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            _statusPill(
              context,
              label: _lastUpdatedLabel(),
              color: _lineGreen,
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            '₿ ${_formatBtc(btcBalance)}',
            maxLines: 1,
            style: FlutterFlowTheme.of(context).displayMedium.override(
                  fontFamily: 'InterTight',
                  color: FlutterFlowTheme.of(context).info,
                  fontSize: 38.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          _formatUsd(usdBalance),
          style: FlutterFlowTheme.of(context).titleMedium.override(
                fontFamily: 'InterTight',
                color: _mutedText,
                fontSize: 17.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  Widget _buildMarketCard(BuildContext context) {
    final change24h = _model.pctChange24h;
    final change1y = _model.pctChange1y;
    final lineColor = FlutterFlowTheme.of(context).primary;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _panelBackground,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: _softBorder),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18.0,
            color: Color(0x33000000),
            offset: Offset(0.0, 10.0),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42.0,
                  height: 42.0,
                  decoration: BoxDecoration(
                    color: _bitcoinOrange,
                    borderRadius: BorderRadius.circular(21.0),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '₿',
                    style: FlutterFlowTheme.of(context).titleLarge.override(
                          fontFamily: 'InterTight',
                          color: Colors.white,
                          fontSize: 25.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bitcoin',
                        style:
                            FlutterFlowTheme.of(context).titleMedium.override(
                                  fontFamily: 'InterTight',
                                  color: FlutterFlowTheme.of(context).info,
                                  fontSize: 18.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        'BTC/USD',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'InterTight',
                              color: _mutedText,
                              fontSize: 12.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                _statusPill(
                  context,
                  label: 'LIVE',
                  color: lineColor,
                  filled: true,
                ),
              ],
            ),
            const SizedBox(height: 18.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.0, 0.12),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: FittedBox(
                      key: ValueKey(_formatUsd(_model.currentPrice)),
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _formatUsd(_model.currentPrice),
                        maxLines: 1,
                        style:
                            FlutterFlowTheme.of(context).displaySmall.override(
                                  fontFamily: 'InterTight',
                                  color: FlutterFlowTheme.of(context).info,
                                  fontSize: 34.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _changeChip(context, '24H', change24h),
                    const SizedBox(height: 6.0),
                    _changeChip(context, '1Y', change1y),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18.0),
            Container(
              height: 178.0,
              decoration: BoxDecoration(
                color: const Color(0xFF0B1011),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: const Color(0xFF1C2628)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6.0, 10.0, 8.0, 8.0),
                child: _buildChart(context, lineColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context, Color lineColor) {
    if (_model.chartReady == true && _model.btcPrices.length > 1) {
      return FlutterFlowLineChart(
        data: [
          FFLineChartData(
            xData: _model.btcEpochMs,
            yData: _model.btcPrices,
            settings: LineChartBarData(
              color: lineColor,
              barWidth: 2.8,
              isCurved: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: lineColor.withValues(alpha: 0.12),
              ),
            ),
          )
        ],
        chartStylingInfo: ChartStylingInfo(
          backgroundColor: Colors.transparent,
          showGrid: true,
          gridColor: const Color(0x1AFFFFFF),
          showBorder: false,
          enableTooltip: true,
          tooltipBackgroundColor: const Color(0xFF111819),
        ),
        axisBounds: AxisBounds(
          minX: 0.0,
          maxX: (_model.btcPrices.length - 1).toDouble(),
          minY: _chartMinY,
          maxY: _chartMaxY,
        ),
        xAxisLabelInfo: const AxisLabelInfo(
          showLabels: false,
          reservedSize: 0.0,
        ),
        yAxisLabelInfo: const AxisLabelInfo(
          showLabels: false,
          reservedSize: 0.0,
        ),
      );
    }

    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _MarketSkeletonPainter(
              lineColor: lineColor,
              gridColor: const Color(0x14FFFFFF),
            ),
          ),
        ),
        if (_model.isLoadingChart != true)
          Center(
            child: InkWell(
              borderRadius: BorderRadius.circular(8.0),
              onTap: _manualRefresh,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.sync_rounded,
                      color: lineColor,
                      size: 16.0,
                    ),
                    const SizedBox(width: 6.0),
                    Text(
                      'Sync market',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'InterTight',
                            color: FlutterFlowTheme.of(context).info,
                            fontSize: 12.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _statusPill(
    BuildContext context, {
    required String label,
    required Color color,
    bool filled = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: filled ? color.withValues(alpha: 0.16) : Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.0,
            height: 6.0,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3.0),
            ),
          ),
          const SizedBox(width: 6.0),
          Text(
            label,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'InterTight',
                  color: filled ? color : _mutedText,
                  fontSize: 11.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }

  Widget _changeChip(BuildContext context, String label, double? value) {
    final color = _changeColor(value);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        '$label ${_changeLabel(value)}',
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: 'InterTight',
              color: color,
              fontSize: 12.0,
              letterSpacing: 0.0,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }

  Widget _buildActionRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _actionTile(
            context,
            icon: Icons.south_west_rounded,
            label: 'Receive',
            onTap: () {},
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: _actionTile(
            context,
            icon: Icons.qr_code_2_rounded,
            label: 'Send',
            onTap: () async {
              context.pushNamed(DuressScanQRWidget.routeName);
            },
          ),
        ),
      ],
    );
  }

  Widget _actionTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: _panelRaised,
      borderRadius: BorderRadius.circular(8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: onTap,
        child: Container(
          height: 72.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: _softBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: FlutterFlowTheme.of(context).info,
                size: 23.0,
              ),
              const SizedBox(width: 9.0),
              Text(
                label,
                style: FlutterFlowTheme.of(context).titleSmall.override(
                      fontFamily: 'InterTight',
                      color: FlutterFlowTheme.of(context).info,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyCard(BuildContext context) {
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
              Container(
                width: 38.0,
                height: 38.0,
                decoration: BoxDecoration(
                  color: _panelRaised,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: _softBorder),
                ),
                child: Icon(
                  Icons.arrow_outward_rounded,
                  color: FlutterFlowTheme.of(context).info,
                  size: 19.0,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\$0 traded this month',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'InterTight',
                            color: FlutterFlowTheme.of(context).info,
                            fontSize: 14.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 3.0),
                    Text(
                      '\$1,000 to next level',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'InterTight',
                            color: _mutedText,
                            fontSize: 12.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              Text(
                '5%',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'InterTight',
                      color: _mutedText,
                      fontSize: 12.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 15.0),
          LinearPercentIndicator(
            percent: 0.05,
            lineHeight: 6.0,
            animation: true,
            animateFromLastPercent: true,
            progressColor: _lineGreen,
            backgroundColor: const Color(0xFF283236),
            barRadius: const Radius.circular(4.0),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverList(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _panelBackground,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: _softBorder),
      ),
      child: Column(
        children: [
          _discoverRow(
            context,
            icon: Icons.edit_calendar_rounded,
            label: 'Set a recurring buy',
            onTap: () {},
          ),
          _divider(),
          _discoverRow(
            context,
            icon: Icons.star_rounded,
            label: 'Place a limit order',
            onTap: () {
              context.pushNamed(DuressSettingsPageWidget.routeName);
            },
          ),
          _divider(),
          _discoverRow(
            context,
            icon: Icons.account_balance_rounded,
            label: 'Get paid in Bitcoin',
            onTap: () {
              context.pushNamed(DuressSettingsPageWidget.routeName);
            },
          ),
          _divider(),
          _discoverRow(
            context,
            icon: Icons.send_rounded,
            label: 'Auto-withdraw bitcoin',
            onTap: () {
              context.pushNamed(DuressSettingsPageWidget.routeName);
            },
          ),
        ],
      ),
    );
  }

  Widget _discoverRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 13.0),
          child: Row(
            children: [
              Container(
                width: 36.0,
                height: 36.0,
                decoration: BoxDecoration(
                  color: _panelRaised,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: _softBorder),
                ),
                child: Icon(
                  icon,
                  color: FlutterFlowTheme.of(context).info,
                  size: 18.0,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'InterTight',
                        color: FlutterFlowTheme.of(context).info,
                        fontSize: 14.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: _mutedText,
                size: 22.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      height: 1.0,
      margin: const EdgeInsets.only(left: 62.0),
      color: _softBorder,
    );
  }
}

class _MarketSkeletonPainter extends CustomPainter {
  const _MarketSkeletonPainter({
    required this.lineColor,
    required this.gridColor,
  });

  final Color lineColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;

    for (var i = 1; i <= 3; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final path = Path()
      ..moveTo(0, size.height * 0.72)
      ..cubicTo(
        size.width * 0.18,
        size.height * 0.58,
        size.width * 0.26,
        size.height * 0.76,
        size.width * 0.39,
        size.height * 0.48,
      )
      ..cubicTo(
        size.width * 0.52,
        size.height * 0.23,
        size.width * 0.66,
        size.height * 0.55,
        size.width * 0.78,
        size.height * 0.36,
      )
      ..cubicTo(
        size.width * 0.88,
        size.height * 0.22,
        size.width * 0.94,
        size.height * 0.31,
        size.width,
        size.height * 0.18,
      );

    final areaPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      areaPath,
      Paint()..color = lineColor.withValues(alpha: 0.08),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor.withValues(alpha: 0.62)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _MarketSkeletonPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor ||
        oldDelegate.gridColor != gridColor;
  }
}
