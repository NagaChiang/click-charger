import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'item_data.dart';
import 'item_state.dart';
import 'utils/utils.dart';

class InventoryListItem extends StatelessWidget {
  final ItemData data;
  final ItemState state;
  final double rate;
  final void Function(String itemId) onItemTapped;
  final bool enabled;

  InventoryListItem({
    @required this.data,
    @required this.state,
    @required this.rate,
    this.onItemTapped,
    this.enabled,
  })  : assert(data != null),
        assert(state != null),
        assert(rate != null);

  @override
  Widget build(BuildContext context) {
    BigInt price = data.calculatePrice(state.amount);
    return Card(
      elevation: enabled ? null : 0.2,
      child: ListTile(
        leading: Container(
          width: 30,
          alignment: Alignment.center,
          child: Icon(data.icon),
        ),
        title: Text(data.name.tr()),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(data.id == 'press'
                ? '1 ${'time'.tr()}/${'second'.tr()}'
                : '${Utils.toFormattedNumber(BigInt.from(rate))} ${'watt'.tr()}/${'second'.tr()}'),
            Text('${Utils.toFormattedNumber(price)} ${'watt'.tr()}'),
          ],
        ),
        trailing: Container(
          width: 40,
          child:
              Text('x ${Utils.toFormattedNumber(BigInt.from(state.amount))}'),
        ),
        enabled: enabled ?? false,
        onTap: () => onItemTapped?.call(data.id),
      ),
    );
  }
}
