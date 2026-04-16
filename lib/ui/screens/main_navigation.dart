import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'jobs_screen.dart';
import 'create_job_screen.dart';
import 'technicians_screen.dart';
import '../widgets/custom_bottom_nav.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;
  int refreshKey = 0;

  // ===============================
  // CHANGE TAB
  // ===============================
  void changeTab(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  // ===============================
  // REFRESH ALL SCREENS
  // ===============================
  void refreshApp() {
    setState(() {
      refreshKey++;
    });
  }

  // ===============================
  // OPEN CREATE JOB SCREEN
  // ===============================
  Future<void> openCreateJob() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreateJobScreen(onSaved: refreshApp)),
    );

    refreshApp();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(key: ValueKey("dash$refreshKey")),
      JobsScreen(key: ValueKey("jobs$refreshKey")),
      TechniciansScreen(key: ValueKey("tech$refreshKey")),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),

      // Keeps screen state alive
      body: IndexedStack(index: currentIndex, children: screens),

      // Bottom Navbar
      bottomNavigationBar: CustomBottomNav(
        currentIndex: currentIndex,
        onTap: changeTab,
        onAddTap: openCreateJob,
      ),
    );
  }
}
