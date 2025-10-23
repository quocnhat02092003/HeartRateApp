import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PpgLineChart extends StatelessWidget {
  final List<double> signal; // tín hiệu cường độ theo thời gian

  const PpgLineChart({super.key, required this.signal});

  @override
  Widget build(BuildContext context) {
    // chuyển đổi sang FlSpot (index ~ thời gian tương đối)
    final spots = signal
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: Colors.teal,
            barWidth: 2,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
            spots: spots.isNotEmpty
                ? spots
                : const [
                    FlSpot(0, 0),
                    FlSpot(1, 2.5),
                    FlSpot(2, 0),
                    FlSpot(3, 2.5),
                    FlSpot(4, 0),
                    FlSpot(5, 2.5),
                  ],
          ),
        ],
      ),
    );
  }
}
