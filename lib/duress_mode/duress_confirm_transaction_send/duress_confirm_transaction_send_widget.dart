import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
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

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

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

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: PopScope(
        canPop: false,
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: Color(0x001D2428),
          body: SafeArea(
            top: true,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 0.0, 0.0),
                      child: FlutterFlowIconButton(
                        borderRadius: 20.0,
                        buttonSize: 40.0,
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: FlutterFlowTheme.of(context).primaryBackground,
                          size: 24.0,
                        ),
                        onPressed: () async {
                          context.safePop();
                        },
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Confirm Transaction',
                                    textAlign: TextAlign.center,
                                    style: FlutterFlowTheme.of(context)
                                        .headlineMedium
                                        .override(
                                          fontFamily: 'hello',
                                          color: FlutterFlowTheme.of(context)
                                              .primaryBackground,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  Text(
                                    'Please review your transaction details',
                                    textAlign: TextAlign.center,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'hello',
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ].divide(SizedBox(height: 16.0)),
                              ),
                              Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Padding(
                                  padding: EdgeInsets.all(24.0),
                                  child: Container(
                                    width: 300.0,
                                    decoration: BoxDecoration(
                                      color: Color(0x9D343739),
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    '${functions.formatBtcTrim(sendAmountBtcForFlow)}',
                                                    textAlign: TextAlign.center,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .displayMedium
                                                        .override(
                                                          fontFamily: 'hello',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryBackground,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'BTC',
                                                    textAlign: TextAlign.center,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .displayMedium
                                                        .override(
                                                          fontFamily: 'hello',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryBackground,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                '≈ ${functions.btcToUsdDisplay(sendAmountBtcForFlow, FFAppState().currentPriceMultiple)} USD',
                                                textAlign: TextAlign.center,
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyLarge
                                                        .override(
                                                          fontFamily: 'hello',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryText,
                                                          letterSpacing: 0.0,
                                                        ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                        ].divide(SizedBox(height: 24.0)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Container(
                                  width: 350.0,
                                  decoration: BoxDecoration(
                                    color: Color(0x9D343739),
                                    borderRadius: BorderRadius.circular(12.0),
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
                                          children: [
                                            Text(
                                              'Network Fee',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily: 'hello',
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .primaryBackground,
                                                        letterSpacing: 0.0,
                                                      ),
                                            ),
                                            Text(
                                              functions.formatBtcTrim(
                                                  _model.feeBtc.toString()),
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    fontFamily: 'hello',
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryBackground,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Total Amount',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    fontFamily: 'hello',
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryBackground,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                            Text(
                                              functions.totalAfterFee(
                                                  sendAmountBtcForFlow,
                                                  _model.feeBtc),
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    fontFamily: 'hello',
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryBackground,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        Divider(
                                          thickness: 1.0,
                                          color: FlutterFlowTheme.of(context)
                                              .alternate,
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'To Address',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily: 'hello',
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .primaryBackground,
                                                        letterSpacing: 0.0,
                                                      ),
                                            ),
                                            Text(
                                              functions.maskAddress(
                                                  FFAppState().scannedAddress,
                                                  6,
                                                  6),
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodySmall
                                                  .override(
                                                    fontFamily: 'hello',
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ].divide(SizedBox(height: 12.0)),
                                    ),
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: GestureDetector(
                                      onHorizontalDragUpdate: (details) async {
                                        _model.slidePct =
                                            details.globalPosition.dx;
                                        safeSetState(() {});
                                        _model.slidePct = _model.sliderValue!;
                                        safeSetState(() {});
                                        if ((_model.slidePct >= 100.0) &&
                                            (functions.totalAfterFee(
                                                    sendAmountBtcForFlow,
                                                    _model.feeBtc) !=
                                                '0')) {
                                          FFAppState().sendAmountBtc =
                                              functions.totalAfterFee(
                                                  sendAmountBtcForFlow,
                                                  _model.feeBtc);
                                          _applyDuressSendBalance(
                                              sendAmountBtcForFlow);
                                          FFAppState().txStartAt =
                                              getCurrentTimestamp;
                                          FFAppState().txTotalMins = 60;
                                          FFAppState().txStatus = 'awaiting';
                                          safeSetState(() {});

                                          context.pushNamed(
                                            DuressOrderProcessedWidget
                                                .routeName,
                                            queryParameters: {
                                              'amountBtc': serializeParam(
                                                functions.totalAfterFee(
                                                    sendAmountBtcForFlow,
                                                    _model.feeBtc),
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

                                          _model.slideValue = 0.0;
                                          safeSetState(() {});
                                          _model.slidePct = 0.0;
                                          safeSetState(() {});
                                        } else {
                                          _model.slideValue = 0.0;
                                          safeSetState(() {});
                                          safeSetState(() {
                                            _model.sliderValue = 0.0;
                                          });
                                          _model.slidePct = 0.0;
                                          safeSetState(() {});
                                        }
                                      },
                                      child: Container(
                                        width: 325.0,
                                        height: 60.0,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .accent1,
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                        ),
                                        child: Container(
                                          width: double.infinity,
                                          child: Stack(
                                            children: [
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 100.0,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            32.0),
                                                    shape: BoxShape.rectangle,
                                                  ),
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0.0, 0.0),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        'Slide to Sign and Send',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
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
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    valueOrDefault<double>(
                                                      functions
                                                          .alignXFromPercent(
                                                              _model.slidePct),
                                                      0.0,
                                                    ),
                                                    0.0),
                                                child: Container(
                                                  width: 60.0,
                                                  height: 60.0,
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, 0.0),
                                                    child: Icon(
                                                      Icons
                                                          .arrow_forward_rounded,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .info,
                                                      size: 24.0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Opacity(
                                                opacity: 0.01,
                                                child: Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0.0, 0.0),
                                                  child: Container(
                                                    width: double.infinity,
                                                    child: Slider(
                                                      activeColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                      inactiveColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .alternate,
                                                      min: 0.0,
                                                      max: 100.0,
                                                      value:
                                                          _model.sliderValue ??=
                                                              _model.slideValue,
                                                      onChanged:
                                                          (newValue) async {
                                                        safeSetState(() =>
                                                            _model.sliderValue =
                                                                newValue);
                                                        _model.slidePct =
                                                            _model.sliderValue!;
                                                        safeSetState(() {});
                                                        if ((_model.sliderValue! >=
                                                                100.0) &&
                                                            (functions.totalAfterFee(
                                                                    sendAmountBtcForFlow,
                                                                    _model
                                                                        .feeBtc) !=
                                                                '0')) {
                                                          FFAppState()
                                                                  .sendAmountBtc =
                                                              functions.totalAfterFee(
                                                                  sendAmountBtcForFlow,
                                                                  _model
                                                                      .feeBtc);
                                                          _applyDuressSendBalance(
                                                              sendAmountBtcForFlow);
                                                          safeSetState(() {});
                                                          FFAppState()
                                                                  .txStartAt =
                                                              getCurrentTimestamp;
                                                          FFAppState()
                                                              .txTotalMins = 60;
                                                          FFAppState()
                                                                  .txStatus =
                                                              'awaiting';
                                                          safeSetState(() {});

                                                          context.pushNamed(
                                                            DuressOrderProcessedWidget
                                                                .routeName,
                                                            queryParameters: {
                                                              'amountBtc':
                                                                  serializeParam(
                                                                functions.totalAfterFee(
                                                                    sendAmountBtcForFlow,
                                                                    _model
                                                                        .feeBtc),
                                                                ParamType
                                                                    .String,
                                                              ),
                                                              'toAddress':
                                                                  serializeParam(
                                                                FFAppState()
                                                                    .scannedAddress,
                                                                ParamType
                                                                    .String,
                                                              ),
                                                              'feeBtc':
                                                                  serializeParam(
                                                                _model.feeBtc,
                                                                ParamType
                                                                    .double,
                                                              ),
                                                            }.withoutNulls,
                                                          );

                                                          _model.slideValue =
                                                              0.0;
                                                          safeSetState(() {});
                                                          _model.slidePct = 0.0;
                                                          safeSetState(() {});
                                                        } else {
                                                          _model.slideValue =
                                                              0.0;
                                                          safeSetState(() {});
                                                          safeSetState(() {
                                                            _model.sliderValue =
                                                                0.0;
                                                          });
                                                        }
                                                      },
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
                                ].divide(SizedBox(height: 16.0)),
                              ),
                            ].divide(SizedBox(height: 24.0)),
                          ),
                        ],
                      ),
                    ]
                        .divide(SizedBox(height: 48.0))
                        .addToStart(SizedBox(height: 12.0))
                        .addToEnd(SizedBox(height: 24.0)),
                  ),
                ),
              ].addToEnd(SizedBox(height: 100.0)),
            ),
          ),
        ),
      ),
    );
  }
}
