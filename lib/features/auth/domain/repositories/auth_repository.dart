import '../entities/app_user.dart';

/// Abstract contract for phone/SMS-OTP authentication.
abstract interface class AuthRepository {
  /// Currently signed-in user, or null.
  AppUser? get currentUser;

  /// Emits the signed-in user whenever the session changes.
  Stream<AppUser?> get authStateChanges;

  /// Sends a one-time password to [phoneNumber].
  Future<void> signInWithPhone(String phoneNumber);

  /// Verifies the OTP and, for first-time users, provisions a profile row with
  /// the device fingerprint and default wallet values.
  Future<AppUser> verifyOtp({
    required String phone,
    required String token,
    required String deviceUuid,
  });

  Future<void> signOut();
}
