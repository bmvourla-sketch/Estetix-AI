import 'drive_category.dart';

/// A saved project in Estetix Drive (one PDF report + preview images).
class DriveProject {
  const DriveProject({
    required this.id,
    required this.category,
    required this.createdAt,
    required this.originalImageUrl,
    required this.renderImageUrl,
    required this.pdfUrl,
    required this.sizeMb,
  });

  final String id;
  final DriveCategory category;
  final DateTime createdAt;
  final String originalImageUrl;
  final String renderImageUrl;
  final String pdfUrl;

  /// Total size (MB) of the files stored for this project.
  final double sizeMb;
}
