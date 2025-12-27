import 'package:flutter/material.dart';
import 'package:flutter_heartrate/features/heart_rate/presentation/screens/blood_pressure_screen.dart';
import '../screens/heart_rate_screen.dart';
import '../../../../database/db/save_info_blood_pressure.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserInfo();
  }

  Future<void> _checkUserInfo() async {
    final hasInfo = await SaveInfoBloodPressure.hasInfoBloodPressure();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
        hasInfo ? const HeartRateScreen() : const BloodPressureScreen(mode: BloodPressureMode.create,),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
