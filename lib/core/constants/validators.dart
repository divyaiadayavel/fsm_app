class Validators {
  // =========================
  // EMAIL VALIDATION
  // =========================
  static String? validateEmail(String value) {
    if (value.trim().isEmpty) {
      return "Email is required";
    }

    final emailRegex = RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return "Enter a valid email address";
    }

    return null;
  }

  // =========================
  // PASSWORD VALIDATION
  // =========================
  static String? validatePassword(String value) {
    if (value.trim().isEmpty) {
      return "Password is required";
    }

    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }

    return null;
  }

  // =========================
  // CONFIRM PASSWORD
  // =========================
  static String? validateConfirmPassword(
    String password,
    String confirmPassword,
  ) {
    if (confirmPassword.trim().isEmpty) {
      return "Confirm password is required";
    }

    if (password != confirmPassword) {
      return "Passwords do not match";
    }

    return null;
  }

  // =========================
  // OTP VALIDATION
  // =========================
  static String? validateOtp(String value) {
    if (value.trim().isEmpty) {
      return "OTP is required";
    }

    if (value.length != 6) {
      return "OTP must be 6 digits";
    }

    return null;
  }
}
