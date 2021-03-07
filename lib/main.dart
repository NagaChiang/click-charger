import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'dashboard_page.dart';
import 'game_data.dart';
import 'game_state.dart';
import 'inventory_page.dart';
import 'item_data.dart';
import 'item_state.dart';
import 'main_screen_page_state.dart';
import 'power_service.dart';
import 'upgrade_data.dart';
import 'upgrade_page.dart';
import 'upgrade_state.dart';
import 'utils/utils.dart';
import 'widgets/animated_number_text.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays([]);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
        primarySwatch: Colors.orange,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
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
  MainScreenPageState _pageState = MainScreenPageState();
  Timer _updateTimer;
  bool _isFadingOut = false;
  Function _onFadedOut;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: _pageState.page.index);
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
            ChangeNotifierProvider.value(value: _gameState),
            ChangeNotifierProvider.value(value: _pageState)
          ],
          child: Container(
            color: Colors.black,
            alignment: Alignment.center,
            child: AspectRatio(
              aspectRatio: 9 / 16,
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 1000),
                transitionBuilder: (child, animation) {
                  animation.addStatusListener((status) {
                    if (_isFadingOut && status == AnimationStatus.completed) {
                      setState(() {
                        _isFadingOut = false;
                      });

                      _onFadedOut?.call();
                    }
                  });

                  return FadeTransition(
                    child: child,
                    opacity: animation,
                  );
                },
                child: _isFadingOut
                    ? Container(
                        color: Colors.black,
                      )
                    : Scaffold(
                        appBar: AppBar(
                          leading: Builder(
                              builder: (context) => kReleaseMode
                                  ? null
                                  : _buildDebugWidget(context)),
                          title: Builder(
                            builder: (context) {
                              return Column(
                                children: [
                                  AnimatedNumberText(
                                    number: context
                                        .select<GameState, double>(
                                            (state) => state.totalPower)
                                        .floor(),
                                    duration: Duration(milliseconds: 200),
                                    postString: ' w',
                                  ),
                                  Text(
                                    '${Utils.toFormattedNumber(_calculateTotalPowerRate(context))} w/s',
                                    style: Theme.of(context)
                                        .accentTextTheme
                                        .caption,
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
                              _pageState.setPage(MainScreenPage.values[index]);
                            },
                            children: [
                              InventoryPage(
                                onItemTapped: _onBuildItemTapped,
                              ),
                              Builder(
                                builder: (context) {
                                  return DashboardPage(
                                    gameData: context.read<GameData>(),
                                    gameState: context.watch<GameState>(),
                                    onChargeButtonPressed:
                                        _onChargeButtonPressed,
                                    onAscensionButtonPressed: (onFadedOut) {
                                      fadeOut(onFadedOut);
                                    },
                                  );
                                },
                              ),
                              UpgradePage(
                                onItemTapped: _onUpgradeItemTapped,
                              ),
                            ],
                          ),
                        ),
                        bottomNavigationBar: Builder(builder: (context) {
                          return BottomNavigationBar(
                            items: [
                              BottomNavigationBarItem(
                                icon: Icon(Icons.build),
                                label: 'Build',
                              ),
                              BottomNavigationBarItem(
                                icon: Icon(Icons.analytics),
                                label: 'Dashboard',
                              ),
                              BottomNavigationBarItem(
                                icon: Icon(Icons.arrow_circle_up),
                                label: 'Upgrade',
                              ),
                            ],
                            currentIndex:
                                context.watch<MainScreenPageState>().page.index,
                            onTap: (int index) {
                              _pageState.setPage(MainScreenPage.values[index]);
                              _pageController.animateToPage(
                                index,
                                duration: Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                              );
                            },
                          );
                        }),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  void fadeOut(VoidCallback onFadedOut) {
    setState(() {
      _isFadingOut = true;
    });

    _onFadedOut = onFadedOut;
  }

  Widget _buildDebugWidget(BuildContext context) {
    assert(!kReleaseMode);

    GameState gameState = context.read<GameState>();

    return Switch(
      value: context.select<GameState, bool>((state) => state.isDebugMode),
      onChanged: (bool value) {
        gameState.setDebugMode(value);
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

    if (!kReleaseMode && _gameState.isDebugMode) {
      power = 100000000000000;
    }

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
      gameData = context.read<GameData>();
      gameState = context.watch<GameState>();
    }

    double totalRate = 0.0;
    for (ItemData data in gameData.itemDatas.values) {
      ItemState state = gameState.itemStates[data.id];
      double bonus = PowerService.calculateUpgradeBonus(
          gameData, gameState, data.upgradeId);
      double rate = data.calculatePowerRate(bonus) * state.amount;
      totalRate += rate;
    }

    return totalRate;
  }
}
