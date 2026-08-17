import '../../domain/entities/credit_package.dart';
import '../../domain/entities/pro_plan.dart';

/// Immutable presentation state for monetization / paywall.
class MonetizationState {
  const MonetizationState({
    this.proPlans = const <ProPlan>[],
    this.creditPackages = const <CreditPackage>[],
    this.hasProAccess = false,
    this.isLoading = false,
    this.isPurchasing = false,
    this.error,
  });

  final List<ProPlan> proPlans;
  final List<CreditPackage> creditPackages;
  final bool hasProAccess;
  final bool isLoading;
  final bool isPurchasing;
  final String? error;

  MonetizationState copyWith({
    List<ProPlan>? proPlans,
    List<CreditPackage>? creditPackages,
    bool? hasProAccess,
    bool? isLoading,
    bool? isPurchasing,
    String? error,
    bool clearError = false,
  }) {
    return MonetizationState(
      proPlans: proPlans ?? this.proPlans,
      creditPackages: creditPackages ?? this.creditPackages,
      hasProAccess: hasProAccess ?? this.hasProAccess,
      isLoading: isLoading ?? this.isLoading,
      isPurchasing: isPurchasing ?? this.isPurchasing,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
