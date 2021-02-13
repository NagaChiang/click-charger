import 'package:click_charger/item_state.dart';
import 'package:click_charger/upgrade_data.dart';
import 'package:click_charger/upgrade_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'game_data.dart';
import 'game_state.dart';
import 'item_data.dart';
import 'power_service.dart';
import 'utils/utils.dart';
import 'widgets/charge_button.dart';

class DashboardPage extends StatelessWidget {
  final GameData gameData;
  final GameState gameState;
  final VoidCallback onChargeButtonPressed;

  DashboardPage({
    @required this.gameData,
    @required this.gameState,
    @required this.onChargeButtonPressed,
  })  : assert(gameData != null),
        assert(gameState != null),
        assert(onChargeButtonPressed != null);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
          flex: 7,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2 / 1,
            ),
            itemCount: Utils.getUnlockedItemCount(gameState),
            itemBuilder: (BuildContext context, int index) {
              ItemData itemData = gameData.itemDatas.values.elementAt(index);
              ItemState itemState =
                  gameState.itemStates.values.elementAt(index);
              UpgradeState upgradeState =
                  gameState.upgradeStates.values.elementAt(index);

              return Card(
                child: Center(
                  child: Column(
                    children: [
                      ListTile(
                        dense: true,
                        leading: Container(
                          alignment: Alignment.center,
                          width: 15,
                          child: Icon(itemData.icon),
                        ),
                        title: Text(
                          itemData.name,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        subtitle: Row(
                          children: [
                            Text(
                              'Lv ${Utils.toFormattedNumber(upgradeState.level)}',
                              style: Theme.of(context).textTheme.caption,
                            ),
                            Spacer(),
                            Text(
                              'x ${Utils.toFormattedNumber(itemState.amount)}',
                              style: Theme.of(context).textTheme.caption,
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                              '${Utils.toFormattedNumber(PowerService.getPowerRate(gameData, gameState, itemData.id))} w/s'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Flexible(
          flex: 1,
          child: ChargeButton(onPressed: onChargeButtonPressed),
        ),
      ],
    );
  }
}
