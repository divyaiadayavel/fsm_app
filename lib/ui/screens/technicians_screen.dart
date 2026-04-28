import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_ui.dart';
import '../../data/services/api_service.dart';
import '../widgets/technician_tile.dart';
import 'add_technician_screen.dart';

class TechniciansScreen extends StatefulWidget {
  const TechniciansScreen({super.key});

  @override
  State<TechniciansScreen> createState() => _TechniciansScreenState();
}

class _TechniciansScreenState extends State<TechniciansScreen> {
  List<Map<String, dynamic>> technicians = [];

  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadTechnicians();
  }

  // ============================
  // LOAD TECHNICIANS (API SAFE)
  // ============================
  Future<void> loadTechnicians() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await ApiService.getTechnicians();

      if (!mounted) return;

      setState(() {
        technicians = response['status'] == true
            ? List<Map<String, dynamic>>.from(response['data'] ?? [])
            : [];
      });
    } catch (e) {
      error = e.toString();
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  // ============================
  // DELETE TECHNICIAN
  // ============================
  Future<void> deleteTechnician(int id) async {
    try {
      final response = await ApiService.deleteTechnician(id);

      if (response['status'] == true) {
        await loadTechnicians();
      } else {
        showMsg(response['message'] ?? "Delete failed");
      }
    } catch (e) {
      showMsg("Error: $e");
    }
  }

  void showDeletePopup(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppUI.radiusMd),
        ),
        title: const Text(
          "Delete Technician?",
          style: TextStyle(
            fontSize: AppUI.subTitle,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        content: const Text(
          "Are you sure you want to delete this technician?",
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await deleteTechnician(id);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ============================
  // ADD TECHNICIAN (API)
  // ============================
  Future<void> openAddScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTechnicianScreen(
          onSave: (data) async {
            try {
              await ApiService.createTechnician({
                "name": data["name"],
                "email": data["email"],
                "phone": data["phone"],
                "role": data["role"],
                "jobs": data["jobs"],
                "online": data["online"],
                "password": data["password"],
              });

              await loadTechnicians();
            } catch (e) {
              if (mounted) {
                showMsg("Error: $e");
              }
            }
          },
        ),
      ),
    );

    if (result == true) {
      await loadTechnicians();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 400;

    final activeCount = technicians
        .where((e) => (e["online"] ?? 0) == 1)
        .length;

    final totalCount = technicians.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(14 * scale),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : error != null
              ? ListView(
                  children: [
                    SizedBox(height: 200 * scale),
                    Center(child: Text(error!)),
                  ],
                )
              : ListView(
                  children: [
                    // HEADER
                    Row(
                      children: [
                        Icon(
                          Icons.groups,
                          color: Colors.black,
                          size: 24 * scale,
                        ),
                        SizedBox(width: 8 * scale),
                        Text(
                          "Technicians",
                          style: TextStyle(
                            fontSize: 20 * scale,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: loadTechnicians,
                          icon: Icon(
                            Icons.refresh,
                            color: Colors.black,
                            size: 22 * scale,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 18 * scale),

                    Text(
                      "Manage field leads and logistics teams",
                      style: TextStyle(
                        color: const Color(0xFF6B7280),
                        fontSize: 13 * scale,
                      ),
                    ),

                    SizedBox(height: 18 * scale),

                    // ADD BUTTON
                    GestureDetector(
                      onTap: openAddScreen,
                      child: Container(
                        height: 52 * scale,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(AppUI.radiusLg),
                        ),
                        child: Center(
                          child: Text(
                            "+ Add Technician",
                            style: TextStyle(
                              fontSize: 16 * scale,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 16 * scale),

                    // STATS
                    Row(
                      children: [
                        Expanded(
                          child: statCard(
                            "ACTIVE NOW",
                            activeCount.toString(),
                            scale,
                          ),
                        ),
                        SizedBox(width: 10 * scale),
                        Expanded(
                          child: statCard(
                            "TOTAL LEADS",
                            totalCount.toString(),
                            scale,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16 * scale),

                    // EMPTY STATE
                    if (technicians.isEmpty)
                      Container(
                        padding: EdgeInsets.all(20 * scale),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppUI.radiusMd),
                        ),
                        child: const Center(
                          child: Text(
                            "No Technicians Added",
                            style: TextStyle(color: Color(0xFF6B7280)),
                          ),
                        ),
                      ),

                    // LIST
                    ...technicians.map((tech) {
                      final id = tech["id"];
                      final jobs = tech["jobs"];
                      final online = tech["online"];

                      return GestureDetector(
                        onLongPress: () => showDeletePopup(
                          id is int ? id : int.tryParse(id.toString()) ?? 0,
                        ),
                        child: TechnicianTile(
                          name: tech["name"]?.toString() ?? "",
                          email: tech["email"]?.toString() ?? "",
                          phone: tech["phone"]?.toString() ?? "",
                          jobs: jobs is int
                              ? jobs
                              : int.tryParse(jobs.toString()) ?? 0,
                          online: online == 1 || online == "1",
                        ),
                      );
                    }),
                  ],
                ),
        ),
      ),
    );
  }

  Widget statCard(String title, String value, double s) {
    return Container(
      height: 110 * s,
      padding: EdgeInsets.all(12 * s),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppUI.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: AppUI.caption,
              letterSpacing: 1.2,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: AppUI.heading,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
