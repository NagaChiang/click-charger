import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clicker/inventory_list_item.dart';
import 'package:flutter_clicker/item_data.dart';
import 'package:flutter_clicker/item_state.dart';

import 'game_data.dart';
import 'game_state.dart';

class InventoryPage extends StatelessWidget {
  final GameData gameData;
  final GameState gameState;
  final Function(int) onItemTapped;

  const InventoryPage(
      {Key key, this.gameState, this.gameData, this.onItemTapped})
      : assert(gameState != null),
        assert(gameData != null),
        assert(onItemTapped != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: ListTile.divideTiles(
        context: context,
        tiles: _buildListItems(),
      ).toList(),
    );
  }

  List<Widget> _buildListItems() {
    List<Widget> itemWidgets = [];
    for (int i = 0; i < gameData.itemDatas.length; i++) {
      ItemData data = gameData.itemDatas[i];
      ItemState state = gameState.itemStates[i];

      itemWidgets.add(InventoryListItem(
        index: i,
        data: data,
        state: state,
        onItemTapped: onItemTapped,
        enabled: gameState.totalPower >= data.calculatePrice(state.amount),
      ));
    }

    return itemWidgets;
  }
}
