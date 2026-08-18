/// Monetization configuration (RevenueCat + AdMob).
///
/// All production secrets are fed via `--dart-define` (see
/// scripts/build_prod.ps1 and .env.production.example.json). The defaults below
/// are the RevenueCat *sandbox/test* key (safe to share) and Google's public
/// *test* AdMob placements, so `flutter run` works out of the box in dev.
///
///   flutter run \
///     --dart-define=REVENUECAT_APPLE_KEY=appl_xxx \
///     --dart-define=REVENUECAT_GOOGLE_KEY=googl_xxx \
///     --dart-define=REWARDED_AD_UNIT_ID=ca-app-pub-xxx \
///     --dart-define=INTERSTITIAL_AD_UNIT_ID=ca-app-pub-xxx
abstract final class MonetizationConfig {
  /// RevenueCat Apple API key (App Store). `appl_...` in production.
  static const String revenueCatAppleApiKey = String.fromEnvironment(
    'REVENUECAT_APPLE_KEY',
    defaultValue: 'test_tWYXGoXguKpoCuKYqAzrbwmuEkD',
  );

  /// RevenueCat Google Play API key. `googl_...` in production.
  static const String revenueCatGoogleApiKey = String.fromEnvironment(
    'REVENUECAT_GOOGLE_KEY',
    defaultValue: 'test_tWYXGoXguKpoCuKYqAzrbwmuEkD',
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

  static const String bannerAdUnitId = String.fromEnvironment(
    'ADMOB_BANNER_ID',
    defaultValue: 'ca-app-pub-3940256099942544/6300978111',
  );

  /// Master switch — set false to disable ads/purchases entirely (e.g. tests).
  static const bool enabled = bool.fromEnvironment(
    'MONETIZATION_ENABLED',
    defaultValue: true,
  );
}
