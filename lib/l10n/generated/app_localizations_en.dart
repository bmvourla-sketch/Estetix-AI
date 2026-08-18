// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Estetix AI';

  @override
  String get appTagline => 'Your AI beauty companion';

  @override
  String get homeTitle => 'Welcome to Estetix AI';

  @override
  String get homeSubtitle =>
      'Smart, personalized beauty insights at your fingertips.';

  @override
  String welcomeMessage(String name) {
    return 'Hello, $name!';
  }

  @override
  String get language => 'Language';

  @override
  String get settings => 'Settings';

  @override
  String get theme => 'Theme';

  @override
  String get themeAuraDark => 'Aura Dark';

  @override
  String get getStarted => 'Get Started';

  @override
  String get phoneLoginTitle => 'Sign in';

  @override
  String get phoneLabel => 'Phone number';

  @override
  String get sendOtp => 'Send code';

  @override
  String get otpLabel => 'Verification code';

  @override
  String get verify => 'Verify';

  @override
  String get changeNumber => 'Change number';

  @override
  String get signOut => 'Sign out';

  @override
  String get tokenBalance => 'Token balance';

  @override
  String get storageUsed => 'Storage';

  @override
  String get aiTransformTitle => 'AI Transform';

  @override
  String get chooseModule => 'Choose module';

  @override
  String get moduleInterior => 'Interior';

  @override
  String get moduleOutdoor => 'Garden & Outdoor';

  @override
  String get moduleFashion => 'Fashion & Makeup';

  @override
  String get moduleDiet => 'Diet & Food';

  @override
  String get chooseStyle => 'Choose style';

  @override
  String get styleBudget => 'Zero Cost';

  @override
  String get styleLuxury => 'Luxury';

  @override
  String get styleRainy => 'Rainy Weather';

  @override
  String get styleCozy => 'Cozy & Warm';

  @override
  String get premiumMode => 'Premium Render (3 tokens)';

  @override
  String get selectPhoto => 'Gallery';

  @override
  String get takePhoto => 'Camera';

  @override
  String get transform => 'Transform';

  @override
  String get uploading => 'Uploading…';

  @override
  String get processing => 'Processing…';

  @override
  String get resultTitle => 'Result';

  @override
  String get analysisLabel => 'Analysis';

  @override
  String get productsLabel => 'Products';

  @override
  String get buyNow => 'Buy Now';

  @override
  String get diyStepsLabel => 'DIY Steps';

  @override
  String get errorInsufficientTokens => 'Insufficient token balance';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get beforeLabel => 'Before';

  @override
  String get afterLabel => 'After';

  @override
  String get driveTitle => 'Estetix Drive';

  @override
  String get driveSubtitle => 'Store your transformations and PDF reports';

  @override
  String get folderInterior => 'Interior';

  @override
  String get folderOutdoor => 'Garden & Outdoor';

  @override
  String get folderFashion => 'Fashion & Makeup';

  @override
  String get folderDiet => 'Diet & Food';

  @override
  String get emptyFolder => 'No projects in this folder yet.';

  @override
  String get saveToDrive => 'Save to Drive';

  @override
  String get savedToDrive => 'Saved to Drive';

  @override
  String get storageFull =>
      'Storage is full. Free up space to save more projects.';

  @override
  String get downloadPdf => 'Download PDF';

  @override
  String get sharePdf => 'Share PDF';

  @override
  String get storageUsage => 'Storage Usage';

  @override
  String get productName => 'Product';

  @override
  String get productPrice => 'Price';

  @override
  String get paywallTitle => 'Estetix Pro';

  @override
  String get paywallSubtitle =>
      'Unlock unlimited transforms and priority access';

  @override
  String get proMonthly => 'Monthly';

  @override
  String get proYearly => 'Yearly';

  @override
  String get bestValue => 'Best Value';

  @override
  String get creditsLabel => 'Credits';

  @override
  String get watchAd => 'Watch Ad, Earn +1 Credit';

  @override
  String get restorePurchases => 'Restore Purchases';

  @override
  String get purchase => 'Buy';

  @override
  String get purchased => 'Purchase completed';

  @override
  String get restored => 'Purchases restored';

  @override
  String get adWatched => '+1 credit earned';

  @override
  String get adUnavailable => 'Ad is unavailable right now';
}
