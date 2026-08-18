import '../entities/health_profile.dart';

/// Reads and writes the user's stored health profile.
abstract interface class HealthProfileRepository {
  Future<HealthProfile?> getProfile(String userId);
  Future<void> saveProfile(String userId, HealthProfile profile);
}
