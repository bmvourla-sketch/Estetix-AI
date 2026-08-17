import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../wallet/domain/entities/wallet.dart';

/// Live storage usage bar: `24.5 MB / 50 MB · 49%`.
///
/// Turns red as the user approaches their quota.
class StorageUsageBar extends StatelessWidget {
  const StorageUsageBar({super.key, required this.wallet});

  final Wallet wallet;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final int percent = (wallet.storageUsageRatio * 100).round();
    final bool nearLimit = percent >= 90;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              '${_format(wallet.usedStorageMb)} MB / ${_format(wallet.maxStorageMb)} MB',
              style: textTheme.bodyMedium,
            ),
            const Spacer(),
            Text(
              '%$percent',
              style: textTheme.bodyMedium?.copyWith(
                color: nearLimit ? const Color(0xFFF87171) : AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: wallet.storageUsageRatio,
            minHeight: 8,
            backgroundColor: AppColors.surfaceElevated,
            color: nearLimit ? const Color(0xFFF87171) : AppColors.emerald,
          ),
        ),
      ],
    );
  }

  String _format(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }
}
