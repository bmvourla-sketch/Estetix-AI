// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Estetix AI';

  @override
  String get appTagline => 'AIビューティーコンパニオン';

  @override
  String get homeTitle => 'Estetix AIへようこそ';

  @override
  String get homeSubtitle => 'スマートでパーソナライズされたビューティーインサイトをすぐに。';

  @override
  String welcomeMessage(String name) {
    return 'こんにちは、$nameさん！';
  }

  @override
  String get language => '言語';

  @override
  String get settings => '設定';

  @override
  String get theme => 'テーマ';

  @override
  String get themeAuraDark => 'Aura Dark';

  @override
  String get getStarted => '始める';

  @override
  String get phoneLoginTitle => 'サインイン';

  @override
  String get phoneLabel => '電話番号';

  @override
  String get sendOtp => 'コードを送信';

  @override
  String get otpLabel => '認証コード';

  @override
  String get verify => '確認';

  @override
  String get changeNumber => '番号を変更';

  @override
  String get signOut => 'サインアウト';

  @override
  String get tokenBalance => 'トークン残高';

  @override
  String get storageUsed => 'ストレージ';

  @override
  String get aiTransformTitle => 'AI変換';

  @override
  String get chooseModule => 'モジュールを選択';

  @override
  String get moduleInterior => 'インテリア';

  @override
  String get moduleOutdoor => '庭・屋外';

  @override
  String get moduleFashion => 'ファッション・メイク';

  @override
  String get moduleDiet => 'ダイエット・料理';

  @override
  String get chooseStyle => 'スタイルを選択';

  @override
  String get styleBudget => 'ゼロコスト';

  @override
  String get styleLuxury => 'ラグジュアリー';

  @override
  String get styleRainy => '雨の日';

  @override
  String get styleCozy => '居心地の良い';

  @override
  String get premiumMode => 'プレミアムレンダー（3トークン）';

  @override
  String get selectPhoto => 'ギャラリー';

  @override
  String get takePhoto => 'カメラ';

  @override
  String get transform => '変換する';

  @override
  String get uploading => 'アップロード中…';

  @override
  String get processing => '処理中…';

  @override
  String get resultTitle => '結果';

  @override
  String get analysisLabel => '分析';

  @override
  String get productsLabel => '商品';

  @override
  String get buyNow => '今すぐ購入';

  @override
  String get diyStepsLabel => 'DIY手順';

  @override
  String get errorInsufficientTokens => 'トークン残高が不足しています';

  @override
  String get errorGeneric => '問題が発生しました。もう一度お試しください。';

  @override
  String get beforeLabel => '前';

  @override
  String get afterLabel => '後';

  @override
  String get driveTitle => 'Estetix Drive';

  @override
  String get driveSubtitle => '変換とPDFレポートを保存';

  @override
  String get folderInterior => 'インテリア';

  @override
  String get folderOutdoor => '庭・屋外';

  @override
  String get folderFashion => 'ファッション・メイク';

  @override
  String get folderDiet => 'ダイエット・料理';

  @override
  String get emptyFolder => 'このフォルダにはまだプロジェクトがありません。';

  @override
  String get saveToDrive => 'Driveに保存';

  @override
  String get savedToDrive => 'Driveに保存しました';

  @override
  String get storageFull => 'ストレージがいっぱいです。空き容量を増やしてください。';

  @override
  String get downloadPdf => 'PDFをダウンロード';

  @override
  String get sharePdf => 'PDFを共有';

  @override
  String get storageUsage => 'ストレージ使用量';

  @override
  String get productName => '商品';

  @override
  String get productPrice => '価格';

  @override
  String get paywallTitle => 'Estetix Pro';

  @override
  String get paywallSubtitle => '無制限の変換と優先アクセスを解除';

  @override
  String get proMonthly => '月額';

  @override
  String get proYearly => '年額';

  @override
  String get bestValue => 'お得';

  @override
  String get creditsLabel => 'クレジット';

  @override
  String get watchAd => '広告を見て+1クレジット獲得';

  @override
  String get restorePurchases => '購入を復元';

  @override
  String get purchase => '購入';

  @override
  String get purchased => '購入が完了しました';

  @override
  String get restored => '購入を復元しました';

  @override
  String get adWatched => '+1クレジット獲得';

  @override
  String get adUnavailable => '現在広告を利用できません';
}
