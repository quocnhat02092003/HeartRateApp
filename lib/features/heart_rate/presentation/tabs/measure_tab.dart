import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:flutter_heartrate/database/db/heart_rate_record.dart';

import 'package:flutter_heartrate/features/heart_rate/service/push_hr_blynk.dart';
import 'package:flutter_heartrate/features/heart_rate/service/push_hr_zalo_bot.dart';

import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../firebase/auth/GoogleAuthService.dart';
import '../widgets/bpm_gauge.dart';
import '../widgets/ppg_line_chart.dart';
import '../../../algorithm/heart_rate_analyzer.dart';
import '../screens/history_measure_screen.dart';

class MeasureTab extends StatefulWidget {
  const MeasureTab({super.key});

  @override
  State<MeasureTab> createState() => MeasureTabState();
}

class MeasureTabState extends State<MeasureTab> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  int _currentBpm = 0;
  int? _startTimestamp;
  bool _isFinishing = false;


  GoogleSignInAccount? get _user => GoogleAuthService.currentUser;

  final List<double> _ppgSignal = [];
  final int _maxSample = 150; // ~5s @30fps

  late HeartRateAnalyzer _analyzer;

  bool _isButtonStartMeasureEnabled = false;

  @override
  void initState() {
    super.initState();
    _analyzer = HeartRateAnalyzer(
      HeartRateAnalyzerConfig(
        fps: 30,
        windowSec: 10,
        stepSec: 1,
        smoothSamples: 3,
        minPeakDistMs: 300,
        bpmMin: 40,
        bpmMax: 180,
      ),
      onBpmCalculated: (bpm) => setState(() {
        _currentBpm = bpm.toInt();
      }),
    );
    
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      final backCamera = _cameras!.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
      );

      _controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      await _controller!.setFlashMode(FlashMode.torch);
      // _isFlashOn = true;
      // setState(() => _isCameraReady = true);

      _startTimestamp = DateTime.now().millisecondsSinceEpoch;

      _controller!.startImageStream((image) async {
        final bytes = image.planes[1].bytes; // plane V (hoặc Cr)
        final avg = bytes.fold<int>(0, (sum, b) => sum + b) / bytes.length;
        final timestamp = DateTime.now().millisecondsSinceEpoch;

        _analyzer.addSample(avg.toDouble());

        // cập nhật tín hiệu PPG để vẽ đồ thị
        setState(() {
          _ppgSignal.add(avg.toDouble());
          if (_ppgSignal.length > _maxSample) {
            _ppgSignal.removeAt(0);
          }
        });

        // nếu đã qua 15s -> dừng đo và chuyển trang
        if (_startTimestamp != null && timestamp - _startTimestamp! >= 15000 && !_isFinishing) {
          _isFinishing = true;
          await _finishMeasurement();
        }
      });
    } catch (e) {
      debugPrint('Lỗi khởi tạo camera: $e');
    }
  }

  Future<void> _finishMeasurement() async {
    if (!mounted) return;

   PushHrBlynk.pushData(_currentBpm);
   PushHrZaloBot.pushDataZalo(_currentBpm);
    await stopCamera();

    if (_user != null){
      await addHeartRateRecordToCloud(_user!.id, _currentBpm.toInt(), List<double>.from(_ppgSignal) );
    }

    if (mounted) {
      await Navigator.of(context)
          .push(
            MaterialPageRoute(
              builder: (_) => HistoryMeasureScreen(bpm: _currentBpm, ppgSignal: List<double>.from(_ppgSignal),),
            ),
          )
          .then((_) async {
            setState(() {
              _currentBpm = 0;
              _startTimestamp = null;
              _isButtonStartMeasureEnabled = false;
              _isFinishing = false;
              _ppgSignal.clear();
            });
          });
    }
  }

  Future<void> stopCamera() async {
    // được gọi khi rời tab đo
    if (_controller != null) {
      await _controller!.setFlashMode(FlashMode.off);
      await _controller!.dispose();
      _controller = null;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const SizedBox(height: 20),
          Center(child:
            Text(
              _isButtonStartMeasureEnabled ? "ĐANG ĐO..." : "ĐỀ TÀI KHÓA LUẬN TỐT NGHIỆP IUH (Nhật-Tâm)",textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 22),
            )
            ),
          const SizedBox(height: 30),
          BpmGauge(
            progress: _currentBpm / 180,
            bpmText: _currentBpm.toString(),
          ),
          const SizedBox(height: 30),
          SizedBox(height: 80, child: PpgLineChart(signal: _ppgSignal)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isButtonStartMeasureEnabled = !_isButtonStartMeasureEnabled;
                if (_isButtonStartMeasureEnabled) {
                  _currentBpm = 0;
                  _initializeCamera();
                } else {
                  stopCamera();
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              textStyle: const TextStyle(color: Colors.white),
            ),
            child: Text(
              _isButtonStartMeasureEnabled ? 'Dừng đo' : 'Bắt đầu đo',
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            AppStrings.lastResult,
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
