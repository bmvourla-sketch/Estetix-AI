import '../../domain/entities/wallet.dart';

/// Immutable presentation state for the token/storage wallet.
class WalletState {
  const WalletState({this.wallet, this.isLoading = false, this.error});

  final Wallet? wallet;
  final bool isLoading;
  final String? error;

  WalletState copyWith({
    Wallet? wallet,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return WalletState(
      wallet: wallet ?? this.wallet,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
