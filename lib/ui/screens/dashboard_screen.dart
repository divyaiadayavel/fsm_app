import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_ui.dart';
import '../../data/services/api_service.dart';
import 'update_job_screen.dart';
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

  String userName = "Admin";
  String imagePath = "";

  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadJobs();
    loadProfile();
  }

  // ============================
  // LOAD JOBS (API SAFE)
  // ============================
  Future<void> loadJobs() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await ApiService.getJobs();

      if (response['status'] != true) {
        throw Exception(response['message'] ?? "Failed to load jobs");
      }

      final data = List<Map<String, dynamic>>.from(response['data']);

      setState(() {
        jobs = data;

        total = jobs.length;
        pending = jobs.where((e) => e["status"] == "Pending").length;
        progress = jobs.where((e) => e["status"] == "In Progress").length;
        completed = jobs.where((e) => e["status"] == "Completed").length;
        cancelled = jobs.where((e) => e["status"] == "Cancelled").length;
      });
    } catch (e) {
      error = e.toString();
    }

    setState(() => isLoading = false);
  }

  // ============================
  // DELETE JOB WITH CONFIRM
  // ============================
  Future<void> deleteJob(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Job"),
        content: const Text("Are you sure you want to delete this job?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final response = await ApiService.deleteJob(id);

    if (response['status'] == true) {
      loadJobs();
    } else {
      showMsg(response['message'] ?? "Delete failed");
    }
  }

  // ============================
  // PROFILE
  // ============================
  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      userName = prefs.getString("admin_name") ?? "Admin";
      imagePath = prefs.getString("admin_image") ?? "";
    });
  }

  Future<void> saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("admin_name", userName);
    await prefs.setString("admin_image", imagePath);
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() => imagePath = picked.path);
      saveProfile();
    }
  }

  void editName() {
    final controller = TextEditingController(text: userName);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Name"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => userName = controller.text.trim());
              saveProfile();
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ============================
  // LOGOUT
  // ============================
  Future<void> logout() async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // ============================
  // CHART VALUES
  // ============================
  List<PieChartSectionData> getChartSections() {
    return [
      PieChartSectionData(
        value: pending.toDouble(),
        color: Colors.orange,
        title: "Pending",
      ),
      PieChartSectionData(
        value: progress.toDouble(),
        color: Colors.blue,
        title: "Progress",
      ),
      PieChartSectionData(
        value: completed.toDouble(),
        color: Colors.green,
        title: "Done",
      ),
      PieChartSectionData(
        value: cancelled.toDouble(),
        color: Colors.red,
        title: "Cancel",
      ),
    ];
  }

  // ============================
  // UI
  // ============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
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
        onRefresh: loadJobs,
        child: Padding(
          padding: AppUI.screen,
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : error != null
              ? ListView(
                  children: [
                    const SizedBox(height: 200),
                    Center(child: Text(error!)),
                  ],
                )
              : ListView(
                  children: [
                    buildProfile(),
                    const SizedBox(height: 16),
                    buildStats(),
                    const SizedBox(height: 16),
                    buildChart(),
                    const SizedBox(height: 16),
                    buildRecentJobs(),
                  ],
                ),
        ),
      ),
    );
  }

  // PROFILE
  Widget buildProfile() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: pickImage,
            child: CircleAvatar(
              radius: 32,
              backgroundImage: imagePath.isNotEmpty
                  ? FileImage(File(imagePath))
                  : null,
              child: imagePath.isEmpty ? const Icon(Icons.person) : null,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Welcome"),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(onPressed: editName, icon: const Icon(Icons.edit)),
        ],
      ),
    );
  }

  // STATS
  Widget buildStats() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.7,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        statTile("TOTAL", total, Colors.blue),
        statTile("PENDING", pending, Colors.orange),
        statTile("PROGRESS", progress, Colors.blueAccent),
        statTile("COMPLETED", completed, Colors.green),
      ],
    );
  }

  // PIE CHART
  Widget buildChart() {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: PieChart(PieChartData(sections: getChartSections())),
    );
  }

  // JOBS
  Widget buildRecentJobs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recent Jobs",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (jobs.isEmpty) const Center(child: Text("No jobs found")),
        ...jobs.take(5).map((job) {
          return Card(
            child: ListTile(
              title: Text(job["title"] ?? ""),
              subtitle: Text(job["location"] ?? ""),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              UpdateJobScreen(job: job, onUpdated: loadJobs),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteJob(job["id"]),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget statTile(String label, int count, Color color) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: Text(
          "$count",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}
