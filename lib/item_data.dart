import 'package:flutter/widgets.dart';

class ItemData {
  final String name;
  final IconData icon;
  final double initialPowerPerSec;
  final double initialPrice;
  final double initialPriceGrowth;
  final double priceGrowthPerAmount;

  const ItemData({
    this.name,
    this.icon,
    this.initialPowerPerSec,
    this.initialPrice,
    this.initialPriceGrowth,
    this.priceGrowthPerAmount,
  });

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
