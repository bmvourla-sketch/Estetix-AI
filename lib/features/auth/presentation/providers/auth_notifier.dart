import 'dart:async';

import 'package:state_notifier/state_notifier.dart';

import '../../../../core/services/device_service.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_ui_state.dart';

/// Drives the phone/SMS-OTP flow and mirrors the Supabase session.
class AuthNotifier extends StateNotifier<AuthUiState> {
  AuthNotifier(this._authRepository, this._deviceService)
      : super(_initialState(_authRepository.currentUser)) {
    _subscription = _authRepository.authStateChanges.listen(_onAuthState);
  }

  final AuthRepository _authRepository;
  final DeviceService _deviceService;
  StreamSubscription<AppUser?>? _subscription;

  static AuthUiState _initialState(AppUser? user) => user == null
      ? const AuthUiState()
      : AuthUiState(status: AuthStatus.authenticated, user: user);

  void _onAuthState(AppUser? user) {
    state = user == null
        ? const AuthUiState()
        : AuthUiState(status: AuthStatus.authenticated, user: user);
  }

  Future<void> signInWithPhone(String phone) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authRepository.signInWithPhone(phone);
      state = state.copyWith(
        status: AuthStatus.awaitingOtp,
        phone: phone,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> verifyOtp(String code) async {
    final String? phone = state.phone;
    if (phone == null) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final String deviceUuid = await _deviceService.getDeviceUuid();
      final AppUser user = await _authRepository.verifyOtp(
        phone: phone,
        token: code,
        deviceUuid: deviceUuid,
      );
      state = AuthUiState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
    } finally {
      state = const AuthUiState();
    }
  }

  /// Returns the flow to the phone-entry step (e.g. "change number").
  void reset() {
    state = const AuthUiState();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
