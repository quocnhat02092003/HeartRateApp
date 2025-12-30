import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_heartrate/database/db/save_info_blood_pressure.dart';

import 'package:flutter_heartrate/database/db/heart_rate_record.dart';

import 'package:flutter_heartrate/features/heart_rate/service/push_hr_blynk.dart';
import 'package:flutter_heartrate/features/heart_rate/service/push_hr_zalo_bot.dart';

import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../firebase/auth/GoogleAuthService.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../../../algorithm/heart_rate_analyzer2.dart';
import '../widgets/bpm_gauge.dart';
import '../widgets/ppg_line_chart.dart';
import '../../../algorithm/heart_rate_analyzer.dart';
import '../screens/history_measure_screen.dart';

class MeasureTab extends StatefulWidget {
  const MeasureTab({super.key});

  @override
  State<MeasureTab> createState() => MeasureTabState();
}

class _BPScaler {
  late List<double> xMean;
  late List<double> xScale;
  late List<double> yMean;
  late List<double> yScale;

  Future<void> load() async {
    final jsonStr = await rootBundle.loadString('assets/models/config.json');
    final data = json.decode(jsonStr);
    xMean = List<double>.from(data['X_mean']);
    xScale = List<double>.from(data['X_scale']);
    yMean = List<double>.from(data['y_mean']);
    yScale = List<double>.from(data['y_scale']);
  }

  List<double> transformX(List<double> input) {
    return List.generate(
      input.length,
      (i) => (input[i] - xMean[i]) / xScale[i],
    );
  }

  List<double> inverseY(List<double> output) {
    return List.generate(
      output.length,
      (i) => output[i] * yScale[i] + yMean[i],
    );
  }
}

class _BPModel {
  late Interpreter interpreter;

  Future<void> load() async {
    interpreter = await Interpreter.fromAsset('assets/models/model.tflite');
    interpreter.allocateTensors();
  }

  List<double> predict(List<double> input) {
    try {
      // Lấy tensor
      var inputTensor = interpreter.getInputTensor(0);
      var outputTensor = interpreter.getOutputTensor(0);

      // Log shape để debug
      debugPrint('[_BPModel] Input tensor shape: ${inputTensor.shape}');
      debugPrint('[_BPModel] Output tensor shape: ${outputTensor.shape}');
      debugPrint('[_BPModel] Input data: $input');

      // Tính tổng số phần tử cần thiết (ví dụ: [1,5] = 5 phần tử)
      int inputSize = inputTensor.shape.reduce((a, b) => a * b);

      // Tạo input buffer Float32 với đúng kích thước
      final inputBuffer = Float32List(inputSize);
      for (int i = 0; i < input.length && i < inputSize; i++) {
        inputBuffer[i] = input[i];
      }

      // Set input data vào tensor (convert Float32List -> Uint8List)
      inputTensor.data = inputBuffer.buffer.asUint8List();

      // Chạy inference
      interpreter.invoke();

      // Lấy output data từ tensor
      final outputData = outputTensor.data.buffer.asFloat32List();

      debugPrint('[_BPModel] Output data: $outputData');

      // Trả về [SYS, DIA]
      return [outputData[0].toDouble(), outputData[1].toDouble()];
    } catch (e, s) {
      debugPrint('[_BPModel] Lỗi predict: $e');
      debugPrint('[_BPModel] Stack: $s');
      rethrow; // Throw lại để caller biết có lỗi
    }
  }
}

class MeasureTabState extends State<MeasureTab> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  int _currentBpm = 0;
  int? _startTimestamp;
  bool _isFinishing = false;
  bool _bpReady = false;

  GoogleSignInAccount? get _user => GoogleAuthService.currentUser;

  final List<double> _ppgSignal = [];
  final int _maxSample = 150; // ~5s @30fps

  late HeartRateAnalyzer _analyzer;
  late _BPScaler _bpScaler;
  late _BPModel _bpModel;

  bool _isButtonStartMeasureEnabled = false;

  // Lưu kết quả dự đoán BP
  double? _lastSys;
  double? _lastDia;

  @override
  void initState() {
    super.initState();
    _bpScaler = _BPScaler();
    _bpModel = _BPModel();
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
      onResultCalculated: (AnalyzerResult result) => setState(() {
        _currentBpm = result.bpm.toInt();
      }),
    );
    _initBpHelpers();
  }

  Future<void> _initBpHelpers() async {
    await _bpScaler.load();
    await _bpModel.load();
    if (mounted) {
      setState(() => _bpReady = true);
    }
  }

  Future<void> _predictBloodPressure() async {
    if (!_bpReady) return;
    final info = await SaveInfoBloodPressure.getInfoBloodPressure();
    if (info == null) {
      print('Thiếu thông tin BP, bỏ qua dự đoán.');
      return;
    }
    final gender = info['gender'] as String? ?? 'Nam';
    final age = (info['age'] as int?)?.toDouble();
    final height = (info['height'] as int?)?.toDouble();
    final weight = (info['weight'] as int?)?.toDouble();
    if (age == null || height == null || weight == null) {
      debugPrint('BP info không đầy đủ.');
      return;
    }
    final input = [
      _encodeGender(gender),
      age,
      height,
      weight,
      _currentBpm.toDouble(),
    ];
    final scaled = _bpScaler.transformX(input);
    final predicted = _bpModel.predict(scaled);
    final real = _bpScaler.inverseY(predicted);
    if (mounted) {
      final sys = double.parse(real[0].toStringAsFixed(1));
      final dia = double.parse(real[1].toStringAsFixed(1));

      // Lưu kết quả vào state
      _lastSys = sys;
      _lastDia = dia;

      print('BP dự đoán: SYS=$sys DIA=$dia');
    }
  }

  double _encodeGender(String gender) {
    switch (gender) {
      case 'Nữ':
        return 1.0;
      case 'Nam':
        return 0.0;
      default:
        return 0.0;
    }
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

      _startTimestamp = DateTime.now().millisecondsSinceEpoch;

      _controller!.startImageStream((image) async {
        final bytes = image.planes[0].bytes;
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
        if (_startTimestamp != null &&
            timestamp - _startTimestamp! >= 15000 &&
            !_isFinishing) {
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

    try {
      debugPrint('[MeasureTab] Bắt đầu hoàn tất phép đo');
      PushHrBlynk.pushData(_currentBpm);
      debugPrint('[MeasureTab] Đã gửi dữ liệu Blynk');
      PushHrZaloBot.pushDataZalo(_currentBpm);
      debugPrint('[MeasureTab] Đã gửi dữ liệu Zalo Bot');
      await stopCamera();
      debugPrint('[MeasureTab] Đã tắt camera');

      // Dự đoán huyết áp TRƯỚC KHI lưu lên cloud
      await _predictBloodPressure();
      debugPrint('[MeasureTab] Đã dự đoán BP: SYS=$_lastSys, DIA=$_lastDia');

      if (_user != null) {
        await addHeartRateRecordToCloud(
          _user!.id,
          _currentBpm.toInt(),
          List<double>.from(_ppgSignal),
          _lastSys ?? 120.0,
          _lastDia ?? 80.0,
        );
        debugPrint('[MeasureTab] Đã lưu dữ liệu cloud');
      }


      if (!mounted) return;
      setState(() => _isButtonStartMeasureEnabled = false);
      debugPrint('[MeasureTab] Đã cập nhật UI trước khi điều hướng');

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => HistoryMeasureScreen(
            bpm: _currentBpm,
            ppgSignal: List<double>.from(_ppgSignal),
            timestamp: DateTime.now(),
            bp_sys: _lastSys ?? 120.0,
            bp_dia: _lastDia ?? 80.0,
          ),
        ),
      );
      debugPrint('[MeasureTab] Đã quay lại từ HistoryMeasureScreen');
    } catch (e, s) {
      debugPrint('Lỗi hoàn tất phép đo: $e');
      debugPrint('$s');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Có lỗi xảy ra khi hoàn tất phép đo.')),
        );
      }
    } finally {
      if (!mounted) return;
      setState(() {
        _currentBpm = 0;
        _startTimestamp = null;
        _isButtonStartMeasureEnabled = false;
        _isFinishing = false;
        _ppgSignal.clear();
        _lastSys = null;
        _lastDia = null;
      });
      debugPrint('[MeasureTab] Đã reset state sau phép đo');
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
          Center(
            child: Text(
              _isButtonStartMeasureEnabled
                  ? "ĐANG ĐO..."
                  : "ĐỀ TÀI KHÓA LUẬN TỐT NGHIỆP IUH (Nhật-Tâm)",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 22),
            ),
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
