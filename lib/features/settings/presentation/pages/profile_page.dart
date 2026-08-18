import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/widgets/aura_background.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../auth/presentation/providers/auth_ui_state.dart';
import '../../../wallet/presentation/widgets/wallet_card.dart';

/// Profile panel: phone, wallet, language and sign out.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LocaleProvider localeProvider = context.watch<LocaleProvider>();
    final String? phone = context.watch<AuthUiState>().user?.phoneNumber;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          const AuraBackground(),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: <Widget>[
                Text(l10n.settings, style: textTheme.titleLarge),
                const SizedBox(height: 12),
                if (phone != null && phone.isNotEmpty)
                  GlassCard(
                    child: ListTile(
                      leading: const Icon(Icons.phone, color: AppColors.emerald),
                      title: Text(phone),
                    ),
                  ),
                const SizedBox(height: 16),
                const WalletCard(),
                const SizedBox(height: 24),
                Text(l10n.language, style: textTheme.titleMedium),
                const SizedBox(height: 12),
                GlassCard(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: <Widget>[
                      for (int i = 0; i < supportedLanguages.length; i++) ...<Widget>[
                        ListTile(
                          onTap: () => localeProvider
                              .setLocale(supportedLanguages[i].locale),
                          leading: Text(supportedLanguages[i].flag,
                              style: const TextStyle(fontSize: 22)),
                          title: Text(supportedLanguages[i].nativeName),
                          trailing: supportedLanguages[i].code ==
                                  localeProvider.locale.languageCode
                              ? const Icon(Icons.check_circle,
                                  color: AppColors.emerald)
                              : const Icon(Icons.circle_outlined,
                                  color: AppColors.textSecondary),
                        ),
                        if (i < supportedLanguages.length - 1)
                          const Divider(height: 1, indent: 16, endIndent: 16),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    leading: const Icon(Icons.logout, color: Color(0xFFF87171)),
                    title: Text(l10n.signOut),
                    onTap: () => context.read<AuthNotifier>().signOut(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
