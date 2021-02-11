import 'package:click_charger/upgrade_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'constants.dart';
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

  int _unlockedItemCount = 1;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    GameData gameData = Provider.of(context, listen: false);
    GameState gameState = Provider.of(context);

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
              onItemTapped: (String itemId) {
                widget.onItemTapped.call(itemId);
                _checkUnlockedItem(context, gameState);
                _checkUnlockedUpgrade(context, gameState, itemId);
              },
              enabled:
                  gameState.totalPower >= data.calculatePrice(state.amount),
            ),
          ),
        );
      },
    );
  }

  void _checkUnlockedItem(BuildContext context, GameState gameState) {
    int newUnlockedItemCount = _getUnlockedItemCount(gameState);
    for (int index = _unlockedItemCount;
        index < newUnlockedItemCount;
        index++) {
      if (_listKey.currentState != null) {
        _listKey.currentState
            .insertItem(index, duration: Duration(milliseconds: 200));
      }

      String itemId = gameState.itemStates.keys.elementAt(index);
      _showItemUnlockedSnackBar(context, itemId);
    }

    _unlockedItemCount = newUnlockedItemCount;
  }

  void _checkUnlockedUpgrade(
      BuildContext context, GameState gameState, String itemId) {
    if (itemId == 'press') {
      return;
    }

    ItemState itemState = gameState.itemStates[itemId];
    if (itemState.amount == Constants.upgradeUnlockItemAmountThreshold) {
      _showUpgradeUnlockedSnackBar(context, itemId);
    }
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

  void _showItemUnlockedSnackBar(BuildContext context, String itemId) {
    GameData gameData = Provider.of<GameData>(context, listen: false);
    ItemData data = gameData.itemDatas[itemId];

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: ListTile(
        leading: Container(
          width: 40,
          alignment: Alignment.center,
          child: Icon(
            data.icon,
            color: Colors.white,
          ),
        ),
        title: Text(
          data.name,
          style: Theme.of(context)
              .textTheme
              .bodyText1
              .copyWith(color: Colors.white),
        ),
        subtitle: Text(
          'Item',
          style: Theme.of(context)
              .textTheme
              .subtitle2
              .copyWith(color: Colors.white70, fontSize: 11),
        ),
        trailing: Text(
          'Unlocked!',
          style: Theme.of(context)
              .textTheme
              .bodyText1
              .copyWith(color: Colors.white),
        ),
      ),
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _showUpgradeUnlockedSnackBar(BuildContext context, String itemId) {
    GameData gameData = Provider.of<GameData>(context, listen: false);
    ItemData itemData = gameData.itemDatas[itemId];
    UpgradeData upgradeData = gameData.upgradeDatas[itemData.upgradeId];

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: ListTile(
        leading: Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          child: Container(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Icon(
                    upgradeData.icon,
                    color: Colors.white,
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Icon(
                    Icons.add,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        title: Text(
          upgradeData.name,
          style: Theme.of(context)
              .textTheme
              .bodyText1
              .copyWith(color: Colors.white),
        ),
        subtitle: Text(
          'Upgrade',
          style: Theme.of(context)
              .textTheme
              .subtitle2
              .copyWith(color: Colors.white70, fontSize: 11),
        ),
        trailing: Text(
          'Unlocked!',
          style: Theme.of(context)
              .textTheme
              .bodyText1
              .copyWith(color: Colors.white),
        ),
      ),
      behavior: SnackBarBehavior.floating,
    ));
  }
}
