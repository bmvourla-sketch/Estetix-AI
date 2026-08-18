import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/monetization_config.dart';

/// A fixed banner ad shown at the bottom of every panel (mobile only).
class BannerAdSlot extends StatefulWidget {
  const BannerAdSlot({super.key});

  @override
  State<BannerAdSlot> createState() => _BannerAdSlotState();
}

class _BannerAdSlotState extends State<BannerAdSlot> {
  BannerAd? _banner;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && MonetizationConfig.enabled) {
      _banner = BannerAd(
        adUnitId: MonetizationConfig.bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) => setState(() {}),
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            ad.dispose();
            _banner = null;
          },
        ),
      )..load();
    }
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || _banner == null) return const SizedBox.shrink();
    return SizedBox(height: 50, child: AdWidget(ad: _banner!));
  }
}
