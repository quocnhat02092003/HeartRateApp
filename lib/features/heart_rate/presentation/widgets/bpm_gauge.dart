import 'package:flutter/material.dart';

class BpmGauge extends StatelessWidget {
  final double progress; // 0..1
  final String bpmText;

  const BpmGauge({super.key, required this.progress, required this.bpmText});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 200,
          height: 200,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 12,
            backgroundColor: Colors.grey.shade800,
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color.fromARGB(255, 197, 54, 54),
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite, color: Colors.red, size: 32),
            const SizedBox(height: 10),
            Text(
              bpmText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'BPM',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
          ],
        ),
      ],
    );
  }
}
