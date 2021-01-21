// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemData _$ItemDataFromJson(Map<String, dynamic> json) {
  return ItemData(
    id: json['id'] as String,
    name: json['name'] as String,
    icon: const IconDataJsonConverter().fromJson(json['icon'] as String),
    initialPowerPerSec: (json['initialPowerPerSec'] as num)?.toDouble(),
    initialPrice: (json['initialPrice'] as num)?.toDouble(),
    initialPriceGrowth: (json['initialPriceGrowth'] as num)?.toDouble(),
    priceGrowthPerAmount: (json['priceGrowthPerAmount'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$ItemDataToJson(ItemData instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': const IconDataJsonConverter().toJson(instance.icon),
      'initialPowerPerSec': instance.initialPowerPerSec,
      'initialPrice': instance.initialPrice,
      'initialPriceGrowth': instance.initialPriceGrowth,
      'priceGrowthPerAmount': instance.priceGrowthPerAmount,
    };
