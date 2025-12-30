import 'package:flutter/material.dart';
import 'package:flutter_heartrate/features/heart_rate/presentation/screens/history_measure_screen.dart';
import 'package:intl/intl.dart';

class HistoryMeasureButton extends StatelessWidget {
  final int bpm;
  final List<double> ppgSignal;
  final double bp_dia;
  final double bp_sys;
  final DateTime timestamp;
  const HistoryMeasureButton({
    super.key,
    required this.bpm,
    required this.timestamp,
    required this.ppgSignal,
    required this.bp_dia,
    required this.bp_sys,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => HistoryMeasureScreen(
              bpm: bpm,
              ppgSignal: ppgSignal,
              timestamp: timestamp,
              bp_dia: bp_dia,
              bp_sys: bp_sys,
            ),
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
                    DateFormat("dd/MM/yyyy HH:mm:ss").format(timestamp),
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
