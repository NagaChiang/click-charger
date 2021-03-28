import 'dart:async';
import 'dart:convert';

import 'package:click_charger/settings_dialog.dart';
import 'package:click_charger/utils/enums.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';
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

SharedPreferences pref;
const String gameStatePrefKey = 'gameState';

final notificationPlugin = FlutterLocalNotificationsPlugin();
const NotificationDetails powerNotificationDetails = NotificationDetails(
  android: AndroidNotificationDetails(
    'charge_clicker_current_power',
    'Current Power',
    'Show current power of the game.',
    playSound: false,
    enableVibration: false,
    autoCancel: false,
    ongoing: false,
    color: Colors.orange,
    showWhen: false,
    showProgress: true,
    indeterminate: true,
    category: 'Status',
  ),
);

Locale resolveLocale(Iterable<Locale> locales, Iterable<Locale> supports) {
  Locale resolvedLocale;
  for (Locale locale in locales) {
    if (locale.languageCode == 'en') {
      resolvedLocale = Locale('en');
    } else if (locale.languageCode == 'zh') {
      if (locale.scriptCode == 'Hant') {
        resolvedLocale = Constants.traditionalChineseLocale;
      } else if (locale.scriptCode == 'Hans') {
        resolvedLocale = Constants.simplifiedChineseLocale;
      } else if (locale.countryCode == 'HK' || locale.countryCode == 'TW') {
        resolvedLocale = Constants.traditionalChineseLocale;
      } else {
        resolvedLocale = Constants.simplifiedChineseLocale;
      }
    }

    if (resolvedLocale != null) {
      break;
    }
  }

  resolvedLocale = resolvedLocale ?? Locale('en');

  print('Resolve locale: $locales -> $resolvedLocale');

  return resolvedLocale;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays([]);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await EasyLocalization.ensureInitialized();
  pref = await SharedPreferences.getInstance();

  if (!kIsWeb) {
    await initializeNotificationPlugin();
  }

  runApp(EasyLocalization(
    path: 'assets/translations',
    supportedLocales: [
      const Locale('en'),
      Constants.traditionalChineseLocale,
      Constants.simplifiedChineseLocale,
    ],
    fallbackLocale: const Locale('en'),
    useFallbackTranslations: true,
    child: ClickChargerApp(),
  ));
}

Future<bool> initializeNotificationPlugin() async {
  final settings = InitializationSettings(
    android: AndroidInitializationSettings('splash'),
    iOS: IOSInitializationSettings(),
    macOS: MacOSInitializationSettings(),
  );

  return notificationPlugin.initialize(settings);
}

class ClickChargerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => 'clickCharger'.tr(),
      themeMode: ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.orange,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      localeListResolutionCallback: resolveLocale,
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  MainScreen({Key key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
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

    WidgetsBinding.instance.addObserver(this);

    _pageController = PageController(initialPage: _pageState.page.index);
    _initFuture = _initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _pageController.dispose();
    _updateTimer.cancel();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      notificationPlugin.cancelAll();
    }
  }

  @override
  void didChangeLocales(List<Locale> locales) {
    if (locales == null || locales.isEmpty) {
      return;
    }

    if (_gameState.language != Language.systemDefault) {
      print(
          'didChangeLocales(): Not using system locale (${_gameState.language}), skip.');
      return;
    }

    print('didChangeLocales(): Reflecting changed system locale...');
    context.setLocale(resolveLocale(locales, context.supportedLocales));
    context.deleteSaveLocale();
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
                          centerTitle: true,
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
                                    postString: ' ${'watt'.tr()}',
                                  ),
                                  Text(
                                    '${Utils.toFormattedNumber(_calculateTotalPowerRate(context))} ${'watt'.tr()}/${'second'.tr()}',
                                    style: Theme.of(context)
                                        .accentTextTheme
                                        .caption,
                                  ),
                                ],
                              );
                            },
                          ),
                          actions: [
                            IconButton(
                              icon: Icon(Icons.settings),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => SettingsDialog(
                                    language: _gameState.language,
                                    onChanged: (value) {
                                      _gameState
                                          .setLanguage(Language.values[value]);
                                      _saveGameStateToPref();

                                      if (_gameState.language ==
                                          Language.systemDefault) {
                                        context.setLocale(resolveLocale(
                                            [context.deviceLocale],
                                            context.supportedLocales));
                                        context.deleteSaveLocale();
                                      } else {
                                        context.setLocale(languageLocaleMap[
                                            _gameState.language]);
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
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
                                label: 'bottomNavBarLabel.build'.tr(),
                              ),
                              BottomNavigationBarItem(
                                icon: Icon(Icons.analytics),
                                label: 'bottomNavBarLabel.dashboard'.tr(),
                              ),
                              BottomNavigationBarItem(
                                icon: Icon(Icons.arrow_circle_up),
                                label: 'bottomNavBarLabel.upgrade'.tr(),
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

    _saveGameStateToPref();

    if (!kIsWeb) {
      _showPowerNotification(_gameState.totalPower);
    }
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

    String gameStateJsonString = pref.getString(gameStatePrefKey);
    if (gameStateJsonString != null) {
      _gameState = GameState.fromJson(json.decode(gameStateJsonString));
    } else {
      _gameState = GameState(gameData: _gameData);
    }

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

  void _saveGameStateToPref() {
    String jsonString = json.encode(_gameState.toJson());
    pref.setString(gameStatePrefKey, jsonString);
  }

  void _showPowerNotification(double power) {
    String powerString =
        '${Utils.toFormattedNumber(power.floor())} ${'watt'.tr()}';
    String rateString =
        '${Utils.toFormattedNumber(_calculateTotalPowerRate(null))} ${'watt'.tr()}/${'second'.tr()}';

    notificationPlugin.show(
      0,
      powerString,
      rateString,
      powerNotificationDetails,
    );
  }
}
