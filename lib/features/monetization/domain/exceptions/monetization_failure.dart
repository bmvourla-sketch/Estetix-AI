/// Failure codes the monetization flow can surface to the UI.
enum MonetizationFailureCode {
  /// The SDK isn't configured (e.g. missing RevenueCat API key).
  notConfigured,

  /// A purchase failed or was cancelled.
  purchaseFailed,

  /// Restoring previous purchases failed.
  restoreFailed,

  /// No rewarded ad was available to show.
  adUnavailable,
}

/// Domain-level failure thrown by `MonetizationRepository` implementations.
class MonetizationFailure implements Exception {
  const MonetizationFailure(this.code, [this.message]);

  final MonetizationFailureCode code;
  final String? message;

  @override
  String toString() => message ?? code.name;
}
