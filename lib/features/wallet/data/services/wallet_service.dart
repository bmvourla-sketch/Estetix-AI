import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';

/// Concrete [WalletRepository] backed by Supabase.
///
/// Balance/storage mutations are delegated to Postgres RPC functions
/// (`deduct_token`, `add_token`, `update_storage_usage`) so they run
/// atomically under RLS — see `supabase/schema.sql`. Reading uses a Realtime
/// stream so every client reflects changes immediately.
class WalletService implements WalletRepository {
  WalletService(this._client);

  final SupabaseClient _client;

  static const String _table = 'profiles';

  @override
  Future<Wallet?> getWallet(String userId) async {
    final Map<String, dynamic>? row =
        await _client.from(_table).select().eq('id', userId).maybeSingle();
    return row == null ? null : Wallet.fromJson(row);
  }

  @override
  Stream<Wallet?> watchWallet(String userId) {
    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((List<Map<String, dynamic>> rows) =>
            rows.isEmpty ? null : Wallet.fromJson(rows.first));
  }

  @override
  Future<Wallet> deductToken(String userId, int amount) =>
      _rpc('deduct_token', {'user_id': userId, 'amount': amount});

  @override
  Future<Wallet> addToken(String userId, int amount) =>
      _rpc('add_token', {'user_id': userId, 'amount': amount});

  @override
  Future<Wallet> updateStorageUsage(String userId, double usedStorageMb) =>
      _rpc('update_storage_usage', {
        'user_id': userId,
        'used_storage_mb': usedStorageMb,
      });

  @override
  Future<Wallet> upgradeStorage(String userId, double amountMb, int cost) =>
      _rpc('upgrade_storage', {
        'user_id': userId,
        'amount_mb': amountMb,
        'cost': cost,
      });

  Future<Wallet> _rpc(String fn, Map<String, dynamic> params) async {
    final Object? data = await _client.rpc(fn, params: params);
    // RPC returns a single profile row (Map) when the function RETURNS one.
    return Wallet.fromJson(Map<String, dynamic>.from(data as Map));
  }
}
