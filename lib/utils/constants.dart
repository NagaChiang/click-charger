import 'dart:ui';

class Constants {
  static const String itemDataPath = 'assets/data/item_data.json';
  static const String upgradeDataPath = 'assets/data/upgrade_data.json';

  static const int upgradeUnlockItemAmountThreshold = 3;

  static const Locale simplifiedChineseLocale =
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans');
  static const Locale traditionalChineseLocale =
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant');

  static const double boostBonus = 0.50;
  static const Duration durationPerBoost = Duration(hours: 4);

  static const int bigIntPrecision = 100;

  static const Duration saveCloudGameInterval = Duration(minutes: 30);

  static const Set<String> productIds = <String>{
    'boost',
    'boost_pack_1',
    'boost_pack_2',
    'boost_pack_3',
    'boost_pack_4',
  };

  static const String serverBaseUrl =
      'https://click-charger-server-ukep5slxwq-ue.a.run.app';
  static final Uri verifyPurchaseUri = Uri.parse('$serverBaseUrl/verify');
  static final Uri useBoostUri = Uri.parse('$serverBaseUrl/useBoost');
  static final Uri rewardedAdUri = Uri.parse('$serverBaseUrl/rewardedAd');

  static BigInt get antimatterPrice {
    if (_antimatterPrice == null) {
      _antimatterPrice = BigInt.parse('10000000000000000000000');
    }

    return _antimatterPrice;
  }

  static BigInt _antimatterPrice;
}
