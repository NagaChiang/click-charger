import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'item_data.dart';
import 'item_state.dart';

class InventoryListItem extends StatelessWidget {
  final ItemData data;
  final ItemState state;
  final void Function(String itemId) onItemTapped;
  final bool enabled;

  InventoryListItem({
    @required this.data,
    @required this.state,
    this.onItemTapped,
    this.enabled,
  })  : assert(data != null),
        assert(state != null);

  @override
  Widget build(BuildContext context) {
    double price = data.calculatePrice(state.amount);

    return ListTile(
      leading: Container(
        width: 30,
        alignment: Alignment.center,
        child: Icon(data.icon),
      ),
      title: Text(data.name),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${data.initialPowerPerSec} w/s'),
          Text('\$$price'),
        ],
      ),
      trailing: Container(
        width: 30,
        child: Text('x ${state.amount}'),
      ),
      enabled: enabled ?? false,
      onTap: () => onItemTapped?.call(data.id),
    );
  }
}
