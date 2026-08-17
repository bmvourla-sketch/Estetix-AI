/// The three Estetix Drive folder categories (mirror the AI transform modules).
enum DriveCategory {
  space('space'),
  wardrobe('wardrobe'),
  kitchen('kitchen');

  const DriveCategory(this.wire);

  /// Path segment used in Supabase Storage and the transform-engine API.
  final String wire;
}
