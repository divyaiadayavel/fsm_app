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

    setState(() {
      technicians = data;
    });
  }

  Future<void> deleteTechnician(int id) async {
    await DatabaseHelper.instance.deleteTechnician(id);
    await loadTechnicians();
  }

  void showDeletePopup(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppUI.radiusMd),
        ),
        title: const Text(
          "Delete Technician?",
          style: TextStyle(
            color: Colors.white,
            fontSize: AppUI.subTitle,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          "Are you sure to delete this technician?",
          style: TextStyle(color: Colors.white70, fontSize: AppUI.body),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(fontSize: AppUI.body)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await deleteTechnician(id);
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red, fontSize: AppUI.body),
            ),
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

    if (result == true) {
      loadTechnicians();
    }
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
                  const Icon(Icons.menu, color: Colors.white, size: 28),
                  const SizedBox(width: AppUI.gapSm),
                  const Text(
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

              const SizedBox(height: AppUI.gapXl),

              const Text(
                "Technicians",
                style: TextStyle(
                  fontSize: AppUI.heading,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: AppUI.gapXs),

              const Text(
                "Managing field leads and logistics teams",
                style: TextStyle(color: Colors.white70, fontSize: AppUI.body),
              ),

              const SizedBox(height: AppUI.gapLg),

              GestureDetector(
                onTap: openAddScreen,
                child: Container(
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppUI.radiusLg),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFCAC5FF), Color(0xFF7267FF)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(.35),
                        blurRadius: 18,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "+ Add Technician",
                      style: TextStyle(
                        fontSize: AppUI.subTitle,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
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
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(AppUI.radiusMd),
                  ),
                  child: const Center(
                    child: Text(
                      "No Technicians Added",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: AppUI.body,
                      ),
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
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppUI.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white60,
              letterSpacing: 1.4,
              fontSize: AppUI.caption,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: AppUI.heading,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
