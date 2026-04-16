import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_ui.dart';
import '../../data/db/database_helper.dart';
import 'map_picker_screen.dart';
import 'jobs_screen.dart';
import 'technicians_screen.dart';
import 'package:geocoding/geocoding.dart';

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

  Future<void> pickLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MapPickerScreen()),
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
      "title": titleController.text,
      "customer": customerController.text,
      "location": locationController.text,
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Job Assigned Successfully")),
      );
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

              const SizedBox(height: AppUI.gapLg),

              Container(
                padding: AppUI.card,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppUI.radiusLg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "NEW ASSIGNMENT",
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: AppUI.caption,
                                  letterSpacing: 2,
                                ),
                              ),
                              SizedBox(height: AppUI.gapXs),
                              Text(
                                "Create Job",
                                style: TextStyle(
                                  fontSize: AppUI.heading,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 52,
                            width: 52,
                            decoration: const BoxDecoration(
                              color: Colors.white10,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppUI.gapLg),
                    divider(),

                    fieldLabel("JOB TITLE"),
                    inputField(titleController, "Enter job title"),

                    fieldLabel("CUSTOMER NAME"),
                    inputField(
                      customerController,
                      "Enter customer",
                      icon: Icons.person_outline,
                    ),
                    fieldLabel("LOCATION"),
                    GestureDetector(onTap: pickLocation, child: mapCard()),

                    const SizedBox(height: AppUI.gapSm),

                    inputField(locationController, "Enter location"),

                    fieldLabel("ASSIGN TECHNICIAN"),
                    technicianDropdown(),

                    fieldLabel("PRIORITY LEVEL"),
                    Row(
                      children: [
                        priorityButton("Low"),
                        const SizedBox(width: AppUI.gapXs),
                        priorityButton("Medium"),
                        const SizedBox(width: AppUI.gapXs),
                        priorityButton("High"),
                      ],
                    ),

                    fieldLabel("CURRENT STATUS"),
                    dropdownField(
                      value: status,
                      items: const ["Pending", "In Progress", "Completed"],
                      onChanged: (v) => setState(() => status = v!),
                    ),

                    const SizedBox(height: AppUI.gapLg),

                    actionButton(
                      title: "Save Job",
                      primary: true,
                      onTap: saveJob,
                    ),

                    const SizedBox(height: AppUI.gapSm),

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
        backgroundColor: AppColors.card,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.white54,
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

  Widget divider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.only(bottom: AppUI.gapMd),
      color: Colors.white10,
    );
  }

  Widget fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: AppUI.gapSm, bottom: AppUI.gapSm),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: AppUI.caption,
          letterSpacing: 1.4,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget inputField(
    TextEditingController controller,
    String hint, {
    IconData? icon,
  }) {
    return Container(
      height: AppUI.inputHeight,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(AppUI.radiusMd),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: AppUI.body),
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, color: Colors.white38) : null,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white70),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18),
        ),
      ),
    );
  }

  Widget mapCard() {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppUI.radiusMd),
        image: const DecorationImage(
          image: AssetImage("assets/images/map_bg.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.all(AppUI.gapSm),
          child: Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white),
              const SizedBox(width: AppUI.gapXs),
              Expanded(
                child: Text(
                  locationController.text.isEmpty
                      ? "Tap to select location"
                      : locationController.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppUI.body,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget technicianDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppUI.gapSm),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(AppUI.radiusMd),
      ),
      child: DropdownButton<String>(
        value: technician,
        dropdownColor: AppColors.card,
        underline: const SizedBox(),
        isExpanded: true,
        style: const TextStyle(color: Colors.white, fontSize: AppUI.body),
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

  Widget dropdownField({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppUI.gapSm),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(AppUI.radiusMd),
      ),
      child: DropdownButton<String>(
        value: value,
        dropdownColor: AppColors.card,
        underline: const SizedBox(),
        isExpanded: true,
        style: const TextStyle(color: Colors.white, fontSize: AppUI.body),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget priorityButton(String value) {
    final active = priority == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => priority = value),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.black26,
            borderRadius: BorderRadius.circular(AppUI.radiusSm),
          ),
          child: Center(
            child: Text(
              value.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: AppUI.body,
              ),
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
        height: AppUI.buttonHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppUI.radiusMd),
          gradient: primary
              ? const LinearGradient(
                  colors: [Color(0xFFCFCBFF), Color(0xFF6F63FF)],
                )
              : null,
          color: primary ? null : Colors.white10,
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: AppUI.subTitle,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
