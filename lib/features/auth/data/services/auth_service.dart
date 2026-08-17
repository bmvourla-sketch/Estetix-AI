import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Concrete [AuthRepository] backed by Supabase Auth + the `profiles` table.
class AuthService implements AuthRepository {
  AuthService(this._client);

  final SupabaseClient _client;

  @override
  AppUser? get currentUser => _mapUser(_client.auth.currentUser);

  @override
  Stream<AppUser?> get authStateChanges => _client.auth.onAuthStateChange
      .map((AuthState authState) => _mapUser(authState.session?.user));

  @override
  Future<void> signInWithPhone(String phoneNumber) async {
    await _client.auth.signInWithOtp(phone: phoneNumber);
  }

  @override
  Future<AppUser> verifyOtp({
    required String phone,
    required String token,
    required String deviceUuid,
  }) async {
    final AuthResponse response = await _client.auth.verifyOTP(
      phone: phone,
      token: token,
      type: OtpType.sms,
    );

    final User? user = response.session?.user ?? _client.auth.currentUser;
    if (user == null) {
      throw const AuthException('Verification failed: no user returned.');
    }

    await _ensureProfile(
      userId: user.id,
      phone: user.phone ?? phone,
      deviceUuid: deviceUuid,
    );

    return AppUser(id: user.id, phoneNumber: user.phone ?? phone);
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Upserts only identity columns so first-time users get the column defaults
  /// (token_balance 1, storage 0/50) while returning users keep their balances.
  Future<void> _ensureProfile({
    required String userId,
    required String phone,
    required String deviceUuid,
  }) async {
    await _client.from('profiles').upsert({
      'id': userId,
      'phone_number': phone,
      'device_uuid': deviceUuid,
    }, onConflict: 'id');
  }

  AppUser? _mapUser(User? user) {
    if (user == null) return null;
    return AppUser(id: user.id, phoneNumber: user.phone ?? '');
  }
}
