import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'console_page.dart';
import 'game_data.dart';
import 'game_state.dart';
import 'inventory_page.dart';
import 'item_data.dart';
import 'item_state.dart';
import 'power_service.dart';
import 'upgrade_data.dart';
import 'upgrade_page.dart';
import 'upgrade_state.dart';
import 'widgets/animated_number_text.dart';
import 'widgets/charge_button.dart';

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

  Future _initFuture;
  GameData _gameData = GameData();
  GameState _gameState;
  PageController _pageController;
  MainScreenPage _currentPage = MainScreenPage.Charge;
  Timer _updateTimer;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: _currentPage.index);
    _initFuture = _initialize();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _updateTimer.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print(snapshot.error);
          return Container();
        }

        return MultiProvider(
          providers: [
            Provider.value(value: _gameData),
            ChangeNotifierProvider.value(value: _gameState)
          ],
          child: Center(
            child: AspectRatio(
              aspectRatio: 9 / 16,
              child: Scaffold(
                appBar: AppBar(
                  title: Builder(
                    builder: (context) {
                      return Column(
                        children: [
                          AnimatedNumberText(
                            number: Provider.of<GameState>(context)
                                .totalPower
                                .floor(),
                            duration: Duration(milliseconds: 200),
                            postString: ' w',
                          ),
                          Text(
                            '${_calculateTotalPowerRate(context).toStringAsFixed(1)} w/s',
                            style: Theme.of(context).accentTextTheme.caption,
                          ),
                        ],
                      );
                    },
                  ),
                  centerTitle: true,
                ),
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
                        onItemTapped: _onBuildItemTapped,
                      ),
                      Builder(
                        builder: (context) {
                          return ConsolePage(
                            totalPower:
                                Provider.of<GameState>(context).totalPower,
                            powerRate: _calculateTotalPowerRate(context),
                          );
                        },
                      ),
                      UpgradePage(
                        onItemTapped: _onUpgradeItemTapped,
                      ),
                    ],
                  ),
                ),
                bottomNavigationBar: BottomNavigationBar(
                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.build),
                      label: 'Inventory',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.analytics),
                      label: 'Console',
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
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerFloat,
                floatingActionButton: ChargeButton(
                  onPressed: _onChargeButtonPressed,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _onTimerUpdate(Timer timer) {
    _gameState.addPower(_calculateTotalPowerRate(null));
  }

  void _onChargeButtonPressed() {
    ItemData pressData = _gameData.itemDatas['press'];
    double bonus = PowerService.calculateUpgradeBonus(
        _gameData, _gameState, pressData.upgradeId);
    double power = pressData.initialPowerPerSec * (1 + bonus);

    _gameState.addPower(power);
  }

  void _onBuildItemTapped(String itemId) {
    ItemData data = _gameData.itemDatas[itemId];
    ItemState state = _gameState.itemStates[itemId];
    double price = data.calculatePrice(state.amount);

    assert(_gameState.totalPower >= price);

    _gameState.addPower(-price);
    _gameState.addItemAmount(itemId, 1);
  }

  void _onUpgradeItemTapped(String upgradeId) {
    UpgradeData data = _gameData.upgradeDatas[upgradeId];
    UpgradeState state = _gameState.upgradeStates[upgradeId];
    double price = data.calculatePrice(state.level);

    assert(_gameState.totalPower >= price);

    _gameState.addPower(-price);
    _gameState.addUpgradeLevel(upgradeId, 1);
  }

  Future _initialize() async {
    _gameData = await GameData.loadFromAssets(context);
    _gameState = GameState(gameData: _gameData);
    _updateTimer = Timer.periodic(
        Duration(seconds: _updateIntervalSeconds), _onTimerUpdate);
  }

  double _calculateTotalPowerRate(BuildContext context) {
    GameData gameData = _gameData;
    GameState gameState = _gameState;
    if (context != null) {
      gameData = Provider.of<GameData>(context);
      gameState = Provider.of<GameState>(context);
    }

    double totalRate = 0.0;
    for (ItemData data in gameData.itemDatas.values) {
      ItemState state = gameState.itemStates[data.id];
      double bonus = PowerService.calculateUpgradeBonus(
          gameData, gameState, data.upgradeId);
      double rate = data.calculatePowerRate(bonus) * state.amount;
      if (data.id == 'press') {
        // TODO: Critical press
      }

      totalRate += rate;
    }

    return totalRate;
  }
}
