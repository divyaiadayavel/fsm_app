import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'ui/screens/main_navigation.dart';

void main() {
  runApp(const FSMApp());
}

class FSMApp extends StatelessWidget {
  const FSMApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FSM App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const MainNavigation(),
    );
  }
}
