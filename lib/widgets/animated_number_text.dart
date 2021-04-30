import 'package:flutter/widgets.dart';

import '../utils/utils.dart';

class AnimatedNumberText extends StatefulWidget {
  final BigInt number;
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

class _AnimatedNumberTextState extends State<AnimatedNumberText>
    with TickerProviderStateMixin {
  static const int _threshold = 1;

  AnimationController _controller;
  BigInt _currentValue = BigInt.zero;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AnimatedNumberText oldWidget) {
    super.didUpdateWidget(oldWidget);

    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if ((widget.number - _currentValue).abs() <= BigInt.from(_threshold)) {
          _currentValue = widget.number;
        } else {
          _currentValue = _currentValue +
              Utils.multiply(widget.number - _currentValue, _controller.value);
        }

        return Text(
          Utils.toFormattedNumber(_currentValue) + (widget.postString ?? ''),
          style: widget.style ?? DefaultTextStyle.of(context).style,
        );
      },
    );
  }
}
