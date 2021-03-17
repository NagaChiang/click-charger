// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameState _$GameStateFromJson(Map<String, dynamic> json) {
  return GameState()
    ..itemStates = (json['itemStates'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(
          k, e == null ? null : ItemState.fromJson(e as Map<String, dynamic>)),
    )
    ..upgradeStates = (json['upgradeStates'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k,
          e == null ? null : UpgradeState.fromJson(e as Map<String, dynamic>)),
    )
    ..totalPower = (json['totalPower'] as num)?.toDouble()
    ..antiMatterCount = json['antiMatterCount'] as int;
}

Map<String, dynamic> _$GameStateToJson(GameState instance) => <String, dynamic>{
      'itemStates': instance.itemStates,
      'upgradeStates': instance.upgradeStates,
      'totalPower': instance.totalPower,
      'antiMatterCount': instance.antiMatterCount,
    };
