import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';

/// Settings screen: language selector + sign out.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LocaleProvider localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: <Widget>[
          Text(l10n.language, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: <Widget>[
                for (int i = 0; i < supportedLanguages.length; i++) ...<Widget>[
                  _LanguageTile(
                    language: supportedLanguages[i],
                    isSelected: supportedLanguages[i].code ==
                        localeProvider.locale.languageCode,
                    onTap: () =>
                        localeProvider.setLocale(supportedLanguages[i].locale),
                  ),
                  if (i < supportedLanguages.length - 1)
                    const Divider(height: 1, indent: 16, endIndent: 16),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),
          GlassCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFFF87171)),
              title: Text(l10n.signOut),
              onTap: () async {
                await context.read<AuthNotifier>().signOut();
                if (context.mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  final AppLanguage language;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Text(language.flag, style: const TextStyle(fontSize: 22)),
      title: Text(language.nativeName),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.emerald)
          : const Icon(Icons.circle_outlined, color: AppColors.textSecondary),
    );
  }
}
