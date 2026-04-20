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
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();

  String role = "Manager";
  bool isLoading = false;
  bool obscurePassword = true;

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> saveTechnician() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty) return showMsg("Enter technician name");

    if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(email)) {
      return showMsg("Enter valid email");
    }

    if (password.isEmpty) {
      return showMsg("Enter password");
    }

    if (password.length < 6) {
      return showMsg("Password must be at least 6 characters");
    }

    if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
      return showMsg("Enter valid 10 digit phone");
    }

    setState(() => isLoading = true);

    await widget.onSave({
      "name": name,
      "email": email,
      "password": password,
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
              const Text(
                "Add Technician",
                style: TextStyle(
                  fontSize: AppUI.title,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: AppUI.gapMd),
              const Text(
                "Create and manage your field workforce",
                style: TextStyle(color: Color(0xFF6B7280)),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppUI.radiusLg),
      ),
      child: Column(
        children: [
          inputField(nameController, "Full Name"),
          const SizedBox(height: AppUI.gapSm),
          inputField(emailController, "Email Address"),
          const SizedBox(height: AppUI.gapSm),

          /// ✅ FIXED PASSWORD FIELD
          passwordField(),

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
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(AppUI.radiusSm),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
          border: InputBorder.none,
        ),
      ),
    );
  }

  /// ✅ NEW PASSWORD FIELD
  Widget passwordField() {
    return Container(
      height: AppUI.inputHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(AppUI.radiusSm),
      ),
      child: TextField(
        controller: passwordController,
        obscureText: obscurePassword,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: "Password",
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(
              obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                obscurePassword = !obscurePassword;
              });
            },
          ),
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
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(AppUI.radiusSm),
      ),
      child: DropdownButton<String>(
        value: role,
        underline: const SizedBox(),
        dropdownColor: Colors.white,
        isExpanded: true,
        style: const TextStyle(color: Colors.black),
        items: roles
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) => setState(() => role = v!),
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
          color: primary ? AppColors.primary : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(AppUI.radiusMd),
        ),
        child: Center(
          child: isLoading && primary
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primary ? Colors.white : Colors.black,
                  ),
                ),
        ),
      ),
    );
  }
}
