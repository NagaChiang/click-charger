import 'package:flutter/material.dart';

import 'item_data.dart';

class GameData {
  List<ItemData> itemDatas = [
    ItemData(
      name: 'Auto Presser',
      icon: Icons.pan_tool,
      initialPowerPerSec: 0.1,
      initialPrice: 10,
      initialPriceGrowth: 1,
      priceGrowthPerAmount: 1,
    ),
    ItemData(
      name: 'Hamster Wheel',
      icon: Icons.pest_control_rodent,
      initialPowerPerSec: 2,
      initialPrice: 100,
      initialPriceGrowth: 10,
      priceGrowthPerAmount: 5,
    ),
    ItemData(
      name: 'Solar Panel',
      icon: Icons.brightness_5,
      initialPowerPerSec: 10,
      initialPrice: 800,
      initialPriceGrowth: 100,
      priceGrowthPerAmount: 20,
    ),
  ];
}
