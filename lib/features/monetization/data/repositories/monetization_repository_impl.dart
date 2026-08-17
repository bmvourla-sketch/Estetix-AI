import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/credit_package.dart';
import '../../domain/entities/pro_plan.dart';
import '../../domain/repositories/monetization_repository.dart';
import '../services/ad_service.dart';
import '../services/revenuecat_service.dart';

/// Concrete [MonetizationRepository]: RevenueCat for purchases, AdMob for
/// rewarded ads, and Supabase RPCs to sync credits / pro status.
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
    await revenueCat.purchase(plan.id);
    await _setProStatus(userId, true);
  }

  @override
  Future<void> purchaseCreditPackage(
    String userId,
    CreditPackage package,
  ) async {
    await revenueCat.purchase(package.id);
    await _addCredits(userId, package.credits);
  }

  @override
  Future<bool> watchRewardedAd(String userId) async {
    final bool earned = await adService.showRewardedAd();
    if (earned) await _addCredits(userId, 1);
    return earned;
  }

  @override
  Future<void> restorePurchases(String userId) async {
    await revenueCat.restore();
    await _setProStatus(userId, await revenueCat.hasProAccess());
  }

  Future<void> _addCredits(String userId, int amount) async {
    await client.rpc(
      'update_user_credits',
      params: <String, dynamic>{'user_id': userId, 'delta': amount},
    );
  }

  Future<void> _setProStatus(String userId, bool isPro) async {
    await client.rpc(
      'set_pro_status',
      params: <String, dynamic>{'user_id': userId, 'is_pro': isPro},
    );
  }
}
