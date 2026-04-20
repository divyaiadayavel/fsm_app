import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_ui.dart';
import '../../data/db/database_helper.dart';
import '../widgets/technician_tile.dart';
import 'add_technician_screen.dart';

class TechniciansScreen extends StatefulWidget {
  const TechniciansScreen({super.key});

  @override
  State<TechniciansScreen> createState() => _TechniciansScreenState();
}

class _TechniciansScreenState extends State<TechniciansScreen> {
  List<Map<String, dynamic>> technicians = [];

  @override
  void initState() {
    super.initState();
    loadTechnicians();
  }

  Future<void> loadTechnicians() async {
    final data = await DatabaseHelper.instance.getTechnicians();
    setState(() => technicians = data);
  }

  Future<void> deleteTechnician(int id) async {
    await DatabaseHelper.instance.deleteTechnician(id);
    await loadTechnicians();
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
            color: Colors.black,
            fontSize: AppUI.subTitle,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          "Are you sure to delete this technician?",
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

  Future<void> openAddScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTechnicianScreen(
          onSave: (data) async {
            await DatabaseHelper.instance.insertTechnician(data);
          },
        ),
      ),
    );

    if (result == true) loadTechnicians();
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = technicians
        .where((e) => (e["online"] ?? 0) == 1)
        .length;
    final totalCount = technicians.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: AppUI.screen,
          child: ListView(
            children: [
              Row(
                children: [
                  const Icon(Icons.menu, color: Colors.black, size: 28),
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

              const SizedBox(height: AppUI.gapXl),

              const Text(
                "Technicians",
                style: TextStyle(
                  fontSize: AppUI.heading,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: AppUI.gapXs),

              const Text(
                "Managing field leads and logistics teams",
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: AppUI.body,
                ),
              ),

              const SizedBox(height: AppUI.gapLg),

              GestureDetector(
                onTap: openAddScreen,
                child: Container(
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppUI.radiusLg),
                  ),
                  child: const Center(
                    child: Text(
                      "+ Add Technician",
                      style: TextStyle(
                        fontSize: AppUI.subTitle,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppUI.gapLg),

              Row(
                children: [
                  Expanded(
                    child: statCard("ACTIVE NOW", activeCount.toString()),
                  ),
                  const SizedBox(width: AppUI.gapSm),
                  Expanded(
                    child: statCard("TOTAL LEADS", totalCount.toString()),
                  ),
                ],
              ),

              const SizedBox(height: AppUI.gapLg),

              if (technicians.isEmpty)
                Container(
                  padding: const EdgeInsets.all(30),
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

              ...technicians.map(
                (tech) => GestureDetector(
                  onLongPress: () => showDeletePopup(tech["id"]),
                  child: TechnicianTile(
                    name: tech["name"] ?? "",
                    email: tech["email"] ?? "",
                    phone: tech["phone"] ?? "",
                    jobs: tech["jobs"] ?? 0,
                    online: (tech["online"] ?? 0) == 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget statCard(String title, String value) {
    return Container(
      height: 130,
      padding: AppUI.card,
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
              letterSpacing: 1.4,
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
