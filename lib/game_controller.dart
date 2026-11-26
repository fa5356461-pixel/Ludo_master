
import 'package:flutter/material.dart';

class GameController extends ChangeNotifier {
  int currentPlayer = 0;
  int diceValue = 1;
  int? selectedToken;

  final List<List<int>> tokenPositions = [
    [-1, -1, -1, -1],
    [-1, -1, -1, -1],
    [-1, -1, -1, -1],
    [-1, -1, -1, -1],
  ];

  final List<Color> playerColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
  ];

  void selectToken(int tokenIndex) {
    selectedToken = tokenIndex;
    notifyListeners();
  }

  void setDiceValue(int value) {
    diceValue = value;
    notifyListeners();
  }

  void nextPlayer() {
    currentPlayer = (currentPlayer + 1) % 4;
    selectedToken = null;
    notifyListeners();
  }
}
