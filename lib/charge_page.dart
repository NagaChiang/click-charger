import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ChargePage extends StatelessWidget {
  ChargePage({
    @required this.watt,
    @required this.onChargeButtonPressed,
  }) : assert(onChargeButtonPressed != null);

  final VoidCallback onChargeButtonPressed;
  final int watt;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(
          '$watt watts',
          style: Theme.of(context).textTheme.headline2,
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
