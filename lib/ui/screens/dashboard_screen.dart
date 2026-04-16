import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_ui.dart';
import '../../data/db/database_helper.dart';
import '../widgets/stat_card.dart';
import '../widgets/recent_job_tile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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

  @override
  Widget build(BuildContext context) {
    final values = getChartValues();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: AppUI.screen,
          child: ListView(
            children: [
              Row(
                children: [
                  Icon(Icons.menu, color: Colors.white, size: AppUI.title),
                  const SizedBox(width: AppUI.gapSm),
                  Text(
                    "Command Center",
                    style: TextStyle(
                      fontSize: AppUI.title,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: AppUI.avatarSize,
                    width: AppUI.avatarSize,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(AppUI.radiusSm),
                    ),
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                ],
              ),

              const SizedBox(height: AppUI.gapLg),

              Text(
                "OPERATIONAL OVERVIEW",
                style: TextStyle(
                  color: Colors.white54,
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
                  color: Colors.white,
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Job Status Distribution",
                            style: TextStyle(
                              fontSize: AppUI.subTitle,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        popupFilter(filter, (value) {
                          setState(() {
                            filter = value;
                          });
                        }),
                      ],
                    ),

                    const SizedBox(height: AppUI.gapMd),

                    Expanded(
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: values.isEmpty
                              ? 5
                              : values.reduce((a, b) => a > b ? a : b) + 2,
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 1,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.white10,
                                strokeWidth: 1,
                              );
                            },
                          ),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: TextStyle(
                                      color: Colors.white38,
                                      fontSize: AppUI.caption,
                                    ),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const labels = [
                                    "PEND",
                                    "PROG",
                                    "COMP",
                                    "CANC",
                                  ];

                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      labels[value.toInt()],
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: AppUI.caption,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                              ),
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
                  Text(
                    "Recent Jobs",
                    style: TextStyle(
                      fontSize: AppUI.title,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "View All",
                      style: TextStyle(
                        color: Colors.white70,
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
                  child: Center(
                    child: Text(
                      "No jobs created yet",
                      style: TextStyle(
                        color: Colors.white54,
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

  Widget popupFilter(String current, Function(String) onSelect) {
    return PopupMenuButton<String>(
      color: AppColors.background,
      onSelected: onSelect,
      itemBuilder: (_) => const [
        PopupMenuItem(value: "Today", child: Text("Today")),
        PopupMenuItem(value: "Weekly", child: Text("Weekly")),
        PopupMenuItem(value: "Monthly", child: Text("Monthly")),
        PopupMenuItem(value: "Yearly", child: Text("Yearly")),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(AppUI.radiusSm),
        ),
        child: Text(
          current.toUpperCase(),
          style: TextStyle(
            color: Colors.white70,
            fontSize: AppUI.caption,
            fontWeight: FontWeight.bold,
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
