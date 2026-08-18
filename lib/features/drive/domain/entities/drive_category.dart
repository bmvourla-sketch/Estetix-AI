/// The four Estetix Drive folder categories (mirror the AI transform modules).
enum DriveCategory {
  outdoor('outdoor'),
  interior('interior'),
  fashion('fashion'),
  diet('diet');

  const DriveCategory(this.wire);

  /// Path segment used in Supabase Storage and the transform-engine API.
  final String wire;
}
