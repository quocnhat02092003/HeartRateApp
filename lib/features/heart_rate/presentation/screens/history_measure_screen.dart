import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../widgets/history_screen_gauge.dart';
import '../widgets/ppg_line_chart.dart';

class HistoryMeasureScreen extends StatefulWidget {
  final int bpm;
  final List<double>? ppgSignal;
  const HistoryMeasureScreen({super.key, required this.bpm, this.ppgSignal});

  @override
  State<HistoryMeasureScreen> createState() => _HistoryMeasureScreenState();
}

class _HistoryMeasureScreenState extends State<HistoryMeasureScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bpm = widget.bpm;
    final ppgSignal = widget.ppgSignal ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.historyTitle)),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: Text(
                  '$bpm BPM',
                  style: const TextStyle(color: Colors.white70, fontSize: 32),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '13 Tháng 9, 2025 - 10:29',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 20),
              HistoryScreenGauge(bpm: bpm),
              Text("Biểu đồ nhịp tim của bạn",
                  style: const TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  height: 80,
                  child: PpgLineChart(signal: ppgSignal),
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  bpm >= 60 && bpm <= 110
                      ? 'Nhịp tim của bạn đang ở mức bình thường.'
                      : 'Nhịp tim của bạn có vẻ bất thường, hãy thư giãn hoặc đo lại sau.',
                  style: TextStyle(
                    color: bpm >= 60 && bpm <= 110
                        ? Colors.green
                        : Colors.orange,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'Kết quả đo chỉ mang tính chất tham khảo. Nếu bạn cảm thấy không ổn, vui lòng liên hệ bác sĩ.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
