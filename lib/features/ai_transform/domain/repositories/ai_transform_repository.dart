import '../entities/transformation_result.dart';

/// Abstract contract for the AI transform pipeline.
abstract interface class AiTransformRepository {
  /// Picks a photo from the gallery or camera; null if the user cancels.
  Future<PickedImage?> pickImage(PickSource source);

  /// Uploads the photo to Supabase Storage (`input-images`) and returns its
  /// public URL.
  Future<String> uploadInputImage(PickedImage image);

  /// Invokes the transform-engine Edge Function.
  Future<List<TransformationResult>> transform({
    required String imageUrl,
    required TransformModule module,
    required TransformStyle style,
    required bool isPremium,
    String? mode,
    String? healthNotes,
    String? context,
  });
}
