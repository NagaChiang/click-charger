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
    basePrice: json['basePrice'] == null
        ? null
        : BigInt.parse(json['basePrice'] as String),
    priceGrowthCoef: (json['priceGrowthCoef'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$UpgradeDataToJson(UpgradeData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': const IconDataJsonConverter().toJson(instance.icon),
      'valuePerLevel': instance.valuePerLevel,
      'basePrice': instance.basePrice?.toString(),
      'priceGrowthCoef': instance.priceGrowthCoef,
    };
