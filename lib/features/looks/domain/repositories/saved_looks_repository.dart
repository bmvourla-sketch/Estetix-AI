import '../entities/saved_look.dart';

/// Stores and lists the user's saved looks.
abstract interface class SavedLooksRepository {
  Future<List<SavedLook>> list(String userId);

  Future<void> save(
    String userId,
    String module,
    String renderUrl,
    String summary,
  );

  Future<void> delete(String id);
}
