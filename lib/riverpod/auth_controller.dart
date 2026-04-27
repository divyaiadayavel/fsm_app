import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

import '../data/services/api_service.dart'; // ✅ ADDED
import 'auth_state.dart';

/// ✅ PROVIDER
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController();
  },
);

class AuthController extends StateNotifier<AuthState> {
  AuthController() : super(AuthState());

  // ==============================
  // 🔐 LOGIN (NOW USING API)
  // ==============================
  Future<bool> login(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await ApiService.login(email, password);

      if (response['status'] == true) {
        state = state.copyWith(
          isLoading: false,
          user: response['data'], // from backend
        );
        return true;
      }

      state = state.copyWith(
        isLoading: false,
        error: response['message'] ?? "Login failed",
      );

      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // ==============================
  // 📩 SEND OTP (KEEP SAME)
  // ==============================
  Future<bool> sendOtp(String email) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final otp = (100000 + Random().nextInt(900000)).toString();

      const username = 'divyaidayavel2001@gmail.com';
      const password = 'dobt wzzc ugli xlum';

      final smtpServer = gmail(username, password);

      final message = Message()
        ..from = Address(username, 'FSM App')
        ..recipients.add(email)
        ..subject = 'OTP Verification'
        ..text = 'Your OTP is: $otp';

      await send(message, smtpServer);

      state = state.copyWith(isLoading: false, otp: otp, otpEmail: email);

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // ==============================
  // 🔢 VERIFY OTP
  // ==============================
  bool verifyOtp(String email, String otp) {
    return state.otp == otp && state.otpEmail == email;
  }

  // ==============================
  // 🔑 RESET PASSWORD (OPTIONAL API LATER)
  // ==============================
  Future<bool> resetPassword(String email, String newPassword) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // 🔴 CURRENTLY LOCAL REMOVED (NO DB)
      // 👉 Later you can connect API here

      state = state.copyWith(isLoading: false, otp: null, otpEmail: null);

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // ==============================
  // 🚪 LOGOUT
  // ==============================
  void logout() {
    state = AuthState();
  }
}