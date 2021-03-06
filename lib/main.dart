import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import 'boost/boost_dialog.dart';
import 'utils/constants.dart';
import 'dashboard/dashboard_page.dart';
import 'data/firestore_model.dart';
import 'game/game_data.dart';
import 'game/game_state.dart';
import 'inventory/inventory_page.dart';
import 'item/item_data.dart';
import 'item/item_state.dart';
import 'utils/main_screen_page_state.dart';
import 'utils/power_service.dart';
import 'upgrade/upgrade_data.dart';
import 'upgrade/upgrade_page.dart';
import 'upgrade/upgrade_state.dart';
import 'utils/utils.dart';
import 'widgets/animated_number_text.dart';
import 'widgets/settings_dialog.dart';
import 'utils/enums.dart';
import 'boost/boost_button.dart';
import 'iap/iap_dialog.dart';
import 'utils/server_api.dart';
import 'utils/analytics.dart';

SharedPreferences pref;
const String gameStatePrefKey = 'gameState';
const String pendingPurchaseIdsPrefKey = 'pendingPurchaseIds';

final notificationPlugin = FlutterLocalNotificationsPlugin();
const NotificationDetails powerNotificationDetails = NotificationDetails(
  android: AndroidNotificationDetails(
    'ChargeClicker_CurrentPower',
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
    timeoutAfter: 2000,
  ),
);

const NotificationDetails boostExpireNotificationDetails = NotificationDetails(
  android: AndroidNotificationDetails(
    'ChargeClicker_BoostExpired',
    'Boost Expired',
    'Boost effect has been expired.',
    color: Colors.orange,
    category: 'Event',
  ),
);

Locale resolveLocale(Iterable<Locale> locales, Iterable<Locale> supports) {
  Locale resolvedLocale;
  for (Locale locale in locales) {
    if (locale.languageCode == 'en') {
      resolvedLocale = Locale('en');
    } else if (locale.languageCode == 'ja') {
      resolvedLocale = Locale('ja');
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
  await Firebase.initializeApp();

  runZonedGuarded<Future<void>>(() async {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    Isolate.current.addErrorListener(RawReceivePort((pair) async {
      final List<dynamic> errorAndStacktrace = pair;
      await FirebaseCrashlytics.instance.recordError(
        errorAndStacktrace.first,
        errorAndStacktrace.last,
      );
    }).sendPort);

    await SystemChrome.setEnabledSystemUIOverlays([]);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    await EasyLocalization.ensureInitialized();
    pref = await SharedPreferences.getInstance();

    await MobileAds.instance.initialize();

    if (defaultTargetPlatform == TargetPlatform.android) {
      InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
    }

    Analytics.instance.setEnabled(kReleaseMode);

    runApp(EasyLocalization(
      path: 'assets/translations',
      supportedLocales: [
        const Locale('en'),
        const Locale('ja'),
        Constants.traditionalChineseLocale,
        Constants.simplifiedChineseLocale,
      ],
      fallbackLocale: const Locale('en'),
      useFallbackTranslations: true,
      child: ClickChargerApp(),
    ));
  }, FirebaseCrashlytics.instance.recordError);
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
  Timer _saveCloudGameTimer;
  bool _isFadingOut = false;
  Function _onFadedOut;
  bool _wasBoostActive = false;
  PackageInfo _packageInfo;

  @override
  void initState() {
    super.initState();

    InAppPurchase.instance.purchaseStream.listen(_onPurchaseUpdated);
    WidgetsBinding.instance.addObserver(this);

    _pageController = PageController(initialPage: _pageState.page.index);
    _initFuture = _initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _pageController.dispose();
    _updateTimer.cancel();
    _saveCloudGameTimer.cancel();

    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      if (_gameState != null) {
        await Analytics.instance.logAppResume(_gameState);
      }
    }

    if (state == AppLifecycleState.paused) {
      _saveLocalGame();
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
            ChangeNotifierProvider.value(value: _pageState),
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
                          leading: IconButton(
                            icon: Icon(Icons.settings),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => SettingsDialog(
                                  language: _gameState.language,
                                  version: _packageInfo?.version,
                                  onChanged: (value) {
                                    _gameState
                                        .setLanguage(Language.values[value]);

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
                                  onLinkedWithExistAccount: () async {
                                    _gameState.copyFrom(await _loadGame(true));
                                    print(
                                      'Linked with existing account. Reload game state with cloud save.',
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                          title: Builder(
                            builder: (context) {
                              return Column(
                                children: [
                                  AnimatedNumberText(
                                    number: context.select<GameState, BigInt>(
                                        (state) => state.totalPower),
                                    duration: Duration(milliseconds: 200),
                                    postString: ' ${'watt'.tr()}',
                                  ),
                                  Text(
                                    '${Utils.toFormattedNumber(BigInt.from(_calculateTotalPowerRate(context)))} ${'watt'.tr()}/${'second'.tr()}',
                                    style: Theme.of(context)
                                        .accentTextTheme
                                        .caption,
                                  ),
                                ],
                              );
                            },
                          ),
                          actions: [
                            Builder(
                                builder: (context) => kReleaseMode
                                    ? null
                                    : _buildDebugWidget(context)),
                            Builder(
                              builder: (context) => BoostButton(
                                endTime: context.select(
                                    (GameState state) => state.boostEndTime),
                                boostCount: context.select(
                                    (GameState state) => state.boostCount),
                                onPressed: _showBoostDialog,
                              ),
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
    if (kReleaseMode) {
      return Container();
    }

    GameState gameState = context.read<GameState>();

    return Switch(
      value: context.select<GameState, bool>((state) => state.isDebugMode),
      onChanged: (bool value) {
        gameState.setDebugMode(value);
      },
    );
  }

  void _onTimerUpdate(Timer timer) {
    _gameState.addPower(BigInt.from(_calculateTotalPowerRate(null)));
    _saveLocalGame();

    if (!kIsWeb) {
      _showPowerNotification(_gameState.totalPower);
    }

    // Boost expire check
    bool isBoostActive = _gameState.isBoostActive();
    if (!kIsWeb && _wasBoostActive && !isBoostActive) {
      _showBoostExpireNotification();
    }
    _wasBoostActive = isBoostActive;
  }

  void _onSaveCloudGameTimerUpdate(Timer timer) {
    _saveCloudGame(_gameState);
  }

  void _onChargeButtonPressed() {
    BigInt power = BigInt.from(PowerService.getPowerPerPress(
      _gameData,
      _gameState,
    ));

    if (!kReleaseMode && _gameState.isDebugMode) {
      power = BigInt.parse('1000000000000000000000');
    }

    _gameState.addPower(power);
  }

  void _onBuildItemTapped(String itemId) async {
    ItemData data = _gameData.itemDatas[itemId];
    ItemState state = _gameState.itemStates[Utils.itemIdToIndex(itemId)];
    BigInt price = data.calculatePrice(state.amount);

    assert(_gameState.totalPower >= price);

    await Analytics.instance.logBuild(_gameState, itemId);

    _gameState.addPower(-price);
    _gameState.addItemAmount(itemId, 1);
  }

  void _onUpgradeItemTapped(String upgradeId) async {
    UpgradeData data = _gameData.upgradeDatas[upgradeId];
    UpgradeState state =
        _gameState.upgradeStates[Utils.upgradeIdToIndex(upgradeId)];
    BigInt price = data.calculatePrice(state.level);

    assert(_gameState.totalPower >= price);

    await Analytics.instance.logUpgrade(_gameState, upgradeId);

    _gameState.addPower(-price);
    _gameState.addUpgradeLevel(upgradeId, 1);
  }

  void _onPurchaseUpdated(List<PurchaseDetails> purchases) {
    purchases.forEach((purchase) async {
      if (purchase.status == PurchaseStatus.error) {
        print(
          'Error purchase: ${purchase.productID}: ${purchase.error.message} (${purchase.verificationData.serverVerificationData})',
        );
        return;
      }

      if (purchase.status == PurchaseStatus.purchased) {
        Utils.showLoadingOverlay(context);
        int newBoostCount = await ServerApi.verifyPurchase(
          FirebaseAuth.instance.currentUser.uid,
          purchase.productID,
          purchase.verificationData.serverVerificationData,
        );

        Navigator.of(context).popUntil((route) => route.isFirst);

        if (newBoostCount != null) {
          await Analytics.instance.logPurchase(
            _gameState,
            purchase.productID,
            purchase.verificationData.serverVerificationData,
          );

          _gameState.setBoostCount(newBoostCount);
          _gameState.removeAd();
          _saveLocalGame();
          try {
            await InAppPurchase.instance.completePurchase(purchase);
          } catch (error, stackTrace) {
            final msg =
                'Error: Failed to complete purchase "${purchase.verificationData.serverVerificationData}": ${error.toString()}.';
            print(msg);

            await FirebaseCrashlytics.instance.recordError(
              error,
              stackTrace,
              reason: msg,
            );
          }
        }
      }
    });
  }

  Future<void> _initialize() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await _initializeNotificationPlugin();
      _packageInfo = await PackageInfo.fromPlatform();
    }

    FirebaseAuth.instance.authStateChanges().listen(_onAuthStateChanged);
    if (FirebaseAuth.instance.currentUser == null) {
      print('First time opening the game. Trying to sign in...');
      await _signIn();
    }

    await _initializeCrashlytics();

    String uid = FirebaseAuth.instance.currentUser.uid;
    Analytics.instance.setUserId(uid);
    await Analytics.instance.logAppOpen();

    _gameData = await GameData.loadFromAssets(context);
    _gameState = await _loadGame();

    //await _verifyAllPendingPurchaseIds();

    _updateTimer = Timer.periodic(
      Duration(seconds: _updateIntervalSeconds),
      _onTimerUpdate,
    );

    _saveCloudGameTimer = Timer.periodic(
      Constants.saveCloudGameInterval,
      _onSaveCloudGameTimerUpdate,
    );
  }

  Future<void> _initializeCrashlytics() async {
    if (kDebugMode) {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
      return;
    }

    final uid = FirebaseAuth.instance.currentUser.uid;
    FirebaseCrashlytics.instance.setUserIdentifier(uid);
  }

  Future<GameState> _loadGame([bool ignoreLocal = false]) async {
    // Local save
    GameState localGame;
    if (!ignoreLocal) {
      String jsonString = pref.getString(gameStatePrefKey);
      if (jsonString != null) {
        localGame = GameState.fromJson(json.decode(jsonString));
      }
    }

    // Cloud save
    String uid = FirebaseAuth.instance.currentUser.uid;
    GameState cloudGame;
    if (FirebaseAuth.instance.currentUser != null) {
      cloudGame = await FirestoreModel.getOrCreateGameState(uid);
    } else {
      print('Error: User doesn\'t even login anonymously.');
    }

    // Create cloud save
    if (cloudGame == null) {
      await FirestoreModel.createGameState(uid, _gameData);
    }

    // Choose which save to load
    if (localGame != null && cloudGame != null) {
      if (localGame.updatedTime.isAfter(cloudGame.updatedTime)) {
        await _saveCloudGame(localGame);
        localGame.boostCount = cloudGame.boostCount ?? 0;
        localGame.boostEndTime = cloudGame.boostEndTime ?? DateTime.now();
        localGame.isRemoveAd = cloudGame.isRemoveAd ?? false;
        localGame.nextRewardedAdTime =
            cloudGame.nextRewardedAdTime ?? DateTime.now();
        print('Find both save. Use local save. Sync with cloud save.');
        return localGame;
      } else {
        print('Find both save. Use cloud save.');
        return cloudGame;
      }
    } else if (cloudGame != null) {
      print('Find cloud save only.');
      return cloudGame;
    } else if (localGame != null) {
      await _saveCloudGame(localGame);
      print('Find local save only. Sync with cloud save.');
      return localGame;
    } else {
      print('Create a new game.');
      return GameState(gameData: _gameData);
    }
  }

  void _onAuthStateChanged(User user) async {
    if (user != null) {
      print('User signed in: $user');
    } else {
      print('User signed out.');
    }
  }

  Future _signIn() async {
    final AuthCredential googleCredential =
        await Utils.createGoogleCredential();
    if (googleCredential != null) {
      await FirebaseAuth.instance.signInWithCredential(googleCredential);
    } else {
      await FirebaseAuth.instance.signInAnonymously();
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'noGooglePlayGamesDialog.title'.tr(),
              style: Theme.of(context).textTheme.headline6,
            ),
            content: Text('noGooglePlayGamesDialog.description'.tr()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('ok'.tr()),
              ),
            ],
          );
        },
      );
    }
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
      ItemState state = gameState.itemStates[Utils.itemIdToIndex(data.id)];
      double bonus = PowerService.calculateUpgradeBonus(
          gameData, gameState, data.upgradeId);
      double rate = data.calculatePowerRate(bonus) * state.amount;
      totalRate += rate;
    }

    double globalBonus = gameState.getAntimatterBonus();
    if (gameState.isBoostActive()) {
      globalBonus += Constants.boostBonus;
    }

    totalRate *= 1 + globalBonus;

    return totalRate;
  }

  void _saveLocalGame() {
    String jsonString = json.encode(_gameState.toJson());
    pref.setString(gameStatePrefKey, jsonString);
  }

  Future<void> _saveCloudGame(GameState state) async {
    await FirestoreModel.updateGameState(
      FirebaseAuth.instance.currentUser.uid,
      state,
    );
  }

  void _addPendingPurchaseId(String purchaseId) {
    List<String> pendingPurchaseIds =
        pref.getStringList(pendingPurchaseIdsPrefKey) ?? <String>[];
    pendingPurchaseIds.add(purchaseId);
    pref.setStringList(pendingPurchaseIdsPrefKey, pendingPurchaseIds);
  }

  // Future<void> _verifyAllPendingPurchaseIds() async {
  //   String uid = FirebaseAuth.instance.currentUser.uid;
  //   List<String> pendingPurchaseIds =
  //       pref.getStringList(pendingPurchaseIdsPrefKey) ?? <String>[];
  //   for (var i = pendingPurchaseIds.length - 1; i >= 0; i--) {
  //     String purchaseId = pendingPurchaseIds[i];
  //     int newBoostCount = await ServerApi.verifyPurchase(uid, purchaseId);
  //     if (newBoostCount != null) {
  //       _gameState.setBoostCount(newBoostCount);
  //       _saveLocalGame();
  //       pendingPurchaseIds.removeAt(i);
  //     } else {
  //       print('Error: Failed to verify purchase "$purchaseId".');
  //     }
  //   }

  //   pref.setStringList(pendingPurchaseIdsPrefKey, pendingPurchaseIds);
  // }

  Future<bool> _initializeNotificationPlugin() async {
    final settings = InitializationSettings(
      android: AndroidInitializationSettings('splash'),
      iOS: IOSInitializationSettings(),
      macOS: MacOSInitializationSettings(),
    );

    return notificationPlugin.initialize(
      settings,
      onSelectNotification: _onSelectNotification,
    );
  }

  Future _onSelectNotification(String payload) async {
    if (payload == 'boost') {
      _showBoostDialog();
    }
  }

  void _showPowerNotification(BigInt power) {
    assert(notificationPlugin != null);

    String powerString = '${Utils.toFormattedNumber(power)} ${'watt'.tr()}';
    String rateString =
        '${Utils.toFormattedNumber(BigInt.from(_calculateTotalPowerRate(null)))} ${'watt'.tr()}/${'second'.tr()}';

    notificationPlugin.show(
      0,
      powerString,
      rateString,
      powerNotificationDetails,
    );
  }

  void _showBoostExpireNotification() {
    assert(notificationPlugin != null);

    notificationPlugin.show(
      1,
      'boostExpiredNotification.title'.tr(),
      'boostExpiredNotification.description'.tr(),
      boostExpireNotificationDetails,
      payload: 'boost',
    );
  }

  void _showBoostDialog() {
    Navigator.of(context).popUntil((route) => route.isFirst);
    showDialog(
      context: context,
      builder: (context) => BoostDialog(
        boostEndTime: _gameState.boostEndTime,
        boostCount: _gameState.boostCount,
        nextRewardedAdTime: _gameState.nextRewardedAdTime,
        onBuyButtonPressed: () {
          _showBoostStoreDialog();
          return _gameState.boostCount;
        },
        onUseButtonPressed: () async {
          await Analytics.instance.logUseBoost(_gameState);
          return await _gameState.useBoost(1);
        },
        onUserEarnedReward: (
          DateTime newBoostEndTime,
          DateTime newNextRewardedAdTime,
        ) async {
          await Analytics.instance.logWatchAd(_gameState);

          _gameState.setBoostEndTime(newBoostEndTime);
          _gameState.setNextRewardedAdTime(newNextRewardedAdTime);
        },
      ),
    );
  }

  Future<void> _showBoostStoreDialog() async {
    Utils.showLoadingOverlay(context);

    final ProductDetailsResponse response =
        await InAppPurchase.instance.queryProductDetails(Constants.productIds);
    if (response.notFoundIDs.isNotEmpty) {
      print('Warning: Product IDs not found: ${response.notFoundIDs}');
    }

    Navigator.of(context).pop();

    List<ProductDetails> products = response.productDetails;
    showDialog(
      context: context,
      builder: (context) => IapDialog(
        products: products,
      ),
    );
  }
}
