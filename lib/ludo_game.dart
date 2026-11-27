
import 'dart:math';

enum LudoColor { red, blue, yellow, green }

class LudoToken {
  int progress;
  LudoToken({this.progress = -1});

  bool get isInBase => progress == -1;
  bool get isFinished => progress == 56;
}

class LudoPlayer {
  final LudoColor color;
  final List<LudoToken> tokens =
      List.generate(4, (_) => LudoToken());

  LudoPlayer(this.color);
}

class LudoGame {
  static const int winningProgress = 56;

  final List<LudoPlayer> players = [
    LudoPlayer(LudoColor.red),
    LudoPlayer(LudoColor.blue),
    LudoPlayer(LudoColor.yellow),
    LudoPlayer(LudoColor.green),
  ];

  int currentPlayerIndex = 0;
  int? diceValue;
  bool hasRolled = false;
  bool gameFinished = false;

  LudoPlayer get currentPlayer => players[currentPlayerIndex];

  int rollDice() {
    if (gameFinished || hasRolled) {
      throw StateError('Dice already rolled.');
    }

    diceValue = Random().nextInt(6) + 1;
    hasRolled = true;
    return diceValue!;
  }

  List<int> get legalTokenIndices {
    if (!hasRolled || diceValue == null || gameFinished) {
      return const [];
    }

    final result = <int>[];

    for (var i = 0; i < 4; i++) {
      final token = currentPlayer.tokens[i];

      if (token.isFinished) continue;

      if (token.isInBase) {
        if (diceValue == 6) result.add(i);
      } else if (token.progress + diceValue! <= 56) {
        result.add(i);
      }
    }

    return result;
  }

  bool moveToken(int tokenIndex) {
    if (!legalTokenIndices.contains(tokenIndex)) {
      throw StateError('Illegal token move.');
    }

    final token = currentPlayer.tokens[tokenIndex];

    if (token.isInBase) {
      token.progress = 0;
    } else {
      token.progress += diceValue!;
    }

    final captured = _captureOpponents(token);

    if (currentPlayer.tokens.every((t) => t.isFinished)) {
      gameFinished = true;
    }

    final rolledSix = diceValue == 6;
    diceValue = null;
    hasRolled = false;

    if (!gameFinished && !rolledSix) {
      currentPlayerIndex =
          (currentPlayerIndex + 1) % players.length;
    }

    return captured;
  }

  bool _captureOpponents(LudoToken movedToken) {
    if (movedToken.isInBase || movedToken.isFinished) {
      return false;
    }

    final cell = _globalCell(
      currentPlayer.color,
      movedToken.progress,
    );

    const safeCells = {0, 8, 13, 21, 26, 34, 39, 47};
    if (safeCells.contains(cell)) return false;

    var captured = false;

    for (var p = 0; p < players.length; p++) {
      if (p == currentPlayerIndex) continue;

      for (final enemy in players[p].tokens) {
        if (enemy.isInBase ||
            enemy.isFinished ||
            enemy.progress > 50) {
          continue;
        }

        if (_globalCell(players[p].color, enemy.progress) ==
            cell) {
          enemy.progress = -1;
          captured = true;
        }
      }
    }

    return captured;
  }

  int _globalCell(LudoColor color, int progress) {
    final offset = switch (color) {
      LudoColor.red => 0,
      LudoColor.blue => 13,
      LudoColor.yellow => 26,
      LudoColor.green => 39,
    };

    return (offset + progress) % 52;
  }

  void reset() {
    for (final player in players) {
      for (final token in player.tokens) {
        token.progress = -1;
      }
    }

    currentPlayerIndex = 0;
    diceValue = null;
    hasRolled = false;
    gameFinished = false;
  }
}
