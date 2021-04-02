// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameState _$GameStateFromJson(Map<String, dynamic> json) {
  return GameState()
    ..language = _$enumDecodeNullable(_$LanguageEnumMap, json['language']) ??
        Language.systemDefault
    ..itemStates = (json['itemStates'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(
          k, e == null ? null : ItemState.fromJson(e as Map<String, dynamic>)),
    )
    ..upgradeStates = (json['upgradeStates'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k,
          e == null ? null : UpgradeState.fromJson(e as Map<String, dynamic>)),
    )
    ..totalPower = (json['totalPower'] as num)?.toDouble()
    ..antiMatterCount = json['antiMatterCount'] as int
    ..boostEndTime = json['boostEndTime'] == null
        ? null
        : DateTime.parse(json['boostEndTime'] as String);
}

Map<String, dynamic> _$GameStateToJson(GameState instance) => <String, dynamic>{
      'language': _$LanguageEnumMap[instance.language],
      'itemStates': instance.itemStates,
      'upgradeStates': instance.upgradeStates,
      'totalPower': instance.totalPower,
      'antiMatterCount': instance.antiMatterCount,
      'boostEndTime': instance.boostEndTime?.toIso8601String(),
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$LanguageEnumMap = {
  Language.systemDefault: 'systemDefault',
  Language.english: 'english',
  Language.traditionalChinese: 'traditionalChinese',
  Language.simplifiedChinese: 'simplifiedChinese',
  Language.japanese: 'japanese',
};
