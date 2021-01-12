import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'item_data.dart';
import 'item_state.dart';

class InventoryListItem extends StatelessWidget {
  final int index;
  final ItemData data;
  final ItemState state;
  final void Function(int itemIndex) onItemTapped;
  final bool enabled;

  InventoryListItem(
      {this.index, this.data, this.state, this.onItemTapped, this.enabled})
      : assert(data != null),
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
          Text('${data.initialPowerPerSec} w/sec'),
          Text('\$$price'),
        ],
      ),
      trailing: Container(
        width: 30,
        child: Text('x ${state.amount}'),
      ),
      enabled: enabled,
      onTap: () => onItemTapped(index),
    );
  }
}
