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
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MainScreen(),
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
  MainScreenPage _currentPage = MainScreenPage.Charge;
  int _totalWatt = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Center(
        child: _buildPage(context, _currentPage),
      ),
      bottomNavigationBar: BottomNavigationBar(
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
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: (index) {
          setState(() {
            _currentPage = MainScreenPage.values[index];
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
