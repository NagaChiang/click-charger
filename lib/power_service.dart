import 'game_data.dart';
import 'game_state.dart';
import 'upgrade_data.dart';
import 'upgrade_state.dart';

class PowerService {
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
}
