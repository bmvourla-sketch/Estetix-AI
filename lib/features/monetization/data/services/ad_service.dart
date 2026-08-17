import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../../core/config/monetization_config.dart';

/// Thin wrapper over the Google Mobile Ads SDK (rewarded + interstitial).
class AdService {
  AdService({
    String? rewardedAdUnitId,
    String? interstitialAdUnitId,
  })  : _rewardedAdUnitId =
            rewardedAdUnitId ?? MonetizationConfig.rewardedAdUnitId,
        _interstitialAdUnitId =
            interstitialAdUnitId ?? MonetizationConfig.interstitialAdUnitId;

  final String _rewardedAdUnitId;
  final String _interstitialAdUnitId;

  Future<void> init() => MobileAds.instance.initialize();

  /// Shows a rewarded video; completes true when the user earns a reward.
  Future<bool> showRewardedAd() {
    final Completer<bool> completer = Completer<bool>();
    unawaited(
      RewardedAd.load(
        adUnitId: _rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                if (!completer.isCompleted) completer.complete(false);
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                ad.dispose();
                if (!completer.isCompleted) completer.complete(false);
              },
            );
            ad.show(
              onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
                if (!completer.isCompleted) completer.complete(true);
              },
            );
          },
          onAdFailedToLoad: (LoadAdError error) {
            if (!completer.isCompleted) completer.complete(false);
          },
        ),
      ),
    );
    return completer.future;
  }

  /// Loads and shows a full-screen interstitial (best-effort).
  Future<void> showInterstitial() async {
    await InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) => ad.dispose(),
            onAdFailedToShowFullScreenContent: (ad, error) => ad.dispose(),
          );
          ad.show();
        },
        onAdFailedToLoad: (LoadAdError error) {
          // No-op: the interstitial is best-effort.
        },
      ),
    );
  }
}
