/// Authenticated user as understood by the presentation/domain layer.
class AppUser {
  const AppUser({required this.id, required this.phoneNumber});

  final String id;
  final String phoneNumber;
}
