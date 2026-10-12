import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/theme.dart';

class Sparkline extends StatelessWidget {
  const Sparkline({super.key, required this.values, this.width = 56, this.height = 30});
  final List<double> values;
  final double width, height;

  @override
  Widget build(BuildContext context) {
    if (values.length < 2) return SizedBox(width: width, height: height);
    final up = values.last >= values.first;
    final color = up ? AppColors.up : AppColors.down;
    final minY = values.reduce(math.min);
    final maxY = values.reduce(math.max);
    final pad = (maxY - minY) == 0 ? 1.0 : (maxY - minY) * 0.1;

    return SizedBox(
      width: width,
      height: height,
      child: LineChart(
        LineChartData(
          minY: minY - pad,
          maxY: maxY + pad,
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: [for (var i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i])],
              isCurved: true,
              curveSmoothness: 0.25,
              preventCurveOverShooting: true,
              color: color,
              barWidth: 1.8,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
