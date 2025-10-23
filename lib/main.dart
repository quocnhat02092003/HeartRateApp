import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heartrate/features/heart_rate/presentation/tabs/history_mesure_tab.dart';
import 'package:flutter_heartrate/firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'features/heart_rate/presentation/screens/heart_rate_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(HeartRateApp());
}

class HeartRateApp extends StatelessWidget {
  const HeartRateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Heart Rate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark, // tách theme riêng
      home: const HeartRateScreen(),
      routes: {
        '/history_measure_tab': (context) => const HistoryMeasureTab(),
      },
    );
  }
}
