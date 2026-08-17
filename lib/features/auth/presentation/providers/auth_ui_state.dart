import '../../domain/entities/app_user.dart';

enum AuthStatus { unauthenticated, awaitingOtp, authenticated }

/// Immutable presentation state for the auth flow.
class AuthUiState {
  const AuthUiState({
    this.status = AuthStatus.unauthenticated,
    this.user,
    this.phone,
    this.isLoading = false,
    this.error,
  });

  final AuthStatus status;
  final AppUser? user;
  final String? phone;
  final bool isLoading;
  final String? error;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthUiState copyWith({
    AuthStatus? status,
    AppUser? user,
    String? phone,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearPhone = false,
  }) {
    return AuthUiState(
      status: status ?? this.status,
      user: user ?? this.user,
      phone: clearPhone ? null : (phone ?? this.phone),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
