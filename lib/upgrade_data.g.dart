// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upgrade_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpgradeData _$UpgradeDataFromJson(Map<String, dynamic> json) {
  return UpgradeData(
    id: json['id'] as String,
    name: json['name'] as String,
    icon: const IconDataJsonConverter().fromJson(json['icon'] as String),
    valuePerLevel: (json['valuePerLevel'] as num)?.toDouble(),
    initialPrice: (json['initialPrice'] as num)?.toDouble(),
    initialPriceGrowth: (json['initialPriceGrowth'] as num)?.toDouble(),
    priceGrowthPerAmount: (json['priceGrowthPerAmount'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$UpgradeDataToJson(UpgradeData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': const IconDataJsonConverter().toJson(instance.icon),
      'valuePerLevel': instance.valuePerLevel,
      'initialPrice': instance.initialPrice,
      'initialPriceGrowth': instance.initialPriceGrowth,
      'priceGrowthPerAmount': instance.priceGrowthPerAmount,
    };
