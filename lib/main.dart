import 'package:flutter/material.dart';

import 'build_page.dart';
import 'charge_page.dart';
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
  PageController _pageController;
  MainScreenPage _currentPage = MainScreenPage.Charge;
  int _totalWatt = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage.index);
  }

  @override
  void dispose() {
    _pageController.dispose();
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
            BuildPage(),
            ChargePage(
              watt: _totalWatt,
              onChargeButtonPressed: () => _charge(1),
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
            label: 'Build',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.charging_station),
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
              curve: Curves.easeOut,
            );
          });
        },
      ),
    );
  }

  Widget _buildPage(BuildContext context, MainScreenPage page) {
    switch (page) {
      case MainScreenPage.Build:
        return BuildPage();
      case MainScreenPage.Charge:
        return ChargePage(
          watt: _totalWatt,
          onChargeButtonPressed: () => _charge(1),
        );
      case MainScreenPage.Upgrade:
        return UpgradePage();
    }

    return null;
  }

  void _charge(int watt) {
    setState(() {
      _totalWatt += watt;
    });
  }
}
