import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';
import '../game_state.dart';
import '../item_state.dart';

class Utils {
  static const int digitNumPerGroup = 3;
  static const int maxGroupNum = 7;

  static const Map<String, int> _itemIdToIndexMap = {
    'press': 0,
    'item_01': 1,
    'item_02': 2,
    'item_03': 3,
    'item_04': 4,
    'item_05': 5,
    'item_06': 6,
    'item_07': 7,
    'item_08': 8,
    'item_09': 9,
  };

  static const Map<String, int> _upgradeIdToIndexMap = {
    'press': 0,
    'upgrade_01': 1,
    'upgrade_02': 2,
    'upgrade_03': 3,
    'upgrade_04': 4,
    'upgrade_05': 5,
    'upgrade_06': 6,
    'upgrade_07': 7,
    'upgrade_08': 8,
    'upgrade_09': 9,
  };

  static String toFormattedNumber(BigInt number) {
    String numberStr = number.toString();
    int groupNum = min(numberStr.length ~/ digitNumPerGroup, maxGroupNum);
    int intNum = numberStr.length - (groupNum * digitNumPerGroup);
    if (intNum == 0) {
      intNum = digitNumPerGroup;
      groupNum -= 1;
    }

    String formattedStr = '';
    for (int end = intNum; end > 0; end -= digitNumPerGroup) {
      if (end < intNum) {
        formattedStr = ',$formattedStr';
      }

      int start = max(end - digitNumPerGroup, 0);
      formattedStr = '${numberStr.substring(start, end)}$formattedStr';
    }

    if (numberStr.length > intNum) {
      formattedStr +=
          '.${numberStr.substring(intNum, intNum + digitNumPerGroup)}';
    }

    formattedStr += getFormattedNumberSuffix(groupNum);

    return formattedStr;
  }

  static String getFormattedNumberSuffix(int groupNum) {
    switch (groupNum) {
      case 0:
        return '';
      case 1:
        return 'k';
      case 2:
        return 'M';
      case 3:
        return 'G';
      case 4:
        return 'T';
      case 5:
        return 'P';
      case 6:
        return 'E';
      case 7:
      default:
        return 'Z';
    }
  }

  static int itemIdToIndex(String itemId) {
    assert(_itemIdToIndexMap.containsKey(itemId));
    if (!_itemIdToIndexMap.containsKey(itemId)) {
      print('Error: Invalid item ID = $itemId');
      return 0;
    }

    return _itemIdToIndexMap[itemId];
  }

  static int upgradeIdToIndex(String upgradeId) {
    assert(_upgradeIdToIndexMap.containsKey(upgradeId));
    if (!_upgradeIdToIndexMap.containsKey(upgradeId)) {
      print('Error: Invalid upgrade ID = $upgradeId');
      return 0;
    }

    return _upgradeIdToIndexMap[upgradeId];
  }

  static int getUnlockedItemCount(GameState gameState) {
    int count = 1;
    for (ItemState state in gameState.itemStates) {
      if (state.amount == 0 || count == gameState.itemStates.length) {
        break;
      }

      count++;
    }

    return count;
  }

  static BigInt multiply(BigInt bigInt, double mul) {
    return bigInt *
        BigInt.from(mul * Constants.bigIntPrecision) ~/
        BigInt.from(Constants.bigIntPrecision);
  }

  static Future linkWithGooglePlayGames() async {
    User user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    AuthCredential credential = await createGoogleCredential();
    if (credential != null) {
      await user.linkWithCredential(credential);
    }
  }

  static Future<AuthCredential> createGoogleCredential() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      signInOption: SignInOption.games,
      scopes: ['email'],
    );

    final GoogleSignInAccount googleUser =
        await googleSignIn.signIn().catchError((error) {
      print('Failed to sign in with Google Play Games: $error');
    });

    if (googleUser == null) {
      print('Failed to sign in with Google Play Games.');
      return null;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return credential;
  }

  static void showLoadingOverlay(
    BuildContext context, {
    bool showProgressIndicator = true,
  }) {
    showDialog(
      context: context,
      builder: (context) => Container(
        child: showProgressIndicator
            ? Center(child: CircularProgressIndicator())
            : null,
      ),
      barrierDismissible: false,
    );
  }

  static Future<int> verifyPurchase(String uid, String purchaseId) async {
    try {
      final response = await http.post(
        Constants.verifyPurchaseUri,
        body: json.encode({
          'uid': uid,
          'purchaseToken': purchaseId,
        }),
      );

      final resultBoostCount = json.decode(response.body)['result'] as int;
      return resultBoostCount;
    } catch (error) {
      print(error);
      return null;
    }
  }
}
