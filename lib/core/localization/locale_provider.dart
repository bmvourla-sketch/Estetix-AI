import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/generated/app_localizations.dart';

/// Holds the active [Locale] and drives directionality for the whole app.
///
/// MaterialApp reads [locale] on every rebuild. When the selected locale is
/// Arabic (or any RTL language), `flutter_localizations` automatically flips
/// the tree to right-to-left — this provider is the single place that decision
/// is made, and [isRTL] / [textDirection] expose it to callers that need it
/// explicitly.
class LocaleProvider extends ChangeNotifier {
  LocaleProvider({SharedPreferences? preferences}) : _prefs = preferences;

  static const String _storageKey = 'app_locale_language_code';
  static const Locale _defaultLocale = Locale('tr');

  SharedPreferences? _prefs;
  Locale _locale = _defaultLocale;

  Locale get locale => _locale;

  /// Whether the current locale reads right-to-left (Arabic).
  bool get isRTL => _locale.languageCode == 'ar';

  /// Explicit direction derived from the locale, for callers that need a
  /// [TextDirection] directly instead of relying on MaterialApp's auto-RTL.
  TextDirection get textDirection =>
      isRTL ? TextDirection.rtl : TextDirection.ltr;

  List<Locale> get supportedLocales => AppLocalizations.supportedLocales;

  /// Loads any persisted locale from disk. Called once at startup.
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    final String? saved = _prefs?.getString(_storageKey);
    if (saved != null &&
        AppLocalizations.supportedLocales.any((Locale l) => l.languageCode == saved)) {
      _locale = Locale(saved);
    }
    notifyListeners();
  }

  /// Changes the locale, notifies listeners, and persists the choice.
  Future<void> setLocale(Locale locale) async {
    if (locale.languageCode == _locale.languageCode) return;
    _locale = locale;
    notifyListeners();
    final SharedPreferences prefs =
        _prefs ??= await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, locale.languageCode);
  }
}
