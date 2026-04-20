import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_ui.dart';
import '../../data/db/database_helper.dart';
import '../widgets/job_card.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  List<Map<String, dynamic>> allJobs = [];
  List<Map<String, dynamic>> filteredJobs = [];

  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadJobs();
    searchController.addListener(applyFilters);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadJobs() async {
    allJobs = await DatabaseHelper.instance.getJobs();
    applyFilters();
  }

  void applyFilters() {
    final query = searchController.text.toLowerCase().trim();

    filteredJobs = allJobs.where((job) {
      return job["title"].toLowerCase().contains(query) ||
          job["customer"].toLowerCase().contains(query) ||
          job["location"].toLowerCase().contains(query);
    }).toList();

    setState(() {});
  }

  Color getSideColor(String priority) {
    switch (priority) {
      case "High":
        return AppColors.error;
      case "Medium":
        return AppColors.blue;
      default:
        return AppColors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: AppUI.screen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.work_outline,
                    color: AppColors.textPrimary,
                    size: AppUI.subTitle,
                  ),
                  const SizedBox(width: AppUI.gapSm),
                  Text(
                    "Jobs",
                    style: TextStyle(
                      fontSize: AppUI.title,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppUI.gapMd),

              Container(
                height: AppUI.inputHeight,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppUI.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: searchController,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    icon: Icon(Icons.search, color: AppColors.textSecondary),
                    hintText: "Search jobs...",
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: AppUI.gapMd),

              Expanded(
                child: filteredJobs.isEmpty
                    ? Center(
                        child: Text(
                          "No jobs found",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: AppUI.body,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredJobs.length,
                        itemBuilder: (context, index) {
                          final job = filteredJobs[index];

                          return JobCard(
                            title: job["title"],
                            company: job["customer"],
                            location: job["location"],
                            technician: job["technician"],
                            priority: job["priority"],
                            status: job["status"],
                            sideColor: getSideColor(job["priority"]),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
