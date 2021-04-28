import 'dart:math';

import '../constants.dart';
import '../game_state.dart';
import '../item_state.dart';

class Utils {
  static const int digitNumPerGroup = 3;
  static const int maxGroupNum = 7;

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

  static int getUnlockedItemCount(GameState gameState) {
    int count = 1;
    for (ItemState state in gameState.itemStates.values) {
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
}
