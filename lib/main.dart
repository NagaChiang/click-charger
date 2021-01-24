import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'console_page.dart';
import 'game_data.dart';
import 'game_state.dart';
import 'inventory_page.dart';
import 'item_data.dart';
import 'item_state.dart';
import 'upgrade_page.dart';
import 'widgets/animated_number_text.dart';

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
                  title: Column(
                    children: [
                      AnimatedNumberText(
                        number: _gameState.totalPower.floor(),
                        duration: Duration(milliseconds: 200),
                        postString: ' w',
                      ),
                      Text(
                        '${_calculateCurrentPowerRate().toStringAsFixed(1)} w/s',
                        style: Theme.of(context).accentTextTheme.caption,
                      ),
                    ],
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
                      ConsolePage(
                        totalPower: _gameState.totalPower,
                        powerRate: _calculateCurrentPowerRate(),
                      ),
                      UpgradePage(),
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
                floatingActionButton: FloatingActionButton(
                  child: Icon(Icons.flash_on),
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

  Future _initialize() async {
    _gameData = await GameData.loadFromAssets(context);
    _gameState = GameState(gameData: _gameData);
    _updateTimer = Timer.periodic(
        Duration(seconds: _updateIntervalSeconds), _onTimerUpdate);
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
