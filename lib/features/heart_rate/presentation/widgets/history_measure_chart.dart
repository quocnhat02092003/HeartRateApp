import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HistoryMeasureChart extends StatelessWidget {
  final List<double> values;
  const HistoryMeasureChart({super.key, required this.values});

  @override
  Widget build(BuildContext context) {
    // Dữ liệu mẫu giống ảnh
    final spots = List<FlSpot>.generate(
      values.length,
      (i) => FlSpot(i.toDouble(), values[i]),
    );

    final avg = values.reduce((a, b) => a + b) / values.length;

    // Chỉ số các điểm muốn hiện số (ở đây hiện tất cả)
    final labelIndices = List<int>.generate(values.length, (i) => i);

    // Tạo barData trước để dùng cho ShowingTooltipIndicators
    final barData = LineChartBarData(
      spots: spots,
      isCurved: true,
      barWidth: 2,
      color: Colors.teal,
      belowBarData: BarAreaData(show: false),
      // Chấm tròn có viền trắng
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, bar, index) {
          return FlDotCirclePainter(
            radius: 4,
            color: Colors.teal,
            strokeWidth: 2,
            strokeColor: Colors.white,
          );
        },
      ),
    );

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),

        // Tooltip hiển thị cố định (không cần chạm)
        showingTooltipIndicators: labelIndices
            .map(
              (i) =>
                  ShowingTooltipIndicators([LineBarSpot(barData, 0, spots[i])]),
            )
            .toList(),

        // Style của “bong bóng số” (ở đây ta làm nền trong suốt chỉ còn chữ)
        lineTouchData: LineTouchData(
          enabled: false, // tắt tương tác chạm
          touchTooltipData: LineTouchTooltipData(
            tooltipPadding: EdgeInsets.zero,
            tooltipMargin: 6,
            getTooltipColor: (value) => Colors.transparent,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((ts) {
                return LineTooltipItem(
                  ts.y.toStringAsFixed(0), // 89, 108, ...
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList();
            },
          ),
        ),

        // Đường trung bình (gạch) + nhãn "TB 77"
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: avg,
              color: Colors.teal,
              strokeWidth: 2,
              dashArray: [8, 6],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.centerRight,
                // “TB 77” giống ảnh (làm tròn)
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
                labelResolver: (line) => 'TB ${avg.round()}',
              ),
            ),
          ],
        ),

        lineBarsData: [barData],
        // padding một chút cho có khoảng không hiển thị số phía trên
        minY: (values.reduce((a, b) => a < b ? a : b)) - 10,
        maxY: (values.reduce((a, b) => a > b ? a : b)) + 20,
      ),
    );
  }
}
