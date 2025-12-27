import 'package:shared_preferences/shared_preferences.dart';

class SaveInfoBloodPressure {
  static const _ageKey = 'age';
  static const _heightKey = 'height';
  static const _weightKey = 'weight';
  static const _genderKey = 'gender';
  static const _timestampKey = 'timestamp';

  static Future<void> saveInfoBloodPressure({
    required int age,
    required String gender,
    required int height,
    required int weight,
    required DateTime timestamp,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_ageKey, age);
    await prefs.setString(_genderKey, gender);
    await prefs.setInt(_heightKey, height);
    await prefs.setInt(_weightKey, weight);
    await prefs.setString(_timestampKey, timestamp.toIso8601String());
  }

  static Future<bool> hasInfoBloodPressure() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_ageKey);
  }

  static Future<Map<String, dynamic>?> getInfoBloodPressure() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_ageKey)) return null;

    return {
      'age': prefs.getInt(_ageKey),
      'gender': prefs.getString(_genderKey),
      'height': prefs.getInt(_heightKey),
      'weight': prefs.getInt(_weightKey),
      'timestamp': DateTime.parse(prefs.getString(_timestampKey)!),
    };
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
