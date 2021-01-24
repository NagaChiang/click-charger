import 'package:flutter/widgets.dart';

class AnimatedNumberText extends ImplicitlyAnimatedWidget {
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
        assert(duration != null),
        super(duration: duration);

  @override
  _AnimatedNumberTextState createState() => _AnimatedNumberTextState();
}

class _AnimatedNumberTextState
    extends AnimatedWidgetBaseState<AnimatedNumberText> {
  Tween<double> _numberTween;

  @override
  Widget build(BuildContext context) {
    return Text(
      _numberTween.evaluate(animation).floor().toString() +
          (widget.postString ?? ''),
      style: widget.style ?? DefaultTextStyle.of(context).style,
    );
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _numberTween = visitor(_numberTween, widget.number,
        (dynamic value) => Tween<double>(begin: value as double));
  }
}
