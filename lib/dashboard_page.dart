import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'constants.dart';
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
  final Function onChargeButtonPressed;
  final Function(Function) onAscensionButtonPressed;

  DashboardPage({
    @required this.gameData,
    @required this.gameState,
    @required this.onChargeButtonPressed,
    @required this.onAscensionButtonPressed,
  })  : assert(gameData != null),
        assert(gameState != null),
        assert(onChargeButtonPressed != null),
        assert(onAscensionButtonPressed != null);

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
              gameState.antiMatterCount > 0
                  ? Flexible(
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
                                  Text(
                                      'x ${Utils.toFormattedNumber(gameState.antiMatterCount)}'),
                                  Spacer(),
                                  Text(
                                      '(+${Utils.toFormattedNumber(gameState.antiMatterCount)}%)'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Spacer(),
            ],
          ),
        ),
        Divider(
          indent: 40,
          endIndent: 40,
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
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
              );
            },
          ),
        ),
        Divider(
          indent: 40,
          endIndent: 40,
        ),
        Flexible(
          flex: 1,
          child: Row(
            children: [
              Spacer(),
              Flexible(
                fit: FlexFit.tight,
                child: ChargeButton(onPressed: onChargeButtonPressed),
              ),
              _isAscensionAvailable()
                  ? Flexible(
                      fit: FlexFit.tight,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: ElevatedButton(
                          onPressed: () {
                            _showAscensionDialog(context);
                          },
                          child: Text('Ascend'),
                        ),
                      ),
                    )
                  : Spacer(),
            ],
          ),
        ),
      ],
    );
  }

  bool _isAscensionAvailable() {
    return gameState.upgradeStates.values.last.level > 0;
  }

  Future<void> _showAscensionDialog(BuildContext context) async {
    int convertedAntimatterCount = _getConvertedAntimatterCount();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Ascension',
            style: Theme.of(context).textTheme.headline5,
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(
                    'Ascending will reset your game and convert your current power into antimatters, which provide permanent universal bonus.'),
                Text(''),
                Text(
                    'You will obtain $convertedAntimatterCount antimatter(s) (+$convertedAntimatterCount%).'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Ascend'),
              onPressed: convertedAntimatterCount > 0
                  ? () {
                      Navigator.of(context).pop();
                      onAscensionButtonPressed?.call(() {
                        gameState.ascend(convertedAntimatterCount);
                      });
                    }
                  : null,
            )
          ],
        );
      },
    );
  }

  int _getConvertedAntimatterCount() {
    return (gameState.totalPower / Constants.antimatterPrice).floor();
  }
}
