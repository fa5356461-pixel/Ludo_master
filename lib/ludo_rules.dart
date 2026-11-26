
class LudoRules {
  static const int homePosition = -1;
  static const int finishPosition = 57;

  static bool canMove({
    required int position,
    required int dice,
  }) {
    if (dice < 1 || dice > 6) return false;

    if (position == homePosition) {
      return dice == 6;
    }

    if (position >= finishPosition) return false;

    return position + dice <= finishPosition;
  }

  static int moveToken({
    required int position,
    required int dice,
  }) {
    if (!canMove(position: position, dice: dice)) {
      return position;
    }

    if (position == homePosition) {
      return 0;
    }

    return position + dice;
  }

  static bool hasWon(List<int> positions) {
    return positions.length == 4 &&
        positions.every((position) =>
            position == finishPosition);
  }
}
