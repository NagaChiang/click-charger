import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';

import 'utils/icondata_json_converter.dart';

part 'upgrade_data.g.dart';

@JsonSerializable()
@IconDataJsonConverter()
class UpgradeData {
  final String id;
  final String name;
  final IconData icon;
  final double valuePerLevel;
  final int maxLevel;
  final double initialPrice;
  final double initialPriceGrowth;
  final double priceGrowthPerAmount;

  const UpgradeData({
    this.id,
    this.name,
    this.icon,
    this.valuePerLevel,
    this.maxLevel,
    this.initialPrice,
    this.initialPriceGrowth,
    this.priceGrowthPerAmount,
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

  double calculatePrice(int level) {
    return initialPrice +
        ((initialPriceGrowth +
                (initialPriceGrowth + priceGrowthPerAmount * (level - 1))) *
            level /
            2);
  }
}
