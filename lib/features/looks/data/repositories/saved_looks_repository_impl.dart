import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/saved_look.dart';
import '../../domain/repositories/saved_looks_repository.dart';

/// Concrete [SavedLooksRepository] backed by `saved_looks` (RLS).
class SavedLooksRepositoryImpl implements SavedLooksRepository {
  SavedLooksRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<List<SavedLook>> list(String userId) async {
    final List<Map<String, dynamic>> data = await _client
        .from('saved_looks')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return data.map(SavedLook.fromJson).toList();
  }

  @override
  Future<void> save(
    String userId,
    String module,
    String renderUrl,
    String summary,
  ) async {
    await _client.from('saved_looks').insert(<String, dynamic>{
      'user_id': userId,
      'module': module,
      'render_url': renderUrl,
      'summary': summary,
    });
  }

  @override
  Future<void> delete(String id) async {
    await _client.from('saved_looks').delete().eq('id', id);
  }
}
