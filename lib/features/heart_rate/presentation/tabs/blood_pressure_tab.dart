import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_heartrate/database/db/heart_rate_record.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../../../../firebase/auth/GoogleAuthService.dart';

class BloodPressureTab extends StatefulWidget {
  const BloodPressureTab({super.key});

  @override
  State<BloodPressureTab> createState() => _BloodPressureTabState();
}

//Chuan hoa du lieu dau vao va dau ra
class BPScaler {
  late List<double> xMean;
  late List<double> xScale;
  late List<double> yMean;
  late List<double> yScale;

  Future<void> load() async {
    final jsonStr =
    await rootBundle.loadString('assets/models/bp_scaler.json');
    final data = json.decode(jsonStr);

    xMean = List<double>.from(data['X_mean']);
    xScale = List<double>.from(data['X_scale']);
    yMean = List<double>.from(data['y_mean']);
    yScale = List<double>.from(data['y_scale']);
  }

  /// Scale input X
  List<double> transformX(List<double> input) {
    return List.generate(
      input.length,
          (i) => (input[i] - xMean[i]) / xScale[i],
    );
  }

  /// Chuyen output Y ve gia tri thuc te mmHg
  List<double> inverseY(List<double> output) {
    return List.generate(
      output.length,
          (i) => output[i] * yScale[i] + yMean[i],
    );
  }
}

class BPModel {
  late Interpreter interpreter;

  //load tflite model
  Future<void> load() async {
    interpreter = await Interpreter.fromAsset(
      'assets/models/bp_model.tflite',
    );
  }

  /// Predict huyet ap (SYS, DIA)
  List<double> predict(List<double> input) {
    final output = List.generate(1, (_) => List.filled(2, 0.0));

    // Chay du doan
    interpreter.run([input], output);

    return [
      output[0][0], // SYS
      output[0][1], // DIA
    ];
  }
}

class _BloodPressureTabState extends State<BloodPressureTab> {
  // Controller cho từng ô nhập liệu
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heartRateController = TextEditingController();

  // Cờ lỗi riêng cho từng ô nhập liệu
  bool _genderError = false;
  String _ageError = "";
  String _heightError = "";
  String _weightError = "";
  String _heartRateError = "";

  bool _isReady = false;

  late BPScaler scaler;
  late BPModel model;

  GoogleSignInAccount? _user;

  @override
  void initState() {
    super.initState();
    scaler = BPScaler();
    model = BPModel();
    _loadUser();

    _initModel();
  }

  Future<void> _loadUser() async {
    _user = GoogleAuthService.currentUser ?? await GoogleAuthService.signInSilently();
    if (mounted) setState(() {});
  }

  Future<void> _initModel() async {
    await scaler.load();
    await model.load();
    setState(() {
      _isReady = true;
    });
  }

  double encodeGender(String gender) {
    switch (gender) {
      case 'Nam':
        return 0.0;
      case 'Nữ':
        return 1.0;
      default:
        return 0.0; // fallback an toàn
    }
  }

  bool _validateGender(String value) {
    return value.trim().isNotEmpty;
  }

  String _validateAge(String value) {
    if (value.toString().isEmpty == true) return "Vui lòng nhập tuổi hợp lệ";
    final parsed = int.tryParse(value);
    if (parsed == null) return "Tuổi phải là số nguyên";
    if (parsed < 20 || parsed > 120) return "Tuổi phải từ 20 đến 120";
    return "";
  }

  String _validateHeight(String value) {
    if (value.toString().isEmpty == true) return "Vui lòng nhập chiều cao hợp lệ";
    final parsed = int.tryParse(value);
    if (parsed == null) return "Chiều cao phải là số nguyên";
    if (parsed < 140 || parsed > 200) return "Chiều cao phải từ 140 đến 200 cm";
    return "";
  }

  String _validateWeight(String value) {
    if (value.toString().isEmpty == true) return "Vui lòng nhập cân nặng hợp lệ";
    final parsed = int.tryParse(value);
    if (parsed == null) return "Cân nặng phải là số nguyên";
    if (parsed < 40 || parsed > 120) return "Cân nặng phải từ 40 đến 120 kg";
    return "";
  }

  String _validateHeartRate(String value) {
    if (value.toString().isEmpty == true) return "Vui lòng nhập nhịp tim hợp lệ";
    final parsed = int.tryParse(value);
    if (parsed == null) return "Nhịp tim phải là số nguyên";
    if (parsed < 40 || parsed > 180) return "Nhịp tim phải từ 40 đến 180 bpm";
    return "";
  }

  @override
  void dispose() {
    // Giải phóng controller khi widget bị huỷ
    _genderController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _heartRateController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_isReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Model đang tải, vui lòng chờ...')),
      );
      return;
    }

    final gender = _genderController.text;
    final age = _ageController.text;
    final height = _heightController.text;
    final weight = _weightController.text;
    final heartRate = _heartRateController.text;

    final genderValid = _validateGender(gender);
    final ageValid = _validateAge(age);
    final heightValid = _validateHeight(height);
    final weightValid = _validateWeight(weight);
    final heartRateValid = _validateHeartRate(heartRate);

    setState(() {
      _genderError = !genderValid;
      _ageError = ageValid;
      _heightError = heightValid;
      _weightError = weightValid;
      _heartRateError = heartRateValid;
    });

    if (!genderValid ||
        ageValid.isNotEmpty ||
        heightValid.isNotEmpty ||
        weightValid.isNotEmpty ||
        heartRateValid.isNotEmpty) {
      return;
    }

    // ===== RAW INPUT =====
    final rawInput = [
      encodeGender(gender),
      double.parse(age),
      double.parse(height),
      double.parse(weight),
      double.parse(heartRate),
    ];

    // ===== SCALE X =====
    final xScaled = scaler.transformX(rawInput);

    // ===== PREDICT =====
    final yScaled = model.predict(xScaled);

    // ===== INVERSE Y =====
    final yReal = scaler.inverseY(yScaled);

    final sys = yReal[0].toStringAsFixed(1);
    final dia = yReal[1].toStringAsFixed(1);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Kết quả huyết áp'),
        content: Text(
          '🫀 Huyết áp dự đoán:\n\n'
              'SYS (Tâm thu): $sys mmHg\n'
              'DIA (Tâm trương): $dia mmHg',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(color: Colors.white70);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            const Text(
              'Nhập thông tin sức khoẻ',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Ô nhập giới tính (Nam/Nữ/Khác) bằng dropdown
            DropdownButtonFormField<String>(
              initialValue: _genderController.text.isNotEmpty
                  ? _genderController.text
                  : null,
              dropdownColor: const Color(0xFF121212),
              style: textStyle,
              decoration: InputDecoration(
                labelText: 'Giới tính',
                errorText:
                    _genderError ? 'Vui lòng chọn giới tính hợp lệ' : null,
                labelStyle: textStyle,
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white38),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyanAccent),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Nam',
                  child: Text('Nam'),
                ),
                DropdownMenuItem(
                  value: 'Nữ',
                  child: Text('Nữ'),
                ),
                DropdownMenuItem(
                  value: 'Khác',
                  child: Text('Khác'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _genderController.text = value;
                    _genderError = false; // clear lỗi khi user chọn lại
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Ô nhập tuổi (số nguyên, năm)
            TextField(
              controller: _ageController,
              style: textStyle,
              cursorColor: Colors.white70,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Tuổi',
                errorText: _ageError == "" ? null : _ageError,
                hintText: 'Ví dụ: 25',
                labelStyle: textStyle,
                hintStyle: const TextStyle(color: Colors.white38),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white38),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyanAccent),
                ),
              ),
              onChanged: (_) {
                if (_ageError != "") {
                  setState(() => _ageError = "");
                }
              },
            ),
            const SizedBox(height: 16),

            // Ô nhập chiều cao (đơn vị cm)
            TextField(
              controller: _heightController,
              style: textStyle,
              cursorColor: Colors.white70,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Chiều cao (cm)',
                errorText:
                    _heightError != "" ? _heightError : null,
                hintText: 'Ví dụ: 170',
                labelStyle: textStyle,
                hintStyle: const TextStyle(color: Colors.white38),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white38),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyanAccent),
                ),
              ),
              onChanged: (_) {
                if (_heightError != "") {
                  setState(() => _heightError = "");
                }
              },
            ),
            const SizedBox(height: 16),

            // Ô nhập cân nặng (đơn vị kg)
            TextField(
              controller: _weightController,
              style: textStyle,
              cursorColor: Colors.white70,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Cân nặng (kg)',
                errorText:
                    _weightError != "" ? _weightError : null,
                hintText: 'Ví dụ: 65',
                labelStyle: textStyle,
                hintStyle: const TextStyle(color: Colors.white38),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white38),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyanAccent),
                ),
              ),
              onChanged: (_) {
                if (_weightError != "") {
                  setState(() => _weightError = "");
                }
              },
            ),
            const SizedBox(height: 16),

            // Ô nhập nhịp tim hiện tại (bpm)
            TextField(
              controller: _heartRateController,
              style: textStyle,
              cursorColor: Colors.white70,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Nhịp tim (bpm)',
                errorText:
                    _heartRateError != "" ? _heartRateError : null,
                hintText: 'Ví dụ: 72',
                labelStyle: textStyle,
                hintStyle: const TextStyle(color: Colors.white38),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white38),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyanAccent),
                ),
                // Nút hành động nằm ngay trong ô input: lấy nhịp tim gần nhất
                suffixIcon: _user != null
                    ? TextButton(
                  onPressed: () async {
                    final bpm = await getLastBpmOnce(_user!.id);

                    if (bpm != null) {
                      setState(() {
                        _heartRateController.text = bpm.toString();
                        _heartRateError = "";
                      });
                    } else {
                      setState(() {
                        _heartRateError = "Không có dữ liệu nhịp tim";
                      });
                    }
                  },
                  child: const Text(
                    'Lấy nhịp tim gần nhất',
                    style: TextStyle(color: Colors.cyanAccent, fontSize: 12),
                  ),
                )
                    : null,
              ),
              onChanged: (_) {
                if (_heartRateError != "") {
                  setState(() => _heartRateError = "");
                }
              },
            ),
            const SizedBox(height: 24),

            // Nút lưu / xác nhận thông tin đã nhập
            ElevatedButton(
              onPressed: _onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              child: const Text('Lưu thông tin và đo huyết áp'),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              child: const Text('Không lưu thông tin và đo huyết áp'),
            ),
          ],
        ),
      ),
    );
  }
}
