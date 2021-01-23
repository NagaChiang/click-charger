import 'package:flutter/foundation.dart';

import 'game_data.dart';
import 'item_state.dart';
import 'item_data.dart';

class GameState with ChangeNotifier {
  Map<String, ItemState> itemStates = {};
  double totalPower = 0;

  GameState({
    @required GameData gameData,
  }) : assert(gameData != null) {
    for (ItemData data in gameData.itemDatas.values) {
      itemStates[data.id] = ItemState();
    }
  }
}