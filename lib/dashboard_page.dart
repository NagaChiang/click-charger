import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'game_data.dart';
import 'game_state.dart';
import 'item_data.dart';
import 'item_state.dart';
import 'power_service.dart';
import 'upgrade_state.dart';
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
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Flexible(
                child: Card(
                  child: SizedBox.expand(
                    child: Center(
                      child: ListTile(
                        dense: true,
                        leading: Container(
                          width: 30,
                          alignment: Alignment.center,
                          child: Icon(Icons.flash_on),
                        ),
                        title: Text(
                            '${Utils.toFormattedNumber(PowerService.getPowerPerPress(gameData, gameState))} w/press'),
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                child: Card(
                  child: SizedBox.expand(
                    child: Center(
                      child: ListTile(
                        dense: true,
                        leading: Container(
                          width: 30,
                          alignment: Alignment.center,
                          child: Icon(Icons.api),
                        ),
                        title: Text('Antimatter'),
                        subtitle: Row(
                          children: [
                            Text('x 0'),
                            Spacer(),
                            Text('(+0%)'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
