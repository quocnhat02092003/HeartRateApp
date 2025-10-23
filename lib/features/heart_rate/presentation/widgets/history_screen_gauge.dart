import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class HistoryScreenGauge extends StatefulWidget {
  const HistoryScreenGauge({super.key, required this.bpm});

  final int bpm;

  @override
  State<HistoryScreenGauge> createState() => _HistoryScreenGaugeState();
}

class _HistoryScreenGaugeState extends State<HistoryScreenGauge> {
  double _currentValue = 0;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.bpm.toDouble();
  }

  Color _getColorForBpm(int bpm) {
    if (bpm < 60) return Colors.orange;
    if (bpm <= 100) return Colors.green;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorForBpm(widget.bpm);

    return Container(
      margin: const EdgeInsets.all(10),
      child: SfRadialGauge(
        enableLoadingAnimation: true,
        animationDuration: 1000,
        axes: <RadialAxis>[
          RadialAxis(
            minimum: 30,
            maximum: 150,
            ranges: <GaugeRange>[
              GaugeRange(
                startValue: 30,
                endValue: 60,
                color: Colors.orange,
                startWidth: 10,
                endWidth: 10,
              ),
              GaugeRange(
                startValue: 60,
                endValue: 100,
                color: Colors.green,
                startWidth: 10,
                endWidth: 10,
              ),
              GaugeRange(
                startValue: 100,
                endValue: 150,
                color: Colors.red,
                startWidth: 10,
                endWidth: 10,
              ),
            ],
            pointers: <GaugePointer>[
              NeedlePointer(
                value: _currentValue,
                needleColor: color,
                knobStyle: KnobStyle(color: color),
                enableAnimation: true,
                animationType: AnimationType.easeOutBack,
                animationDuration: 800,
              ),
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                widget: Text(
                  '${_currentValue.toInt()} BPM',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                angle: 90,
                positionFactor: 0.5,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
