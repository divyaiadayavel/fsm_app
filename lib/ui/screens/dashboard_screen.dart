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

  @override
  void initState() {
    super.initState();
    loadJobs();
  }

  Future<void> loadJobs() async {
    final data = await DatabaseHelper.instance.getJobs();

    if (!mounted) return;

    setState(() {
      jobs = data;

      total = jobs.length;
      pending = jobs.where((e) => e["status"] == "Pending").length;
      progress = jobs.where((e) => e["status"] == "In Progress").length;
      completed = jobs.where((e) => e["status"] == "Completed").length;
      cancelled = jobs.where((e) => e["status"] == "Cancelled").length;
    });
  }

  List<double> getChartValues() {
    return [
      pending.toDouble(),
      progress.toDouble(),
      completed.toDouble(),
      cancelled.toDouble(),
    ];
  }

  Future<void> logout() async {
    if (!mounted) return;

    final bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: Text("Logout", style: TextStyle(color: AppColors.textPrimary)),
          content: Text(
            "Are you sure you want to logout?",
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                "Cancel",
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Yes", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
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
        backgroundColor: AppColors.card,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        title: Text(
          "Admin Dashboard",
          style: TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: loadJobs,
          ),
          IconButton(
            icon: Icon(Icons.logout, color: AppColors.textPrimary),
            onPressed: logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: loadJobs,
        child: SafeArea(
          child: Padding(
            padding: AppUI.screen,
            child: ListView(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.menu,
                      color: AppColors.textPrimary,
                      size: AppUI.title,
                    ),
                    const SizedBox(width: AppUI.gapSm),
                    Text(
                      "Command Center",
                      style: TextStyle(
                        fontSize: AppUI.title,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      height: AppUI.avatarSize,
                      width: AppUI.avatarSize,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(AppUI.radiusSm),
                      ),
                      child: Icon(Icons.person, color: AppColors.textPrimary),
                    ),
                  ],
                ),

                const SizedBox(height: AppUI.gapLg),

                Text(
                  "OPERATIONAL OVERVIEW",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    letterSpacing: 2,
                    fontSize: AppUI.caption,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: AppUI.gapXs),

                Text(
                  "Systems Active",
                  style: TextStyle(
                    fontSize: AppUI.heading,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
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
                      color: AppColors.orange,
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
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(AppUI.radiusLg),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Job Status Distribution",
                        style: TextStyle(
                          fontSize: AppUI.subTitle,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppUI.gapMd),

                      Expanded(
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: values.every((e) => e == 0)
                                ? 5
                                : values.reduce((a, b) => a > b ? a : b) + 2,
                            borderData: FlBorderData(show: false),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: AppColors.border,
                                  strokeWidth: 1,
                                );
                              },
                            ),
                            titlesData: FlTitlesData(
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            barGroups: [
                              barItem(0, values[0], AppColors.orange),
                              barItem(1, values[1], AppColors.blue),
                              barItem(2, values[2], AppColors.green),
                              barItem(3, values[3], AppColors.error),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppUI.gapLg),

                Text(
                  "Recent Jobs",
                  style: TextStyle(
                    fontSize: AppUI.title,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: AppUI.gapSm),

                if (jobs.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(AppUI.radiusMd),
                    ),
                    child: Center(
                      child: Text(
                        "No jobs created yet",
                        style: TextStyle(color: AppColors.textSecondary),
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
