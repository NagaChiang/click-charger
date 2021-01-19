import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'inventory_list_item.dart';
import 'item_data.dart';
import 'item_state.dart';
import 'game_data.dart';
import 'game_state.dart';

class InventoryPage extends StatelessWidget {
  final GameData gameData;
  final GameState gameState;
  final Function(String) onItemTapped;

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
    for (ItemData data in gameData.itemDatas.values) {
      ItemState state = gameState.itemStates[data.id];
      itemWidgets.add(InventoryListItem(
        data: data,
        state: state,
        onItemTapped: onItemTapped,
        enabled: gameState.totalPower >= data.calculatePrice(state.amount),
      ));
    }

    return itemWidgets;
  }
}
