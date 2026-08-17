import '../repositories/home_repository.dart';

/// Returns the current user's display name.
class GetWelcomeMessage {
  const GetWelcomeMessage(this._repository);

  final HomeRepository _repository;

  Future<String> call() async {
    final user = await _repository.fetchCurrentUser();
    return user.name;
  }
}
