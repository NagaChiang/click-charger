import 'dart:ui';

class Constants {
  static const String itemDataPath = 'assets/data/item_data.json';
  static const String upgradeDataPath = 'assets/data/upgrade_data.json';

  static const int upgradeUnlockItemAmountThreshold = 3;
  static const int antimatterPrice = 100000000000000;

  static const Locale simplifiedChineseLocale =
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans');
  static const Locale traditionalChineseLocale =
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant');
}
