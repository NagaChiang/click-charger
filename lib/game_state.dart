import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import 'constants.dart';
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
  BigInt totalPower = BigInt.zero;
  int antiMatterCount = 0;
  int boostCount = 0;
  DateTime boostEndTime = DateTime.now();

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

  void addPower(BigInt power) {
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

    totalPower = BigInt.zero;
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

  void addBoostCount(int count) {
    boostCount += count;
    notifyListeners();
  }

  void useBoost(int count) {
    assert(boostCount >= count);
    if (boostCount < count) {
      print('Trying to use $count boosts when you only have $boostCount.');
      return;
    }

    boostCount -= count;

    Duration boostDuration = Constants.durationPerBoost * count;
    if (boostEndTime.isAfter(DateTime.now())) {
      boostEndTime = boostEndTime.add(boostDuration);
    } else {
      boostEndTime = DateTime.now().add(boostDuration);
    }

    notifyListeners();
  }

  bool isBoostActive() {
    return boostEndTime.isAfter(DateTime.now());
  }

  void setDebugMode(bool isEnabled) {
    isDebugMode = isEnabled;
    notifyListeners();
  }
}
