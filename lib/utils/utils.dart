import 'package:intl/intl.dart';

import '../game_state.dart';
import '../item_state.dart';

class Utils {
  static final NumberFormat _numberFormat = NumberFormat('#,###.#');

  static String toFormattedNumber(num number) {
    return _numberFormat.format(number);
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
}
