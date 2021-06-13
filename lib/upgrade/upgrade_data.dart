import 'dart:convert';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';

import '../utils/icondata_json_converter.dart';
import '../utils/utils.dart';

part 'upgrade_data.g.dart';

@JsonSerializable()
@IconDataJsonConverter()
class UpgradeData {
  final String id;
  final String name;
  final IconData icon;
  final double valuePerLevel;
  final BigInt basePrice;
  final double priceGrowthCoef;

  const UpgradeData({
    this.id,
    this.name,
    this.icon,
    this.valuePerLevel,
    this.basePrice,
    this.priceGrowthCoef,
  });

  static Future<List<UpgradeData>> loadFromAssets(
    BuildContext context,
    String path,
  ) async {
    String jsonString = await DefaultAssetBundle.of(context).loadString(path);
    List<UpgradeData> dataList = List<UpgradeData>.from(
        json.decode(jsonString).map((j) => UpgradeData.fromJson(j)));

    return dataList;
  }

  factory UpgradeData.fromJson(Map<String, dynamic> json) =>
      _$UpgradeDataFromJson(json);

  Map<String, dynamic> toJson() => _$UpgradeDataToJson(this);

  double calculateBonus(int level) {
    return valuePerLevel * level;
  }

  BigInt calculatePrice(int owned) {
    return Utils.multiply(basePrice, pow(priceGrowthCoef, owned));
  }
}
