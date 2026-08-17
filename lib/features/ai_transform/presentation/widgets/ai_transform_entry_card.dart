import 'package:flutter/material.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/providers/auth_ui_state.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';
import '../../domain/repositories/ai_transform_repository.dart';
import '../pages/ai_transform_flow_page.dart';
import '../providers/ai_transform_notifier.dart';
import '../providers/ai_transform_state.dart';

/// Home-screen entry point into the AI transform flow.
class AiTransformEntryCard extends StatelessWidget {
  const AiTransformEntryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return GlassCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.auto_fix_high, color: Colors.white, size: 22),
        ),
        title: Text(l10n.aiTransformTitle),
        subtitle: Text(l10n.appTagline),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                StateNotifierProvider<AiTransformNotifier, AiTransformState>(
              create: (BuildContext ctx) => AiTransformNotifier(
                aiRepository: getIt<AiTransformRepository>(),
                walletRepository: getIt<WalletRepository>(),
                userId: ctx.read<AuthUiState>().user?.id ?? '',
              ),
              child: const AiTransformFlowPage(),
            ),
          ),
        ),
      ),
    );
  }
}
