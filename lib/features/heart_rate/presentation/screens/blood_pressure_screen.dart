import 'package:flutter/material.dart';
import 'package:flutter_heartrate/database/db/save_info_blood_pressure.dart';
import 'package:flutter_heartrate/features/heart_rate/presentation/screens/heart_rate_screen.dart';

class BloodPressureScreen extends StatefulWidget {
  final BloodPressureMode mode;
  const BloodPressureScreen({super.key, required this.mode});

  @override
  State<BloodPressureScreen> createState() => _BloodPressureTabState();
}

class _BloodPressureTabState extends State<BloodPressureScreen> {
  // Biến lưu trữ thông tin người dùng
  String gender = '';
  int age = 0;
  int height = 0;
  int weight = 0;

  // Controller cho từng ô nhập liệu
  late final TextEditingController _genderController = TextEditingController();
  late final TextEditingController _ageController = TextEditingController();
  late final TextEditingController _heightController = TextEditingController();
  late final TextEditingController _weightController = TextEditingController();

  // Cờ lỗi riêng cho từng ô nhập liệu
  bool _genderError = false;
  String _ageError = "";
  String _heightError = "";
  String _weightError = "";

  @override
  void initState() {
    super.initState();
    if (widget.mode == BloodPressureMode.edit) {
      _loadOldData();
    }
  }

  Future<void> _loadOldData() async {
    final info = await SaveInfoBloodPressure.getInfoBloodPressure();
    if (info == null) return;

    setState(() {
      _ageController.text = info['age'].toString();
      _heightController.text = info['height'].toString();
      _weightController.text = info['weight'].toString();
      _genderController.text = info['gender'].toString();
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
    if (value.toString().isEmpty == true)
      return "Vui lòng nhập chiều cao hợp lệ";
    final parsed = int.tryParse(value);
    if (parsed == null) return "Chiều cao phải là số nguyên";
    if (parsed < 140 || parsed > 200) return "Chiều cao phải từ 140 đến 200 cm";
    return "";
  }

  String _validateWeight(String value) {
    if (value.toString().isEmpty == true)
      return "Vui lòng nhập cân nặng hợp lệ";
    final parsed = int.tryParse(value);
    if (parsed == null) return "Cân nặng phải là số nguyên";
    if (parsed < 40 || parsed > 120) return "Cân nặng phải từ 40 đến 120 kg";
    return "";
  }

  @override
  void dispose() {
    // Giải phóng controller khi widget bị huỷ
    _genderController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _onSubmit() async {
    final gender = _genderController.text;
    final age = _ageController.text;
    final height = _heightController.text;
    final weight = _weightController.text;

    final genderValid = _validateGender(gender);
    final ageValid = _validateAge(age);
    final heightValid = _validateHeight(height);
    final weightValid = _validateWeight(weight);

    setState(() {
      _genderError = !genderValid;
      _ageError = ageValid;
      _heightError = heightValid;
      _weightError = weightValid;
    });

    if (!genderValid ||
        ageValid.isNotEmpty ||
        heightValid.isNotEmpty ||
        weightValid.isNotEmpty) {
      return;
    }

    await SaveInfoBloodPressure.saveInfoBloodPressure(
      age: int.parse(age),
      gender: gender,
      height: int.parse(height),
      weight: int.parse(weight),
      timestamp: DateTime.now(),
    );

    if (widget.mode == BloodPressureMode.edit) {
      Navigator.pop(context);
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HeartRateScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(color: Colors.white70);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.mode == BloodPressureMode.create
              ? "Thông tin sức khỏe"
              : "Chỉnh sửa thông tin sức khỏe",
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ô nhập giới tính (Nam/Nữ/Khác) bằng dropdown
              DropdownButtonFormField<String>(
                initialValue: _genderController.text.isNotEmpty
                    ? _genderController.text
                    : null,
                dropdownColor: const Color(0xFF121212),
                style: textStyle,
                decoration: InputDecoration(
                  labelText: 'Giới tính *',
                  errorText: _genderError
                      ? 'Vui lòng chọn giới tính hợp lệ'
                      : null,
                  labelStyle: textStyle,
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white38),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.cyanAccent),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'Nam', child: Text('Nam')),
                  DropdownMenuItem(value: 'Nữ', child: Text('Nữ')),
                  DropdownMenuItem(value: 'Khác', child: Text('Khác')),
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
                  labelText: 'Tuổi *',
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
                  labelText: 'Chiều cao (cm) *',
                  errorText: _heightError != "" ? _heightError : null,
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
                  labelText: 'Cân nặng (kg) *',
                  errorText: _weightError != "" ? _weightError : null,
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
              const SizedBox(height: 24),
              Text(
                "Để kết quả tính toán của chúng tôi chuẩn xác nhất, vui lòng cung cấp thông tin một cách thực tế và rõ ràng.",
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
              const SizedBox(height: 10),
              // Nút lưu / xác nhận thông tin đã nhập
              ElevatedButton(
                onPressed: _onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                child: Text(widget.mode == BloodPressureMode.create ? 'Lưu thông tin' : 'Cập nhật thông tin'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum BloodPressureMode { create, edit }
