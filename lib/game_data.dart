import 'dart:convert';

import 'package:flutter/widgets.dart';

import 'item_data.dart';
import 'constants.dart';

class GameData {
  Map<String, ItemData> itemDatas = {};

  Future load(BuildContext context) async {
    String itemDataString =
        await DefaultAssetBundle.of(context).loadString(Constants.itemDataPath);
    List<ItemData> itemDataList = List<ItemData>.from(
        json.decode(itemDataString).map((j) => ItemData.fromJson(j)));
    itemDataList.forEach((data) {
      itemDatas[data.id] = data;
    });
  }
}
