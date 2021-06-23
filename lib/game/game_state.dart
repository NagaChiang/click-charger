import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'boost_state.dart';
import 'game_data.dart';
import '../item/item_state.dart';
import '../upgrade/upgrade_state.dart';
import '../utils/enums.dart';
import '../utils/utils.dart';
import '../utils/server_api.dart';

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

    itemStates = List.generate(
      gameData.itemDatas.length,
      (index) => ItemState(),
    );

    upgradeStates = List.generate(
      gameData.upgradeDatas.length,
      (index) => UpgradeState(),
    );
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
    itemStates = List.generate(
      itemStates.length,
      (index) => ItemState(),
    );

    upgradeStates = List.generate(
      upgradeStates.length,
      (index) => UpgradeState(),
    );

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

  void removeAd() {
    if (isRemoveAd) {
      return;
    }

    isRemoveAd = true;
    notifyListeners();
  }

  Future<BoostState> useBoost(int count) async {
    assert(boostCount >= count);
    if (boostCount < count) {
      print('Trying to use $count boosts when you only have $boostCount.');
      return null;
    }

    final uid = FirebaseAuth.instance.currentUser.uid;
    final newBoostState = await ServerApi.useBoost(uid, count);
    if (newBoostState == null) {
      return null;
    }

    boostCount = newBoostState.count;
    boostEndTime = newBoostState.endTime;

    notifyListeners();

    return newBoostState;
  }

  bool isBoostActive() {
    return boostEndTime.isAfter(DateTime.now());
  }

  void setDebugMode(bool isEnabled) {
    isDebugMode = isEnabled;
    notifyListeners();
  }
}
