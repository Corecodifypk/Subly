import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class MonthlySpendingChart extends StatefulWidget {
  const MonthlySpendingChart({
    super.key,
    required this.data,
    this.months = const ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN'],
  });

  final List<double> data;
  final List<String> months;

  @override
  State<MonthlySpendingChart> createState() => _MonthlySpendingChartState();
}

class _MonthlySpendingChartState extends State<MonthlySpendingChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int? _touchedIndex;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spots = List.generate(
      widget.data.length,
      (i) => FlSpot(i.toDouble(), widget.data[i]),
    );
    final maxData = widget.data.isEmpty
        ? 0.0
        : widget.data.reduce((a, b) => a > b ? a : b);
    final maxY = (maxData * 1.2).clamp(10.0, double.infinity);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = Curves.easeOutCubic.transform(_controller.value);
        final animatedSpots = spots
            .map((s) => FlSpot(s.x, s.y * progress))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'STATISTICS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textLightGrey,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Monthly Spending',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: Stack(
                children: [
                  LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        drawHorizontalLine: false,
                        verticalInterval: 1,
                        getDrawingVerticalLine: (value) => FlLine(
                          color: AppColors.dividerGrey,
                          strokeWidth: 1,
                          dashArray: [4, 4],
                        ),
                      ),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx < 0 || idx >= widget.months.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  widget.months[idx],
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textLightGrey,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: (widget.data.length - 1).toDouble(),
                      minY: 0,
                      maxY: maxY,
                      lineTouchData: LineTouchData(
                        enabled: true,
                        touchCallback: (event, response) {
                          setState(() {
                            if (response?.lineBarSpots != null &&
                                response!.lineBarSpots!.isNotEmpty) {
                              _touchedIndex =
                                  response.lineBarSpots!.first.spotIndex;
                            }
                          });
                        },
                        getTouchedSpotIndicator: (barData, spotIndexes) {
                          return spotIndexes.map((index) {
                            return TouchedSpotIndicatorData(
                              FlLine(
                                color: AppColors.chartPurple,
                                strokeWidth: 1.5,
                                dashArray: [4, 4],
                              ),
                              FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, bar, i) =>
                                    FlDotCirclePainter(
                                  radius: 6,
                                  color: AppColors.chartPurple,
                                  strokeWidth: 0,
                                ),
                              ),
                            );
                          }).toList();
                        },
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) => Colors.white,
                          getTooltipItems: (spots) => spots.map((spot) {
                            return LineTooltipItem(
                              '\$${spot.y.toInt()}',
                              const TextStyle(
                                color: AppColors.textDark,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: animatedSpots,
                          isCurved: true,
                          curveSmoothness: 0.35,
                          color: AppColors.chartPurple,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, bar, index) {
                              if (_touchedIndex == index) {
                                return FlDotCirclePainter(
                                  radius: 6,
                                  color: AppColors.chartPurple,
                                  strokeWidth: 0,
                                );
                              }
                              return FlDotCirclePainter(
                                radius: 0,
                                color: Colors.transparent,
                                strokeWidth: 0,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.chartPurple.withValues(alpha: 0.25),
                                AppColors.chartPurple.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    duration: Duration.zero,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
