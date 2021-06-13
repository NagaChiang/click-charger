import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../utils/constants.dart';
import '../game/game_data.dart';
import '../game/game_state.dart';
import '../item/item_state.dart';
import 'upgrade_data.dart';
import 'upgrade_list_item.dart';
import 'upgrade_state.dart';

class UpgradePage extends StatefulWidget {
  final Function(String) onItemTapped;

  const UpgradePage({Key key, this.onItemTapped})
      : assert(onItemTapped != null),
        super(key: key);

  @override
  _UpgradePageState createState() => _UpgradePageState();
}

class _UpgradePageState extends State<UpgradePage> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  int _unlockedItemCount = 0;

  @override
  Widget build(BuildContext context) {
    GameData gameData = Provider.of(context, listen: false);
    GameState gameState = Provider.of(context);

    _updateUnlockedItemCount(gameState);

    return AnimatedList(
      key: _listKey,
      padding: const EdgeInsets.all(8.0),
      initialItemCount: _unlockedItemCount,
      itemBuilder: (context, index, animation) {
        UpgradeData data = gameData.upgradeDatas.values.elementAt(index);
        UpgradeState state = gameState.upgradeStates[index];

        return UpgradeListItem(
          data: data,
          state: state,
          onItemTapped: widget.onItemTapped,
          enabled: gameState.totalPower >= data.calculatePrice(state.level),
        );
      },
    );
  }

  void _updateUnlockedItemCount(GameState gameState) {
    int newCount = _getUnlockedItemCount(gameState);
    for (int i = _unlockedItemCount; i < newCount; i++) {
      if (_listKey.currentState != null) {
        _listKey.currentState
            .insertItem(i, duration: Duration(milliseconds: 200));
      }
    }

    _unlockedItemCount = newCount;
  }

  int _getUnlockedItemCount(GameState gameState) {
    for (int i = gameState.itemStates.length - 1; i >= 0; i--) {
      ItemState itemState = gameState.itemStates[i];
      if (itemState.amount >= Constants.upgradeUnlockItemAmountThreshold) {
        return i + 1;
      }
    }

    return 1;
  }
}
