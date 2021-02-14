import 'package:click_charger/upgrade_state.dart';
import 'package:flutter/foundation.dart';
import 'game_data.dart';
import 'item_state.dart';
import 'item_data.dart';
import 'upgrade_data.dart';

class GameState with ChangeNotifier {
  bool isDebugMode = false;
  Map<String, ItemState> itemStates = {};
  Map<String, UpgradeState> upgradeStates = {};
  double totalPower = 0;
  int antiMatterCount = 0;

  GameState({
    @required GameData gameData,
  }) : assert(gameData != null) {
    for (ItemData data in gameData.itemDatas.values) {
      itemStates[data.id] = ItemState();
    }

    for (UpgradeData data in gameData.upgradeDatas.values) {
      upgradeStates[data.id] = UpgradeState();
    }
  }

  double getAntimatterBonus() {
    return 0.01 * antiMatterCount;
  }

  void addPower(double power) {
    totalPower += power;
    notifyListeners();
  }

  void addItemAmount(String itemId, int amount) {
    assert(itemStates.containsKey(itemId));

    itemStates[itemId].amount += amount;
    notifyListeners();
  }

  void addUpgradeLevel(String upgradeId, int level) {
    assert(upgradeStates.containsKey(upgradeId));

    upgradeStates[upgradeId].level += level;
    notifyListeners();
  }

  void ascend(int antimatter) {
    antiMatterCount += antimatter;

    totalPower = 0;
    itemStates.updateAll((key, value) => ItemState());
    upgradeStates.updateAll((key, value) => UpgradeState());

    notifyListeners();
  }

  void setDebugMode(bool isEnabled) {
    isDebugMode = isEnabled;
    notifyListeners();
  }
}
