import 'package:flutter/material.dart';

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
      home: MainMenu(),
    );
  }
}

class MainMenu extends StatefulWidget {
  MainMenu({Key key}) : super(key: key);

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  static const _pages = [
    Text('Index 0'),
    Text('Index 1'),
    Text('Index 2'),
  ];

  var _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page Title'),
      ),
      body: Center(
        child: _pages[_selectedIndex],
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
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
