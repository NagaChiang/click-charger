import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'upgrade_data.dart';
import 'upgrade_state.dart';
import 'utils/utils.dart';

class UpgradeListItem extends StatelessWidget {
  final UpgradeData data;
  final UpgradeState state;
  final void Function(String upgradeId) onItemTapped;
  final bool enabled;

  UpgradeListItem({
    @required this.data,
    @required this.state,
    this.onItemTapped,
    this.enabled,
  })  : assert(data != null),
        assert(state != null);

  @override
  Widget build(BuildContext context) {
    double price = data.calculatePrice(state.level);

    return Card(
      elevation: enabled ? null : 0.2,
      child: ListTile(
        leading: Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          child: Container(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Icon(data.icon),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Icon(
                    Icons.add,
                    size: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        title: Text(data.name.tr()),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(data.id == 'press'
                ? '+${data.valuePerLevel}/${'level'.tr()}'
                : '+${data.valuePerLevel * 100}%/${'level'.tr()}'),
            Text('${Utils.toFormattedNumber(price)} ${'watt'.tr()}'),
          ],
        ),
        trailing: Container(
          width: 40,
          child:
              Text('${'level'.tr()} ${Utils.toFormattedNumber(state.level)}'),
        ),
        enabled: enabled ?? false,
        onTap: () => onItemTapped?.call(data.id),
      ),
    );
  }
}
