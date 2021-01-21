import 'package:flutter/widgets.dart';

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

  double calculatePrice(int level) {
    return initialPrice +
        ((initialPriceGrowth +
                (initialPriceGrowth + priceGrowthPerAmount * (level - 1))) *
            level /
            2);
  }
}
