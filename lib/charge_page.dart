import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'animations/animated_number_text.dart';

class ChargePage extends StatefulWidget {
  ChargePage({
    @required this.totalPower,
    @required this.powerRate,
    @required this.onChargeButtonPressed,
  }) : assert(onChargeButtonPressed != null);

  final double totalPower;
  final double powerRate;
  final VoidCallback onChargeButtonPressed;

  @override
  _ChargePageState createState() => _ChargePageState();
}

class _ChargePageState extends State<ChargePage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            AnimatedNumberText(
              number: widget.totalPower.floor(),
              duration: Duration(milliseconds: 250),
              style: Theme.of(context).textTheme.headline2,
            ),
            Text(
              '${widget.powerRate} w/s',
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
          onPressed: () => widget.onChargeButtonPressed(),
          style: ElevatedButton.styleFrom(
            elevation: 10.0,
          ),
        ),
      ],
    );
  }
}
