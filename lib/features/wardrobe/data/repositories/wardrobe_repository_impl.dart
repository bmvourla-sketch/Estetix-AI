import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/wardrobe_item.dart';
import '../../domain/repositories/wardrobe_repository.dart';

/// Concrete [WardrobeRepository]: uploads photos to the `input-images` bucket
/// and stores their public URL in `wardrobe_items`.
class WardrobeRepositoryImpl implements WardrobeRepository {
  WardrobeRepositoryImpl(this._client);

  final SupabaseClient _client;

  static const String _bucket = 'input-images';

  @override
  Future<List<WardrobeItem>> list(String userId) async {
    final List<Map<String, dynamic>> data = await _client
        .from('wardrobe_items')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return data.map(WardrobeItem.fromJson).toList();
  }

  @override
  Future<WardrobeItem> add(
    String userId,
    String category,
    Uint8List bytes,
    String fileName,
  ) async {
    final String ext = fileName.contains('.')
        ? fileName.split('.').last.toLowerCase()
        : 'jpg';
    final String path =
        'wardrobe/$userId/${DateTime.now().microsecondsSinceEpoch}.$ext';
    await _client.storage.from(_bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: _mime(ext)),
        );
    final String url = _client.storage.from(_bucket).getPublicUrl(path);

    final Map<String, dynamic> row = await _client
        .from('wardrobe_items')
        .insert(<String, dynamic>{
          'user_id': userId,
          'category': category,
          'image_url': url,
        })
        .select()
        .single();
    return WardrobeItem.fromJson(row);
  }

  @override
  Future<void> delete(String id) async {
    await _client.from('wardrobe_items').delete().eq('id', id);
  }

  String _mime(String ext) => ext == 'png' ? 'image/png' : 'image/jpeg';
}
