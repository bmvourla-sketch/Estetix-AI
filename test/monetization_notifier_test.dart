import 'package:flutter_test/flutter_test.dart';

import 'package:estetix_ai/features/monetization/domain/entities/credit_package.dart';
import 'package:estetix_ai/features/monetization/domain/entities/pro_plan.dart';
import 'package:estetix_ai/features/monetization/domain/repositories/monetization_repository.dart';
import 'package:estetix_ai/features/monetization/presentation/providers/monetization_notifier.dart';

class _FakeMonetizationRepository implements MonetizationRepository {
  _FakeMonetizationRepository({
    this.hasPro = false,
    this.earnReward = true,
    this.throwOnAction = false,
  });

  final bool hasPro;
  final bool earnReward;
  final bool throwOnAction;

  @override
  Future<bool> hasProAccess() async => hasPro;

  @override
  Future<void> logIn(String userId) async {}

  @override
  Future<List<ProPlan>> getProPlans() async => const <ProPlan>[
        ProPlan(id: 'pro_monthly', priceString: '₺199,99/ay', isYearly: false),
        ProPlan(id: 'pro_yearly', priceString: '₺999,99/yıl', isYearly: true),
      ];

  @override
  Future<List<CreditPackage>> getCreditPackages() async =>
      const <CreditPackage>[
        CreditPackage(id: 'credits_3', credits: 3, priceString: '₺59,99'),
        CreditPackage(id: 'credits_5', credits: 5, priceString: '₺89,99'),
        CreditPackage(id: 'credits_10', credits: 10, priceString: '₺149,99'),
      ];

  @override
  Future<void> purchaseProPlan(String userId, ProPlan plan) async {
    if (throwOnAction) throw Exception('boom');
  }

  @override
  Future<void> purchaseCreditPackage(
    String userId,
    CreditPackage package,
  ) async {
    if (throwOnAction) throw Exception('boom');
  }

  @override
  Future<bool> watchRewardedAd(String userId) async {
    if (throwOnAction) throw Exception('boom');
    return earnReward;
  }

  @override
  Future<int> rateApp(String userId) async {
    if (throwOnAction) throw Exception('boom');
    return 5;
  }

  @override
  Future<void> restorePurchases(String userId) async {
    if (throwOnAction) throw Exception('boom');
  }
}

void main() {
  test('load populates plans, packages and pro status', () async {
    final MonetizationNotifier notifier =
        MonetizationNotifier(_FakeMonetizationRepository(hasPro: true));
    await notifier.load();
    expect(notifier.state.proPlans, hasLength(2));
    expect(notifier.state.creditPackages, hasLength(3));
    expect(notifier.state.hasProAccess, isTrue);
    expect(notifier.state.isLoading, isFalse);
  });

  test('purchasePro returns true on success', () async {
    final MonetizationNotifier notifier =
        MonetizationNotifier(_FakeMonetizationRepository());
    final bool ok = await notifier.purchasePro(
      'u',
      const ProPlan(id: 'pro_monthly', priceString: 'x', isYearly: false),
    );
    expect(ok, isTrue);
  });

  test('purchaseCredits returns false on failure', () async {
    final MonetizationNotifier notifier = MonetizationNotifier(
      _FakeMonetizationRepository(throwOnAction: true),
    );
    final bool ok = await notifier.purchaseCredits(
      'u',
      const CreditPackage(id: 'credits_3', credits: 3, priceString: 'x'),
    );
    expect(ok, isFalse);
  });

  test('watchAd returns the earned flag', () async {
    final MonetizationNotifier notifier =
        MonetizationNotifier(_FakeMonetizationRepository(earnReward: true));
    expect(await notifier.watchAd('u'), isTrue);
  });
}
