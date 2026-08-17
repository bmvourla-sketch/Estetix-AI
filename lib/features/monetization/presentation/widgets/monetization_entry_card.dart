import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../pages/paywall_page.dart';

/// Home-screen entry point into the paywall / pro upgrade.
class MonetizationEntryCard extends StatelessWidget {
  const MonetizationEntryCard({super.key});

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
          child: const Icon(Icons.workspace_premium,
              color: Colors.white, size: 22),
        ),
        title: Text(l10n.paywallTitle),
        subtitle: Text(l10n.paywallSubtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const PaywallPage()),
        ),
      ),
    );
  }
}
