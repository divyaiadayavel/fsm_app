import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'jobs_screen.dart';
import 'create_job_screen.dart';
import 'technicians_screen.dart';

import '../widgets/custom_bottom_nav.dart';
import '../../core/constants/app_colors.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;
  int refreshKey = 0;

  void changeTab(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  void refreshApp() {
    setState(() {
      refreshKey++;
    });
  }

  Future<void> openCreateJob() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreateJobScreen(onSaved: refreshApp)),
    );

    refreshApp();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      AdminDashboard(key: ValueKey("dash$refreshKey")),
      JobsScreen(key: ValueKey("jobs$refreshKey")),
      TechniciansScreen(key: ValueKey("tech$refreshKey")),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,

      body: IndexedStack(index: currentIndex, children: screens),

      bottomNavigationBar: CustomBottomNav(
        currentIndex: currentIndex,
        onTap: changeTab,
        onAddTap: openCreateJob,
      ),
    );
  }
}
