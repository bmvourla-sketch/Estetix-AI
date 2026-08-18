import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/aura_background.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../wallet/presentation/providers/wallet_state.dart';
import '../../domain/entities/drive_category.dart';
import '../widgets/storage_usage_bar.dart';
import 'drive_folder_page.dart';

/// Estetix Drive home: live storage bar + the three category folders.
class DrivePage extends StatelessWidget {
  const DrivePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final TextTheme textTheme = Theme.of(context).textTheme;
    final wallet = context.watch<WalletState>().wallet;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.driveTitle)),
      body: Stack(
        children: <Widget>[
          const AuraBackground(),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: <Widget>[
                Text(
                  l10n.driveSubtitle,
                  style: textTheme.bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                if (wallet != null) ...<Widget>[
                  const SizedBox(height: 16),
                  GlassCard(child: StorageUsageBar(wallet: wallet)),
                ],
                const SizedBox(height: 24),
                _FolderCard(
                  category: DriveCategory.outdoor,
                  label: l10n.folderOutdoor,
                  icon: Icons.yard_outlined,
                ),
                const SizedBox(height: 14),
                _FolderCard(
                  category: DriveCategory.interior,
                  label: l10n.folderInterior,
                  icon: Icons.chair_outlined,
                ),
                const SizedBox(height: 14),
                _FolderCard(
                  category: DriveCategory.fashion,
                  label: l10n.folderFashion,
                  icon: Icons.checkroom,
                ),
                const SizedBox(height: 14),
                _FolderCard(
                  category: DriveCategory.diet,
                  label: l10n.folderDiet,
                  icon: Icons.restaurant_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FolderCard extends StatelessWidget {
  const _FolderCard({
    required this.category,
    required this.label,
    required this.icon,
  });

  final DriveCategory category;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.emerald, size: 22),
        ),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => DriveFolderPage(category: category),
          ),
        ),
      ),
    );
  }
}
