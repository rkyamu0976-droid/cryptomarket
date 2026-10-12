import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/coin.dart';
import '../services/api_service.dart';
import '../utils/format.dart';
import 'common.dart';
import 'state_views.dart';

class PriceChart extends StatefulWidget {
  const PriceChart({super.key, required this.coinId});
  final String coinId;
  @override
  State<PriceChart> createState() => _PriceChartState();
}

class _PriceChartState extends State<PriceChart> {
  static const _ranges = {'24H': 1, '7D': 7, '30D': 30, '90D': 90, '1Y': 365};

  String _range = '7D';
  bool _loading = true;
  String? _error;
  List<ChartPoint> _points = [];
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    final id = ++_requestId;
    try {
      final pts = await context.read<ApiService>().fetchChart(widget.coinId, _ranges[_range]!);
      if (!mounted || id != _requestId) return;
      setState(() {
        _points = pts;
        _loading = false;
        _error = null;
      });
    } on ApiException catch (e) {
      if (!mounted || id != _requestId) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  void _select(String range) {
    if (range == _range) return;
    setState(() {
      _range = range;
      _loading = true;
      _error = null;
    });
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 8, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          const SizedBox(height: 14),
          SizedBox(height: 230, child: _chartArea()),
          const SizedBox(height: 10),
          if (_points.length > 1 && !_loading && _error == null)
            Padding(
              padding: const EdgeInsets.only(right: 56),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(Fmt.chartDate(_points.first.time, withTime: _range == '24H' || _range == '7D'),
                      style: AppText.muted(11.5)),
                  Text(Fmt.chartDate(_points.last.time, withTime: _range == '24H' || _range == '7D'),
                      style: AppText.muted(11.5)),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final r in _ranges.keys)
                AppChip(label: r, selected: r == _range, onTap: () => _select(r)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _header() {
    if (_points.length < 2 || _loading || _error != null) {
      return Text('Price chart', style: AppText.muted(13, weight: FontWeight.w600));
    }
    final change = (_points.last.price - _points.first.price) / _points.first.price * 100;
    return Row(
      children: [
        Text('$_range change', style: AppText.muted(13, weight: FontWeight.w600)),
        const SizedBox(width: 10),
        ChangePill(change),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.only(right: 6),
          child: Text('Touch & drag to inspect', style: AppText.muted(11.5)),
        ),
      ],
    );
  }

  Widget _chartArea() {
    if (_loading) {
      return const Center(child: SkeletonBox(height: 200, radius: 14));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center, style: AppText.muted(13.5)),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _loading = true;
                  _error = null;
                });
                _fetch();
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (_points.length < 2) {
      return Center(child: Text('No chart data for this range.', style: AppText.muted(13.5)));
    }

    final prices = _points.map((p) => p.price);
    final minP = prices.reduce(math.min);
    final maxP = prices.reduce(math.max);
    final span = maxP - minP;
    final pad = span == 0 ? 1.0 : span * 0.08;
    final interval = span == 0 ? 1.0 : (span + 2 * pad) / 4;
    final up = _points.last.price >= _points.first.price;
    final color = up ? AppColors.up : AppColors.down;
    final showTime = _range == '24H' || _range == '7D';

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (_points.length - 1).toDouble(),
        minY: minP - pad,
        maxY: maxP + pad,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: AppColors.border.withOpacity(0.6), strokeWidth: 1, dashArray: [4, 4]),
        ),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 56,
              interval: interval,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text(Fmt.axisPrice(value), style: AppText.muted(10.5)),
              ),
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.surfaceHigh,
            getTooltipItems: (spots) => spots.map((s) {
              final p = _points[s.spotIndex];
              return LineTooltipItem(
                '${Fmt.price(p.price)}\n',
                AppText.number(13, color: AppColors.text),
                children: [
                  TextSpan(
                    text: Fmt.chartDate(p.time, withTime: showTime),
                    style: AppText.muted(11),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [for (var i = 0; i < _points.length; i++) FlSpot(i.toDouble(), _points[i].price)],
            isCurved: true,
            curveSmoothness: 0.2,
            preventCurveOverShooting: true,
            color: color,
            barWidth: 2.4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [color.withOpacity(0.28), color.withOpacity(0.0)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
