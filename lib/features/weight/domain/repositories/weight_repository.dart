import '../entities/weight_entry.dart';

/// Stores and lists the user's weight log.
abstract interface class WeightRepository {
  Future<List<WeightEntry>> list(String userId);

  Future<void> add(String userId, double weightKg);
}
