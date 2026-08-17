import '../entities/user_profile.dart';

/// Abstract contract for the home feature's data access.
abstract interface class HomeRepository {
  Future<UserProfile> fetchCurrentUser();
}
