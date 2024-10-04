import 'dart:io';
import 'dart:math';

enum CurrentPlayer { X, O }

class GameManager {
  static bool? gameModePvp;
  static bool isPlaying = false;
  static int? boardSize;
  static Random random = Random();
  static CurrentPlayer currentPlayer = CurrentPlayer.X;
  static List<List<String>>? board;
  static void GenerateBoard() {
    print('  ${List.generate(boardSize!, (index) => index + 1).join(' ')}');
    for (int i = 0; i < boardSize!; i++) {
      print('${i + 1} ${board![i].join(' ')}');
    }
  }

  static bool checkValidSize(String size) {
    int? parsableSize = int.tryParse(size);
    if (parsableSize == null || parsableSize < 3 || parsableSize > 9) {
      return false;
    } else {
      boardSize = parsableSize;
      board = List.generate(
          boardSize!, (index) => List.generate(boardSize!, (index) => '.'));
      return true;
    }
  }

  static CurrentPlayer choosePlayer() {
    currentPlayer = random.nextBool() ? CurrentPlayer.X : CurrentPlayer.O;
    return currentPlayer;
  }

  static List<int>? checkCoordinates(String coordinates) {
    List<String> parts = coordinates.split(' ');
    if (parts.length != 2) {
      print('Enter correct coordinates (e. g. 1 2): ');
      return null;
    }

    int? x = int.tryParse(parts[0]);
    int? y = int.tryParse(parts[1]);

    if (x == null ||
        y == null ||
        x < 1 ||
        y < 1 ||
        x > boardSize! ||
        y > boardSize!) {
      print('Incorrect coordinates. Enter the number from 1 to $boardSize');
      return null;
    }

    return [x - 1, y - 1];
  }

  static void move(List<int>? coordinates) {
    if (coordinates != null && board![coordinates[0]][coordinates[1]] != '.') {
      print('incorrect coordinates');
    } else if (currentPlayer == CurrentPlayer.X) {
      board![coordinates![0]][coordinates[1]] = 'X';
      if (checkForWin()) {
        isPlaying = false;
        return;
      }
      currentPlayer = CurrentPlayer.O;
    } else if (currentPlayer == CurrentPlayer.O) {
      board![coordinates![0]][coordinates[1]] = 'O';
      if (checkForWin()) {
        isPlaying = false;
        return;
      }
      currentPlayer = CurrentPlayer.X;
    }
  }

  static bool checkForDraw() {
    for (var element in board!) {
      for (var el in element) {
        if (el == '.') return false;
      }
    }
    print('Draw');
    isPlaying = false;
    return true;
  }

  static bool checkForWin() {
    String symbol = currentPlayer == CurrentPlayer.X ? 'X' : 'O';

    for (int i = 0; i < boardSize!; i++) {
      if (board![i].every((element) => element == symbol)) {
        return true;
      }
    }

    for (int i = 0; i < boardSize!; i++) {
      bool isWin = true;
      for (int j = 0; j < boardSize!; j++) {
        if (board![j][i] != symbol) {
          isWin = false;
          break;
        }
      }
      if (isWin) {
        print('$symbol wins!');
        return true;
      }
    }

    bool diagonal1Win = true;
    for (int i = 0; i < boardSize!; i++) {
      if (board![i][i] != symbol) {
        diagonal1Win = false;
        break;
      }
    }
    if (diagonal1Win) {
      print('$symbol wins!');
      return true;
    }

    bool diagonal2Win = true;
    for (int i = 0; i < boardSize!; i++) {
      if (board![i][boardSize! - 1 - i] != symbol) {
        diagonal2Win = false;
        break;
      }
    }
    return diagonal2Win;
  }

  static void Pvp() {
    GameManager.isPlaying = true;

    while (GameManager.isPlaying != false) {
      GameManager.GenerateBoard();
      if (GameManager.currentPlayer == CurrentPlayer.X) {
        print('X\'s turn, input coordinates (e. g. 1 2): ');
      } else {
        print('O\'s turn, input coordinates');
      }

      String? coordinates = stdin.readLineSync();
      List<int>? move = GameManager.checkCoordinates(coordinates!);
      if (move != null) {
        GameManager.move(move);
      }
      if (GameManager.checkForDraw() == true) {
        return;
      }
    }
  }

  static void PlayerVsComputer() {
    GameManager.isPlaying = true;

    while (GameManager.isPlaying != false) {
      GameManager.GenerateBoard();

      if (GameManager.currentPlayer == CurrentPlayer.X) {
        print('X\'s turn, input coordinates (e.g. 1 2): ');
        String? coordinates = stdin.readLineSync();
        List<int>? move = GameManager.checkCoordinates(coordinates!);
        if (move != null) {
          GameManager.move(move);
        }
      } else {
        print('Computer\'s turn');
        List<int> randomMove = makeRandomMove();
        GameManager.move(randomMove);
      }

      if (GameManager.checkForDraw()) {
        return;
      }
    }
  }

  static List<int> makeRandomMove() {
    List<List<int>> availableMoves = [];
    for (int i = 0; i < boardSize!; i++) {
      for (int j = 0; j < boardSize!; j++) {
        if (board![i][j] == '.') {
          availableMoves.add([i, j]);
        }
      }
    }
    return availableMoves[random.nextInt(availableMoves.length)];
  }
}

void main() {
  print('Choose game mode \n 1 - Player vs player \n 2 - Player vs computer');
  String? gameMode = stdin.readLineSync();
  if (int.parse(gameMode!) == 1) {
    GameManager.gameModePvp = true;
  } else if (int.parse(gameMode) == 2) {
    GameManager.gameModePvp = false;
  } else {
    print('incorrect input');
    return;
  }

  print('Enter the board size (3-9)');

  GameManager.currentPlayer = GameManager.choosePlayer();
  String? boardSize = stdin.readLineSync();
  if (!GameManager.checkValidSize(boardSize!)) {
    print('incorrect input');
    return;
  }

  if (GameManager.gameModePvp!) {
    GameManager.Pvp();
  } else {
    GameManager.PlayerVsComputer();
  }
}
