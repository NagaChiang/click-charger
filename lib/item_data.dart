import 'dart:convert';

import 'package:click_charger/utils/icondata_json_converter.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:flutter/widgets.dart';

part 'item_data.g.dart';

@JsonSerializable()
@IconDataJsonConverter()
class ItemData {
  final String id;
  final String name;
  final IconData icon;
  final double initialPowerPerSec;
  final double initialPrice;
  final double initialPriceGrowth;
  final double priceGrowthPerAmount;
  final String upgradeId;

  const ItemData({
    this.id,
    this.name,
    this.icon,
    this.initialPowerPerSec,
    this.initialPrice,
    this.initialPriceGrowth,
    this.priceGrowthPerAmount,
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
    return initialPowerPerSec * (1 + bonus);
  }

  double calculatePrice(int amount) {
    return initialPrice +
        ((initialPriceGrowth +
                (initialPriceGrowth + priceGrowthPerAmount * (amount - 1))) *
            amount /
            2);
  }
}
