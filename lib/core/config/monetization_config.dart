/// Monetization configuration (RevenueCat + AdMob).
///
/// All production secrets are fed via `--dart-define` (see
/// scripts/build_prod.ps1 and .env.production.example). Defaults are empty or
/// Google's public *test* placements, so a debug build never ships a real key.
///
///   flutter run \
///     --dart-define=REVENUECAT_APPLE_KEY=appl_xxx \
///     --dart-define=REVENUECAT_GOOGLE_KEY=googl_xxx \
///     --dart-define=REWARDED_AD_UNIT_ID=ca-app-pub-xxx \
///     --dart-define=INTERSTITIAL_AD_UNIT_ID=ca-app-pub-xxx
abstract final class MonetizationConfig {
  /// RevenueCat Apple API key (App Store). `appl_...`
  static const String revenueCatAppleApiKey = String.fromEnvironment(
    'REVENUECAT_APPLE_KEY',
    defaultValue: '',
  );

  /// RevenueCat Google Play API key. `googl_...`
  static const String revenueCatGoogleApiKey = String.fromEnvironment(
    'REVENUECAT_GOOGLE_KEY',
    defaultValue: '',
  );

  /// Legacy single-key fallback (kept for backwards compatibility).
  static const String revenueCatApiKey = String.fromEnvironment(
    'REVENUECAT_API_KEY',
    defaultValue: '',
  );

  static const String rewardedAdUnitId = String.fromEnvironment(
    'REWARDED_AD_UNIT_ID',
    defaultValue: 'ca-app-pub-3940256099942544/5224354917',
  );

  static const String interstitialAdUnitId = String.fromEnvironment(
    'INTERSTITIAL_AD_UNIT_ID',
    defaultValue: 'ca-app-pub-3940256099942544/1033173712',
  );

  /// Master switch — set false to disable ads/purchases entirely (e.g. tests).
  static const bool enabled = bool.fromEnvironment(
    'MONETIZATION_ENABLED',
    defaultValue: true,
  );
}
