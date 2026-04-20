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

  double? selectedLat;
  double? selectedLng;

  bool isLoading = false;
  int currentIndex = 1;

  @override
  void initState() {
    super.initState();
    loadTechnicians();
  }

  @override
  void dispose() {
    titleController.dispose();
    customerController.dispose();
    locationController.dispose();
    super.dispose();
  }

  Future<void> loadTechnicians() async {
    final data = await DatabaseHelper.instance.getTechnicians();

    if (!mounted) return;

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
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
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

    if (result != null && mounted) {
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
      "status": "Pending",
      "lat": selectedLat,
      "lng": selectedLng,
    });

    await DatabaseHelper.instance.increaseTechnicianJobs(technician!);

    widget.onSaved();

    if (mounted) {
      Navigator.pop(context);
    }
  }

  void onNavTap(int index) {
    if (index == currentIndex) return;

    if (index == 0) {
      Navigator.pop(context);
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const JobsScreen()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TechniciansScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: AppUI.screen,
          child: ListView(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.menu,
                    color: AppColors.textPrimary,
                    size: 26,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Create Job",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.textPrimary),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              sectionTitle("JOB TITLE"),
              inputField(titleController, "Enter job title"),

              const SizedBox(height: 16),

              sectionTitle("CUSTOMER NAME"),
              inputField(customerController, "Enter customer name"),

              const SizedBox(height: 16),

              sectionTitle("LOCATION"),
              locationField(),

              const SizedBox(height: 14),

              GestureDetector(onTap: pickLocation, child: mapCard()),

              const SizedBox(height: 16),

              sectionTitle("ASSIGN TECHNICIAN"),
              technicianDropdown(),

              const SizedBox(height: 16),

              sectionTitle("PRIORITY LEVEL"),
              Row(
                children: [
                  Expanded(child: priorityButton("Low")),
                  const SizedBox(width: 10),
                  Expanded(child: priorityButton("Medium")),
                  const SizedBox(width: 10),
                  Expanded(child: priorityButton("High")),
                ],
              ),

              const SizedBox(height: 28),

              actionButton(title: "Save Job", primary: true, onTap: saveJob),

              const SizedBox(height: 14),

              actionButton(
                title: "Cancel",
                primary: false,
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onNavTap,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: AppColors.white,
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget inputField(TextEditingController controller, String hint) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 18),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hint,
            hintStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget locationField() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: TextField(
          controller: locationController,
          onSubmitted: (_) => updateCoordinatesFromAddress(),
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 18),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Enter address",
            hintStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 18,
            ),
            suffixIcon: IconButton(
              onPressed: updateCoordinatesFromAddress,
              icon: isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search, color: AppColors.primary),
            ),
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
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          selectedLat == null
              ? "Search address to show location"
              : "Lat: ${selectedLat!.toStringAsFixed(4)}\nLng: ${selectedLng!.toStringAsFixed(4)}",
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget technicianDropdown() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: technician,
          isExpanded: true,
          dropdownColor: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 18),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
          ),
          items: technicians.map((e) {
            return DropdownMenuItem<String>(
              value: e["name"],
              child: Text(e["name"]),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => technician = value);
          },
        ),
      ),
    );
  }

  Widget priorityButton(String value) {
    final active = priority == value;

    return GestureDetector(
      onTap: () => setState(() => priority = value),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : const Color(0xFFEDEDED),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Text(
            value,
            style: TextStyle(
              color: active ? AppColors.white : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
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
        height: 58,
        decoration: BoxDecoration(
          color: primary ? AppColors.primary : const Color(0xFFEDEDED),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: primary ? AppColors.white : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
