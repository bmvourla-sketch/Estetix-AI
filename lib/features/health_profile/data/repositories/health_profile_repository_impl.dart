import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/health_profile.dart';
import '../../domain/repositories/health_profile_repository.dart';

/// Concrete [HealthProfileRepository] backed by `profiles` columns (RLS lets
/// each user read/update their own row).
class HealthProfileRepositoryImpl implements HealthProfileRepository {
  HealthProfileRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<HealthProfile?> getProfile(String userId) async {
    final Object? data = await _client
        .from('profiles')
        .select('age, height_cm, weight_kg, health_conditions, goal')
        .eq('id', userId)
        .maybeSingle();
    if (data == null) return null;
    return HealthProfile.fromJson(Map<String, dynamic>.from(data as Map));
  }

  @override
  Future<void> saveProfile(String userId, HealthProfile profile) async {
    await _client
        .from('profiles')
        .update(profile.toJson())
        .eq('id', userId);
  }
}
