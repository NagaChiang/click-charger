import 'dart:async';

import 'package:flutter/material.dart';

import 'charge_page.dart';
import 'game_data.dart';
import 'game_state.dart';
import 'inventory_page.dart';
import 'item_data.dart';
import 'item_state.dart';
import 'upgrade_page.dart';

void main() {
  runApp(ClickChargerApp());
}

class ClickChargerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Click Charger',
      themeMode: ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.green,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

enum MainScreenPage {
  Build,
  Charge,
  Upgrade,
}

class MainScreen extends StatefulWidget {
  MainScreen({Key key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const int _updateIntervalSeconds = 1;

  GameData _gameData = GameData();
  GameState _gameState;
  PageController _pageController;
  MainScreenPage _currentPage = MainScreenPage.Charge;
  Timer _updateTimer;

  @override
  void initState() {
    super.initState();

    _gameState = GameState(gameData: _gameData);
    _pageController = PageController(initialPage: _currentPage.index);

    _updateTimer = Timer.periodic(
        Duration(seconds: _updateIntervalSeconds), _onTimerUpdate);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _updateTimer.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: PageView(
          controller: _pageController,
          onPageChanged: (int index) {
            setState(() {
              _currentPage = MainScreenPage.values[index];
            });
          },
          children: [
            InventoryPage(
              gameData: _gameData,
              gameState: _gameState,
              onItemTapped: _onBuildItemTapped,
            ),
            ChargePage(
              totalPower: _gameState.totalPower,
              powerRate: _calculateCurrentPowerRate(),
              onChargeButtonPressed: () => _onChargeButtonPressed(),
            ),
            UpgradePage(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).backgroundColor,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flash_on),
            label: 'Charge',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_circle_up),
            label: 'Upgrade',
          ),
        ],
        currentIndex: _currentPage.index,
        onTap: (int index) {
          setState(() {
            _currentPage = MainScreenPage.values[index];
            _pageController.animateToPage(
              index,
              duration: Duration(milliseconds: 250),
              curve: Curves.easeInOut,
            );
          });
        },
      ),
    );
  }

  void _onTimerUpdate(Timer timer) {
    setState(() {
      _gameState.totalPower += _calculateCurrentPowerRate();
    });
  }

  void _onChargeButtonPressed() {
    setState(() {
      _gameState.totalPower += 1; // TODO: Upgraded press
    });
  }

  void _onBuildItemTapped(String itemId) {
    setState(() {
      ItemData data = _gameData.itemDatas[itemId];
      ItemState state = _gameState.itemStates[itemId];
      double price = data.calculatePrice(state.amount);

      assert(_gameState.totalPower >= price);

      _gameState.totalPower -= price;
      state.amount++;
    });
  }

  double _calculateCurrentPowerRate() {
    double rate = 0.0;
    for (ItemData data in _gameData.itemDatas.values) {
      ItemState state = _gameState.itemStates[data.id];
      rate += data.calculatePowerRate() * state.amount;
    }

    return rate;
  }
}
