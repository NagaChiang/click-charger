import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ChargePage extends StatelessWidget {
  ChargePage({
    @required this.totalPower,
    @required this.powerRate,
    @required this.onChargeButtonPressed,
  }) : assert(onChargeButtonPressed != null);

  final double totalPower;
  final double powerRate;
  final VoidCallback onChargeButtonPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            Text(
              '${totalPower.floorToDouble()} w',
              style: Theme.of(context).textTheme.headline2,
            ),
            Text(
              '$powerRate w/s',
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ],
        ),
        ElevatedButton(
          child: SizedBox(
            width: 128.0,
            height: 128.0,
            child: DecoratedBox(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            ),
          ),
          onPressed: () => onChargeButtonPressed(),
          style: ElevatedButton.styleFrom(
            elevation: 10.0,
          ),
        ),
      ],
    );
  }
}
