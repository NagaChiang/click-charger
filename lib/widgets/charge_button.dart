import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ChargeButton extends StatefulWidget {
  final VoidCallback onPressed;

  ChargeButton({this.onPressed});

  @override
  _ChargeButtonState createState() => _ChargeButtonState();
}

class _ChargeButtonState extends State<ChargeButton>
    with SingleTickerProviderStateMixin {
  double _scale = 0;
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 50),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _animationController.value;

    return GestureDetector(
      onTapDown: (detail) => _onTapStart(),
      onTapUp: (detail) => _onTapEnd(),
      onTapCancel: () => _onTapEnd(),
      child: Transform.scale(
        scale: _scale,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(shape: CircleBorder()),
          onPressed: () {
            widget.onPressed?.call();
          },
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: Icon(
              Icons.flash_on,
              size: 35,
            ),
          ),
        ),
      ),
    );
  }

  void _onTapStart() {
    _animationController.forward();
  }

  void _onTapEnd() {
    _animationController.reverse();
  }
}
