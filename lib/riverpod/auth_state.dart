class AuthState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? user;
  final String? otpEmail;
  final String? otp;

  AuthState({
    this.isLoading = false,
    this.error,
    this.user,
    this.otpEmail,
    this.otp,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? user,
    String? otpEmail,
    String? otp,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
      otpEmail: otpEmail ?? this.otpEmail,
      otp: otp ?? this.otp,
    );
  }
}
