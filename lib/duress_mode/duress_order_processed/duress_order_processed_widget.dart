import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'duress_order_processed_model.dart';
export 'duress_order_processed_model.dart';

/// Create a page that shows text in the middle saying "Decoy Seed Active"
/// with and orange check mark adn a button at the bottom of the page that
/// says "Back to Home"
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
  late DuressOrderProcessedModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DuressOrderProcessedModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(
        Duration(
          milliseconds: 2500,
        ),
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
          child: Align(
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 24.0),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 360),
                            curve: Curves.bounceOut,
                            width: 80.0,
                            height: 80.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).primary,
                              shape: BoxShape.circle,
                            ),
                            child: Align(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 40.0,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          'Order Processed',
                          textAlign: TextAlign.center,
                          style: FlutterFlowTheme.of(context)
                              .headlineMedium
                              .override(
                                font: GoogleFonts.interTight(
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .headlineMedium
                                      .fontStyle,
                                ),
                                color: FlutterFlowTheme.of(context)
                                    .primaryBackground,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .headlineMedium
                                    .fontStyle,
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
    );
  }
}
