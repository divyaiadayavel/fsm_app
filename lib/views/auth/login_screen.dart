import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/validators.dart';
import '../../riverpod/auth_controller.dart';

import '../../data/services/api_service.dart';
import '../../ui/screens/main_navigation.dart';
import '../../ui/screens/technician_dashboard_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();

  bool hidePassword = true;
  bool rememberMe = false;

  bool validateEmailNow = false;
  bool validatePasswordNow = false;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    emailFocus.addListener(() {
      if (!emailFocus.hasFocus) {
        setState(() {
          validateEmailNow = true;
        });
        formKey.currentState?.validate();
      }
    });

    passwordFocus.addListener(() {
      if (!passwordFocus.hasFocus) {
        setState(() {
          validatePasswordNow = true;
        });
        formKey.currentState?.validate();
      }
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  // ==========================
  // LOGIN (MERGED FINAL)
  // ==========================
  Future<void> login() async {
    setState(() {
      validateEmailNow = true;
      validatePasswordNow = true;
    });

    if (!formKey.currentState!.validate()) return;

    final auth = ref.read(authControllerProvider.notifier);

    setState(() => isLoading = true);

    // ✅ CALL BOTH (to keep your provider logic intact)
    final success = await auth.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    // ✅ ALSO GET API RESPONSE DIRECTLY (NO SQLITE)
    final res = await ApiService.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (!mounted) return;

    setState(() => isLoading = false);

    // ==========================
    // SUCCESS
    // ==========================
    if (success && res['status'] == true && res['data'] != null) {
      final user = res['data'] as Map<String, dynamic>;

      // ✅ ADMIN
      if (user["role"] == "admin") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      }
      // ✅ TECHNICIAN
      else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => TechnicianDashboardScreen(
              technicianId: int.tryParse(user["id"].toString()),
              technicianName: user["name"] ?? "Technician",
            ),
          ),
        );
      }
    } else {
      final error =
          res['message'] ??
          ref.read(authControllerProvider).error ??
          "Login failed";

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "FSM Login",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Sign in to continue",
                      style: TextStyle(fontSize: 15, color: Colors.black54),
                    ),
                    const SizedBox(height: 30),

                    const Text(
                      "Email Address",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: emailController,
                      focusNode: emailFocus,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                      autovalidateMode: validateEmailNow
                          ? AutovalidateMode.always
                          : AutovalidateMode.disabled,
                      validator: (v) => Validators.validateEmail(v ?? ""),
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(passwordFocus);
                      },
                      decoration: inputDecoration(
                        "Enter your email",
                        Icons.email_outlined,
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      "Password",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: passwordController,
                      focusNode: passwordFocus,
                      obscureText: hidePassword,
                      textInputAction: TextInputAction.done,
                      autovalidateMode: validatePasswordNow
                          ? AutovalidateMode.always
                          : AutovalidateMode.disabled,
                      validator: (v) => Validators.validatePassword(v ?? ""),
                      decoration: inputDecoration(
                        "Enter your password",
                        Icons.lock_outline,
                        suffix: IconButton(
                          icon: Icon(
                            hidePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              hidePassword = !hidePassword;
                            });
                          },
                        ),
                      ),
                      onFieldSubmitted: (_) => login(),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Checkbox(
                          value: rememberMe,
                          activeColor: AppColors.primary,
                          onChanged: (v) {
                            setState(() {
                              rememberMe = v ?? false;
                            });
                          },
                        ),
                        const Text("Remember me"),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: (authState.isLoading || isLoading)
                            ? null
                            : login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: (authState.isLoading || isLoading)
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "LOGIN",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration inputDecoration(
    String hint,
    IconData icon, {
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black45),
      prefixIcon: Icon(icon, color: Colors.black54),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
      ),
    );
  }
}
