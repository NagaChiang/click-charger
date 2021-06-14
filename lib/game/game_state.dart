import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/constants.dart';
import 'game_data.dart';
import '../item/item_state.dart';
import '../upgrade/upgrade_state.dart';
import '../utils/enums.dart';
import '../utils/utils.dart';

part 'game_state.g.dart';

@JsonSerializable(explicitToJson: true)
class GameState with ChangeNotifier {
  @JsonKey(ignore: true)
  bool isDebugMode = false;

  @JsonKey(defaultValue: Language.systemDefault)
  Language language = Language.systemDefault;

  List<ItemState> itemStates = [];
  List<UpgradeState> upgradeStates = [];
  BigInt totalPower = BigInt.zero;
  int antiMatterCount = 0;
  int boostCount = 0;

  DateTime createdTime = DateTime.now();
  DateTime updatedTime = DateTime.now();
  DateTime boostEndTime = DateTime.now();

  bool isRemoveAd = false;

  GameState({GameData gameData}) {
    if (gameData == null) {
      return;
    }

    itemStates = List.filled(gameData.itemDatas.length, ItemState());
    upgradeStates = List.filled(gameData.upgradeDatas.length, UpgradeState());
  }

  factory GameState.fromJson(Map<String, dynamic> json) =>
      _$GameStateFromJson(json);

  factory GameState.fromFirestoreJson(Map<String, dynamic> json) {
    return GameState()
      ..language = _$enumDecodeNullable(_$LanguageEnumMap, json['language']) ??
          Language.systemDefault
      ..itemStates = (json['itemStates'] as List)
          ?.map((e) =>
              e == null ? null : ItemState.fromJson(e as Map<String, dynamic>))
          ?.toList()
      ..upgradeStates = (json['upgradeStates'] as List)
          ?.map((e) => e == null
              ? null
              : UpgradeState.fromJson(e as Map<String, dynamic>))
          ?.toList()
      ..totalPower = json['totalPower'] == null
          ? null
          : BigInt.parse(json['totalPower'] as String)
      ..antiMatterCount = json['antiMatterCount'] as int
      ..boostCount = json['boostCount'] as int
      ..createdTime = json['createdTime'] == null
          ? null
          : (json['createdTime'] as Timestamp).toDate()
      ..updatedTime = json['updatedTime'] == null
          ? null
          : (json['updatedTime'] as Timestamp).toDate()
      ..boostEndTime = json['boostEndTime'] == null
          ? null
          : (json['boostEndTime'] as Timestamp).toDate()
      ..isRemoveAd = json['isRemoveAd'] as bool ?? false;
  }

  Map<String, dynamic> toJson() => _$GameStateToJson(this);

  Map<String, dynamic> toFirestoreJson() {
    Map<String, dynamic> data = toJson();
    data['createdTime'] = Timestamp.fromDate(createdTime);
    data['updatedTime'] = Timestamp.fromDate(updatedTime);
    data['boostEndTime'] = Timestamp.fromDate(boostEndTime);

    return data;
  }

  double getAntimatterBonus() {
    return 0.01 * antiMatterCount;
  }

  void addPower(BigInt power) {
    totalPower += power;
    updatedTime = DateTime.now();
    notifyListeners();
  }

  void addItemAmount(String itemId, int amount) {
    itemStates[Utils.itemIdToIndex(itemId)].amount += amount;
    notifyListeners();
  }

  void addUpgradeLevel(String upgradeId, int level) {
    upgradeStates[Utils.upgradeIdToIndex(upgradeId)].level += level;
    notifyListeners();
  }

  void ascend(int antimatter) {
    antiMatterCount += antimatter;

    totalPower = BigInt.zero;
    itemStates.fillRange(0, itemStates.length, ItemState());
    upgradeStates.fillRange(0, upgradeStates.length, UpgradeState());

    notifyListeners();
  }

  void setLanguage(Language newLanguage) {
    if (language == newLanguage) {
      return;
    }

    language = newLanguage;
    notifyListeners();
  }

  void setBoostCount(int count) {
    if (boostCount == count) {
      return;
    }

    boostCount = count;
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
