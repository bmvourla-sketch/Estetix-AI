/// A liked transformation result saved as a reusable "look".
class SavedLook {
  const SavedLook({
    required this.id,
    required this.module,
    required this.renderUrl,
    required this.summary,
    required this.createdAt,
  });

  final String id;
  final String module;
  final String renderUrl;
  final String summary;
  final DateTime createdAt;

  factory SavedLook.fromJson(Map<String, dynamic> json) => SavedLook(
        id: json['id'] as String? ?? '',
        module: json['module'] as String? ?? '',
        renderUrl: json['render_url'] as String? ?? '',
        summary: json['summary'] as String? ?? '',
        createdAt:
            DateTime.tryParse(json['created_at'] as String? ?? '') ??
                DateTime.now(),
      );
}
