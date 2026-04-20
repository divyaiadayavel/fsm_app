import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_ui.dart';
import '../../data/db/database_helper.dart';
import '../widgets/stat_card.dart';
import '../widgets/recent_job_tile.dart';
import 'package:fsm_app/views/auth/login_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<Map<String, dynamic>> jobs = [];

  int total = 0;
  int pending = 0;
  int progress = 0;
  int completed = 0;
  int cancelled = 0;

  String filter = "Weekly";

  @override
  void initState() {
    super.initState();
    loadJobs();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadJobs();
  }

  Future<void> loadJobs() async {
    jobs = await DatabaseHelper.instance.getJobs();

    total = jobs.length;
    pending = jobs.where((e) => e["status"] == "Pending").length;
    progress = jobs.where((e) => e["status"] == "In Progress").length;
    completed = jobs.where((e) => e["status"] == "Completed").length;
    cancelled = jobs.where((e) => e["status"] == "Cancelled").length;

    setState(() {});
  }

  List<double> getChartValues() {
    return [
      pending.toDouble(),
      progress.toDouble(),
      completed.toDouble(),
      cancelled.toDouble(),
    ];
  }

  // ===============================
  // FIXED LOGOUT (SAFE NAVIGATION)
  // ===============================
  Future<void> logout() async {
    if (!mounted) return;

    final bool? confirmLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final values = getChartValues();

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: logout),
        ],
      ),

      body: SafeArea(
        child: Padding(
          padding: AppUI.screen,
          child: ListView(
            children: [
              Row(
                children: [
                  Icon(Icons.menu, color: Colors.black, size: AppUI.title),
                  const SizedBox(width: AppUI.gapSm),
                  const Text(
                    "Command Center",
                    style: TextStyle(
                      fontSize: AppUI.title,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: AppUI.avatarSize,
                    width: AppUI.avatarSize,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppUI.radiusSm),
                    ),
                    child: const Icon(Icons.person, color: Colors.black),
                  ),
                ],
              ),

              const SizedBox(height: AppUI.gapLg),

              const Text(
                "OPERATIONAL OVERVIEW",
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  letterSpacing: 2,
                  fontSize: AppUI.caption,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: AppUI.gapXs),

              const Text(
                "Systems Active",
                style: TextStyle(
                  fontSize: AppUI.heading,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: AppUI.gapLg),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.18,
                crossAxisSpacing: AppUI.gapSm,
                mainAxisSpacing: AppUI.gapSm,
                children: [
                  StatCard(
                    icon: Icons.bar_chart_rounded,
                    label: "TOTAL JOBS",
                    count: total,
                    color: AppColors.primary,
                  ),
                  StatCard(
                    icon: Icons.pending_actions_rounded,
                    label: "PENDING",
                    count: pending,
                    color: AppColors.pink,
                  ),
                  StatCard(
                    icon: Icons.pie_chart_outline_rounded,
                    label: "IN PROGRESS",
                    count: progress,
                    color: AppColors.blue,
                  ),
                  StatCard(
                    icon: Icons.check_circle_outline,
                    label: "COMPLETED",
                    count: completed,
                    color: AppColors.green,
                  ),
                ],
              ),

              const SizedBox(height: AppUI.gapLg),

              Container(
                height: AppUI.chartHeight,
                padding: AppUI.card,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppUI.radiusLg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Job Status Distribution",
                      style: TextStyle(
                        fontSize: AppUI.subTitle,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: AppUI.gapMd),

                    Expanded(
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: (values.isEmpty || values.every((e) => e == 0))
                              ? 5
                              : values.reduce((a, b) => a > b ? a : b) + 2,
                          gridData: FlGridData(show: true),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          barGroups: [
                            barItem(0, values[0], Colors.orange),
                            barItem(1, values[1], Colors.blue),
                            barItem(2, values[2], Colors.green),
                            barItem(3, values[3], Colors.red),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppUI.gapLg),

              Row(
                children: [
                  const Text(
                    "Recent Jobs",
                    style: TextStyle(
                      fontSize: AppUI.title,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "View All",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: AppUI.body,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppUI.gapSm),

              if (jobs.isEmpty)
                Container(
                  padding: AppUI.card,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(AppUI.radiusMd),
                  ),
                  child: const Center(
                    child: Text(
                      "No jobs created yet",
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: AppUI.body,
                      ),
                    ),
                  ),
                ),

              ...jobs
                  .take(5)
                  .map(
                    (job) => RecentJobTile(
                      title: job["title"],
                      location: job["location"],
                      status: job["status"],
                      time: job["customer"],
                      icon: Icons.build_circle_outlined,
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  BarChartGroupData barItem(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 22,
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    );
  }
}
