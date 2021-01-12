import 'package:flutter/foundation.dart';
import 'package:flutter_clicker/game_data.dart';
import 'package:flutter_clicker/item_state.dart';

import 'item_data.dart';

class GameState {
  List<ItemState> itemStates = [];
  double totalPower = 0;

  GameState({@required GameData gameData}) : assert(gameData != null) {
    for (ItemData data in gameData.itemDatas) {
      itemStates.add(ItemState());
    }
  }
}
