// Automatic FlutterFlow imports
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:math' as math;

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
  State<ChartWidget> createState() => _ChartWidgetState();
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
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                if (widget.chartTitle.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      widget.chartTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                Expanded(
                  child: CustomPaint(
                    painter: _LineChartPainter(
                      data: data,
                      lineColor: widget.lineColor,
                      gridColor: Colors.grey.withValues(alpha: 0.20),
                      labelColor: Colors.grey.shade600,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
                if (widget.labelName.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: widget.lineColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(widget.labelName),
                      ],
                    ),
                  ),
              ],
            ),
          )
        : const SizedBox(
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

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.data,
    required this.lineColor,
    required this.gridColor,
    required this.labelColor,
  });

  final List<_ChartData> data;
  final Color lineColor;
  final Color gridColor;
  final Color labelColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || size.width <= 0 || size.height <= 0) {
      return;
    }

    const leftPadding = 8.0;
    const rightPadding = 8.0;
    const topPadding = 8.0;
    const bottomPadding = 8.0;
    final chartWidth = math.max(0.0, size.width - leftPadding - rightPadding);
    final chartHeight = math.max(0.0, size.height - topPadding - bottomPadding);

    final minY = data.map((d) => d.yAxisValue).reduce(math.min);
    final maxY = data.map((d) => d.yAxisValue).reduce(math.max);
    final range = maxY == minY ? 1.0 : maxY - minY;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = topPadding + (chartHeight / 4) * i;
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        gridPaint,
      );
    }

    final path = Path();
    for (var i = 0; i < data.length; i++) {
      final x = data.length == 1
          ? leftPadding + chartWidth / 2
          : leftPadding + (chartWidth / (data.length - 1)) * i;
      final normalizedY = (data[i].yAxisValue - minY) / range;
      final y = topPadding + chartHeight * (1 - normalizedY);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    for (var i = 0; i < data.length; i++) {
      final x = data.length == 1
          ? leftPadding + chartWidth / 2
          : leftPadding + (chartWidth / (data.length - 1)) * i;
      final normalizedY = (data[i].yAxisValue - minY) / range;
      final y = topPadding + chartHeight * (1 - normalizedY);
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.labelColor != labelColor;
  }
}
