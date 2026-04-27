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

  int? technicianId; // ✅ ID instead of name
  String priority = "High";

  double? selectedLat;
  double? selectedLng;

  bool isLoading = false;

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

  // ============================
  // 📋 LOAD TECHNICIANS (API)
  // ============================
  Future<void> loadTechnicians() async {
    final response = await ApiService.getTechnicians();

    if (!mounted) return;

    if (response['status'] == true) {
      setState(() {
        technicians = List<Map<String, dynamic>>.from(response['data']);

        if (technicians.isNotEmpty) {
          technicianId =
              int.parse(technicians.first["id"].toString());
        }
      });
    }
  }

  // ============================
  // 📍 GET LAT LNG FROM ADDRESS
  // ============================
  Future<void> updateCoordinatesFromAddress() async {
    final text = locationController.text.trim();

    if (text.isEmpty) return;

    setState(() => isLoading = true);

    try {
      final result =
          await locationFromAddress("$text, Tamil Nadu, India");

      if (result.isNotEmpty) {
        setState(() {
          selectedLat = result.first.latitude;
          selectedLng = result.first.longitude;
        });
      }
    } catch (_) {} finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // ============================
  // 🗺 MAP PICKER
  // ============================
  Future<void> pickLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(
          initialLat: selectedLat,
          initialLng: selectedLng,
        ),
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

  // ============================
  // 💾 SAVE JOB (API)
  // ============================
  Future<void> saveJob() async {
    if (titleController.text.trim().isEmpty) return;
    if (technicianId == null) return;

    final response = await ApiService.createJob({
      "title": titleController.text.trim(),
      "customer": customerController.text.trim(),
      "location": locationController.text.trim(),
      "technician_id": technicianId,
      "priority": priority,
      "status": "Pending",
      "lat": selectedLat,
      "lng": selectedLng,
    });

    if (response['status'] == true) {
      widget.onSaved();

      if (mounted) Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? "Failed")),
      );
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
              buildTextField(titleController, "Enter job title", scale),

              SizedBox(height: 16 * scale),

              sectionTitle("CUSTOMER NAME"),
              buildTextField(customerController, "Enter customer name", scale),

              SizedBox(height: 16 * scale),

              sectionTitle("LOCATION"),
              buildLocationField(scale),

              SizedBox(height: 12 * scale),

              GestureDetector(onTap: pickLocation, child: mapCard(scale)),

              SizedBox(height: 16 * scale),

              sectionTitle("ASSIGN TECHNICIAN"),
              buildTechnicianDropdown(scale),

              SizedBox(height: 16 * scale),

              sectionTitle("PRIORITY LEVEL"),
              Row(
                children: [
                  Expanded(child: priorityButton("Low", scale)),
                  SizedBox(width: 8 * scale),
                  Expanded(child: priorityButton("Medium", scale)),
                  SizedBox(width: 8 * scale),
                  Expanded(child: priorityButton("High", scale)),
                ],
              ),

              SizedBox(height: 30 * scale),

              buildActionButton(
                "Save Job",
                primaryBlue,
                Colors.white,
                scale,
                saveJob,
              ),

              SizedBox(height: 12 * scale),

              buildActionButton(
                "Cancel",
                greyBoxColor,
                blackText,
                scale,
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

  Widget buildTextField(
      TextEditingController controller, String hint, double s) {
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

  Widget buildLocationField(double s) {
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
              ? const CircularProgressIndicator()
              : Icon(Icons.search, color: primaryBlue),
        ),
      ),
    );
  }

  Widget mapCard(double s) {
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

  Widget buildTechnicianDropdown(double s) {
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
              value: int.parse(e["id"].toString()),
              child: Text(e["name"]),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              technicianId = value;
            });
          },
        ),
      ),
    );
  }

  Widget priorityButton(String value, double s) {
    final active = priority == value;

    return GestureDetector(
      onTap: () {
        setState(() => priority = value);
      },
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: active ? primaryBlue : greyBoxColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            value,
            style: TextStyle(
              color: active ? Colors.white : blackText,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildActionButton(
      String label, Color bg, Color text, double s, VoidCallback tap) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: tap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
        ),
        child: Text(label),
      ),
    );
  }
}