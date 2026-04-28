// technician_dashboard_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_ui.dart';
import '../../data/services/api_service.dart';
import 'package:fsm_app/views/auth/login_screen.dart';
import 'package:image_picker/image_picker.dart';

class TechnicianDashboardScreen extends StatefulWidget {
  final int? technicianId;
  final String? technicianName;

  const TechnicianDashboardScreen({
    super.key,
    this.technicianId,
    this.technicianName,
  });

  @override
  State<TechnicianDashboardScreen> createState() =>
      _TechnicianDashboardScreenState();
}

class _TechnicianDashboardScreenState extends State<TechnicianDashboardScreen> {
  List<Map<String, dynamic>> jobs = [];

  String technicianName = "Technician";
  int? technicianId;

  String imagePath = "";

  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();

    // ✅ DIRECT DATA FROM LOGIN (NO EMAIL MATCHING)
    technicianId = widget.technicianId;
    technicianName = widget.technicianName ?? "Technician";

    loadData();
  }

  // ==========================
  // LOAD DATA (FIXED)
  // ==========================
  Future<void> loadData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final jobRes = await ApiService.getJobs();

      if (jobRes['status'] != true) {
        throw Exception("Failed to load jobs");
      }

      final allJobs = List<Map<String, dynamic>>.from(jobRes['data']);

      final assignedJobs = allJobs.where((job) {
        return job["technician_id"].toString() == technicianId.toString();
      }).toList();

      await loadProfileImage();

      if (!mounted) return;

      setState(() {
        jobs = assignedJobs;
      });
    } catch (e) {
      error = e.toString();
    }

    if (mounted) setState(() => isLoading = false);
  }

  // ==========================
  // PROFILE IMAGE
  // ==========================
  Future<void> loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final key = "tech_image_$technicianId";
    imagePath = prefs.getString(key) ?? "";
  }

  Future<void> saveProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final key = "tech_image_$technicianId";
    await prefs.setString(key, imagePath);
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => imagePath = picked.path);
      await saveProfileImage();
    }
  }

  // ==========================
  // LOGOUT
  // ==========================
  Future<void> logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  // ==========================
  // UPDATE STATUS
  // ==========================
  Future<void> showStatusDialog(Map<String, dynamic> job) async {
    String selectedStatus = job["status"] ?? "Pending";

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Update Job Status"),
        content: StatefulBuilder(
          builder: (context, setStateDialog) {
            return DropdownButton<String>(
              value: selectedStatus,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: "Pending", child: Text("Pending")),
                DropdownMenuItem(
                  value: "In Progress",
                  child: Text("In Progress"),
                ),
                DropdownMenuItem(value: "Completed", child: Text("Completed")),
              ],
              onChanged: (v) {
                setStateDialog(() {
                  selectedStatus = v!;
                });
              },
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await ApiService.updateJob({
                "id": job["id"],
                "status": selectedStatus,
              });
              Navigator.pop(context);
              loadData();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // ==========================
  // COLORS
  // ==========================
  Color statusColor(String status) {
    switch (status) {
      case "Pending":
        return Colors.orange;
      case "In Progress":
        return Colors.blue;
      case "Completed":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color priorityColor(String priority) {
    switch (priority) {
      case "High":
        return Colors.red;
      case "Medium":
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  // ==========================
  // UI
  // ==========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Technician Dashboard"),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: logout),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: AppUI.screen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PROFILE
              Row(
                children: [
                  GestureDetector(
                    onTap: pickImage,
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFFE5E7EB),
                      backgroundImage: imagePath.isNotEmpty
                          ? FileImage(File(imagePath))
                          : null,
                      child: imagePath.isEmpty
                          ? const Icon(Icons.person, color: Colors.black)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      technicianName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              const Text(
                "Assigned Jobs",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : error != null
                    ? Center(child: Text(error!))
                    : jobs.isEmpty
                    ? const Center(
                        child: Text(
                          "No Jobs Assigned",
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      )
                    : ListView.builder(
                        itemCount: jobs.length,
                        itemBuilder: (_, i) => jobCard(jobs[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget jobCard(Map<String, dynamic> job) {
    final status = job["status"] ?? "";
    final priority = job["priority"] ?? "";

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  job["title"] ?? "",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              statusBadge(status),
            ],
          ),

          const SizedBox(height: 10),

          infoRow(Icons.business, job["customer"] ?? ""),
          const SizedBox(height: 8),
          infoRow(Icons.location_on_outlined, job["location"] ?? ""),

          const SizedBox(height: 14),

          Row(
            children: [
              priorityBadge(priority),
              const Spacer(),
              ElevatedButton(
                onPressed: () => showStatusDialog(job),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Update status",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.black54),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget statusBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor(text).withOpacity(.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: statusColor(text),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget priorityBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: priorityColor(text).withOpacity(.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        "$text Priority",
        style: TextStyle(
          color: priorityColor(text),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
