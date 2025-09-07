// Automatic FlutterFlow imports
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'index.dart'; // Imports other custom widgets

import 'index.dart'; // Imports other custom widgets

import 'index.dart'; // Imports other custom widgets

// Set your widget name, define your parameter, and then add the
// boilerplate code using the green button on the right!

import 'package:syncfusion_flutter_charts/charts.dart';

class ChartWidget extends StatefulWidget {
  const ChartWidget({
    super.key,
    this.width,
    this.height,
    this.labelName = '',
    required this.xAxisData,
    required this.yAxisData,
    required this.chartTitle,
    required this.lineColor,
  });

  final double? width;
  final double? height;
  final List<String> xAxisData;
  final List<double> yAxisData;
  final String chartTitle;
  final String labelName;
  final Color lineColor;

  @override
  _ChartWidgetState createState() => _ChartWidgetState();
}

class _ChartWidgetState extends State<ChartWidget> {
  List<_ChartData> data = [];

  @override
  void initState() {
    super.initState();
    if (widget.xAxisData.length == widget.yAxisData.length) {
      for (int i = 0; i < widget.yAxisData.length; i++) {
        data.add(_ChartData(widget.xAxisData[i], widget.yAxisData[i]));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.xAxisData.length == widget.yAxisData.length
        ? SizedBox(
            width: widget.width,
            height: widget.height,
            child: SfCartesianChart(
              primaryXAxis: const CategoryAxis(),
              // Chart title
              title: ChartTitle(
                text: widget.chartTitle,
                textStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // Enable legend
              legend: Legend(isVisible: widget.labelName != ''),
              // Enable tooltip
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <CartesianSeries<_ChartData, String>>[
                LineSeries(
                  dataSource: data,
                  xValueMapper: (_ChartData data, _) => data.xAxisValue,
                  yValueMapper: (_ChartData data, _) => data.yAxisValue,
                  name: widget.labelName,
                  color: widget.lineColor,
                  // Enable data label
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                )
              ],
            ),
          )
        : SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: Text(
                  "Length of X-Axis data is not same as Y-Axis Data\n Please make sure both list have same length."),
            ),
          );
  }
}

class _ChartData {
  _ChartData(this.xAxisValue, this.yAxisValue);

  final String xAxisValue;
  final double yAxisValue;
}
