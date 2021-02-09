import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'widgets/animated_number_text.dart';

class ConsolePage extends StatefulWidget {
  ConsolePage({
    @required this.totalPower,
    @required this.powerRate,
  })  : assert(totalPower != null),
        assert(powerRate != null);

  final double totalPower;
  final double powerRate;

  @override
  _ConsolePageState createState() => _ConsolePageState();
}

class _ConsolePageState extends State<ConsolePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            AnimatedNumberText(
              number: widget.totalPower.floor(),
              duration: Duration(milliseconds: 200),
              style: Theme.of(context).textTheme.headline2,
            ),
            Text(
              '${widget.powerRate.toStringAsFixed(1)} w/s',
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ],
        ),
      ],
    );
  }
}
