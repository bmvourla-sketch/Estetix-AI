import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/aura_background.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../ai_transform/presentation/widgets/ai_transform_entry_card.dart';
import '../../../drive/presentation/widgets/drive_entry_card.dart';
import '../../../monetization/presentation/widgets/monetization_entry_card.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../wallet/presentation/widgets/wallet_card.dart';
import '../providers/home_provider.dart';

/// Authenticated home screen.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          const AuraBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ListView(
                children: <Widget>[
                  const SizedBox(height: 12),
                  _TopBar(
                    title: l10n.appTitle,
                    onSettings: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const SettingsPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  const WalletCard(),
                  const SizedBox(height: 16),
                  const AiTransformEntryCard(),
                  const SizedBox(height: 16),
                  const DriveEntryCard(),
                  const SizedBox(height: 16),
                  const MonetizationEntryCard(),
                  const SizedBox(height: 16),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(l10n.homeTitle, style: textTheme.headlineSmall),
                        const SizedBox(height: 8),
                        Text(
                          l10n.homeSubtitle,
                          style: textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 24),
                        Consumer<HomeProvider>(
                          builder: (BuildContext context, HomeProvider provider, _) {
                            if (provider.isLoading) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: LinearProgressIndicator(),
                                ),
                              );
                            }
                            if (provider.error != null) {
                              return Text(
                                provider.error!,
                                style: const TextStyle(color: Color(0xFFF87171)),
                              );
                            }
                            if (provider.userName.isNotEmpty) {
                              return Text(
                                l10n.welcomeMessage(provider.userName),
                                style: textTheme.titleMedium,
                              );
                            }
                            return FilledButton(
                              onPressed: () =>
                                  context.read<HomeProvider>().load(),
                              child: Text(l10n.getStarted),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.onSettings});

  final String title;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        IconButton(
          onPressed: onSettings,
          icon: const Icon(Icons.settings_outlined),
          tooltip: AppLocalizations.of(context).settings,
        ),
      ],
    );
  }
}
