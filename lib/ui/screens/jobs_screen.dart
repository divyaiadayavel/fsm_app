// jobs_screen.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_ui.dart';
import '../../data/services/api_service.dart';
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

  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadJobs();
    searchController.addListener(applyFilters);
  }

  @override
  void dispose() {
    searchController.removeListener(applyFilters);
    searchController.dispose();
    super.dispose();
  }

  // ==============================
  // LOAD JOBS (API)
  // ==============================
  Future<void> loadJobs() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    final response = await ApiService.getJobs();

    if (response['status'] == true) {
      allJobs = List<Map<String, dynamic>>.from(response['data'] ?? []);
    } else {
      error = response['message'] ?? "Failed to load jobs";
    }

    applyFilters();

    setState(() {
      isLoading = false;
    });
  }

  // ==============================
  // FILTER
  // ==============================
  void applyFilters() {
    final query = searchController.text.toLowerCase().trim();

    filteredJobs = allJobs.where((job) {
      final title = (job["title"] ?? "").toString().toLowerCase();
      final customer = (job["customer"] ?? "").toString().toLowerCase();
      final location = (job["location"] ?? "").toString().toLowerCase();

      return title.contains(query) ||
          customer.contains(query) ||
          location.contains(query);
    }).toList();

    if (mounted) setState(() {});
  }

  // ==============================
  // PRIORITY COLOR
  // ==============================
  Color getSideColor(String? priority) {
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
    final size = MediaQuery.of(context).size;
    final scale = (size.width / 400).clamp(0.85, 1.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppUI.screen.left * scale),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  Icon(
                    Icons.work_outline,
                    color: AppColors.textPrimary,
                    size: AppUI.subTitle * scale,
                  ),
                  SizedBox(width: AppUI.gapSm * scale),
                  Text(
                    "Jobs",
                    style: TextStyle(
                      fontSize: AppUI.title * scale,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppUI.gapMd * scale),

              // SEARCH
              Container(
                height: (AppUI.inputHeight * scale).clamp(40.0, 52.0),
                padding: EdgeInsets.symmetric(horizontal: 12 * scale),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppUI.radiusMd * scale),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: searchController,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13 * scale,
                  ),
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                      size: 18 * scale,
                    ),
                    hintText: "Search jobs...",
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13 * scale,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),

              SizedBox(height: AppUI.gapMd * scale),

              // BODY
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: loadJobs,
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : error != null
                      ? ListView(
                          children: [
                            SizedBox(height: 150 * scale),
                            Center(
                              child: Text(
                                error!,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: AppUI.body * scale,
                                ),
                              ),
                            ),
                          ],
                        )
                      : filteredJobs.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(height: 150 * scale),
                            Center(
                              child: Text(
                                "No jobs found",
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: AppUI.body * scale,
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          itemCount: filteredJobs.length,
                          itemBuilder: (context, index) {
                            final job = filteredJobs[index];

                            return JobCard(
                              title: job["title"] ?? "",
                              company: job["customer"] ?? "",
                              location: job["location"] ?? "",
                              technician: job["technician"] ?? "",
                              priority: job["priority"] ?? "",
                              status: job["status"] ?? "",
                              sideColor: getSideColor(job["priority"]),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
