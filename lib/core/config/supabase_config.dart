/// Supabase project configuration.
///
/// The project URL and publishable key are client-safe (the publishable key is
/// shipped to every client by design). Override via `--dart-define` if needed:
///
///   flutter run \
///     --dart-define=SUPABASE_URL=https://YOUR-PROJECT.supabase.co \
///     --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR-PUBLISHABLE-KEY
///
/// NEVER put the Supabase secret/service-role key here — it belongs only in
/// the Edge Function environment (see supabase/functions/transform-engine).
abstract final class SupabaseConfig {
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://nmvoakaaaktqykdwfsrl.supabase.co',
  );

  static const String publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'sb_publishable_lCWCJvddnc9aXeiGdpQ5YA_7yor21HD',
  );
}
