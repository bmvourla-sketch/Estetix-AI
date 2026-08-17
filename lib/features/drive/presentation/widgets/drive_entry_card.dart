import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../pages/drive_page.dart';

/// Home-screen entry point into Estetix Drive.
class DriveEntryCard extends StatelessWidget {
  const DriveEntryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return GlassCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.folder_open, color: Colors.white, size: 22),
        ),
        title: Text(l10n.driveTitle),
        subtitle: Text(l10n.driveSubtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const DrivePage()),
        ),
      ),
    );
  }
}
