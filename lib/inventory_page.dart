import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'inventory_list_item.dart';
import 'item_data.dart';
import 'item_state.dart';
import 'game_data.dart';
import 'game_state.dart';
import 'power_service.dart';

class InventoryPage extends StatefulWidget {
  final Function(String) onItemTapped;

  InventoryPage({Key key, this.onItemTapped})
      : assert(onItemTapped != null),
        super(key: key);

  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  int _unlockedItemCount = 0;

  @override
  bool get wantKeepAlive => true;

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
        ItemData data = gameData.itemDatas.values.elementAt(index);
        ItemState state = gameState.itemStates[data.id];
        double bonus = PowerService.calculateUpgradeBonus(
            gameData, gameState, data.upgradeId);

        return SizeTransition(
          sizeFactor: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: InventoryListItem(
              data: data,
              state: state,
              rate: data.initialPowerPerSec * (1 + bonus),
              onItemTapped: widget.onItemTapped,
              enabled:
                  gameState.totalPower >= data.calculatePrice(state.amount),
            ),
          ),
        );
      },
    );
  }

  void _updateUnlockedItemCount(GameState gameState) {
    int newUnlockedItemCount = _getUnlockedItemCount(gameState);
    for (int index = _unlockedItemCount;
        index < newUnlockedItemCount;
        index++) {
      if (_listKey.currentState != null) {
        _listKey.currentState
            .insertItem(index, duration: Duration(milliseconds: 200));
      }
    }

    _unlockedItemCount = newUnlockedItemCount;
  }

  int _getUnlockedItemCount(GameState gameState) {
    int count = 1;
    for (ItemState state in gameState.itemStates.values) {
      if (state.amount == 0) {
        break;
      }

      count++;
    }

    return count;
  }
}
