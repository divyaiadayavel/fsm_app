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

  @override
  void initState() {
    super.initState();
    loadJobs();
    loadProfile();
  }

  // ============================
  // 🔥 LOAD JOBS FROM API
  // ============================
  Future<void> loadJobs() async {
    final response = await ApiService.getJobs();

    if (!mounted) return;

    if (response['status'] == true) {
      final data = List<Map<String, dynamic>>.from(response['data']);

      setState(() {
        jobs = data;

        total = jobs.length;
        pending = jobs.where((e) => e["status"] == "Pending").length;
        progress =
            jobs.where((e) => e["status"] == "In Progress").length;
        completed =
            jobs.where((e) => e["status"] == "Completed").length;
        cancelled =
            jobs.where((e) => e["status"] == "Cancelled").length;
      });
    } else {
      setState(() {
        jobs = [];
      });
    }
  }

  // ============================
  // 🗑 DELETE JOB
  // ============================
  Future<void> deleteJob(int id) async {
    final response = await ApiService.deleteJob(id);

    if (response['status'] == true) {
      loadJobs();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'])),
      );
    }
  }

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
      setState(() {
        imagePath = picked.path;
      });

      saveProfile();
    }
  }

  void editName() {
    final controller = TextEditingController(text: userName);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Name"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                userName = controller.text.trim();
              });

              saveProfile();
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
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
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final values = getChartValues();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        title: Text("Admin Dashboard",
            style: TextStyle(color: AppColors.textPrimary)),
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
          child: ListView(
            children: [
              // PROFILE
              Container(
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
                        child: imagePath.isEmpty
                            ? const Icon(Icons.person)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Welcome"),
                          Text(userName,
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    IconButton(onPressed: editName, icon: Icon(Icons.edit)),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // STATS
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                children: [
                  statTile("TOTAL", total, Colors.blue),
                  statTile("PENDING", pending, Colors.orange),
                  statTile("PROGRESS", progress, Colors.blueAccent),
                  statTile("COMPLETED", completed, Colors.green),
                ],
              ),

              const SizedBox(height: 16),

              // RECENT JOBS
              const Text("Recent Jobs",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

              const SizedBox(height: 10),

              if (jobs.isEmpty)
                const Center(child: Text("No jobs found")),

              ...jobs.take(5).map((job) {
                return Card(
                  child: ListTile(
                    title: Text(job["title"]),
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
                                builder: (_) => UpdateJobScreen(
                                  job: job,
                                  onUpdated: loadJobs,
                                ),
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
          ),
        ),
      ),
    );
  }

  Widget statTile(String label, int count, Color color) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: Text("$count",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ),
    );
  }
}