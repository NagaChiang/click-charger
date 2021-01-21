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

  const ItemData({
    this.id,
    this.name,
    this.icon,
    this.initialPowerPerSec,
    this.initialPrice,
    this.initialPriceGrowth,
    this.priceGrowthPerAmount,
  });

  factory ItemData.fromJson(Map<String, dynamic> json) =>
      _$ItemDataFromJson(json);

  Map<String, dynamic> toJson() => _$ItemDataToJson(this);

  double calculatePowerRate() {
    return initialPowerPerSec; // TODO: Upgraded
  }

  double calculatePrice(int amount) {
    return initialPrice +
        ((initialPriceGrowth +
                (initialPriceGrowth + priceGrowthPerAmount * (amount - 1))) *
            amount /
            2);
  }
}
