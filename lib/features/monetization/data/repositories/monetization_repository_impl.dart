import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/credit_package.dart';
import '../../domain/entities/pro_plan.dart';
import '../../domain/repositories/monetization_repository.dart';
import '../services/ad_service.dart';
import '../services/revenuecat_service.dart';

/// Concrete [MonetizationRepository]: RevenueCat for purchases, AdMob for
/// rewarded ads, and the `reward-token` Edge Function for reward grants.
///
/// Credits and pro status after a purchase are granted *server-side* by the
/// `paywall-webhook` Edge Function (RevenueCat webhook), not by the client.
class MonetizationRepositoryImpl implements MonetizationRepository {
  MonetizationRepositoryImpl({
    required this.client,
    required this.revenueCat,
    required this.adService,
  });

  final SupabaseClient client;
  final RevenueCatService revenueCat;
  final AdService adService;

  @override
  Future<bool> hasProAccess() => revenueCat.hasProAccess();

  @override
  Future<void> logIn(String userId) => revenueCat.logIn(userId);

  @override
  Future<List<ProPlan>> getProPlans() => revenueCat.loadProPlans();

  @override
  Future<List<CreditPackage>> getCreditPackages() =>
      revenueCat.loadCreditPackages();

  @override
  Future<void> purchaseProPlan(String userId, ProPlan plan) async {
    // Pro status is granted server-side by paywall-webhook (RevenueCat).
    await revenueCat.purchase(plan.id);
  }

  @override
  Future<void> purchaseCreditPackage(
    String userId,
    CreditPackage package,
  ) async {
    // Credits are granted server-side by paywall-webhook (RevenueCat).
    await revenueCat.purchase(package.id);
  }

  @override
  Future<bool> watchRewardedAd(String userId) async {
    final bool earned = await adService.showRewardedAd();
    if (earned) await _grantReward('video');
    return earned;
  }

  @override
  Future<int> rateApp(String userId) => _grantReward('rate');

  /// Grants tokens server-side via the service-role `reward-token` function.
  Future<int> _grantReward(String rewardType) async {
    final FunctionResponse response = await client.functions.invoke(
      'reward-token',
      body: <String, dynamic>{'reward_type': rewardType},
    );
    if (response.status < 200 || response.status >= 300) return 0;
    final Object? payload = response.data;
    if (payload is Map && payload['granted'] is num) {
      return (payload['granted'] as num).toInt();
    }
    return 0;
  }

  @override
  Future<void> restorePurchases(String userId) async {
    await revenueCat.restore();
  }
}
