import 'package:chess_gemini_2/domain/entities/board.dart';
import 'package:chess_gemini_2/domain/entities/cell.dart';
import 'package:chess_gemini_2/domain/entities/piece.dart';

class SomeBoardsForTest {
  static Board boardForGetGameResult() {
    final List<List<Piece?>> initialSquares = List.generate(
      8,
      (_) => List.filled(8, null),
    );

    // Place pawns
    for (int col = 0; col < 8; col++) {
      initialSquares[1][col] = Pawn(
        color: PieceColor.black,
        type: PieceType.pawn,
      );
      initialSquares[6][col] = Pawn(
        color: PieceColor.white,
        type: PieceType.pawn,
      );
    }

    // Place other pieces for Black
    initialSquares[0][0] = Rook(color: PieceColor.black, type: PieceType.rook);
    initialSquares[0][1] = Knight(
      color: PieceColor.black,
      type: PieceType.knight,
    );
    initialSquares[0][2] = Bishop(
      color: PieceColor.black,
      type: PieceType.bishop,
    );
    initialSquares[0][3] = Queen(
      color: PieceColor.black,
      type: PieceType.queen,
    );
    initialSquares[0][4] = King(color: PieceColor.black, type: PieceType.king);
    initialSquares[0][5] = Bishop(
      color: PieceColor.black,
      type: PieceType.bishop,
    );
    initialSquares[0][6] = Knight(
      color: PieceColor.black,
      type: PieceType.knight,
    );
    initialSquares[0][7] = Rook(color: PieceColor.black, type: PieceType.rook);

    // Place other pieces for White
    initialSquares[7][0] = Rook(color: PieceColor.white, type: PieceType.rook);
    initialSquares[7][1] = Knight(
      color: PieceColor.white,
      type: PieceType.knight,
    );
    initialSquares[7][2] = Bishop(
      color: PieceColor.white,
      type: PieceType.bishop,
    );
    initialSquares[7][3] = Queen(
      color: PieceColor.white,
      type: PieceType.queen,
    );
    initialSquares[7][4] = King(color: PieceColor.white, type: PieceType.king);
    initialSquares[7][5] = Bishop(
      color: PieceColor.white,
      type: PieceType.bishop,
    );
    initialSquares[7][6] = Knight(
      color: PieceColor.white,
      type: PieceType.knight,
    );
    initialSquares[7][7] = Rook(color: PieceColor.white, type: PieceType.rook);

    // Initial king positions
    final Map<PieceColor, Cell> initialKingPositions = {
      PieceColor.white: const Cell(row: 7, col: 4),
      PieceColor.black: const Cell(row: 0, col: 4),
    };
    // Initial FEN for the starting position - FEN الأولي للوضعية الافتتاحية
    // final initialFen = _boardToFen(
    //   initialSquares,
    //   PieceColor.white,
    //   initialKingPositions,
    //   const {},
    //   null,
    //   0,
    //   1,
    // );
    return Board(
      squares: initialSquares,
      kingPositions: initialKingPositions,
      currentPlayer: PieceColor.white,
      zobristKey: 0, // Zobrist key for the board state

      // positionHistory: [initialFen], // Add initial position to history
    );
  }

  /// king vs king
  ///
  ///
  static Board get kingVsKing {
    final List<List<Piece?>> initialSquares = List.generate(
      8,
      (_) => List.filled(8, null),
    );

    // Place pawns

    initialSquares[1][4] = King(
      color: PieceColor.black,
      type: PieceType.king,
      hasMoved: true,
    );

    initialSquares[5][4] = King(
      color: PieceColor.white,
      type: PieceType.king,
      hasMoved: true,
    );

    // Initial king positions
    final Map<PieceColor, Cell> initialKingPositions = {
      PieceColor.white: const Cell(row: 5, col: 4),
      PieceColor.black: const Cell(row: 1, col: 4),
    };

    return Board(
      squares: initialSquares,
      kingPositions: initialKingPositions,
      currentPlayer: PieceColor.white,
      zobristKey: 0, // Zobrist key for the board state
      // positionHistory: [initialFen], // Add initial position to history
    );
  }

  /// kingAndBishopVSKing
  ///
  ///
  static Board get kingAndBishopVSKing {
    final List<List<Piece?>> initialSquares = List.generate(
      8,
      (_) => List.filled(8, null),
    );

    // Place pawns

    initialSquares[0][4] = King(
      color: PieceColor.black,
      type: PieceType.king,
      hasMoved: true,
    );

    initialSquares[7][4] = King(
      color: PieceColor.white,
      type: PieceType.king,
      hasMoved: true,
    );
    initialSquares[7][2] = Bishop(
      color: PieceColor.white,
      type: PieceType.bishop,
    );
    // Initial king positions
    final Map<PieceColor, Cell> initialKingPositions = {
      PieceColor.white: const Cell(row: 7, col: 4),
      PieceColor.black: const Cell(row: 0, col: 4),
    };

    return Board(
      squares: initialSquares,
      kingPositions: initialKingPositions,
      currentPlayer: PieceColor.white,
      zobristKey: 0, // Zobrist key for the board state

      // positionHistory: [initialFen], // Add initial position to history
    );
  }

  /// kingAndKnightVSKing
  ///
  ///
  static Board get kingAndKnightVSKing {
    final List<List<Piece?>> initialSquares = List.generate(
      8,
      (_) => List.filled(8, null),
    );

    // Place pawns

    initialSquares[0][4] = King(
      color: PieceColor.black,
      type: PieceType.king,
      hasMoved: true,
    );

    initialSquares[7][4] = King(
      color: PieceColor.white,
      type: PieceType.king,
      hasMoved: true,
    );
    initialSquares[7][2] = Knight(
      color: PieceColor.white,
      type: PieceType.knight,
    );
    // Initial king positions
    final Map<PieceColor, Cell> initialKingPositions = {
      PieceColor.white: const Cell(row: 7, col: 4),
      PieceColor.black: const Cell(row: 0, col: 4),
    };

    return Board(
      squares: initialSquares,
      kingPositions: initialKingPositions,
      currentPlayer: PieceColor.white,
      castlingRights: {
        PieceColor.black: {
          CastlingSide.kingSide: false,
          CastlingSide.queenSide: false,
        },
        PieceColor.white: {
          CastlingSide.kingSide: false,
          CastlingSide.queenSide: false,
        },
      },
      zobristKey: 0, // Zobrist key for the board state
      // positionHistory: [initialFen], // Add initial position to history
    );
  }

  /// kingAndBishopVSKingAndBishopAnother
  ///
  ///
  static Board get kingAndBishopVSKingAndBishopAnother {
    final List<List<Piece?>> initialSquares = List.generate(
      8,
      (_) => List.filled(8, null),
    );

    // Place pawns

    initialSquares[0][4] = King(
      color: PieceColor.black,
      type: PieceType.king,
      hasMoved: true,
    );

    initialSquares[7][4] = King(
      color: PieceColor.white,
      type: PieceType.king,
      // hasMoved: true,
    );
    initialSquares[7][2] = Bishop(
      color: PieceColor.white,
      type: PieceType.bishop,
    );
    initialSquares[0][5] = Bishop(
      color: PieceColor.black,
      type: PieceType.bishop,
    );
    // Initial king positions
    final Map<PieceColor, Cell> initialKingPositions = {
      PieceColor.white: const Cell(row: 7, col: 4),
      PieceColor.black: const Cell(row: 0, col: 4),
    };

    final board = Board(
      squares: initialSquares,
      kingPositions: initialKingPositions,
      currentPlayer: PieceColor.white,
      zobristKey: 0, // Zobrist key for the board state

      // positionHistory: [initialFen], // Add initial position to history
    );
    return board.copyWith(positionHistory: [board.toFenString()]);
  }

  ///
  ///
  static Board get drawFoStalemate {
    final List<List<Piece?>> initialSquares = List.generate(
      8,
      (_) => List.filled(8, null),
    );

    // Place pawns

    initialSquares[0][0] = King(
      color: PieceColor.black,
      type: PieceType.king,
      hasMoved: true,
    );

    initialSquares[2][2] = King(
      color: PieceColor.white,
      type: PieceType.king,
      // hasMoved: true,
    );
    initialSquares[1][2] = Queen(
      color: PieceColor.white,
      type: PieceType.queen,
    );

    // Initial king positions
    final Map<PieceColor, Cell> initialKingPositions = {
      PieceColor.white: const Cell(row: 2, col: 2),
      PieceColor.black: const Cell(row: 0, col: 0),
    };

    final board = Board(
      squares: initialSquares,
      kingPositions: initialKingPositions,
      currentPlayer: PieceColor.black,
      zobristKey: 0, // Zobrist key for the board state

      // positionHistory: [initialFen], // Add initial position to history
    );
    return board.copyWith(positionHistory: [board.toFenString()]);
  }

  ///
  ///
  static Board get checkMate {
    final List<List<Piece?>> initialSquares = List.generate(
      8,
      (_) => List.filled(8, null),
    );

    // Place pawns

    initialSquares[0][0] = King(
      color: PieceColor.black,
      type: PieceType.king,
      hasMoved: true,
    );

    initialSquares[2][2] = King(
      color: PieceColor.white,
      type: PieceType.king,
      // hasMoved: true,
    );
    initialSquares[1][2] = Queen(
      color: PieceColor.white,
      type: PieceType.queen,
    );

    // Initial king positions
    final Map<PieceColor, Cell> initialKingPositions = {
      PieceColor.white: const Cell(row: 2, col: 2),
      PieceColor.black: const Cell(row: 0, col: 0),
    };

    final board = Board(
      squares: initialSquares,
      kingPositions: initialKingPositions,
      currentPlayer: PieceColor.white,
      zobristKey: 0, // Zobrist key for the board state

      // positionHistory: [initialFen], // Add initial position to history
    );
    return board.copyWith(positionHistory: [board.toFenString()]);
  }

  /// initial board
  ///
  ///
  static Board initial() => Board.initial();

  ///
  ///
  /// test ai
}

class SomeBaordsForAITest {
  static Board get statrtAIasBlack {
    List<List<Piece?>> squares = Board.initial().copyWith().squares;

    /// black knight
    squares[2][2] = squares[0][1];
    squares[2][5] = squares[0][6];
    squares[0][1] = null;
    squares[0][6] = null;

    /// white pawns
    squares[5][2] = squares[6][2];
    squares[4][4] = squares[6][4];
    squares[6][2] = null;
    squares[6][4] = null;

    /// white bishop
    squares[4][2] = squares[7][5];
    squares[7][5] = null;

    return Board.initial()
        .copyWith(squares: squares, currentPlayer: PieceColor.black)
        .copyWithDeepPieces();
  }
}
