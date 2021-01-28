import 'package:click_charger/upgrade_data.dart';
import 'package:click_charger/upgrade_list_item.dart';
import 'package:click_charger/upgrade_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'game_data.dart';
import 'game_state.dart';

class UpgradePage extends StatelessWidget {
  final Function(String) onItemTapped;

  const UpgradePage({Key key, this.onItemTapped})
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
    for (UpgradeData data in gameData.upgradeDatas.values) {
      UpgradeState state = gameState.upgradeStates[data.id];
      itemWidgets.add(UpgradeListItem(
        data: data,
        state: state,
        onItemTapped: onItemTapped,
        enabled: gameState.totalPower >= data.calculatePrice(state.level),
      ));
    }

    return itemWidgets;
  }
}
