/// A one-time consumable credit package (3 / 5 / 10 credits).
class CreditPackage {
  const CreditPackage({
    required this.id,
    required this.credits,
    required this.priceString,
  });

  /// RevenueCat product identifier, e.g. `credits_3`.
  final String id;

  /// Number of credits granted on purchase.
  final int credits;

  /// Localized price, e.g. `₺59,99`.
  final String priceString;
}
