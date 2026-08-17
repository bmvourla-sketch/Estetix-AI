import 'dart:async';

import 'package:state_notifier/state_notifier.dart';

import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';
import 'wallet_state.dart';

/// Reactive wallet state: subscribes to a live stream and exposes safe
/// mutations for balance and storage.
class WalletNotifier extends StateNotifier<WalletState> {
  WalletNotifier(this._repository) : super(const WalletState());

  final WalletRepository _repository;
  StreamSubscription<Wallet?>? _subscription;
  String? _userId;

  /// Starts (idempotently) watching [userId]'s wallet.
  void watch(String userId) {
    if (_userId == userId && _subscription != null) return;
    _userId = userId;
    _subscription?.cancel();
    state = const WalletState(isLoading: true);
    _subscription = _repository.watchWallet(userId).listen(
          _onWallet,
          onError: (Object error, StackTrace stackTrace) {
            state = state.copyWith(isLoading: false, error: error.toString());
          },
        );
  }

  void _onWallet(Wallet? wallet) {
    state = state.copyWith(wallet: wallet, isLoading: false, clearError: true);
  }

  Future<void> deductToken(int amount) =>
      _mutate((String id) => _repository.deductToken(id, amount));

  Future<void> addToken(int amount) =>
      _mutate((String id) => _repository.addToken(id, amount));

  Future<void> updateStorageUsage(double usedStorageMb) => _mutate(
        (String id) => _repository.updateStorageUsage(id, usedStorageMb),
      );

  Future<void> _mutate(Future<Wallet> Function(String userId) operation) async {
    final String? id = _userId;
    if (id == null) return;
    try {
      final Wallet wallet = await operation(id);
      state = state.copyWith(wallet: wallet, clearError: true);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
