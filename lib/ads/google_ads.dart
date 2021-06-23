import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class GoogleAds {
  static String get bannerId => kReleaseMode
      ? 'ca-app-pub-4921712279387990/7019021451'
      : BannerAd.testAdUnitId;

  static String get rewardedId => kReleaseMode
      ? 'ca-app-pub-4921712279387990/6242522604'
      : RewardedAd.testAdUnitId;
}
