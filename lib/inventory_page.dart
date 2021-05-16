import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'constants.dart';
import 'inventory_list_item.dart';
import 'item_data.dart';
import 'item_state.dart';
import 'game_data.dart';
import 'game_state.dart';
import 'upgrade_data.dart';
import 'power_service.dart';
import 'utils/utils.dart';

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
  void initState() {
    super.initState();

    _unlockedItemCount = Utils.getUnlockedItemCount(context.read<GameState>());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    GameData gameData = context.read<GameData>();
    GameState gameState = context.watch<GameState>();

    return AnimatedList(
      key: _listKey,
      padding: const EdgeInsets.all(8.0),
      initialItemCount: _unlockedItemCount,
      itemBuilder: (context, index, animation) {
        ItemData data = gameData.itemDatas.values.elementAt(index);
        ItemState state = gameState.itemStates[index];
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
              rate: data.baseProduction * (1 + bonus),
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
    int newUnlockedItemCount = Utils.getUnlockedItemCount(gameState);
    for (int index = _unlockedItemCount;
        index < newUnlockedItemCount;
        index++) {
      if (_listKey.currentState != null) {
        _listKey.currentState
            .insertItem(index, duration: Duration(milliseconds: 200));
      }

      _showItemUnlockedSnackBar(context, index);
    }

    _unlockedItemCount = newUnlockedItemCount;
  }

  void _checkUnlockedUpgrade(
      BuildContext context, GameState gameState, String itemId) {
    if (itemId == 'press') {
      return;
    }

    ItemState itemState = gameState.itemStates[Utils.itemIdToIndex(itemId)];
    if (itemState.amount == Constants.upgradeUnlockItemAmountThreshold) {
      _showUpgradeUnlockedSnackBar(context, itemId);
    }
  }

  void _showItemUnlockedSnackBar(BuildContext context, int itemIndex) {
    GameData gameData = context.read<GameData>();
    ItemData data = gameData.itemDatas.values.elementAt(itemIndex);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: Duration(milliseconds: 2000),
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
          data.name.tr(),
          style: Theme.of(context)
              .textTheme
              .bodyText1
              .copyWith(color: Colors.white),
        ),
        subtitle: Text(
          'item'.tr(),
          style: Theme.of(context)
              .textTheme
              .subtitle2
              .copyWith(color: Colors.white70, fontSize: 11),
        ),
        trailing: Text(
          'unlockedMessage'.tr(),
          style: Theme.of(context)
              .textTheme
              .bodyText1
              .copyWith(color: Colors.white),
        ),
      ),
    ));
  }

  void _showUpgradeUnlockedSnackBar(BuildContext context, String itemId) {
    GameData gameData = context.read<GameData>();
    ItemData itemData = gameData.itemDatas[itemId];
    UpgradeData upgradeData = gameData.upgradeDatas[itemData.upgradeId];

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: Duration(milliseconds: 2000),
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
          upgradeData.name.tr(),
          style: Theme.of(context)
              .textTheme
              .bodyText1
              .copyWith(color: Colors.white),
        ),
        subtitle: Text(
          'upgrade'.tr(),
          style: Theme.of(context)
              .textTheme
              .subtitle2
              .copyWith(color: Colors.white70, fontSize: 11),
        ),
        trailing: Text(
          'unlockedMessage'.tr(),
          style: Theme.of(context)
              .textTheme
              .bodyText1
              .copyWith(color: Colors.white),
        ),
      ),
    ));
  }
}
