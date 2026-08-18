/// A photographed wardrobe item (clothing or a self photo).
class WardrobeItem {
  const WardrobeItem({
    required this.id,
    required this.category,
    required this.imageUrl,
    required this.createdAt,
  });

  final String id;
  final String category;
  final String imageUrl;
  final DateTime createdAt;

  factory WardrobeItem.fromJson(Map<String, dynamic> json) => WardrobeItem(
        id: json['id'] as String? ?? '',
        category: json['category'] as String? ?? '',
        imageUrl: json['image_url'] as String? ?? '',
        createdAt:
            DateTime.tryParse(json['created_at'] as String? ?? '') ??
                DateTime.now(),
      );
}
