import 'package:click_charger/item_data.dart';
import 'package:click_charger/item_state.dart';

import 'constants.dart';
import 'game_data.dart';
import 'game_state.dart';
import 'upgrade_data.dart';
import 'upgrade_state.dart';

class PowerService {
  static double getPowerRate(
    GameData gameData,
    GameState gameState,
    String itemId,
  ) {
    assert(gameData.itemDatas.containsKey(itemId));
    assert(gameState.itemStates.containsKey(itemId));

    ItemData itemData = gameData.itemDatas[itemId];
    ItemState itemState = gameState.itemStates[itemId];

    assert(gameData.upgradeDatas.containsKey(itemData.upgradeId));
    assert(gameState.upgradeStates.containsKey(itemData.upgradeId));

    UpgradeData upgradeData = gameData.upgradeDatas[itemData.upgradeId];
    UpgradeState upgradeState = gameState.upgradeStates[itemData.upgradeId];

    double bonus = upgradeData.calculateBonus(upgradeState.level);
    double rate = itemData.calculatePowerRate(bonus) * itemState.amount;

    double globalBonus = gameState.getAntimatterBonus();
    if (gameState.isBoostActive()) {
      globalBonus += Constants.boostBonus;
    }

    rate *= (1 + globalBonus);

    return rate;
  }

  static double calculateUpgradeBonus(
    GameData gameData,
    GameState gameState,
    String upgradeId,
  ) {
    assert(gameData.upgradeDatas.containsKey(upgradeId));
    assert(gameState.upgradeStates.containsKey(upgradeId));

    UpgradeData data = gameData.upgradeDatas[upgradeId];
    UpgradeState state = gameState.upgradeStates[upgradeId];

    return data.calculateBonus(state.level);
  }

  static double getPowerPerPress(GameData gameData, GameState gameState) {
    UpgradeData upgradeData = gameData.upgradeDatas['press'];
    UpgradeState upgradeState = gameState.upgradeStates['press'];
    double bonus = upgradeData.calculateBonus(upgradeState.level);
    double globalBonus = gameState.getAntimatterBonus();

    if (gameState.isBoostActive()) {
      globalBonus += Constants.boostBonus;
    }

    return 1 * (1 + bonus) * (1 + globalBonus);
  }
}