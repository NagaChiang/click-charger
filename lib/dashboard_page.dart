import 'package:easy_localization/easy_localization.dart';
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
import 'utils/google_ads.dart';
import 'utils/utils.dart';
import 'widgets/banner_ad_widget.dart';
import 'widgets/fancy_button.dart';

class DashboardPage extends StatefulWidget {
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
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool isShowAds = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isShowAds)
          Flexible(
            child: BannerAdWidget(
              adUnitId: GoogleAds.bannerId,
              onAdFailedToLoad: () {
                setState(() {
                  isShowAds = false;
                });
              },
            ),
          ),
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
                            '${Utils.toFormattedNumber(BigInt.from(PowerService.getPowerPerPress(widget.gameData, widget.gameState)))} ${'watt'.tr()}/${'press'.tr()}'),
                      ),
                    ),
                  ),
                ),
              ),
              widget.gameState.antiMatterCount > 0
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
                              title: Text('antimatter'.tr()),
                              subtitle: Row(
                                children: [
                                  Text(
                                      'x ${Utils.toFormattedNumber(BigInt.from(widget.gameState.antiMatterCount))}'),
                                  Spacer(),
                                  Text(
                                      '(+${Utils.toFormattedNumber(BigInt.from(widget.gameState.antiMatterCount))}%)'),
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
            itemCount: Utils.getUnlockedItemCount(widget.gameState),
            itemBuilder: (BuildContext context, int index) {
              ItemData itemData =
                  widget.gameData.itemDatas.values.elementAt(index);
              ItemState itemState = widget.gameState.itemStates[index];
              UpgradeState upgradeState = widget.gameState.upgradeStates[index];

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
                        itemData.name.tr(),
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      subtitle: Row(
                        children: [
                          Text(
                            '${'level'.tr()} ${Utils.toFormattedNumber(BigInt.from(upgradeState.level))}',
                            style: Theme.of(context).textTheme.caption,
                          ),
                          Spacer(),
                          Text(
                            'x ${Utils.toFormattedNumber(BigInt.from(itemState.amount))}',
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
                            '${Utils.toFormattedNumber(BigInt.from(PowerService.getPowerRate(widget.gameData, widget.gameState, itemData.id)))} ${'watt'.tr()}/${'second'.tr()}'),
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
          fit: FlexFit.tight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(),
              Flexible(
                fit: FlexFit.tight,
                child: FancyButton(
                  child: Center(child: Icon(Icons.flash_on)),
                  color: Colors.orange,
                  size: 20,
                  onPressed: widget.onChargeButtonPressed,
                ),
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
                          child: Text('ascend'.tr()),
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
    return widget.gameState.upgradeStates.last.level > 0;
  }

  Future<void> _showAscensionDialog(BuildContext context) async {
    int convertedAntimatterCount = _getConvertedAntimatterCount();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(
            child: Text(
              'ascension'.tr(),
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('ascensionDescription'.tr()),
                Text(''),
                Text('ascensionHint'.tr(namedArgs: {
                  'count': convertedAntimatterCount.toString(),
                })),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('cancel'.tr()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('ascend'.tr()),
              onPressed: convertedAntimatterCount > 0
                  ? () {
                      Navigator.of(context).pop();
                      widget.onAscensionButtonPressed?.call(() {
                        widget.gameState.ascend(convertedAntimatterCount);
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
    return (widget.gameState.totalPower ~/ Constants.antimatterPrice).toInt();
  }
}
