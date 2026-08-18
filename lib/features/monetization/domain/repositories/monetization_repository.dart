import '../entities/credit_package.dart';
import '../entities/pro_plan.dart';

/// Abstract contract for monetization (RevenueCat purchases + AdMob rewards).
abstract interface class MonetizationRepository {
  /// Whether the user currently holds the `pro_access` entitlement.
  Future<bool> hasProAccess();

  /// Ties the RevenueCat app-user-id to the Supabase user id so server-side
  /// purchase events can be attributed to the right profile.
  Future<void> logIn(String userId);

  /// Subscription options (monthly + yearly) with localized prices.
  Future<List<ProPlan>> getProPlans();

  /// One-time credit packages (3 / 5 / 10 credits).
  Future<List<CreditPackage>> getCreditPackages();

  /// Purchases [plan] and syncs the `pro_access` entitlement to Supabase.
  Future<void> purchaseProPlan(String userId, ProPlan plan);

  /// Purchases [package] and credits the user's token balance.
  Future<void> purchaseCreditPackage(String userId, CreditPackage package);

  /// Shows a rewarded video; returns true when the user earned a credit.
  Future<bool> watchRewardedAd(String userId);

  /// Grants the one-time "+5 token" rate bonus; returns tokens granted
  /// (0 when the user already rated).
  Future<int> rateApp(String userId);

  /// Restores previous purchases and syncs the entitlement to Supabase.
  Future<void> restorePurchases(String userId);
}
