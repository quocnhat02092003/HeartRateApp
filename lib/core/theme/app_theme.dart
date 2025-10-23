import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get dark => ThemeData.dark().copyWith(
    scaffoldBackgroundColor: Colors.white12,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        letterSpacing: .2,
        fontSize: 18,
      ),
    ),
    tabBarTheme: const TabBarThemeData(
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.grey,
    ),
  );
}
