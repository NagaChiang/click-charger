import 'package:flutter/widgets.dart';

import '../item/item_data.dart';
import '../upgrade/upgrade_data.dart';
import '../utils/constants.dart';

class GameData {
  Map<String, ItemData> itemDatas = {};
  Map<String, UpgradeData> upgradeDatas = {};

  static Future<GameData> loadFromAssets(BuildContext context) async {
    GameData gameData = GameData();

    List<ItemData> itemDataList =
        await ItemData.loadFromAssets(context, Constants.itemDataPath);
    itemDataList.forEach((data) {
      gameData.itemDatas[data.id] = data;
    });

    List<UpgradeData> upgradeDataList =
        await UpgradeData.loadFromAssets(context, Constants.upgradeDataPath);
    upgradeDataList.forEach((data) {
      gameData.upgradeDatas[data.id] = data;
    });

    return gameData;
  }
}
