import '../entities/wallet.dart';

/// Abstract contract for wallet balance + storage access.
abstract interface class WalletRepository {
  /// Live stream of the user's wallet, updated via Supabase Realtime.
  Stream<Wallet?> watchWallet(String userId);

  /// One-shot fetch of the wallet (used for pre-flight token checks).
  Future<Wallet?> getWallet(String userId);

  Future<Wallet> deductToken(String userId, int amount);

  Future<Wallet> addToken(String userId, int amount);

  Future<Wallet> updateStorageUsage(String userId, double usedStorageMb);

  /// Spends [cost] tokens to increase the user's max storage by [amountMb].
  Future<Wallet> upgradeStorage(String userId, double amountMb, int cost);
}
