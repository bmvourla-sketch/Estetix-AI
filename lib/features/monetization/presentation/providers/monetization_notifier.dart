import 'package:state_notifier/state_notifier.dart';

import '../../domain/entities/credit_package.dart';
import '../../domain/entities/pro_plan.dart';
import '../../domain/repositories/monetization_repository.dart';
import 'monetization_state.dart';

/// Reactive state for the paywall: loads offerings, purchases, ad rewards.
class MonetizationNotifier extends StateNotifier<MonetizationState> {
  MonetizationNotifier(this._repository) : super(const MonetizationState());

  final MonetizationRepository _repository;

  /// Ties the RevenueCat user to the Supabase user (call after sign-in).
  Future<void> logIn(String userId) => _repository.logIn(userId);

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final List<ProPlan> proPlans = await _repository.getProPlans();
      final List<CreditPackage> creditPackages =
          await _repository.getCreditPackages();
      final bool hasPro = await _repository.hasProAccess();
      state = state.copyWith(
        isLoading: false,
        proPlans: proPlans,
        creditPackages: creditPackages,
        hasProAccess: hasPro,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Purchases a pro plan. Returns true on success.
  Future<bool> purchasePro(String userId, ProPlan plan) =>
      _run(() => _repository.purchaseProPlan(userId, plan));

  /// Purchases a credit package. Returns true on success.
  Future<bool> purchaseCredits(String userId, CreditPackage package) =>
      _run(() => _repository.purchaseCreditPackage(userId, package));

  /// Watches a rewarded ad. Returns true when a credit was earned.
  Future<bool> watchAd(String userId) async {
    state = state.copyWith(isPurchasing: true, clearError: true);
    try {
      final bool earned = await _repository.watchRewardedAd(userId);
      state = state.copyWith(isPurchasing: false);
      return earned;
    } catch (e) {
      state = state.copyWith(isPurchasing: false, error: e.toString());
      return false;
    }
  }

  /// Opens the store rating and grants the one-time +5 token bonus.
  Future<int> rateApp(String userId) async {
    state = state.copyWith(isPurchasing: true, clearError: true);
    try {
      final int granted = await _repository.rateApp(userId);
      state = state.copyWith(isPurchasing: false);
      return granted;
    } catch (e) {
      state = state.copyWith(isPurchasing: false, error: e.toString());
      return 0;
    }
  }

  /// Restores previous purchases. Returns true on success.
  Future<bool> restore(String userId) =>
      _run(() => _repository.restorePurchases(userId));

  Future<bool> _run(Future<void> Function() action) async {
    state = state.copyWith(isPurchasing: true, clearError: true);
    try {
      await action();
      state = state.copyWith(isPurchasing: false);
      return true;
    } catch (e) {
      state = state.copyWith(isPurchasing: false, error: e.toString());
      return false;
    }
  }
}
