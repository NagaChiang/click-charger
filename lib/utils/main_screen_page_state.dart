import 'package:flutter/foundation.dart';

enum MainScreenPage {
  Build,
  Charge,
  Upgrade,
}

class MainScreenPageState with ChangeNotifier {
  MainScreenPage page = MainScreenPage.Charge;

  void setPage(MainScreenPage newPage) {
    page = newPage;
    notifyListeners();
  }
}
