import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'inventory_list_item.dart';
import 'item_data.dart';
import 'item_state.dart';
import 'game_data.dart';
import 'game_state.dart';
import 'power_service.dart';

class InventoryPage extends StatelessWidget {
  final Function(String) onItemTapped;

  const InventoryPage({Key key, this.onItemTapped})
      : assert(onItemTapped != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: ListTile.divideTiles(
        context: context,
        tiles: _buildListItems(context),
      ).toList(),
    );
  }

  List<Widget> _buildListItems(BuildContext context) {
    GameData gameData = Provider.of(context, listen: false);
    GameState gameState = Provider.of(context);

    List<Widget> itemWidgets = [];
    for (ItemData data in gameData.itemDatas.values) {
      ItemState state = gameState.itemStates[data.id];
      double bonus = PowerService.calculateUpgradeBonus(
          gameData, gameState, data.upgradeId);

      itemWidgets.add(InventoryListItem(
        data: data,
        state: state,
        rate: data.initialPowerPerSec * (1 + bonus),
        onItemTapped: onItemTapped,
        enabled: gameState.totalPower >= data.calculatePrice(state.amount),
      ));
    }

    return itemWidgets;
  }
}
