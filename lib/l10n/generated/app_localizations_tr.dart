// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Estetix AI';

  @override
  String get appTagline => 'Yapay zekâ güzellik asistanınız';

  @override
  String get homeTitle => 'Estetix AI\'ya hoş geldiniz';

  @override
  String get homeSubtitle =>
      'Akıllı, kişiselleştirilmiş güzellik içgörüleri parmaklarınızın ucunda.';

  @override
  String welcomeMessage(String name) {
    return 'Merhaba, $name!';
  }

  @override
  String get language => 'Dil';

  @override
  String get settings => 'Ayarlar';

  @override
  String get theme => 'Tema';

  @override
  String get themeAuraDark => 'Aura Dark';

  @override
  String get getStarted => 'Başlayın';

  @override
  String get phoneLoginTitle => 'Giriş yap';

  @override
  String get phoneLabel => 'Telefon numarası';

  @override
  String get sendOtp => 'Kod gönder';

  @override
  String get otpLabel => 'Doğrulama kodu';

  @override
  String get verify => 'Doğrula';

  @override
  String get changeNumber => 'Numarayı değiştir';

  @override
  String get signOut => 'Çıkış yap';

  @override
  String get tokenBalance => 'Token bakiyesi';

  @override
  String get storageUsed => 'Depolama';

  @override
  String get aiTransformTitle => 'AI Dönüştürme';

  @override
  String get chooseModule => 'Modül seç';

  @override
  String get moduleInterior => 'İç Mekan';

  @override
  String get moduleOutdoor => 'Bahçe & Dış Mekan';

  @override
  String get moduleFashion => 'Moda & Makyaj';

  @override
  String get moduleDiet => 'Diyet & Yemek';

  @override
  String get chooseStyle => 'Stil seç';

  @override
  String get styleBudget => 'Sıfır Masraf';

  @override
  String get styleLuxury => 'Lüks';

  @override
  String get styleRainy => 'Yağmurlu Hava';

  @override
  String get styleCozy => 'Sıcak & Samimi';

  @override
  String get premiumMode => 'Lüks Render (3 token)';

  @override
  String get selectPhoto => 'Galeri';

  @override
  String get takePhoto => 'Kamera';

  @override
  String get transform => 'Dönüştür';

  @override
  String get uploading => 'Yükleniyor…';

  @override
  String get processing => 'İşleniyor…';

  @override
  String get resultTitle => 'Sonuç';

  @override
  String get analysisLabel => 'Analiz';

  @override
  String get productsLabel => 'Ürünler';

  @override
  String get buyNow => 'Satın Al';

  @override
  String get diyStepsLabel => 'Uygulama Adımları';

  @override
  String get errorInsufficientTokens => 'Yetersiz token bakiyesi';

  @override
  String get errorGeneric => 'Bir şeyler ters gitti. Tekrar dene.';

  @override
  String get beforeLabel => 'Önce';

  @override
  String get afterLabel => 'Sonra';

  @override
  String get driveTitle => 'Estetix Drive';

  @override
  String get driveSubtitle => 'Dönüşümlerinizi ve PDF raporlarınızı saklayın';

  @override
  String get folderInterior => 'İç Mekan';

  @override
  String get folderOutdoor => 'Bahçe & Dış Mekan';

  @override
  String get folderFashion => 'Moda & Makyaj';

  @override
  String get folderDiet => 'Diyet & Yemek';

  @override
  String get emptyFolder => 'Bu klasörde henüz proje yok.';

  @override
  String get saveToDrive => 'Drive\'a Kaydet';

  @override
  String get savedToDrive => 'Drive\'a kaydedildi';

  @override
  String get storageFull =>
      'Depo dolu. Yeni proje kaydetmek için alan boşaltın.';

  @override
  String get downloadPdf => 'PDF İndir';

  @override
  String get sharePdf => 'PDF Paylaş';

  @override
  String get storageUsage => 'Depo Kullanımı';

  @override
  String get productName => 'Ürün';

  @override
  String get productPrice => 'Fiyat';

  @override
  String get paywallTitle => 'Estetix Pro';

  @override
  String get paywallSubtitle =>
      'Sınırsız dönüşüm ve öncelikli erişim için yükseltin';

  @override
  String get proMonthly => 'Aylık';

  @override
  String get proYearly => 'Yıllık';

  @override
  String get bestValue => 'En Avantajlı';

  @override
  String get creditsLabel => 'Kredi';

  @override
  String get watchAd => 'Reklam İzle, +1 Kredi Kazan';

  @override
  String get restorePurchases => 'Satın Alımları Geri Yükle';

  @override
  String get purchase => 'Satın Al';

  @override
  String get purchased => 'Satın alma tamamlandı';

  @override
  String get restored => 'Satın alımlar geri yüklendi';

  @override
  String get adWatched => '+1 kredi kazandınız';

  @override
  String get adUnavailable => 'Reklam şu anda kullanılamıyor';
}
