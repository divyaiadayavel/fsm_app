import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

import '../../data/services/api_service.dart';
import 'map_picker_screen.dart';

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

  int? technicianId;
  String priority = "High";

  double? selectedLat;
  double? selectedLng;

  bool isLoading = false;
  bool isTechLoading = true;

  final Color greyBoxColor = const Color(0xFFF2F2F2);
  final Color primaryBlue = const Color(0xFF4C61EE);
  final Color blackText = Colors.black;
  final Color secondaryGrey = Colors.black54;

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

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ==========================
  // LOAD TECHNICIANS
  // ==========================
  Future<void> loadTechnicians() async {
    try {
      final response = await ApiService.getTechnicians();

      if (!mounted) return;

      if (response['status'] == true) {
        technicians = List<Map<String, dynamic>>.from(response['data']);

        if (technicians.isNotEmpty) {
          technicianId = int.tryParse(technicians.first["id"].toString());
        }
      } else {
        showMsg("Failed to load technicians");
      }
    } catch (e) {
      showMsg("Error loading technicians");
    }

    if (mounted) setState(() => isTechLoading = false);
  }

  // ==========================
  // LOCATION
  // ==========================
  Future<void> updateCoordinatesFromAddress() async {
    final text = locationController.text.trim();

    if (text.isEmpty) return;

    setState(() => isLoading = true);

    try {
      final result = await locationFromAddress("$text, Tamil Nadu, India");

      if (result.isNotEmpty) {
        selectedLat = result.first.latitude;
        selectedLng = result.first.longitude;
      }
    } catch (_) {
      showMsg("Location not found");
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

    if (result != null && mounted) {
      setState(() {
        locationController.text = result["address"];
        selectedLat = result["lat"];
        selectedLng = result["lng"];
      });
    }
  }

  // ==========================
  // ✅ FIXED SAVE JOB (FINAL)
  // ==========================
  Future<void> saveJob() async {
    if (titleController.text.trim().isEmpty) {
      showMsg("Title required");
      return;
    }

    if (technicianId == null) {
      showMsg("Select technician");
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await ApiService.createJob({
        "title": titleController.text.trim(),
        "customer": customerController.text.trim(),
        "location": locationController.text.trim(),
        "technician_id": technicianId.toString(), // ✅ FIX
        "priority": priority,
        "status": "Pending",
        "lat": selectedLat ?? 0,
        "lng": selectedLng ?? 0,
      });

      print("CREATE JOB RESPONSE: $response");

      if (!mounted) return;

      setState(() => isLoading = false);

      if (response['status'] == true) {
        // ✅ SAFE NAVIGATION
        if (Navigator.canPop(context)) {
          Navigator.pop(context, true);
        }
      } else {
        showMsg(response['message'] ?? "Failed to create job");
      }
    } catch (e) {
      setState(() => isLoading = false);
      showMsg("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 400;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24 * scale),
          child: ListView(
            children: [
              SizedBox(height: 20 * scale),

              Row(
                children: [
                  Text(
                    "Create Job",
                    style: TextStyle(
                      fontSize: 24 * scale,
                      fontWeight: FontWeight.bold,
                      color: blackText,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, size: 24 * scale),
                  ),
                ],
              ),

              SizedBox(height: 20 * scale),

              sectionTitle("JOB TITLE"),
              buildTextField(titleController, "Enter job title"),

              SizedBox(height: 16 * scale),

              sectionTitle("CUSTOMER NAME"),
              buildTextField(customerController, "Enter customer name"),

              SizedBox(height: 16 * scale),

              sectionTitle("LOCATION"),
              buildLocationField(),

              SizedBox(height: 12 * scale),

              GestureDetector(onTap: pickLocation, child: mapCard()),

              SizedBox(height: 16 * scale),

              sectionTitle("ASSIGN TECHNICIAN"),
              isTechLoading
                  ? const Center(child: CircularProgressIndicator())
                  : buildTechnicianDropdown(),

              SizedBox(height: 16 * scale),

              sectionTitle("PRIORITY LEVEL"),
              Row(
                children: [
                  Expanded(child: priorityButton("Low")),
                  SizedBox(width: 8 * scale),
                  Expanded(child: priorityButton("Medium")),
                  SizedBox(width: 8 * scale),
                  Expanded(child: priorityButton("High")),
                ],
              ),

              SizedBox(height: 30 * scale),

              buildActionButton(
                isLoading ? "Saving..." : "Save Job",
                primaryBlue,
                Colors.white,
                isLoading ? () {} : saveJob,
              ),

              SizedBox(height: 12 * scale),

              buildActionButton(
                "Cancel",
                greyBoxColor,
                blackText,
                () => Navigator.pop(context),
              ),

              SizedBox(height: 20 * scale),
            ],
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: secondaryGrey,
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: greyBoxColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget buildLocationField() {
    return TextField(
      controller: locationController,
      onSubmitted: (_) => updateCoordinatesFromAddress(),
      decoration: InputDecoration(
        hintText: "Enter address",
        filled: true,
        fillColor: greyBoxColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          onPressed: updateCoordinatesFromAddress,
          icon: isLoading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(Icons.search, color: primaryBlue),
        ),
      ),
    );
  }

  Widget mapCard() {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: greyBoxColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          selectedLat == null
              ? "Tap to pick location"
              : "Lat: ${selectedLat!.toStringAsFixed(4)}\nLng: ${selectedLng!.toStringAsFixed(4)}",
        ),
      ),
    );
  }

  Widget buildTechnicianDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: greyBoxColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: technicianId,
          isExpanded: true,
          items: technicians.map((e) {
            return DropdownMenuItem<int>(
              value: int.tryParse(e["id"].toString()),
              child: Text(e["name"] ?? ""),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => technicianId = value);
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
        height: 44,
        decoration: BoxDecoration(
          color: active ? primaryBlue : greyBoxColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            value,
            style: TextStyle(color: active ? Colors.white : blackText),
          ),
        ),
      ),
    );
  }

  Widget buildActionButton(
    String label,
    Color bg,
    Color text,
    VoidCallback tap,
  ) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: tap,
        style: ElevatedButton.styleFrom(backgroundColor: bg),
        child: Text(label, style: TextStyle(color: text)),
      ),
    );
  }
}
