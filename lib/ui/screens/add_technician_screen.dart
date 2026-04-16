import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_ui.dart';

class AddTechnicianScreen extends StatefulWidget {
  final Future<void> Function(Map<String, dynamic>) onSave;

  const AddTechnicianScreen({super.key, required this.onSave});

  @override
  State<AddTechnicianScreen> createState() => _AddTechnicianScreenState();
}

class _AddTechnicianScreenState extends State<AddTechnicianScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  String role = "Manager";
  bool isLoading = false;

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> saveTechnician() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty) {
      showMsg("Enter technician name");
      return;
    }

    final emailValid = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(email);

    if (!emailValid) {
      showMsg("Enter valid email");
      return;
    }

    final phoneValid = RegExp(r'^[0-9]{10}$').hasMatch(phone);

    if (!phoneValid) {
      showMsg("Enter valid 10 digit phone");
      return;
    }

    setState(() => isLoading = true);

    await widget.onSave({
      "name": name,
      "email": email,
      "phone": phone,
      "role": role,
      "jobs": 0,
      "online": 1,
    });

    if (mounted) {
      setState(() => isLoading = false);
      Navigator.pop(context, true);
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
              const SizedBox(height: AppUI.gapSm),

              const Text(
                "Add Technician",
                style: TextStyle(
                  fontSize: AppUI.title,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: AppUI.gapMd),

              const Text(
                "Create and manage your field workforce",
                style: TextStyle(fontSize: AppUI.body, color: Colors.white70),
              ),

              const SizedBox(height: AppUI.gapLg),

              card(),
            ],
          ),
        ),
      ),
    );
  }

  Widget card() {
    return Container(
      padding: AppUI.card,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppUI.radiusLg),
      ),
      child: Column(
        children: [
          inputField(nameController, "Full Name"),
          const SizedBox(height: AppUI.gapSm),

          inputField(emailController, "Email Address"),
          const SizedBox(height: AppUI.gapSm),

          inputField(phoneController, "Phone Number"),
          const SizedBox(height: AppUI.gapSm),

          dropdownField(),
          const SizedBox(height: AppUI.gapLg),

          actionButton(
            title: "Save Technician",
            primary: true,
            onTap: isLoading ? null : saveTechnician,
          ),

          const SizedBox(height: AppUI.gapSm),

          actionButton(
            title: "Cancel",
            primary: false,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget inputField(TextEditingController controller, String hint) {
    return Container(
      height: AppUI.inputHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(AppUI.radiusSm),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: AppUI.body),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Colors.white54,
            fontSize: AppUI.body,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget dropdownField() {
    final roles = [
      "Manager",
      "Senior Technician",
      "Junior Technician",
      "Labour",
    ];

    return Container(
      height: AppUI.inputHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(AppUI.radiusSm),
      ),
      child: DropdownButton<String>(
        value: role,
        underline: const SizedBox(),
        dropdownColor: AppColors.card,
        isExpanded: true,
        style: const TextStyle(color: Colors.white, fontSize: AppUI.body),
        items: roles
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) {
          setState(() => role = v!);
        },
      ),
    );
  }

  Widget actionButton({
    required String title,
    required bool primary,
    required VoidCallback? onTap,
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
          child: isLoading && primary
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  title,
                  style: const TextStyle(
                    fontSize: AppUI.body,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
