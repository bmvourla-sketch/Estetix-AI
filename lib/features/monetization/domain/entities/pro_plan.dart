/// A pro subscription option.
class ProPlan {
  const ProPlan({
    required this.id,
    required this.priceString,
    required this.isYearly,
  });

  /// RevenueCat product identifier, e.g. `pro_monthly` / `pro_yearly`.
  final String id;

  /// Localized price, e.g. `₺199,99/ay`.
  final String priceString;

  /// True for the yearly plan (shown with a "best value" badge).
  final bool isYearly;
}
