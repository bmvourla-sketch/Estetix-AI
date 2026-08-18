import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ja'),
    Locale('tr'),
    Locale('zh'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'Estetix AI'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Your AI beauty companion'**
  String get appTagline;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Estetix AI'**
  String get homeTitle;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Smart, personalized beauty insights at your fingertips.'**
  String get homeSubtitle;

  /// Greeting with the user's name
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}!'**
  String welcomeMessage(String name);

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeAuraDark.
  ///
  /// In en, this message translates to:
  /// **'Aura Dark'**
  String get themeAuraDark;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @phoneLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get phoneLoginTitle;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneLabel;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendOtp;

  /// No description provided for @otpLabel.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get otpLabel;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @changeNumber.
  ///
  /// In en, this message translates to:
  /// **'Change number'**
  String get changeNumber;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @tokenBalance.
  ///
  /// In en, this message translates to:
  /// **'Token balance'**
  String get tokenBalance;

  /// No description provided for @storageUsed.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storageUsed;

  /// No description provided for @aiTransformTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Transform'**
  String get aiTransformTitle;

  /// No description provided for @chooseModule.
  ///
  /// In en, this message translates to:
  /// **'Choose module'**
  String get chooseModule;

  /// No description provided for @moduleInterior.
  ///
  /// In en, this message translates to:
  /// **'Interior'**
  String get moduleInterior;

  /// No description provided for @moduleOutdoor.
  ///
  /// In en, this message translates to:
  /// **'Garden & Outdoor'**
  String get moduleOutdoor;

  /// No description provided for @moduleFashion.
  ///
  /// In en, this message translates to:
  /// **'Fashion & Makeup'**
  String get moduleFashion;

  /// No description provided for @moduleDiet.
  ///
  /// In en, this message translates to:
  /// **'Diet & Food'**
  String get moduleDiet;

  /// No description provided for @chooseStyle.
  ///
  /// In en, this message translates to:
  /// **'Choose style'**
  String get chooseStyle;

  /// No description provided for @styleBudget.
  ///
  /// In en, this message translates to:
  /// **'Zero Cost'**
  String get styleBudget;

  /// No description provided for @styleLuxury.
  ///
  /// In en, this message translates to:
  /// **'Luxury'**
  String get styleLuxury;

  /// No description provided for @styleRainy.
  ///
  /// In en, this message translates to:
  /// **'Rainy Weather'**
  String get styleRainy;

  /// No description provided for @styleCozy.
  ///
  /// In en, this message translates to:
  /// **'Cozy & Warm'**
  String get styleCozy;

  /// No description provided for @premiumMode.
  ///
  /// In en, this message translates to:
  /// **'Premium Render (3 tokens)'**
  String get premiumMode;

  /// No description provided for @selectPhoto.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get selectPhoto;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get takePhoto;

  /// No description provided for @transform.
  ///
  /// In en, this message translates to:
  /// **'Transform'**
  String get transform;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading…'**
  String get uploading;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing…'**
  String get processing;

  /// No description provided for @resultTitle.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get resultTitle;

  /// No description provided for @analysisLabel.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get analysisLabel;

  /// No description provided for @productsLabel.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get productsLabel;

  /// No description provided for @buyNow.
  ///
  /// In en, this message translates to:
  /// **'Buy Now'**
  String get buyNow;

  /// No description provided for @diyStepsLabel.
  ///
  /// In en, this message translates to:
  /// **'DIY Steps'**
  String get diyStepsLabel;

  /// No description provided for @errorInsufficientTokens.
  ///
  /// In en, this message translates to:
  /// **'Insufficient token balance'**
  String get errorInsufficientTokens;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @beforeLabel.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get beforeLabel;

  /// No description provided for @afterLabel.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get afterLabel;

  /// No description provided for @driveTitle.
  ///
  /// In en, this message translates to:
  /// **'Estetix Drive'**
  String get driveTitle;

  /// No description provided for @driveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Store your transformations and PDF reports'**
  String get driveSubtitle;

  /// No description provided for @folderInterior.
  ///
  /// In en, this message translates to:
  /// **'Interior'**
  String get folderInterior;

  /// No description provided for @folderOutdoor.
  ///
  /// In en, this message translates to:
  /// **'Garden & Outdoor'**
  String get folderOutdoor;

  /// No description provided for @folderFashion.
  ///
  /// In en, this message translates to:
  /// **'Fashion & Makeup'**
  String get folderFashion;

  /// No description provided for @folderDiet.
  ///
  /// In en, this message translates to:
  /// **'Diet & Food'**
  String get folderDiet;

  /// No description provided for @emptyFolder.
  ///
  /// In en, this message translates to:
  /// **'No projects in this folder yet.'**
  String get emptyFolder;

  /// No description provided for @saveToDrive.
  ///
  /// In en, this message translates to:
  /// **'Save to Drive'**
  String get saveToDrive;

  /// No description provided for @savedToDrive.
  ///
  /// In en, this message translates to:
  /// **'Saved to Drive'**
  String get savedToDrive;

  /// No description provided for @storageFull.
  ///
  /// In en, this message translates to:
  /// **'Storage is full. Free up space to save more projects.'**
  String get storageFull;

  /// No description provided for @downloadPdf.
  ///
  /// In en, this message translates to:
  /// **'Download PDF'**
  String get downloadPdf;

  /// No description provided for @sharePdf.
  ///
  /// In en, this message translates to:
  /// **'Share PDF'**
  String get sharePdf;

  /// No description provided for @storageUsage.
  ///
  /// In en, this message translates to:
  /// **'Storage Usage'**
  String get storageUsage;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get productName;

  /// No description provided for @productPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get productPrice;

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'Estetix Pro'**
  String get paywallTitle;

  /// No description provided for @paywallSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock unlimited transforms and priority access'**
  String get paywallSubtitle;

  /// No description provided for @proMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get proMonthly;

  /// No description provided for @proYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get proYearly;

  /// No description provided for @bestValue.
  ///
  /// In en, this message translates to:
  /// **'Best Value'**
  String get bestValue;

  /// No description provided for @creditsLabel.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get creditsLabel;

  /// No description provided for @watchAd.
  ///
  /// In en, this message translates to:
  /// **'Watch Ad, Earn +1 Credit'**
  String get watchAd;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;

  /// No description provided for @purchase.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get purchase;

  /// No description provided for @purchased.
  ///
  /// In en, this message translates to:
  /// **'Purchase completed'**
  String get purchased;

  /// No description provided for @restored.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored'**
  String get restored;

  /// No description provided for @adWatched.
  ///
  /// In en, this message translates to:
  /// **'+1 credit earned'**
  String get adWatched;

  /// No description provided for @adUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Ad is unavailable right now'**
  String get adUnavailable;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'ja',
    'tr',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'tr':
      return AppLocalizationsTr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
