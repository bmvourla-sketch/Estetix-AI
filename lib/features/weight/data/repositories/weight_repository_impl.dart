import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/weight_entry.dart';
import '../../domain/repositories/weight_repository.dart';

/// Concrete [WeightRepository] backed by `weight_entries` (RLS).
class WeightRepositoryImpl implements WeightRepository {
  WeightRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<List<WeightEntry>> list(String userId) async {
    final List<Map<String, dynamic>> data = await _client
        .from('weight_entries')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: true);
    return data.map(WeightEntry.fromJson).toList();
  }

  @override
  Future<void> add(String userId, double weightKg) async {
    await _client.from('weight_entries').insert(<String, dynamic>{
      'user_id': userId,
      'weight_kg': weightKg,
    });
  }
}
