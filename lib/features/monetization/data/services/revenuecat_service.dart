import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../../core/config/monetization_config.dart';
import '../../domain/entities/credit_package.dart';
import '../../domain/entities/pro_plan.dart';
import '../../domain/exceptions/monetization_failure.dart';

/// Thin wrapper over the RevenueCat SDK.
class RevenueCatService {
  bool _configured = false;

  bool get isConfigured => _configured;

  /// Configures RevenueCat. No-ops when no API key is set (dev/tests).
  Future<void> init() async {
    if (_configured) return;
    final String apiKey = _resolveApiKey();
    if (apiKey.isEmpty) return;
    await Purchases.configure(PurchasesConfiguration(apiKey));
    _configured = true;
  }

  /// Prefers the platform-specific RevenueCat key (Apple vs Google Play),
  /// falling back to the legacy single key for backwards compatibility.
  String _resolveApiKey() {
    final bool isApple = defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
    final String platformKey = isApple
        ? MonetizationConfig.revenueCatAppleApiKey
        : MonetizationConfig.revenueCatGoogleApiKey;
    return platformKey.isNotEmpty
        ? platformKey
        : MonetizationConfig.revenueCatApiKey;
  }

  /// Ties RevenueCat's app-user-id to the Supabase user id, so the
  /// paywall-webhook can map purchase events back to `profiles`.
  Future<void> logIn(String userId) async {
    if (!_configured) return;
    await Purchases.logIn(userId);
  }

  Future<List<ProPlan>> loadProPlans() async {
    final List<Package> packages = await _loadPackages();
    final List<ProPlan> plans = <ProPlan>[];
    for (final Package p in packages) {
      if (p.packageType != PackageType.monthly &&
          p.packageType != PackageType.annual) {
        continue;
      }
      plans.add(
        ProPlan(
          id: p.storeProduct.identifier,
          priceString: p.storeProduct.priceString,
          isYearly: p.packageType == PackageType.annual,
        ),
      );
    }
    return plans;
  }

  Future<List<CreditPackage>> loadCreditPackages() async {
    final List<Package> packages = await _loadPackages();
    final List<CreditPackage> credits = <CreditPackage>[];
    for (final Package p in packages) {
      final String id = p.storeProduct.identifier;
      if (!id.startsWith('credits_')) continue;
      credits.add(
        CreditPackage(
          id: id,
          credits: _creditsFromId(id),
          priceString: p.storeProduct.priceString,
        ),
      );
    }
    return credits;
  }

  Future<void> purchase(String productId) async {
    if (!_configured) {
      throw const MonetizationFailure(MonetizationFailureCode.notConfigured);
    }
    final Package? package = await _findPackage(productId);
    if (package == null) {
      throw const MonetizationFailure(MonetizationFailureCode.purchaseFailed);
    }
    await Purchases.purchasePackage(package);
  }

  Future<void> restore() async {
    if (!_configured) {
      throw const MonetizationFailure(MonetizationFailureCode.notConfigured);
    }
    await Purchases.restorePurchases();
  }

  Future<bool> hasProAccess() async {
    if (!_configured) return false;
    final CustomerInfo info = await Purchases.getCustomerInfo();
    return info.entitlements.active['pro_access']?.isActive ?? false;
  }

  Future<List<Package>> _loadPackages() async {
    if (!_configured) return const <Package>[];
    final Offerings offerings = await Purchases.getOfferings();
    return offerings.current?.availablePackages ?? const <Package>[];
  }

  Future<Package?> _findPackage(String productId) async {
    for (final Package p in await _loadPackages()) {
      if (p.storeProduct.identifier == productId) return p;
    }
    return null;
  }

  int _creditsFromId(String id) {
    final String suffix = id.replaceFirst('credits_', '');
    return int.tryParse(suffix) ?? 0;
  }
}
