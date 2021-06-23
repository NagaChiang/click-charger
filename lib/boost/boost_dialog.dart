import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:easy_localization/easy_localization.dart';

import '../utils/constants.dart';
import '../utils/utils.dart';
import '../game/boost_state.dart';
import '../ads/google_ads.dart';
import '../ads/rewarded_ad_loader.dart';
import '../utils/server_api.dart';

class BoostDialog extends StatefulWidget {
  BoostDialog({
    @required this.boostEndTime,
    @required this.boostCount,
    @required this.nextRewardedAdTime,
    @required this.onBuyButtonPressed,
    @required this.onUseButtonPressed,
    @required this.onUserEarnedReward,
  })  : assert(boostEndTime != null),
        assert(boostCount != null),
        assert(onBuyButtonPressed != null),
        assert(onUseButtonPressed != null);

  final DateTime boostEndTime;
  final int boostCount;
  final DateTime nextRewardedAdTime;
  final int Function() onBuyButtonPressed;
  final Future<BoostState> Function() onUseButtonPressed;
  final Function(
    DateTime newBoostEndTime,
    DateTime newNextRewardedAdTime,
  ) onUserEarnedReward;

  @override
  _BoostDialogState createState() => _BoostDialogState();
}

class _BoostDialogState extends State<BoostDialog> {
  int _boostCount;
  DateTime _boostEndTime;
  Duration _boostRemainTime;
  DateTime _nextRewardedAdTime;
  Duration _rewardedAdRemainTime;
  Timer _updateTimer;
  RewardedAdLoader _rewardedAdLoader;

  @override
  void initState() {
    super.initState();

    _boostCount = widget.boostCount;
    _boostEndTime = widget.boostEndTime;
    _nextRewardedAdTime = widget.nextRewardedAdTime;

    _updateRemainTime();
    _updateTimer = Timer.periodic(
        Duration(milliseconds: 1000), (timer) => _updateRemainTime());

    _rewardedAdLoader = RewardedAdLoader(
      adUnitId: GoogleAds.rewardedId,
      onUserEarnedReward: (ad, item) async {
        Utils.showLoadingOverlay(context);

        final result = await ServerApi.rewardedAd(
          FirebaseAuth.instance.currentUser.uid,
        );

        Navigator.of(context).pop();

        if (result == null) {
          return;
        }

        setState(() {
          _boostEndTime = result.boostEndTime;
          _nextRewardedAdTime = result.nextRewardedAdTime;
          widget.onUserEarnedReward?.call(_boostEndTime, _nextRewardedAdTime);
          _updateRemainTime();
        });
      },
      onAdFailedToLoad: (error) {
        _showRewardedAdErrorSnackBar();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _showRewardedAdErrorSnackBar();
      },
      onFinished: () {
        Navigator.of(context).pop();
      },
    );
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
                _boostRemainTime.toString().split('.').first,
                style: Theme.of(context).textTheme.headline4.copyWith(
                      color: _boostRemainTime > Duration()
                          ? Colors.green
                          : Colors.red,
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
        ElevatedButton(
          child: Column(
            children: [
              Text('watchAd'.tr()),
              if (_rewardedAdRemainTime > Duration())
                Text(_rewardedAdRemainTime.toString().split('.').first),
            ],
          ),
          onPressed: _rewardedAdRemainTime > Duration()
              ? null
              : () async {
                  Utils.showLoadingOverlay(context);
                  await _rewardedAdLoader.show();
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
              ? () async {
                  Utils.showLoadingOverlay(context);

                  final newBoostState = await widget.onUseButtonPressed.call();
                  if (newBoostState != null) {
                    _boostCount = newBoostState.count;
                    _boostEndTime = newBoostState.endTime;
                    _updateRemainTime();
                  }

                  Navigator.of(context).pop();
                }
              : null,
        ),
      ],
    );
  }

  void _updateRemainTime() {
    setState(() {
      _boostRemainTime = _boostEndTime.difference(DateTime.now());
      _rewardedAdRemainTime = _nextRewardedAdTime.difference(DateTime.now());

      if (_boostRemainTime.isNegative) {
        _boostRemainTime = Duration();
      }

      if (_rewardedAdRemainTime.isNegative) {
        _rewardedAdRemainTime = Duration();
      }
    });
  }

  void _showRewardedAdErrorSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to show rewarded ad.')),
    );
  }
}
