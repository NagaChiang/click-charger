// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameState _$GameStateFromJson(Map<String, dynamic> json) {
  return GameState()
    ..language = _$enumDecodeNullable(_$LanguageEnumMap, json['language']) ??
        Language.systemDefault
    ..itemStates = (json['itemStates'] as List)
        ?.map((e) =>
            e == null ? null : ItemState.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..upgradeStates = (json['upgradeStates'] as List)
        ?.map((e) =>
            e == null ? null : UpgradeState.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..totalPower = json['totalPower'] == null
        ? null
        : BigInt.parse(json['totalPower'] as String)
    ..antiMatterCount = json['antiMatterCount'] as int
    ..boostCount = json['boostCount'] as int
    ..createdTime = json['createdTime'] == null
        ? null
        : DateTime.parse(json['createdTime'] as String)
    ..updatedTime = json['updatedTime'] == null
        ? null
        : DateTime.parse(json['updatedTime'] as String)
    ..boostEndTime = json['boostEndTime'] == null
        ? null
        : DateTime.parse(json['boostEndTime'] as String)
    ..isRemoveAd = json['isRemoveAd'] as bool ?? false;
}

Map<String, dynamic> _$GameStateToJson(GameState instance) => <String, dynamic>{
      'language': _$LanguageEnumMap[instance.language],
      'itemStates': instance.itemStates?.map((e) => e?.toJson())?.toList(),
      'upgradeStates':
          instance.upgradeStates?.map((e) => e?.toJson())?.toList(),
      'totalPower': instance.totalPower?.toString(),
      'antiMatterCount': instance.antiMatterCount,
      'boostCount': instance.boostCount,
      'createdTime': instance.createdTime?.toIso8601String(),
      'updatedTime': instance.updatedTime?.toIso8601String(),
      'boostEndTime': instance.boostEndTime?.toIso8601String(),
      'isRemoveAd': instance.isRemoveAd ?? false,
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
