import 'package:flutter/material.dart';

class MyIntProvider extends ChangeNotifier {
  int myInt = 0;

  void updateInt(int newValue) {
    myInt = newValue;
    notifyListeners();
  }
}
