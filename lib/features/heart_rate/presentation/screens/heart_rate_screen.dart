import 'package:flutter/material.dart';
import 'package:flutter_heartrate/features/heart_rate/presentation/screens/ai_assistant_screen.dart';
import 'package:flutter_heartrate/features/heart_rate/presentation/tabs/blood_pressure_tab.dart';
import 'package:flutter_heartrate/features/heart_rate/presentation/tabs/history_mesure_tab.dart';
import 'package:flutter_heartrate/features/heart_rate/presentation/tabs/more_tab.dart';
import '../../../../core/constants/app_strings.dart';
import '../tabs/help_tab.dart';
import '../tabs/measure_tab.dart';

class HeartRateScreen extends StatefulWidget {
  const HeartRateScreen({super.key});

  @override
  State<HeartRateScreen> createState() => _HeartRateScreenState();
}

class _HeartRateScreenState extends State<HeartRateScreen>
    with SingleTickerProviderStateMixin {
  int currentPageIndex = 2;
  NavigationDestinationLabelBehavior labelBehavior =
      NavigationDestinationLabelBehavior.onlyShowSelected;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentPageIndex == 0
              ? AppStrings.help
              : currentPageIndex == 1
              ? AppStrings.bloodPressureTitle
              : currentPageIndex == 2
              ? AppStrings.appTitle
              : currentPageIndex == 3
              ? AppStrings.history
              : AppStrings.setting,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.redAccent,
      ),
      bottomNavigationBar: NavigationBar(
        animationDuration: Duration(milliseconds: 1000),
        backgroundColor: Color.fromRGBO(26, 46, 40, 0.288),
        height: 70,
        labelBehavior: labelBehavior,
        selectedIndex: currentPageIndex,
        onDestinationSelected: (int index) => {
          setState(() {
            currentPageIndex = index;
          }),
        },
        destinations: <Widget>[
          NavigationDestination(
            icon: Icon(Icons.help_outline),
            selectedIcon: Icon(Icons.help),
            label: 'Trợ giúp',
          ),
          NavigationDestination(
            icon: Icon(Icons.noise_aware_outlined),
            selectedIcon: Icon(Icons.noise_aware),
            label: 'Huyết áp',
          ),
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Trang chủ',
            selectedIcon: Icon(Icons.home),
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Lịch sử',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_suggest_outlined),
            selectedIcon: Icon(Icons.settings_suggest),
            label: 'Cài đặt',
          ),
        ],
      ),
      body: <Widget>[
        HelpTab(),
        BloodPressureTab(),
        MeasureTab(),
        HistoryMeasureTab(),
        MoreTab(
          goToHistoryMeasureTab: () {
            setState(() {
              currentPageIndex = 3;
            });
          },
        ),
      ][currentPageIndex],
      floatingActionButton: currentPageIndex == 2
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => AiAssistantScreen()));
              },
              enableFeedback: true,
              child: Icon(Icons.auto_awesome),
            )
          : null,
    );
  }
}
