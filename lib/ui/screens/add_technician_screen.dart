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

    if (name.isEmpty) {
      return showMsg("Enter technician name");
    }

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
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: AppUI.screen,
          child: ListView(
            children: [
              const SizedBox(height: 8),

              const Text(
                "Add Technician",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Create and manage your field workforce",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),

              const SizedBox(height: 30),

              inputField(controller: nameController, hint: "Full Name"),

              const SizedBox(height: 18),

              inputField(
                controller: emailController,
                hint: "Email Address",
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 18),

              passwordField(),

              const SizedBox(height: 18),

              inputField(
                controller: phoneController,
                hint: "Phone Number",
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 18),

              dropdownField(),

              const SizedBox(height: 30),

              actionButton(
                title: "Save Technician",
                primary: true,
                onTap: isLoading ? null : saveTechnician,
              ),

              const SizedBox(height: 14),

              actionButton(
                title: "Cancel",
                primary: false,
                onTap: () => Navigator.pop(context),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget inputField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
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
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.black, fontSize: 18),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black54, fontSize: 18),
          ),
        ),
      ),
    );
  }

  Widget passwordField() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: TextField(
          controller: passwordController,
          obscureText: obscurePassword,
          style: const TextStyle(color: Colors.black, fontSize: 18),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Password",
            hintStyle: const TextStyle(color: Colors.black54, fontSize: 18),
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.black54,
              ),
              onPressed: () {
                setState(() {
                  obscurePassword = !obscurePassword;
                });
              },
            ),
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
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: role,
          isExpanded: true,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(16),
          style: const TextStyle(color: Colors.black, fontSize: 18),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.black54,
          ),
          items: roles.map((item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: (value) {
            setState(() {
              role = value!;
            });
          },
        ),
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
        height: 58,
        decoration: BoxDecoration(
          color: primary ? AppColors.primary : const Color(0xFFEDEDED),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: isLoading && primary
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primary ? Colors.white : Colors.black,
                  ),
                ),
        ),
      ),
    );
  }
}
