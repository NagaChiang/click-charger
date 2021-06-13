import 'dart:async';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BoostButton extends StatefulWidget {
  BoostButton({
    @required this.endTime,
    @required this.boostCount,
    @required this.onPressed,
  });

  final DateTime endTime;
  final int boostCount;
  final Function onPressed;

  @override
  _BoostButtonState createState() => _BoostButtonState();
}

class _BoostButtonState extends State<BoostButton> {
  Timer _updateTimer;
  bool _isActive = false;

  @override
  void initState() {
    super.initState();

    _checkActive();
    _updateTimer =
        Timer.periodic(Duration(milliseconds: 1000), (timer) => _checkActive());
  }

  @override
  void dispose() {
    _updateTimer.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Badge(
        badgeColor: _isActive ? Colors.green : Colors.red,
        position: BadgePosition.bottomEnd(bottom: 1, end: -2),
        child: FaIcon(FontAwesomeIcons.rocket),
      ),
      onPressed: widget.onPressed,
    );
  }

  void _checkActive() {
    setState(() {
      _isActive = widget.endTime.isAfter(DateTime.now());
    });
  }
}
