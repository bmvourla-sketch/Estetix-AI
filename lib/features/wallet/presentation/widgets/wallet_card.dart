import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/wallet.dart';
import '../providers/wallet_state.dart';

/// Live token balance + storage usage, fed by [WalletState] (Realtime-backed).
class WalletCard extends StatelessWidget {
  const WalletCard({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final WalletState walletState = context.watch<WalletState>();
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Wallet? wallet = walletState.wallet;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.monetization_on, color: AppColors.emerald),
              const SizedBox(width: 8),
              Text(l10n.tokenBalance, style: textTheme.titleMedium),
              const Spacer(),
              Text(
                wallet == null ? '—' : '${wallet.tokenBalance}',
                style: textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (walletState.isLoading)
            const LinearProgressIndicator()
          else if (wallet != null)
            _StorageBar(wallet: wallet)
          else
            const SizedBox.shrink(),
          if (walletState.error != null) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              walletState.error!,
              style: const TextStyle(color: Color(0xFFF87171), fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _StorageBar extends StatelessWidget {
  const _StorageBar({required this.wallet});

  final Wallet wallet;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String used = _formatMb(wallet.usedStorageMb);
    final String max = _formatMb(wallet.maxStorageMb);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              l10n.storageUsed,
              style: textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const Spacer(),
            Text('$used MB / $max MB', style: textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: wallet.storageUsageRatio,
            minHeight: 8,
            backgroundColor: AppColors.surfaceElevated,
            color: AppColors.purple,
          ),
        ),
      ],
    );
  }

  String _formatMb(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }
}
