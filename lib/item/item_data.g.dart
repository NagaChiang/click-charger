// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../item/item_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemData _$ItemDataFromJson(Map<String, dynamic> json) {
  return ItemData(
    id: json['id'] as String,
    name: json['name'] as String,
    icon: const IconDataJsonConverter().fromJson(json['icon'] as String),
    baseProduction: (json['baseProduction'] as num)?.toDouble(),
    basePrice: json['basePrice'] == null
        ? null
        : BigInt.parse(json['basePrice'] as String),
    priceGrowthCoef: (json['priceGrowthCoef'] as num)?.toDouble(),
    upgradeId: json['upgradeId'] as String,
  );
}

Map<String, dynamic> _$ItemDataToJson(ItemData instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': const IconDataJsonConverter().toJson(instance.icon),
      'baseProduction': instance.baseProduction,
      'basePrice': instance.basePrice?.toString(),
      'priceGrowthCoef': instance.priceGrowthCoef,
      'upgradeId': instance.upgradeId,
    };
