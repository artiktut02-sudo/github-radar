import 'package:flutter/material.dart';
import 'screens/trending_screen.dart';

void main() {
  runApp(const GitHubRadarApp());
}

class GitHubRadarApp extends StatelessWidget {
  const GitHubRadarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GitHub Radar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D1117), // Цвет GitHub Dark
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF161B22),
          elevation: 0,
        ),
      ),
      home: const TrendingScreen(),
    );
  }
}
