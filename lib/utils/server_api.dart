import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'constants.dart';
import '../game/boost_state.dart';

class ServerApi {
  static Future<int> verifyPurchase(
    String uid,
    String productId,
    String purchaseId,
  ) async {
    try {
      final response = await http.post(
        Constants.verifyPurchaseUri,
        body: json.encode({
          'uid': uid,
          'productId': productId,
          'purchaseToken': purchaseId,
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
    } catch (error) {
      print(error);
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
    } catch (error) {
      print(error);
      return null;
    }
  }
}
