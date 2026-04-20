import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_ui.dart';
import '../../data/db/database_helper.dart';
import 'jobs_screen.dart';
import 'map_picker_screen.dart';
import 'technicians_screen.dart';

class CreateJobScreen extends StatefulWidget {
  final VoidCallback onSaved;

  const CreateJobScreen({super.key, required this.onSaved});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final titleController = TextEditingController();
  final customerController = TextEditingController();
  final locationController = TextEditingController();

  List<Map<String, dynamic>> technicians = [];

  String? technician;
  String priority = "High";
  String status = "In Progress";

  double? selectedLat;
  double? selectedLng;
  bool isLoading = false;
  int currentIndex = 1;

  @override
  void initState() {
    super.initState();
    loadTechnicians();
  }

  Future<void> loadTechnicians() async {
    final data = await DatabaseHelper.instance.getTechnicians();

    setState(() {
      technicians = data;
      if (technicians.isNotEmpty) {
        technician = technicians.first["name"];
      }
    });
  }

  Future<void> updateCoordinatesFromAddress() async {
    final text = locationController.text.trim();
    if (text.isEmpty) return;

    setState(() => isLoading = true);

    try {
      final result = await locationFromAddress("$text, Tamil Nadu, India");

      if (result.isNotEmpty) {
        setState(() {
          selectedLat = result.first.latitude;
          selectedLng = result.first.longitude;
        });
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> pickLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            MapPickerScreen(initialLat: selectedLat, initialLng: selectedLng),
      ),
    );

    if (result != null) {
      setState(() {
        locationController.text = result["address"];
        selectedLat = result["lat"];
        selectedLng = result["lng"];
      });
    }
  }

  Future<void> saveJob() async {
    if (titleController.text.trim().isEmpty) return;
    if (technician == null) return;

    await DatabaseHelper.instance.insertJob({
      "title": titleController.text.trim(),
      "customer": customerController.text.trim(),
      "location": locationController.text.trim(),
      "technician": technician,
      "priority": priority,
      "status": status,
      "lat": selectedLat,
      "lng": selectedLng,
    });

    await DatabaseHelper.instance.increaseTechnicianJobs(technician!);

    widget.onSaved();

    if (mounted) {
      Navigator.pop(context);
    }
  }

  void onNavTap(int i) {
    if (i == currentIndex) return;

    if (i == 0) {
      Navigator.pop(context);
    } else if (i == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const JobsScreen()),
      );
    } else if (i == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TechniciansScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: AppUI.screen,
          child: ListView(
            children: [
              Row(
                children: [
                  const Icon(Icons.menu, color: Colors.black, size: 26),
                  const SizedBox(width: 10),
                  const Text(
                    "Create Job",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.black),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionTitle("JOB TITLE"),
                    inputField(titleController, "Enter job title"),

                    sectionTitle("CUSTOMER NAME"),
                    inputField(customerController, "Enter customer name"),

                    sectionTitle("LOCATION"),
                    locationField(),

                    const SizedBox(height: 12),
                    GestureDetector(onTap: pickLocation, child: mapCard()),

                    sectionTitle("ASSIGN TECHNICIAN"),
                    technicianDropdown(),

                    sectionTitle("PRIORITY LEVEL"),
                    Row(
                      children: [
                        Expanded(child: priorityButton("Low")),
                        const SizedBox(width: 8),
                        Expanded(child: priorityButton("Medium")),
                        const SizedBox(width: 8),
                        Expanded(child: priorityButton("High")),
                      ],
                    ),

                    const SizedBox(height: 22),

                    actionButton(
                      title: "Save Job",
                      primary: true,
                      onTap: saveJob,
                    ),

                    const SizedBox(height: 12),

                    actionButton(
                      title: "Cancel",
                      primary: false,
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onNavTap,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.black54,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: "Create",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: "Jobs"),
          BottomNavigationBarItem(icon: Icon(Icons.groups), label: "Techs"),
        ],
      ),
    );
  }

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget inputField(TextEditingController controller, String hint) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.grey),
        ),
      ),
    );
  }

  Widget locationField() {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: locationController,
        onSubmitted: (_) => updateCoordinatesFromAddress(),
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Enter address",
          hintStyle: TextStyle(color: AppColors.grey),
          suffixIcon: IconButton(
            onPressed: updateCoordinatesFromAddress,
            icon: isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.search, color: AppColors.primary),
          ),
        ),
      ),
    );
  }

  Widget mapCard() {
    return Container(
      height: 110,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          selectedLat == null
              ? "Search address to show location"
              : "Lat: ${selectedLat!.toStringAsFixed(4)}\nLng: ${selectedLng!.toStringAsFixed(4)}",
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget technicianDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButton<String>(
        value: technician,
        underline: const SizedBox(),
        isExpanded: true,
        dropdownColor: Colors.white,
        style: const TextStyle(color: Colors.black),
        items: technicians.map((e) {
          return DropdownMenuItem<String>(
            value: e["name"],
            child: Text(e["name"]),
          );
        }).toList(),
        onChanged: (v) => setState(() => technician = v),
      ),
    );
  }

  Widget priorityButton(String value) {
    final active = priority == value;

    return GestureDetector(
      onTap: () => setState(() => priority = value),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            value,
            style: TextStyle(
              color: active ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget actionButton({
    required String title,
    required bool primary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: primary ? AppColors.primary : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: primary ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
