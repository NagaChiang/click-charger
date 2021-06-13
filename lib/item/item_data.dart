import 'dart:convert';
import 'dart:math';

import 'package:click_charger/utils/icondata_json_converter.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:flutter/widgets.dart';

import '../utils/utils.dart';

part 'item_data.g.dart';

@JsonSerializable()
@IconDataJsonConverter()
class ItemData {
  final String id;
  final String name;
  final IconData icon;
  final double baseProduction;
  final BigInt basePrice;
  final double priceGrowthCoef;
  final String upgradeId;

  const ItemData({
    this.id,
    this.name,
    this.icon,
    this.baseProduction,
    this.basePrice,
    this.priceGrowthCoef,
    this.upgradeId,
  });

  static Future<List<ItemData>> loadFromAssets(
    BuildContext context,
    String path,
  ) async {
    String jsonString = await DefaultAssetBundle.of(context).loadString(path);
    List<ItemData> dataList = List<ItemData>.from(
        json.decode(jsonString).map((j) => ItemData.fromJson(j)));

    return dataList;
  }

  factory ItemData.fromJson(Map<String, dynamic> json) =>
      _$ItemDataFromJson(json);

  Map<String, dynamic> toJson() => _$ItemDataToJson(this);

  double calculatePowerRate(double bonus) {
    return baseProduction * (1 + bonus);
  }

  BigInt calculatePrice(int owned) {
    return Utils.multiply(basePrice, pow(priceGrowthCoef, owned));
  }
}
