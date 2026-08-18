import 'dart:typed_data';

import '../entities/wardrobe_item.dart';

/// Stores and lists the user's wardrobe photos.
abstract interface class WardrobeRepository {
  Future<List<WardrobeItem>> list(String userId);

  Future<WardrobeItem> add(
    String userId,
    String category,
    Uint8List bytes,
    String fileName,
  );

  Future<void> delete(String id);
}
