import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:easy_localization/easy_localization.dart';

import '../utils/constants.dart';

class BoostDialog extends StatefulWidget {
  BoostDialog({
    @required this.endTime,
    @required this.boostCount,
    @required this.onBuyButtonPressed,
    @required this.onUseButtonPressed,
  })  : assert(endTime != null),
        assert(boostCount != null),
        assert(onBuyButtonPressed != null),
        assert(onUseButtonPressed != null);

  final DateTime endTime;
  final int boostCount;
  final int Function() onBuyButtonPressed;
  final DateTime Function() onUseButtonPressed;

  @override
  _BoostDialogState createState() => _BoostDialogState();
}

class _BoostDialogState extends State<BoostDialog> {
  int _boostCount;
  DateTime _endTime;
  Duration _remainTime;
  Timer _updateTimer;

  @override
  void initState() {
    super.initState();

    _boostCount = widget.boostCount;
    _endTime = widget.endTime;

    _updateRemainTime();
    _updateTimer = Timer.periodic(
        Duration(milliseconds: 1000), (timer) => _updateRemainTime());
  }

  @override
  void dispose() {
    _updateTimer.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Text(
          'boost'.tr(),
          style: Theme.of(context).textTheme.headline5,
        ),
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            Center(
              child: Text(
                _remainTime.toString().split('.').first,
                style: Theme.of(context).textTheme.headline4.copyWith(
                      color:
                          _remainTime > Duration() ? Colors.green : Colors.red,
                    ),
              ),
            ),
            Text(''),
            Text(
              'boostDialogDescription'.tr(
                namedArgs: {
                  "bonus": (Constants.boostBonus * 100).toStringAsFixed(0),
                  "duration": Constants.durationPerBoost.inHours.toString(),
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text('cancel'.tr()),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: Text('buy'.tr()),
          onPressed: () {
            setState(() {
              _boostCount = widget.onBuyButtonPressed.call();
            });
          },
        ),
        ElevatedButton(
          child: Text(
            'useButton'.tr(
              namedArgs: {
                "count": _boostCount.toString(),
              },
            ),
          ),
          onPressed: _boostCount > 0
              ? () {
                  _boostCount--; // Hack
                  _endTime = widget.onUseButtonPressed.call();
                  _updateRemainTime();
                }
              : null,
        ),
      ],
    );
  }

  void _updateRemainTime() {
    setState(() {
      _remainTime = _endTime.difference(DateTime.now());
      if (_remainTime.isNegative) {
        _remainTime = Duration();
      }
    });
  }
}
