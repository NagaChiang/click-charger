import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import 'game_data.dart';
import 'item_state.dart';
import 'item_data.dart';
import 'upgrade_data.dart';
import 'upgrade_state.dart';
import 'utils/enums.dart';

part 'game_state.g.dart';

@JsonSerializable()
class GameState with ChangeNotifier {
  @JsonKey(ignore: true)
  bool isDebugMode = false;

  @JsonKey(defaultValue: Language.systemDefault)
  Language language = Language.systemDefault;

  Map<String, ItemState> itemStates = {};
  Map<String, UpgradeState> upgradeStates = {};
  double totalPower = 0;
  int antiMatterCount = 0;

  GameState({GameData gameData}) {
    if (gameData == null) {
      return;
    }

    for (ItemData data in gameData.itemDatas.values) {
      itemStates[data.id] = ItemState();
    }

    for (UpgradeData data in gameData.upgradeDatas.values) {
      upgradeStates[data.id] = UpgradeState();
    }
  }

  factory GameState.fromJson(Map<String, dynamic> json) =>
      _$GameStateFromJson(json);

  Map<String, dynamic> toJson() => _$GameStateToJson(this);

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

  void setLanguage(Language newLanguage) {
    if (language == newLanguage) {
      return;
    }

    language = newLanguage;
    notifyListeners();
  }

  void setDebugMode(bool isEnabled) {
    isDebugMode = isEnabled;
    notifyListeners();
  }
}
