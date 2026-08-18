// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Estetix AI';

  @override
  String get appTagline => '您的 AI 美容伴侣';

  @override
  String get homeTitle => '欢迎使用 Estetix AI';

  @override
  String get homeSubtitle => '智能、个性化的美容洞察，触手可及。';

  @override
  String welcomeMessage(String name) {
    return '您好，$name！';
  }

  @override
  String get language => '语言';

  @override
  String get settings => '设置';

  @override
  String get theme => '主题';

  @override
  String get themeAuraDark => 'Aura Dark';

  @override
  String get getStarted => '开始';

  @override
  String get phoneLoginTitle => '登录';

  @override
  String get phoneLabel => '电话号码';

  @override
  String get sendOtp => '发送验证码';

  @override
  String get otpLabel => '验证码';

  @override
  String get verify => '验证';

  @override
  String get changeNumber => '更换号码';

  @override
  String get signOut => '退出登录';

  @override
  String get tokenBalance => '代币余额';

  @override
  String get storageUsed => '存储';

  @override
  String get aiTransformTitle => 'AI 改造';

  @override
  String get chooseModule => '选择模块';

  @override
  String get moduleInterior => '室内设计';

  @override
  String get moduleOutdoor => '花园与户外';

  @override
  String get moduleFashion => '时尚与美妆';

  @override
  String get moduleDiet => '饮食与美食';

  @override
  String get chooseStyle => '选择风格';

  @override
  String get styleBudget => '零花费';

  @override
  String get styleLuxury => '奢华';

  @override
  String get styleRainy => '雨天';

  @override
  String get styleCozy => '温馨';

  @override
  String get premiumMode => '高级渲染（3 代币）';

  @override
  String get selectPhoto => '相册';

  @override
  String get takePhoto => '相机';

  @override
  String get transform => '转换';

  @override
  String get uploading => '上传中…';

  @override
  String get processing => '处理中…';

  @override
  String get resultTitle => '结果';

  @override
  String get analysisLabel => '分析';

  @override
  String get productsLabel => '商品';

  @override
  String get buyNow => '立即购买';

  @override
  String get diyStepsLabel => 'DIY 步骤';

  @override
  String get errorInsufficientTokens => '代币余额不足';

  @override
  String get errorGeneric => '出错了，请重试。';

  @override
  String get beforeLabel => '之前';

  @override
  String get afterLabel => '之后';

  @override
  String get driveTitle => 'Estetix Drive';

  @override
  String get driveSubtitle => '保存您的转换和 PDF 报告';

  @override
  String get folderInterior => '室内设计';

  @override
  String get folderOutdoor => '花园与户外';

  @override
  String get folderFashion => '时尚与美妆';

  @override
  String get folderDiet => '饮食与美食';

  @override
  String get emptyFolder => '此文件夹中还没有项目。';

  @override
  String get saveToDrive => '保存到 Drive';

  @override
  String get savedToDrive => '已保存到 Drive';

  @override
  String get storageFull => '存储已满。请释放空间以保存更多项目。';

  @override
  String get downloadPdf => '下载 PDF';

  @override
  String get sharePdf => '分享 PDF';

  @override
  String get storageUsage => '存储使用情况';

  @override
  String get productName => '产品';

  @override
  String get productPrice => '价格';

  @override
  String get paywallTitle => 'Estetix Pro';

  @override
  String get paywallSubtitle => '解锁无限转换和优先访问';

  @override
  String get proMonthly => '月度';

  @override
  String get proYearly => '年度';

  @override
  String get bestValue => '最划算';

  @override
  String get creditsLabel => '积分';

  @override
  String get watchAd => '观看广告，赚取 +1 积分';

  @override
  String get restorePurchases => '恢复购买';

  @override
  String get purchase => '购买';

  @override
  String get purchased => '购买完成';

  @override
  String get restored => '购买已恢复';

  @override
  String get adWatched => '+1 积分已到账';

  @override
  String get adUnavailable => '广告暂时不可用';
}
