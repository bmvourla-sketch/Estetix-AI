import 'package:flutter/widgets.dart';

/// Describes one supported language for the selector UI.
class AppLanguage {
  const AppLanguage({
    required this.code,
    required this.nativeName,
    required this.flag,
  });

  /// ISO-639 language code, e.g. 'tr', 'ar'.
  final String code;

  /// The language's endonym, shown to users in its own script.
  final String nativeName;

  /// An emoji flag for quick visual scanning.
  final String flag;

  Locale get locale => Locale(code);
}

/// The eight supported languages, kept in sync with `lib/l10n/*.arb`.
const List<AppLanguage> supportedLanguages = <AppLanguage>[
  AppLanguage(code: 'tr', nativeName: 'Türkçe', flag: '🇹🇷'),
  AppLanguage(code: 'en', nativeName: 'English', flag: '🇬🇧'),
  AppLanguage(code: 'ar', nativeName: 'العربية', flag: '🇸🇦'),
  AppLanguage(code: 'es', nativeName: 'Español', flag: '🇪🇸'),
  AppLanguage(code: 'de', nativeName: 'Deutsch', flag: '🇩🇪'),
  AppLanguage(code: 'fr', nativeName: 'Français', flag: '🇫🇷'),
  AppLanguage(code: 'ja', nativeName: '日本語', flag: '🇯🇵'),
  AppLanguage(code: 'zh', nativeName: '中文', flag: '🇨🇳'),
];
