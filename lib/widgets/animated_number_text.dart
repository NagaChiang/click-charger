import 'package:flutter/widgets.dart';

import '../utils/utils.dart';

class AnimatedNumberText extends StatefulWidget {
  final int number;
  final Duration duration;
  final TextStyle style;
  final String postString;

  const AnimatedNumberText({
    @required this.number,
    @required this.duration,
    this.style,
    this.postString,
  })  : assert(number != null),
        assert(duration != null);

  @override
  _AnimatedNumberTextState createState() => _AnimatedNumberTextState();
}

class _AnimatedNumberTextState extends State<AnimatedNumberText> {
  static const int _threshold = 1;

  double _currentValue = 0;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: _currentValue, end: widget.number.toDouble()),
      duration: widget.duration,
      builder: (context, value, child) {
        if (widget.number.toDouble() - _currentValue <= _threshold) {
          _currentValue = widget.number.toDouble();
        } else {
          _currentValue = value;
        }

        return Text(
          Utils.toFormattedNumber(_currentValue.floor()) +
              (widget.postString ?? ''),
          style: widget.style ?? DefaultTextStyle.of(context).style,
        );
      },
    );
  }
}
