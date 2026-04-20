import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'package:fsm_app/views/auth/login_screen.dart';

void main() {
  runApp(const ProviderScope(child: FSMApp()));
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

      // IMPORTANT: Start with LoginScreen, not MainNavigation
      home: const LoginScreen(),
    );
  }
}
