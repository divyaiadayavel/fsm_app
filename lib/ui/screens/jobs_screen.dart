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
  String selectedStatus = "All";

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
      final matchesSearch =
          job["title"].toLowerCase().contains(query) ||
          job["customer"].toLowerCase().contains(query) ||
          job["location"].toLowerCase().contains(query);

      final matchesStatus =
          selectedStatus == "All" || job["status"] == selectedStatus;

      return matchesSearch && matchesStatus;
    }).toList();

    setState(() {});
  }

  Color getSideColor(String priority) {
    switch (priority) {
      case "High":
        return Colors.redAccent;
      case "Medium":
        return Colors.blueAccent;
      default:
        return Colors.grey;
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
                children: const [
                  Icon(
                    Icons.work_outline,
                    color: Colors.black,
                    size: AppUI.subTitle,
                  ),
                  SizedBox(width: AppUI.gapSm),
                  Text(
                    "Jobs",
                    style: TextStyle(
                      fontSize: AppUI.title,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppUI.gapMd),

              Container(
                height: AppUI.inputHeight,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppUI.radiusMd),
                ),
                child: TextField(
                  controller: searchController,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: AppUI.body,
                  ),
                  decoration: const InputDecoration(
                    icon: Icon(Icons.search, color: Colors.black54),
                    hintText: "Search jobs...",
                    hintStyle: TextStyle(
                      color: Colors.black45,
                      fontSize: AppUI.body,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: AppUI.gapSm),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    statusChip("All"),
                    statusChip("Pending"),
                    statusChip("In Progress"),
                    statusChip("Completed"),
                    statusChip("Cancelled"),
                  ],
                ),
              ),

              const SizedBox(height: AppUI.gapMd),

              Expanded(
                child: filteredJobs.isEmpty
                    ? const Center(
                        child: Text(
                          "No jobs found",
                          style: TextStyle(
                            color: Colors.black54,
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

  Widget statusChip(String title) {
    final active = selectedStatus == title;

    return Padding(
      padding: const EdgeInsets.only(right: AppUI.gapXs),
      child: GestureDetector(
        onTap: () {
          selectedStatus = title;
          applyFilters();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(AppUI.radiusLg),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: active ? Colors.white : Colors.black,
              fontSize: AppUI.caption,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
