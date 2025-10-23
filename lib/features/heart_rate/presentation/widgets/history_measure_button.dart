import 'package:flutter/material.dart';
import 'package:flutter_heartrate/features/heart_rate/presentation/screens/history_measure_screen.dart';

class HistoryMeasureButton extends StatelessWidget {
  final int bpm;
  final DateTime timestamp;
  const HistoryMeasureButton({super.key, required this.bpm, required this.timestamp});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => HistoryMeasureScreen(bpm: bpm),
          ),
        );
      },
      child: Column(
        children: [
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 4),
                  Icon(Icons.history, color: Colors.white70),
                  const SizedBox(width: 8),
                  Text(
                    timestamp.toString(),
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.redAccent),
                  const SizedBox(width: 4),
                  Text(
                    bpm.toString(),
                    style: TextStyle(color: Colors.white70, fontSize: 30),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'bpm',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.blueAccent),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
