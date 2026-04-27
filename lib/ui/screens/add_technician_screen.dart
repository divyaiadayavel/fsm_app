import 'package:flutter/material.dart';

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

  // COLORS MATCHING YOUR IMAGE
  final Color greyBoxColor = const Color(
    0xFFF2F2F2,
  ); // Consistent grey for all boxes
  final Color primaryBlue = const Color(
    0xFF4C61EE,
  ); // Vibrant blue for Save button
  final Color blackTextColor = Colors.black;
  final Color greyTextColor = Colors.black54;

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
              SizedBox(height: 30 * scale),
              Text(
                "Add Technician",
                style: TextStyle(
                  fontSize: 26 * scale,
                  fontWeight: FontWeight.bold,
                  color: blackTextColor,
                ),
              ),
              SizedBox(height: 8 * scale),
              Text(
                "Create and manage your field workforce",
                style: TextStyle(fontSize: 15 * scale, color: greyTextColor),
              ),
              SizedBox(height: 30 * scale),

              // NAME FIELD
              buildInputField(
                controller: nameController,
                hint: "Full Name",
                icon: Icons.person_outline_rounded,
                scale: scale,
              ),
              SizedBox(height: 16 * scale),

              // EMAIL FIELD
              buildInputField(
                controller: emailController,
                hint: "Email Address",
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                scale: scale,
              ),
              SizedBox(height: 16 * scale),

              // PASSWORD FIELD
              buildPasswordField(scale),
              SizedBox(height: 16 * scale),

              // PHONE FIELD
              buildInputField(
                controller: phoneController,
                hint: "Phone Number",
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                scale: scale,
              ),
              SizedBox(height: 16 * scale),

              // DROPDOWN (MANAGER)
              buildDropdownField(scale),

              SizedBox(height: 35 * scale),

              // SAVE BUTTON (Blue)
              buildActionButton(
                "Save Technician",
                primaryBlue,
                Colors.white,
                scale,
                () {},
              ),

              SizedBox(height: 12 * scale),

              // CANCEL BUTTON (Grey - Matching Input Fields)
              buildActionButton(
                "Cancel",
                greyBoxColor,
                blackTextColor,
                scale,
                () {
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: 20 * scale),
            ],
          ),
        ),
      ),
    );
  }

  // --- COMPONENT HELPERS ---

  Widget buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required double scale,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: blackTextColor, fontSize: 16 * scale),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: greyTextColor, fontSize: 16 * scale),
        prefixIcon: Icon(icon, color: greyTextColor, size: 22 * scale),
        filled: true,
        fillColor: greyBoxColor, // This adds the grey box background
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none, // Removes the line border
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 18 * scale),
      ),
    );
  }

  Widget buildPasswordField(double scale) {
    return TextField(
      controller: passwordController,
      obscureText: obscurePassword,
      style: TextStyle(color: blackTextColor, fontSize: 16 * scale),
      decoration: InputDecoration(
        hintText: "Password",
        hintStyle: TextStyle(color: greyTextColor, fontSize: 16 * scale),
        prefixIcon: Icon(
          Icons.lock_outline_rounded,
          color: greyTextColor,
          size: 22 * scale,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: greyTextColor,
            size: 20 * scale,
          ),
          onPressed: () => setState(() => obscurePassword = !obscurePassword),
        ),
        filled: true,
        fillColor: greyBoxColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 18 * scale),
      ),
    );
  }

  Widget buildDropdownField(double scale) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * scale),
      decoration: BoxDecoration(
        color: greyBoxColor, // Matching grey box
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: role,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: greyTextColor),
          items: ["Manager", "Technician", "Labour"]
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    style: TextStyle(
                      color: blackTextColor,
                      fontSize: 16 * scale,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (val) => setState(() => role = val!),
        ),
      ),
    );
  }

  Widget buildActionButton(
    String label,
    Color bg,
    Color text,
    double scale,
    VoidCallback tap,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 56 * scale,
      child: ElevatedButton(
        onPressed: tap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: text,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 16 * scale, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
