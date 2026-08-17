/// Wallet data for the signed-in user.
class Wallet {
  const Wallet({
    required this.tokenBalance,
    required this.usedStorageMb,
    required this.maxStorageMb,
  });

  final int tokenBalance;
  final double usedStorageMb;
  final double maxStorageMb;

  /// Fraction of storage used, clamped to `[0, 1]` for progress bars.
  double get storageUsageRatio {
    if (maxStorageMb <= 0) return 0;
    return (usedStorageMb / maxStorageMb).clamp(0.0, 1.0);
  }

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      tokenBalance: (json['token_balance'] as num?)?.toInt() ?? 0,
      usedStorageMb: (json['used_storage_mb'] as num?)?.toDouble() ?? 0,
      maxStorageMb: (json['max_storage_mb'] as num?)?.toDouble() ?? 0,
    );
  }

  Wallet copyWith({
    int? tokenBalance,
    double? usedStorageMb,
    double? maxStorageMb,
  }) {
    return Wallet(
      tokenBalance: tokenBalance ?? this.tokenBalance,
      usedStorageMb: usedStorageMb ?? this.usedStorageMb,
      maxStorageMb: maxStorageMb ?? this.maxStorageMb,
    );
  }
}
