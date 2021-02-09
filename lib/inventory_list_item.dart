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
    double price = data.calculatePrice(state.amount);
    return Card(
      elevation: enabled ? null : 0.2,
      child: ListTile(
        leading: Container(
          width: 30,
          alignment: Alignment.center,
          child: Icon(data.icon),
        ),
        title: Text(data.name),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(data.id == 'press'
                ? '1 time/s'
                : '${Utils.toFormattedNumber(rate)} w/s'),
            Text('\$${Utils.toFormattedNumber(price)}'),
          ],
        ),
        trailing: Container(
          width: 40,
          child: Text('x ${Utils.toFormattedNumber(state.amount)}'),
        ),
        enabled: enabled ?? false,
        onTap: () => onItemTapped?.call(data.id),
      ),
    );
  }
}
