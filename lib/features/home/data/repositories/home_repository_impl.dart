import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/home_repository.dart';

/// Concrete [HomeRepository].
///
/// In a real app this would delegate to a remote API client or a local
/// database (see `data/datasources/`). Here it simulates a fetch.
class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl();

  @override
  Future<UserProfile> fetchCurrentUser() async {
    // Placeholder for a remote/local data source call.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return const UserProfile(name: 'Estetix');
  }
}
