import 'dart:convert';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import 'constants.dart';
import '../game/boost_state.dart';

class RewardedAdResult {
  final DateTime nextRewardedAdTime;
  final DateTime boostEndTime;

  RewardedAdResult({
    @required this.nextRewardedAdTime,
    @required this.boostEndTime,
  });
}

class ServerApi {
  static Future<int> verifyPurchase(
    String uid,
    String productId,
    String purchaseToken,
  ) async {
    try {
      final response = await http.post(
        Constants.verifyPurchaseUri,
        body: json.encode({
          'uid': uid,
          'productId': productId,
          'purchaseToken': purchaseToken,
        }),
      );

      if (response.statusCode != HttpStatus.ok) {
        print(
          'Failed to verify purchase: ${response.body} (${response.statusCode})',
        );
        return null;
      }

      final resultBoostCount = json.decode(response.body)['result'] as int;
      return resultBoostCount;
    } catch (error, stackTrace) {
      print(error);
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason:
            '$uid failed to verify purchase for $productId ($purchaseToken)',
      );

      return null;
    }
  }

  static Future<BoostState> useBoost(String uid, int count) async {
    try {
      final response = await http.post(
        Constants.useBoostUri,
        body: json.encode({
          'uid': uid,
          'count': count,
        }),
      );

      if (response.statusCode != HttpStatus.ok) {
        print(
          'Failed to use boost: ${response.body} (${response.statusCode})',
        );
        return null;
      }

      final bodyJson = json.decode(response.body);
      final resultBoostState = BoostState(
        count: bodyJson['count'] as int,
        endTime: DateTime.tryParse(bodyJson['endTime']),
      );

      return resultBoostState;
    } catch (error, stackTrace) {
      print(error);
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: '$uid failed to use $count boost.',
      );

      return null;
    }
  }

  static Future<RewardedAdResult> rewardedAd(String uid) async {
    try {
      final response = await http.post(
        Constants.rewardedAdUri,
        body: json.encode({
          'uid': uid,
        }),
      );

      if (response.statusCode != HttpStatus.ok) {
        print(
          'Failed to earn rewarded ad: ${response.body} (${response.statusCode})',
        );
        return null;
      }

      final bodyJson = json.decode(response.body);
      final result = RewardedAdResult(
        boostEndTime: DateTime.parse(bodyJson['boostEndTime']),
        nextRewardedAdTime: DateTime.parse(bodyJson['nextRewardedAdTime']),
      );

      return result;
    } catch (error, stackTrace) {
      print(error);
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: '$uid failed to earn rewarded ad.',
      );

      return null;
    }
  }
}
