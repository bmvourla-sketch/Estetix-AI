// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Estetix AI';

  @override
  String get appTagline => 'رفيقك الذكي للجمال';

  @override
  String get homeTitle => 'مرحبًا بك في Estetix AI';

  @override
  String get homeSubtitle => 'رؤى جمال ذكية ومخصصة في متناول يدك.';

  @override
  String welcomeMessage(String name) {
    return 'مرحبًا، $name!';
  }

  @override
  String get language => 'اللغة';

  @override
  String get settings => 'الإعدادات';

  @override
  String get theme => 'المظهر';

  @override
  String get themeAuraDark => 'Aura Dark';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get phoneLoginTitle => 'تسجيل الدخول';

  @override
  String get phoneLabel => 'رقم الهاتف';

  @override
  String get sendOtp => 'إرسال الرمز';

  @override
  String get otpLabel => 'رمز التحقق';

  @override
  String get verify => 'تحقق';

  @override
  String get changeNumber => 'تغيير الرقم';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get tokenBalance => 'رصيد الرمز';

  @override
  String get storageUsed => 'التخزين';

  @override
  String get aiTransformTitle => 'التحويل بالذكاء الاصطناعي';

  @override
  String get chooseModule => 'اختر الوحدة';

  @override
  String get moduleSpace => 'المكان';

  @override
  String get moduleWardrobe => 'خزانة الملابس';

  @override
  String get moduleKitchen => 'النظام الغذائي والمطبخ';

  @override
  String get chooseStyle => 'اختر النمط';

  @override
  String get styleBudget => 'بدون تكلفة';

  @override
  String get styleLuxury => 'فاخر';

  @override
  String get styleRainy => 'طقس ممطر';

  @override
  String get styleCozy => 'دافئ ومريح';

  @override
  String get premiumMode => 'رندر فاخر (3 رموز)';

  @override
  String get selectPhoto => 'المعرض';

  @override
  String get takePhoto => 'الكاميرا';

  @override
  String get transform => 'حوّل';

  @override
  String get uploading => 'جارٍ الرفع…';

  @override
  String get processing => 'جارٍ المعالجة…';

  @override
  String get resultTitle => 'النتيجة';

  @override
  String get analysisLabel => 'التحليل';

  @override
  String get productsLabel => 'المنتجات';

  @override
  String get buyNow => 'اشترِ الآن';

  @override
  String get diyStepsLabel => 'خطوات التنفيذ';

  @override
  String get errorInsufficientTokens => 'رصيد الرموز غير كافٍ';

  @override
  String get errorGeneric => 'حدث خطأ ما. حاول مرة أخرى.';

  @override
  String get beforeLabel => 'قبل';

  @override
  String get afterLabel => 'بعد';

  @override
  String get driveTitle => 'Estetix Drive';

  @override
  String get driveSubtitle => 'احفظ تحويلاتك وتقارير PDF';

  @override
  String get folderSpace => 'المساحة والحديقة';

  @override
  String get folderWardrobe => 'خزانة الملابس والأسلوب';

  @override
  String get folderKitchen => 'النظام الغذائي والمطبخ';

  @override
  String get emptyFolder => 'لا توجد مشاريع في هذا المجلد بعد.';

  @override
  String get saveToDrive => 'حفظ في Drive';

  @override
  String get savedToDrive => 'تم الحفظ في Drive';

  @override
  String get storageFull => 'التخزين ممتلئ. حرر مساحة لحفظ المزيد من المشاريع.';

  @override
  String get downloadPdf => 'تنزيل PDF';

  @override
  String get sharePdf => 'مشاركة PDF';

  @override
  String get storageUsage => 'استخدام التخزين';

  @override
  String get productName => 'المنتج';

  @override
  String get productPrice => 'السعر';

  @override
  String get paywallTitle => 'Estetix Pro';

  @override
  String get paywallSubtitle => 'افتح تحويلات غير محدودة ووصولاً ذا أولوية';

  @override
  String get proMonthly => 'شهري';

  @override
  String get proYearly => 'سنوي';

  @override
  String get bestValue => 'أفضل قيمة';

  @override
  String get creditsLabel => 'رصيد';

  @override
  String get watchAd => 'شاهد الإعلان واكسب +1 رصيد';

  @override
  String get restorePurchases => 'استعادة المشتريات';

  @override
  String get purchase => 'شراء';

  @override
  String get purchased => 'اكتمل الشراء';

  @override
  String get restored => 'تمت استعادة المشتريات';

  @override
  String get adWatched => 'تم كسب +1 رصيد';

  @override
  String get adUnavailable => 'الإعلان غير متاح حالياً';
}
