import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedAdLoader {
  final String adUnitId;
  final Function(LoadAdError) onAdFailedToLoad;
  final Function(RewardedAd, AdError) onAdFailedToShowFullScreenContent;
  final Function(RewardedAd, RewardItem) onUserEarnedReward;
  final Function onFinished;

  RewardedAdLoader({
    @required this.adUnitId,
    this.onAdFailedToLoad,
    this.onAdFailedToShowFullScreenContent,
    this.onUserEarnedReward,
    this.onFinished,
  });

  Future<void> show() async {
    await RewardedAd.load(
      adUnitId: adUnitId,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) async {
          print('[RewardedAd] onAdLoaded.');

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              print('[RewardedAd] onAdShowedFullScreenContent');
            },
            onAdDismissedFullScreenContent: (RewardedAd ad) {
              print('[RewardedAd] onAdDismissedFullScreenContent.');
              ad.dispose();
              onFinished?.call();
            },
            onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
              print('[RewardedAd] onAdFailedToShowFullScreenContent: $error');
              onAdFailedToShowFullScreenContent?.call(ad, error);
              ad.dispose();
              onFinished?.call();
            },
            onAdImpression: (RewardedAd ad) {
              print('[RewardedAd] onAdImpression.');
            },
          );

          await ad.show(
            onUserEarnedReward: (ad, item) {
              print('[RewardedAd] onUserEarnedReward');
              onUserEarnedReward?.call(ad, item);
            },
          );
        },
        onAdFailedToLoad: (error) {
          print('[RewardedAd] onAdFailedToLoad: $error');
          onAdFailedToLoad?.call(error);
          onFinished?.call();
        },
      ),
    );
  }
}
