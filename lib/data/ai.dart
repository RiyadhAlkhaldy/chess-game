// package: com.example.chess.player;

// import 'package:com.example.chess.Cell';
// import 'package:com.example.chess.GameManager';
// import 'package:com.example.chess.MoveController';
// import 'package:com.example.chess.Utils';
// import 'package:com.example.chess.figures';

import 'dart:math';

// افتراضات للفئات والتعريفات المطلوبة
// ستحتاج إلى تعريف هذه الفئات بناءً على تطبيق الشطرنج الخاص بك
class Cell {
  Figure? _figure; // Using nullable Figure
  Cell({Figure? figure}) : _figure = figure; // Allow initial figure to be null

  Figure? getFigure() => _figure;
  void setFigure(Figure? figure) {
    _figure = figure;
  }
}

enum Team { WHITE, BLACK }

abstract class Figure {
  final Team team;
  Figure(this.team);
  List<Cell>
  getAvailableCells(); // This needs to be implemented by concrete figures
}

class Pawn extends Figure {
  Pawn(super.team);
  @override
  List<Cell> getAvailableCells() {
    // Implement pawn specific moves
    return [];
  }
}

class Knight extends Figure {
  Knight(super.team);
  @override
  List<Cell> getAvailableCells() {
    // Implement knight specific moves
    return [];
  }
}

class Bishop extends Figure {
  Bishop(super.team);
  @override
  List<Cell> getAvailableCells() {
    // Implement bishop specific moves
    return [];
  }
}

class Rook extends Figure {
  Rook(super.team);
  @override
  List<Cell> getAvailableCells() {
    // Implement rook specific moves
    return [];
  }
}

class Queen extends Figure {
  Queen(super.team);
  @override
  List<Cell> getAvailableCells() {
    // Implement queen specific moves
    return [];
  }
}

class King extends Figure {
  King(super.team);
  @override
  List<Cell> getAvailableCells() {
    // Implement king specific moves
    return [];
  }
}

class Player {
  final Team team;
  final List<Figure> _figures;
  Player(this.team, this._figures);

  List<Figure> getFigures() => _figures;
}

class Move {
  final Cell from;
  final Cell to;
  final Player player;

  Move(this.from, this.to, this.player);
}

// ستحتاج لإنشاء هذه الفئة وتعبئة قيمها
class Utils {
  static const int PAWN = 100;
  static const int KNIGHT = 320;
  static const int BISHOP = 330;
  static const int ROOK = 500;
  static const int QUEEN = 900;
  static const int KING = 20000; // قيمة عالية جدًا للملك

  static const List<List<int>> PAWN_BONUS = [
    [0, 0, 0, 0, 0, 0, 0, 0],
    [50, 50, 50, 50, 50, 50, 50, 50],
    [10, 10, 20, 30, 30, 20, 10, 10],
    [5, 5, 10, 25, 25, 10, 5, 5],
    [0, 0, 0, 20, 20, 0, 0, 0],
    [5, -5, -10, 0, 0, -10, -5, 5],
    [5, 10, 10, -20, -20, 10, 10, 5],
    [0, 0, 0, 0, 0, 0, 0, 0],
  ];

  static const List<List<int>> KNIGHT_BONUS = [
    [-50, -40, -30, -30, -30, -30, -40, -50],
    [-40, -20, 0, 0, 0, 0, -20, -40],
    [-30, 0, 10, 15, 15, 10, 0, -30],
    [-30, 5, 15, 20, 20, 15, 5, -30],
    [-30, 0, 15, 20, 20, 15, 0, -30],
    [-30, 5, 10, 15, 15, 10, 5, -30],
    [-40, -20, 0, 5, 5, 0, -20, -40],
    [-50, -40, -30, -30, -30, -30, -40, -50],
  ];

  static const List<List<int>> BISHOP_BONUS = [
    [-20, -10, -10, -10, -10, -10, -10, -20],
    [-10, 0, 0, 0, 0, 0, 0, -10],
    [-10, 0, 5, 10, 10, 5, 0, -10],
    [-10, 5, 5, 10, 10, 5, 5, -10],
    [-10, 0, 10, 10, 10, 10, 0, -10],
    [-10, 10, 10, 10, 10, 10, 10, -10],
    [-10, 5, 0, 0, 0, 0, 5, -10],
    [-20, -10, -10, -10, -10, -10, -10, -20],
  ];

  static const List<List<int>> ROOK_BONUS = [
    [0, 0, 0, 0, 0, 0, 0, 0],
    [5, 10, 10, 10, 10, 10, 10, 5],
    [-5, 0, 0, 0, 0, 0, 0, -5],
    [-5, 0, 0, 0, 0, 0, 0, -5],
    [-5, 0, 0, 0, 0, 0, 0, -5],
    [-5, 0, 0, 0, 0, 0, 0, -5],
    [-5, 0, 0, 0, 0, 0, 0, -5],
    [0, 0, 0, 5, 5, 0, 0, 0],
  ];

  static const List<List<int>> QUEEN_BONUS = [
    [-20, -10, -10, -5, -5, -10, -10, -20],
    [-10, 0, 0, 0, 0, 0, 0, -10],
    [-10, 0, 5, 5, 5, 5, 0, -10],
    [-5, 0, 5, 5, 5, 5, 0, -5],
    [0, 0, 5, 5, 5, 5, 0, -5],
    [-10, 5, 5, 5, 5, 5, 0, -10],
    [-10, 0, 5, 0, 0, 0, 0, -10],
    [-20, -10, -10, -5, -5, -10, -10, -20],
  ];

  static const List<List<int>> KING_BONUS = [
    [-30, -40, -40, -50, -50, -40, -40, -30],
    [-30, -40, -40, -50, -50, -40, -40, -30],
    [-30, -40, -40, -50, -50, -40, -40, -30],
    [-30, -40, -40, -50, -50, -40, -40, -30],
    [-20, -30, -30, -40, -40, -30, -30, -20],
    [-10, -20, -20, -20, -20, -20, -20, -10],
    [20, 20, 0, 0, 0, 0, 20, 20],
    [20, 30, 10, 0, 0, 10, 30, 20],
  ];
}

// GameManager و MoveController ستحتاج إلى تعريفات كاملة لهما بناءً على منطق لعبتك
class GameManager {
  final Board _board;
  final MoveController _controller;
  final Player _whitePlayer;
  final Player _blackPlayer;

  GameManager(
    this._board,
    this._controller,
    this._whitePlayer,
    this._blackPlayer,
  );

  Board getBoard() => _board;
  MoveController getController() => _controller;

  Player getOpponent(Player player) {
    return player.team == Team.WHITE ? _blackPlayer : _whitePlayer;
  }
}

class Board {
  final List<List<Cell>> _cells;
  Board(this._cells);
  List<List<Cell>> getCells() => _cells;
}

class MoveController {
  final GameManager manager;
  MoveController(this.manager);

  // هذه الدوال تحتاج إلى تنفيذ حقيقي بناءً على منطق الشطرنج
  // وقد تتطلب الوصول إلى حالة اللوحة (Board) والقطع (Figures)
  List<Cell> filterByCheck(
    Player player,
    List<Cell> availableCells,
    Cell fromCell,
  ) {
    // قم بتنفيذ منطق تصفية الخلايا لمنع التحقق (Check)
    // هذا الجزء معقد ويتطلب محاكاة الحركة والتحقق من وضع الملك
    return availableCells;
  }

  Cell findCellByFigure(Figure figure, List<List<Cell>> cells) {
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (cells[i][j].getFigure() == figure) {
          return cells[i][j];
        }
      }
    }
    throw Exception(
      "Figure not found on board",
    ); // أو تعامل مع الحالة بطريقة أخرى
  }

  void move(Cell from, Cell to, Player player) {
    // تنفيذ حركة القطعة فعليًا على اللوحة
    // يجب أن يتعامل مع أخذ القطع وغيرها
    to.setFigure(from.getFigure());
    from.setFigure(null);
  }

  bool isCheck(Player player) {
    // تحديد ما إذا كان ملك اللاعب في وضع كش (Check)
    // يتطلب هذا البحث عن ملك اللاعب والتحقق مما إذا كانت أي قطعة للخصم تهدده
    return false;
  }
}

class AIController {
  final GameManager manager;
  final List<List<Cell>> cells;
  final MoveController moveController;
  int movesCount = 0; // Initialize movesCount directly

  AIController(this.manager)
    : cells = manager.getBoard().getCells(),
      moveController = manager.getController();

  Move? getMove(Player player) {
    // Change return type to nullable Move
    return _rootMinimax(4, player);
  }

  Move? _rootMinimax(int level, Player player) {
    // Change return type to nullable Move
    movesCount = 0;

    Move? bestMove; // Make bestMove nullable
    int bestValue =
        -double.infinity.toInt(); // Use Dart's negative infinity for int

    for (Figure figure in player.getFigures()) {
      Cell? fromCell = moveController.findCellByFigure(
        figure,
        cells,
      ); // Skip if figure is not on the board

      for (Cell cell in moveController.filterByCheck(
        player,
        figure.getAvailableCells(),
        fromCell,
      )) {
        Move move = Move(fromCell, cell, player);

        Figure? tempFigure = move.to.getFigure(); // Make tempFigure nullable
        int index = -1;
        if (tempFigure != null) {
          index = manager.getOpponent(player).getFigures().indexOf(tempFigure);
        }

        moveController.move(move.from, move.to, move.player);
        int value = _minimax(
          level - 1,
          -double.infinity.toInt(),
          double.infinity.toInt(),
          false,
          manager.getOpponent(player),
        );

        if (value > bestValue) {
          bestValue = value;
          bestMove = move;
        }

        moveController.move(move.to, move.from, move.player);

        if (index != -1 && tempFigure != null) {
          manager
              .getOpponent(player)
              .getFigures()
              .insert(index, tempFigure); // Use insert for List
        }
        move.to.setFigure(tempFigure);
      }
    }
    print(movesCount);
    return bestMove;
  }

  int _minimax(
    int level,
    int alpha,
    int beta,
    bool isMaximizer,
    Player player,
  ) {
    if (level == 0) {
      if (isMaximizer) {
        return evaluationFunction(player);
      } else {
        return evaluationFunction(manager.getOpponent(player));
      }
    }

    int minmax =
        isMaximizer ? -double.infinity.toInt() : double.infinity.toInt();
    Player opponent = manager.getOpponent(player);

    bool alphaBetaCut = false;
    for (Figure figure in player.getFigures()) {
      // Отсечение (Pruning)
      if (alphaBetaCut) break;

      Cell? fromCell = moveController.findCellByFigure(
        figure,
        cells,
      ); // Skip if figure is not on the board

      for (Cell cell in moveController.filterByCheck(
        player,
        figure.getAvailableCells(),
        fromCell,
      )) {
        Move move = Move(fromCell, cell, player);

        // Запоминаем фигуру, если она будет съедена
        Figure? tempFigure = move.to.getFigure();
        int index = -1;
        if (tempFigure != null) {
          index = opponent.getFigures().indexOf(tempFigure);
        }

        moveController.move(move.from, move.to, move.player);
        if (isMaximizer) {
          minmax = max(
            _minimax(level - 1, alpha, beta, false, opponent),
            minmax,
          );
          alpha = max(alpha, minmax);
        } else {
          minmax = min(
            _minimax(level - 1, alpha, beta, true, opponent),
            minmax,
          );
          beta = min(beta, minmax);
        }
        if (beta <= alpha) alphaBetaCut = true;
        moveController.move(move.to, move.from, move.player);

        // Возвращаем съеденную фигуру
        if (index != -1 && tempFigure != null) {
          opponent.getFigures().insert(index, tempFigure);
        }
        move.to.setFigure(tempFigure);
      }
    }
    return minmax;
  }

  int evaluationFunction(Player player) {
    movesCount++;
    int sum = 0;

    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        Cell cell = cells[i][j];
        if (cell.getFigure() != null) {
          Figure figure = cell.getFigure()!; // Use ! to assert non-null
          int figureValue = 0;
          List<List<int>> bonusTable;

          if (figure is Pawn) {
            figureValue = Utils.PAWN;
            bonusTable = Utils.PAWN_BONUS;
          } else if (figure is Knight) {
            figureValue = Utils.KNIGHT;
            bonusTable = Utils.KNIGHT_BONUS;
          } else if (figure is Bishop) {
            figureValue = Utils.BISHOP;
            bonusTable = Utils.BISHOP_BONUS;
          } else if (figure is Rook) {
            figureValue = Utils.ROOK;
            bonusTable = Utils.ROOK_BONUS;
          } else if (figure is Queen) {
            figureValue = Utils.QUEEN;
            bonusTable = Utils.QUEEN_BONUS;
          } else if (figure is King) {
            figureValue = Utils.KING;
            bonusTable = Utils.KING_BONUS;
          } else {
            continue; // Should not happen if all figures are covered
          }

          int sign = (player.team == figure.team) ? 1 : -1;
          int bonus =
              (figure.team == Team.WHITE)
                  ? -bonusTable[i][j]
                  : bonusTable[7 - i][7 - j];

          sum += (sign * figureValue) + bonus;
        }
      }
    }
    if (moveController.isCheck(manager.getOpponent(player)))
      sum += 20000; // Checkmate bonus
    return sum;
  }

  Move? getRandomMove(Player player) {
    // Change return type to nullable Move
    Random random = Random();
    Figure? figure; // Make figure nullable
    List<Cell> list;
    do {
      if (player.getFigures().isEmpty)
        return null; // Handle case where player has no figures
      figure = player.getFigures()[random.nextInt(player.getFigures().length)];
      Cell? fromCell = moveController.findCellByFigure(figure, cells);
      list = moveController.filterByCheck(
        player,
        figure.getAvailableCells(),
        fromCell,
      );
    } while (list.isEmpty);

    Cell cell = list[random.nextInt(list.length)];

    return Move(
      moveController.findCellByFigure(figure, cells),
      cell,
      player,
    ); // Use ! to assert non-null
  }
}
