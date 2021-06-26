import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

import '../game/game_state.dart';

class Analytics {
  static Analytics _instance;

  static Analytics get instance {
    _instance ??= Analytics._();
    return _instance;
  }

  FirebaseAnalytics _firebaseAnalytics;
  FirebaseAnalyticsObserver _firebaseAnalyticsObserver;

  FirebaseAnalyticsObserver get observer => _firebaseAnalyticsObserver;

  Analytics._() {
    _firebaseAnalytics = FirebaseAnalytics();
    _firebaseAnalyticsObserver = FirebaseAnalyticsObserver(
      analytics: _firebaseAnalytics,
    );
  }

  void setEnabled(bool enabled) {
    _firebaseAnalytics.setAnalyticsCollectionEnabled(enabled);
  }

  void setUserId(String uid) {
    _firebaseAnalytics.setUserId(uid);
  }

  Future<void> logAppOpen() async {
    await _firebaseAnalytics.logAppOpen();
  }

  Future<void> logAppResume(GameState gameState) async {
    await _firebaseAnalytics.logEvent(
      name: 'app_resume',
      parameters: {
        'gameState': gameState.toJson(),
      },
    );
  }

  Future<void> logBuild(GameState gameState, String itemId) async {
    await _firebaseAnalytics.logEvent(
      name: 'build',
      parameters: {
        'gameState': gameState.toJson(),
        'itemId': itemId,
      },
    );
  }

  Future<void> logUpgrade(GameState gameState, String upgradeId) async {
    await _firebaseAnalytics.logEvent(
      name: 'upgrade',
      parameters: {
        'gameState': gameState.toJson(),
        'upgradeId': upgradeId,
      },
    );
  }

  Future<void> logPurchase(
    GameState gameState,
    String productId,
    String purchaseToken,
  ) async {
    await _firebaseAnalytics.logEvent(
      name: 'purchase',
      parameters: {
        'gameState': gameState.toJson(),
        'productId': productId,
        'purchaseToken': purchaseToken,
      },
    );
  }

  Future<void> logUseBoost(GameState gameState) async {
    await _firebaseAnalytics.logEvent(
      name: 'use_boost',
      parameters: {
        'gameState': gameState.toJson(),
      },
    );
  }

  Future<void> logWatchAd(GameState gameState) async {
    await _firebaseAnalytics.logEvent(
      name: 'watch_ad',
      parameters: {
        'gameState': gameState.toJson(),
      },
    );
  }

  Future<void> logAscend(GameState gameState, int antimatterCount) async {
    await _firebaseAnalytics.logEvent(
      name: 'ascend',
      parameters: {
        'gameState': gameState.toJson(),
        'antimatterCount': antimatterCount,
      },
    );
  }
}
