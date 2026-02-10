import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_charts.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'duress_home_page_model.dart';
export 'duress_home_page_model.dart';

/// Create a homepage that displays the amount of Bitcoin the user has at the
/// top.
///
/// Below that, I want the Bitcoin price chart displayed in a container in the
/// middle of the page, measured against the United States dollar. In the top
/// left corner of that container, I want the Bitcoin B. In the other top
/// right-hand corner of that container, I want the United States price per
/// Bitcoin and the percentage gain over the past year. And below that chart,
/// I want a container on the bottom left that says receive button with a
/// download arrow And then in the bottom right, I want a container to have a
/// send button with another QR code logo.
class DuressHomePageWidget extends StatefulWidget {
  const DuressHomePageWidget({super.key});

  static String routeName = 'DuressHomePage';
  static String routePath = '/duressHomePage';

  @override
  State<DuressHomePageWidget> createState() => _DuressHomePageWidgetState();
}

class _DuressHomePageWidgetState extends State<DuressHomePageWidget> {
  late DuressHomePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DuressHomePageModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.chartReady = false;
      _model.btcPrices = [].toList().cast<double>();
      _model.btcEpochMs = [].toList().cast<double>();
      _model.retryCount = 0;
      safeSetState(() {});
      _model.btcResp = await BtcChartOneYearCall.call();

      if ((_model.btcResp?.succeeded ?? true) == true) {
        _model.prices1y = getJsonField(
          (_model.btcResp?.jsonBody ?? ''),
          r'''$.prices''',
          true,
        )!
            .toList()
            .cast<dynamic>();
        safeSetState(() {});
        _model.btcPrices = functions
            .extractPriceList(_model.prices1y.toList())
            .toList()
            .cast<double>();
        _model.btcEpochMs = functions
            .extractEpochMsList(_model.prices1y.toList())
            .toList()
            .cast<double>();
        safeSetState(() {});
        _model.chartReady = true;
        safeSetState(() {});
        _model.firstPrice = _model.btcPrices.firstOrNull;
        _model.currentPrice = _model.btcPrices.lastOrNull;
        safeSetState(() {});
        FFAppState().currentPriceMultiple = _model.currentPrice!;
        safeSetState(() {});
        _model.pctChange1y =
            functions.percentageChange(_model.firstPrice, _model.currentPrice);
        safeSetState(() {});
        FFAppState().fakeUsdValue = valueOrDefault<double>(
          functions.usdFromBtc(
              FFAppState().fakeBtcBalance, _model.currentPrice!),
          0.0,
        );
        FFAppState().update(() {});
        FFAppState().fakeSeeded = true;
        safeSetState(() {});
      } else {
        _model.chartReady = false;
        _model.btcPrices = [].toList().cast<double>();
        _model.btcEpochMs = [].toList().cast<double>();
        safeSetState(() {});
        if (_model.retryCount < 2) {
          _model.retryCount = _model.retryCount + 1;
          safeSetState(() {});
          _model.btcResp2 = await BtcChartOneYearCall.call();

          if ((_model.btcResp2?.succeeded ?? true) == true) {
            _model.prices1y = getJsonField(
              (_model.btcResp2?.jsonBody ?? ''),
              r'''$.prices''',
              true,
            )!
                .toList()
                .cast<dynamic>();
            safeSetState(() {});
            _model.btcPrices = functions
                .extractPriceList(_model.prices1y.toList())
                .toList()
                .cast<double>();
            _model.btcEpochMs = functions
                .extractEpochMsList(_model.prices1y.toList())
                .toList()
                .cast<double>();
            safeSetState(() {});
            _model.chartReady = true;
            safeSetState(() {});
            _model.firstPrice = _model.btcPrices.firstOrNull;
            _model.currentPrice = _model.btcPrices.lastOrNull;
            safeSetState(() {});
            _model.pctChange1y = functions.percentageChange(
                _model.firstPrice, _model.currentPrice);
            safeSetState(() {});
            FFAppState().fakeUsdValue = valueOrDefault<double>(
              functions.usdFromBtc(
                  FFAppState().fakeBtcBalance, _model.currentPrice!),
              0.0,
            );
            FFAppState().update(() {});
            FFAppState().fakeSeeded = true;
            safeSetState(() {});
          } else {
            _model.chartReady = false;
            _model.btcPrices = [].toList().cast<double>();
            _model.btcEpochMs = [].toList().cast<double>();
            safeSetState(() {});
            if (_model.retryCount < 2) {
              _model.retryCount = _model.retryCount + 1;
              safeSetState(() {});
              _model.btcResp3 = await BtcChartOneYearCall.call();

              if ((_model.btcResp3?.succeeded ?? true) == true) {
                _model.prices1y = getJsonField(
                  (_model.btcResp3?.jsonBody ?? ''),
                  r'''$.prices''',
                  true,
                )!
                    .toList()
                    .cast<dynamic>();
                safeSetState(() {});
                _model.btcPrices = functions
                    .extractPriceList(_model.prices1y.toList())
                    .toList()
                    .cast<double>();
                _model.btcEpochMs = functions
                    .extractEpochMsList(_model.prices1y.toList())
                    .toList()
                    .cast<double>();
                safeSetState(() {});
                _model.chartReady = true;
                safeSetState(() {});
                _model.firstPrice = _model.btcPrices.firstOrNull;
                _model.currentPrice = _model.btcPrices.lastOrNull;
                safeSetState(() {});
                _model.pctChange1y = functions.percentageChange(
                    _model.firstPrice, _model.currentPrice);
                safeSetState(() {});
                FFAppState().fakeUsdValue = valueOrDefault<double>(
                  functions.usdFromBtc(
                      FFAppState().fakeBtcBalance, _model.currentPrice!),
                  0.0,
                );
                FFAppState().update(() {});
                FFAppState().fakeSeeded = true;
                safeSetState(() {});
              } else {
                _model.chartReady = false;
                _model.btcPrices = [].toList().cast<double>();
                _model.btcEpochMs = [].toList().cast<double>();
                safeSetState(() {});
              }
            }
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
        backgroundColor: Color(0x001D2428),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: AlignmentDirectional(0.0, 0.0),
                    child: Stack(
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              20.0, 0.0, 0.0, 0.0),
                          child: Container(
                            width: 40.0,
                            height: 40.0,
                            decoration: BoxDecoration(
                              color: Color(0xFF343739),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Align(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: FlutterFlowIconButton(
                                borderRadius: 40.0,
                                buttonSize: 40.0,
                                icon: Icon(
                                  Icons.menu,
                                  color: FlutterFlowTheme.of(context).info,
                                  size: 24.0,
                                ),
                                onPressed: () async {
                                  context.pushNamed(
                                      DuressSettingsPageWidget.routeName);
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional(0.0, 0.0),
                    child: Stack(
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 10.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    20.0, 0.0, 0.0, 0.0),
                                child: Container(
                                  width: 40.0,
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF343739),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Align(
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: FlutterFlowIconButton(
                                      borderRadius: 40.0,
                                      buttonSize: 40.0,
                                      icon: Icon(
                                        Icons.timer_sharp,
                                        color:
                                            FlutterFlowTheme.of(context).info,
                                        size: 24.0,
                                      ),
                                      onPressed: () {
                                        print('IconButton pressed ...');
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    20.0, 0.0, 0.0, 0.0),
                                child: Container(
                                  width: 40.0,
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF343739),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Align(
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: FlutterFlowIconButton(
                                      borderRadius: 40.0,
                                      buttonSize: 40.0,
                                      icon: Icon(
                                        Icons.person,
                                        color:
                                            FlutterFlowTheme.of(context).info,
                                        size: 24.0,
                                      ),
                                      onPressed: () {
                                        print('IconButton pressed ...');
                                      },
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
                ],
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          24.0, 32.0, 24.0, 24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Your Bitcoin Balance',
                                style: FlutterFlowTheme.of(context)
                                    .headlineLarge
                                    .override(
                                      fontFamily: 'hello',
                                      color: FlutterFlowTheme.of(context).info,
                                      fontSize: 16.0,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                              Text(
                                '₿ ${valueOrDefault<String>(
                                  formatNumber(
                                    FFAppState().fakeBtcBalance,
                                    formatType: FormatType.decimal,
                                    decimalType: DecimalType.periodDecimal,
                                  ),
                                  '0',
                                )}',
                                style: FlutterFlowTheme.of(context)
                                    .displayMedium
                                    .override(
                                      fontFamily: 'hello',
                                      color: FlutterFlowTheme.of(context).info,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                '\$ ${valueOrDefault<String>(
                                  formatNumber(
                                    FFAppState().fakeUsdValue,
                                    formatType: FormatType.decimal,
                                    decimalType: DecimalType.periodDecimal,
                                  ),
                                  '0',
                                )}',
                                style: FlutterFlowTheme.of(context)
                                    .bodyLarge
                                    .override(
                                      fontFamily: 'hello',
                                      color: FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ].divide(SizedBox(height: 8.0)),
                          ),
                          Align(
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Container(
                                width: 350.0,
                                height: 300.0,
                                decoration: BoxDecoration(
                                  color: Color(0x9D343739),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 8.0,
                                      color: Color(0x1A000000),
                                      offset: Offset(
                                        0.0,
                                        2.0,
                                      ),
                                    )
                                  ],
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 40.0,
                                            height: 40.0,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                            ),
                                            child: Align(
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: Text(
                                                '₿',
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .titleLarge
                                                    .override(
                                                      fontFamily:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleLargeFamily,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                      fontSize: 24.0,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      useGoogleFonts:
                                                          !FlutterFlowTheme.of(
                                                                  context)
                                                              .titleLargeIsCustom,
                                                    ),
                                              ),
                                            ),
                                          ),
                                          Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                valueOrDefault<String>(
                                                  formatNumber(
                                                    _model.currentPrice,
                                                    formatType:
                                                        FormatType.decimal,
                                                    decimalType: DecimalType
                                                        .periodDecimal,
                                                    currency: '\$',
                                                  ),
                                                  '0',
                                                ),
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .titleMedium
                                                        .override(
                                                          fontFamily: 'hello',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .info,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                              ),
                                              Text(
                                                valueOrDefault<String>(
                                                  functions.formatpctLabel(
                                                      valueOrDefault<double>(
                                                    _model.pctChange1y,
                                                    0.0,
                                                  )),
                                                  '0',
                                                ),
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'hello',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primary,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Container(
                                            width: double.infinity,
                                            height: 200.0,
                                            decoration: BoxDecoration(
                                              color: Color(0x4D000000),
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            child: Stack(
                                              children: [
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0.0, 0.0),
                                                  child: Container(
                                                    width: 370.0,
                                                    height: 230.0,
                                                    child: FlutterFlowLineChart(
                                                      data: [
                                                        FFLineChartData(
                                                          xData:
                                                              _model.btcEpochMs,
                                                          yData:
                                                              _model.btcPrices,
                                                          settings:
                                                              LineChartBarData(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            barWidth: 2.0,
                                                            isCurved: true,
                                                            dotData: FlDotData(
                                                                show: false),
                                                            belowBarData:
                                                                BarAreaData(
                                                              show: true,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .accent1,
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                      chartStylingInfo:
                                                          ChartStylingInfo(
                                                        backgroundColor:
                                                            Color(0x4D000000),
                                                        showBorder: false,
                                                      ),
                                                      axisBounds: AxisBounds(),
                                                      xAxisLabelInfo:
                                                          AxisLabelInfo(
                                                        reservedSize: 32.0,
                                                      ),
                                                      yAxisLabelInfo:
                                                          AxisLabelInfo(
                                                        reservedSize: 40.0,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                if (_model.chartReady == false)
                                                  Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, 0.0),
                                                    child:
                                                        FlutterFlowIconButton(
                                                      borderRadius: 8.0,
                                                      buttonSize: 60.0,
                                                      fillColor:
                                                          Color(0x4D000000),
                                                      icon: Icon(
                                                        Icons.refresh,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        size: 32.0,
                                                      ),
                                                      onPressed: () async {
                                                        if (_model
                                                                .isLoadingChart !=
                                                            true) {
                                                          _model.isLoadingChart =
                                                              true;
                                                          safeSetState(() {});
                                                          _model.chartReady =
                                                              false;
                                                          _model.btcPrices = []
                                                              .toList()
                                                              .cast<double>();
                                                          _model.btcEpochMs = []
                                                              .toList()
                                                              .cast<double>();
                                                          safeSetState(() {});
                                                          _model.btcResp4 =
                                                              await BtcChartOneYearCall
                                                                  .call();

                                                          if ((_model.btcResp4
                                                                      ?.succeeded ??
                                                                  true) ==
                                                              true) {
                                                            _model.prices1y =
                                                                getJsonField(
                                                              (_model.btcResp4
                                                                      ?.jsonBody ??
                                                                  ''),
                                                              r'''$.prices''',
                                                              true,
                                                            )!
                                                                    .toList()
                                                                    .cast<
                                                                        dynamic>();
                                                            safeSetState(() {});
                                                            _model.btcPrices = functions
                                                                .extractPriceList(
                                                                    _model
                                                                        .prices1y
                                                                        .toList())
                                                                .toList()
                                                                .cast<double>();
                                                            _model.btcEpochMs = functions
                                                                .extractEpochMsList(
                                                                    _model
                                                                        .prices1y
                                                                        .toList())
                                                                .toList()
                                                                .cast<double>();
                                                            safeSetState(() {});
                                                            _model.chartReady =
                                                                true;
                                                            safeSetState(() {});
                                                            _model.firstPrice =
                                                                _model.btcPrices
                                                                    .firstOrNull;
                                                            _model.currentPrice =
                                                                _model.btcPrices
                                                                    .lastOrNull;
                                                            safeSetState(() {});
                                                            _model.pctChange1y =
                                                                functions.percentageChange(
                                                                    _model
                                                                        .firstPrice,
                                                                    _model
                                                                        .currentPrice);
                                                            safeSetState(() {});
                                                            FFAppState()
                                                                    .fakeUsdValue =
                                                                valueOrDefault<
                                                                    double>(
                                                              functions.usdFromBtc(
                                                                  FFAppState()
                                                                      .fakeBtcBalance,
                                                                  _model
                                                                      .currentPrice!),
                                                              0.0,
                                                            );
                                                            FFAppState()
                                                                .update(() {});
                                                            FFAppState()
                                                                    .fakeSeeded =
                                                                true;
                                                            safeSetState(() {});
                                                          } else {
                                                            _model.btcResp5 =
                                                                await BtcChartOneYearCall
                                                                    .call();

                                                            if ((_model.btcResp5
                                                                        ?.succeeded ??
                                                                    true) ==
                                                                true) {
                                                              _model.prices1y =
                                                                  getJsonField(
                                                                (_model.btcResp5
                                                                        ?.jsonBody ??
                                                                    ''),
                                                                r'''$.prices''',
                                                                true,
                                                              )!
                                                                      .toList()
                                                                      .cast<
                                                                          dynamic>();
                                                              safeSetState(
                                                                  () {});
                                                              _model.btcPrices = functions
                                                                  .extractPriceList(_model
                                                                      .prices1y
                                                                      .toList())
                                                                  .toList()
                                                                  .cast<
                                                                      double>();
                                                              _model.btcEpochMs = functions
                                                                  .extractEpochMsList(_model
                                                                      .prices1y
                                                                      .toList())
                                                                  .toList()
                                                                  .cast<
                                                                      double>();
                                                              safeSetState(
                                                                  () {});
                                                              _model.chartReady =
                                                                  true;
                                                              safeSetState(
                                                                  () {});
                                                              _model.firstPrice =
                                                                  _model
                                                                      .btcPrices
                                                                      .firstOrNull;
                                                              _model.currentPrice =
                                                                  _model
                                                                      .btcPrices
                                                                      .lastOrNull;
                                                              safeSetState(
                                                                  () {});
                                                              _model.pctChange1y =
                                                                  functions.percentageChange(
                                                                      _model
                                                                          .firstPrice,
                                                                      _model
                                                                          .currentPrice);
                                                              safeSetState(
                                                                  () {});
                                                              FFAppState()
                                                                      .fakeUsdValue =
                                                                  valueOrDefault<
                                                                      double>(
                                                                functions.usdFromBtc(
                                                                    FFAppState()
                                                                        .fakeBtcBalance,
                                                                    _model
                                                                        .currentPrice!),
                                                                0.0,
                                                              );
                                                              FFAppState()
                                                                  .update(
                                                                      () {});
                                                              FFAppState()
                                                                      .fakeSeeded =
                                                                  true;
                                                              safeSetState(
                                                                  () {});
                                                            } else {
                                                              _model.chartReady =
                                                                  false;
                                                              _model.btcPrices = []
                                                                  .toList()
                                                                  .cast<
                                                                      double>();
                                                              _model.btcEpochMs = []
                                                                  .toList()
                                                                  .cast<
                                                                      double>();
                                                              safeSetState(
                                                                  () {});
                                                            }
                                                          }
                                                        }

                                                        safeSetState(() {});
                                                      },
                                                    ),
                                                  ),
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
                          ),
                          Container(
                            width: 350.0,
                            height: 100.0,
                            decoration: BoxDecoration(),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 160.0,
                                  height: 80.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  child: Stack(
                                    children: [
                                      Material(
                                        color: Colors.transparent,
                                        elevation: 3.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                        ),
                                        child: Container(
                                          width: double.infinity,
                                          height: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Color(0xFF343739),
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.download_rounded,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryBackground,
                                                size: 24.0,
                                              ),
                                              Text(
                                                'Receive',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmallFamily,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryBackground,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .titleSmallIsCustom,
                                                        ),
                                              ),
                                            ].divide(SizedBox(height: 4.0)),
                                          ),
                                        ),
                                      ),
                                      Opacity(
                                        opacity: 0.0,
                                        child: Align(
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          child: FFButtonWidget(
                                            onPressed: () {
                                              print('Button pressed ...');
                                            },
                                            text: '',
                                            options: FFButtonOptions(
                                              width: 160.0,
                                              height: 80.0,
                                              padding: EdgeInsets.all(0.0),
                                              iconPadding: EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 0.0, 0.0, 0.0),
                                              color: Color(0xFF343739),
                                              textStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .override(
                                                        fontFamily: 'hello',
                                                        color: Colors.white,
                                                        letterSpacing: 0.0,
                                                      ),
                                              elevation: 3.0,
                                              borderRadius:
                                                  BorderRadius.circular(16.0),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 160.0,
                                  height: 80.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  child: Stack(
                                    children: [
                                      Material(
                                        color: Colors.transparent,
                                        elevation: 5.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                        ),
                                        child: Container(
                                          width: double.infinity,
                                          height: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Color(0xFF343739),
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.qr_code_rounded,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryBackground,
                                                size: 24.0,
                                              ),
                                              Text(
                                                'Send',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmallFamily,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryBackground,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .titleSmallIsCustom,
                                                        ),
                                              ),
                                            ].divide(SizedBox(height: 4.0)),
                                          ),
                                        ),
                                      ),
                                      Opacity(
                                        opacity: 0.0,
                                        child: Align(
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          child: FFButtonWidget(
                                            onPressed: () async {
                                              context.pushNamed(
                                                  DuressScanQRWidget.routeName);
                                            },
                                            text: '',
                                            options: FFButtonOptions(
                                              width: 160.0,
                                              height: 80.0,
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      16.0, 0.0, 16.0, 0.0),
                                              iconPadding: EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 0.0, 0.0, 0.0),
                                              color: Color(0xFF343739),
                                              textStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .override(
                                                        fontFamily: 'hello',
                                                        color: Colors.white,
                                                        letterSpacing: 0.0,
                                                      ),
                                              elevation: 3.0,
                                              borderRadius:
                                                  BorderRadius.circular(16.0),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ].divide(SizedBox(width: 16.0)),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Stack(
                                children: [
                                  Align(
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Container(
                                      width: 350.0,
                                      height: 100.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xFF343739),
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                      child: Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      20.0, 0.0, 0.0, 0.0),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            -1.0, 0.0),
                                                    child: Container(
                                                      width: 40.0,
                                                      height: 40.0,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primaryText,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12.0),
                                                      ),
                                                      child: Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                -1.0, 0.0),
                                                        child:
                                                            FlutterFlowIconButton(
                                                          borderRadius: 40.0,
                                                          buttonSize: 40.0,
                                                          icon: Icon(
                                                            Icons.arrow_outward,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .info,
                                                            size: 20.0,
                                                          ),
                                                          onPressed: () {
                                                            print(
                                                                'IconButton pressed ...');
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 0.0,
                                                                10.0, 0.0),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  1.0, 0.0),
                                                          child: Text(
                                                            '\$0 traded this month',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'hello',
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .info,
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  1.0, 0.0),
                                                          child: Text(
                                                            '\$1000 to next level',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'hello',
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryText,
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
                                                          ),
                                                        ),
                                                      ].divide(SizedBox(
                                                          height: 6.0)),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                LinearPercentIndicator(
                                                  percent: 0.05,
                                                  width: 300.0,
                                                  lineHeight: 6.0,
                                                  animation: true,
                                                  animateFromLastPercent: true,
                                                  progressColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .primaryBackground,
                                                  backgroundColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .accent4,
                                                  padding: EdgeInsets.zero,
                                                ),
                                              ],
                                            ),
                                          ].divide(SizedBox(height: 24.0)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            'Discover More',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'hello',
                                  color: FlutterFlowTheme.of(context).info,
                                  fontSize: 24.0,
                                  letterSpacing: 0.0,
                                ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: Container(
                              width: 350.0,
                              height: 100.0,
                              decoration: BoxDecoration(
                                color: Color(0xFF343739),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 15.0, 0.0, 0.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    -1.0, 0.0),
                                                child: Container(
                                                  width: 40.0,
                                                  height: 40.0,
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.0),
                                                  ),
                                                  child: Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            -1.0, 0.0),
                                                    child:
                                                        FlutterFlowIconButton(
                                                      borderRadius: 40.0,
                                                      buttonSize: 40.0,
                                                      icon: Icon(
                                                        Icons.edit_calendar,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .info,
                                                        size: 20.0,
                                                      ),
                                                      onPressed: () {
                                                        print(
                                                            'IconButton pressed ...');
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Align(
                                            alignment:
                                                AlignmentDirectional(0.0, 0.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Text(
                                                  'Set a recurring buy',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily: 'hello',
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .info,
                                                        letterSpacing: 0.0,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ].divide(SizedBox(height: 10.0)),
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Align(
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 2.0, 0.0, 0.0),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: Image.asset(
                                                'assets/images/ChatGPT_Image_Feb_9,_2026,_12_38_23_PM.png',
                                                width: 100.0,
                                                height: 100.0,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: Container(
                              width: 350.0,
                              height: 275.0,
                              decoration: BoxDecoration(
                                color: Color(0xFF343739),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      10.0, 0.0, 10.0, 0.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Align(
                                        alignment:
                                            AlignmentDirectional(-1.0, 0.0),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  15.0, 0.0, 0.0, 0.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    -1.0, 0.0),
                                                child: Container(
                                                  width: 40.0,
                                                  height: 40.0,
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.0),
                                                  ),
                                                  child: Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            -1.0, 0.0),
                                                    child:
                                                        FlutterFlowIconButton(
                                                      borderRadius: 40.0,
                                                      buttonSize: 40.0,
                                                      icon: Icon(
                                                        Icons.star,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .info,
                                                        size: 20.0,
                                                      ),
                                                      onPressed: () async {
                                                        context.pushNamed(
                                                            DuressSettingsPageWidget
                                                                .routeName);
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                'Place a limit order',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'hello',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .info,
                                                          letterSpacing: 0.0,
                                                        ),
                                              ),
                                            ].divide(SizedBox(width: 20.0)),
                                          ),
                                        ),
                                      ),
                                      Divider(
                                        thickness: 1.0,
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            15.0, 0.0, 0.0, 0.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Align(
                                              alignment: AlignmentDirectional(
                                                  -1.0, 0.0),
                                              child: Container(
                                                width: 40.0,
                                                height: 40.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                ),
                                                child: Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          -1.0, 0.0),
                                                  child: FlutterFlowIconButton(
                                                    borderRadius: 40.0,
                                                    buttonSize: 40.0,
                                                    icon: FaIcon(
                                                      FontAwesomeIcons.building,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .info,
                                                      size: 20.0,
                                                    ),
                                                    onPressed: () async {
                                                      context.pushNamed(
                                                          DuressSettingsPageWidget
                                                              .routeName);
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              'Get paid in Bitcoin',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily: 'hello',
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .info,
                                                        letterSpacing: 0.0,
                                                      ),
                                            ),
                                          ].divide(SizedBox(width: 20.0)),
                                        ),
                                      ),
                                      Divider(
                                        thickness: 1.0,
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            15.0, 0.0, 0.0, 0.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Align(
                                              alignment: AlignmentDirectional(
                                                  -1.0, 0.0),
                                              child: Container(
                                                width: 40.0,
                                                height: 40.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                ),
                                                child: Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          -1.0, 0.0),
                                                  child: FlutterFlowIconButton(
                                                    borderRadius: 40.0,
                                                    buttonSize: 40.0,
                                                    icon: Icon(
                                                      Icons.send,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .info,
                                                      size: 20.0,
                                                    ),
                                                    onPressed: () async {
                                                      context.pushNamed(
                                                          DuressSettingsPageWidget
                                                              .routeName);
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              'Auto-withdraw bitcoin',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily: 'hello',
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .info,
                                                        letterSpacing: 0.0,
                                                      ),
                                            ),
                                          ].divide(SizedBox(width: 20.0)),
                                        ),
                                      ),
                                    ].divide(SizedBox(height: 18.0)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Text(
                            'Fix the money, fix the world.',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'hello',
                                  color: FlutterFlowTheme.of(context).info,
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ].divide(SizedBox(height: 32.0)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
