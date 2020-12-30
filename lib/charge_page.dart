import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ChargePage extends StatelessWidget {
  final VoidCallback onChargeButtonPressed;
  final int watt;

  ChargePage({
    @required this.watt,
    @required this.onChargeButtonPressed,
  }) : assert(onChargeButtonPressed != null);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(
          '$watt watts',
          style: Theme.of(context).textTheme.headline2,
        ),
        Ink(
          // decoration: ShapeDecoration(
          //   color: Theme.of(context).accentColor,
          //   shape: BeveledRectangleBorder(),
          // ),
          child: IconButton(
            icon: Icon(Icons.select_all),
            iconSize: 128.0,
            onPressed: () => onChargeButtonPressed(),
          ),
        ),
      ],
    );
  }
}
