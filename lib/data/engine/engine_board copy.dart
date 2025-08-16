// // lib/data/engine/engine_board.dart
// //
// // EngineBoard: طبقة متحوّلة (mutable) للاستخدام داخل محرك الذكاء الاصطناعي فقط.
// // - تتجنب النسخ العميق على كل نقلة (simulateMove) وتستبدله بـ makeMove/unmakeMove.
// // - تُحدّث zobristKey بشكل تدريجي (incremental) باستخدام ZobristHashing.
// // - تدعم حالات خاصة: التبييت Castling، الأخذ بالمرور En Passant، الترقي Promotion.
// // - تُحافظ على stack للتراجع السريع عن الحركات (unmakeMove).
// //
// // ملاحظة: تُستخدم فقط داخل البحث. خارج المحرك ما زال بإمكانك التعامل مع Board (freezed).

// import 'package:chess_gemini_2/domain/entities/board.dart';
// import 'package:chess_gemini_2/domain/entities/cell.dart';
// import 'package:chess_gemini_2/domain/entities/move.dart';
// import 'package:chess_gemini_2/domain/entities/piece.dart';
// import 'package:chess_gemini_2/domain/repositories/zobrist_hashing.dart';
// import '../../data/chess_logic.dart';

// /// حالة للتراجع السريع: نخزن أقل قدر ممكن لاستعادة الوضعية السابقة.
// class _Undo {
//   final Move move;                        // النقلة نفسها (من/إلى + خصائص)
//   final Piece? captured;                  // القطعة المأخوذة (بما فيها en-passant)
//   final Piece? movedBefore;               // القطعة قبل التحريك (قبل ترقية البيدق)
//   final Piece? movedAfter;                // القطعة بعد التحريك (بعد الترقي إن وجد)
//   final Cell kingBefore;                  // موضع الملك قبل النقلة (للجانب الذي تحرك)
//   final Map<PieceColor, Map<CastlingSide, bool>> castlingBefore; // حقوق التبييت قبل
//   final Cell? epBefore;                   // هدف الأخذ بالمرور قبل
//   final int halfMoveBefore;               // عداد أنصاف النقلات قبل
//   final int fullMoveBefore;               // رقم النقلات الكاملة قبل
//   final int zobristBefore;                // قيمة الزوبريست قبل
//   final bool didCastle;                   // هل تمت عملية تبييت بهذه النقلة
//   final Cell? rookFrom;                   // في حالة التبييت: من أين تحرك الرخ
//   final Cell? rookTo;                     // في حالة التبييت: إلى أين تحرك الرخ

//   _Undo({
//     required this.move,
//     required this.captured,
//     required this.movedBefore,
//     required this.movedAfter,
//     required this.kingBefore,
//     required this.castlingBefore,
//     required this.epBefore,
//     required this.halfMoveBefore,
//     required this.fullMoveBefore,
//     required this.zobristBefore,
//     required this.didCastle,
//     required this.rookFrom,
//     required this.rookTo,
//   });
// }

// /// محركنا سيعمل على هذا الكائن بدلاً من Board (freezed) لتجنب النسخ.
// /// نبني EngineBoard من Board مرة واحدة، ثم نحرّك/نتراجع محليًا.
// class EngineBoard {
//   // تمثيل اللوحة: نفس الشكل 8x8 لكن متحوّل.
//   final List<List<Piece?>> squares;

//   // اللاعب الحالي على اللعب.
//   PieceColor sideToMove;

//   // مواقع الملوك (لتسريع فحوصات الكش).
//   final Map<PieceColor, Cell> kingPos;

//   // حقوق التبييت.
//   final Map<PieceColor, Map<CastlingSide, bool>> castlingRights;

//   // هدف الأخذ بالمرور (إن وجد).
//   Cell? enPassantTarget;

//   // عدادات 50 حركة ورقم الحركة الكاملة.
//   int halfMoveClock;
//   int fullMoveNumber;

//   // مفتاح زوبريست الحالي.
//   int zobristKey;

//   // مكدس التراجع.
//   final List<_Undo> _stack = [];

//   EngineBoard._internal({
//     required this.squares,
//     required this.sideToMove,
//     required this.kingPos,
//     required this.castlingRights,
//     required this.enPassantTarget,
//     required this.halfMoveClock,
//     required this.fullMoveNumber,
//     required this.zobristKey,
//   });

//   /// محوّل من Board (freezed) إلى EngineBoard مرة واحدة مع إعادة استخدام نفس الهياكل قدر الإمكان.
//   factory EngineBoard.fromBoard(Board b) {
//     // تأكد من تهيئة جداول زوبريست مرة واحدة.
//     if (!ZobristHashing.zobristKeysInitialized) {
//       ZobristHashing.initializeZobristKeys();
//       ZobristHashing.zobristKeysInitialized = true;
//     }

//     // ننسخ squares سطحياً (قوائم داخلية جديدة لكن القطع نفسها) لتجنب تعديل كائن Board نفسه.
//     final sq = List<List<Piece?>>.generate(
//       8,
//       (r) => List<Piece?>.from(b.squares[r]),
//       growable: false,
//     );

//     final rights = {
//       PieceColor.white: {
//         CastlingSide.kingSide: b.castlingRights[PieceColor.white]![CastlingSide.kingSide]!,
//         CastlingSide.queenSide: b.castlingRights[PieceColor.white]![CastlingSide.queenSide]!,
//       },
//       PieceColor.black: {
//         CastlingSide.kingSide: b.castlingRights[PieceColor.black]![CastlingSide.kingSide]!,
//         CastlingSide.queenSide: b.castlingRights[PieceColor.black]![CastlingSide.queenSide]!,
//       },
//     };

//     return EngineBoard._internal(
//       squares: sq,
//       sideToMove: b.currentPlayer,
//       kingPos: Map<PieceColor, Cell>.from(b.kingPositions),
//       castlingRights: rights,
//       enPassantTarget: b.enPassantTarget,
//       halfMoveClock: b.halfMoveClock,
//       fullMoveNumber: b.fullMoveNumber,
//       zobristKey: b.zobristKey != 0 ? b.zobristKey : ZobristHashing.calculateZobristKey(b),
//     );
//   }

//   /// محوّل سريع إلى Board عند الحاجة (للاستهلاك خارج المحرك عند نهاية البحث مثلاً).
//   Board toBoardSnapshot() {
//     return Board(
//       squares: List<List<Piece?>>.generate(8, (r) => List<Piece?>.from(squares[r])),
//       currentPlayer: sideToMove,
//       kingPositions: Map<PieceColor, Cell>.from(kingPos),
//       castlingRights: {
//         PieceColor.white: {
//           CastlingSide.kingSide: castlingRights[PieceColor.white]![CastlingSide.kingSide]!,
//           CastlingSide.queenSide: castlingRights[PieceColor.white]![CastlingSide.queenSide]!,
//         },
//         PieceColor.black: {
//           CastlingSide.kingSide: castlingRights[PieceColor.black]![CastlingSide.kingSide]!,
//           CastlingSide.queenSide: castlingRights[PieceColor.black]![CastlingSide.queenSide]!,
//         },
//       },
//       enPassantTarget: enPassantTarget,
//       halfMoveClock: halfMoveClock,
//       fullMoveNumber: fullMoveNumber,
//       positionHistory: const [],
//       zobristKey: zobristKey,
//     );
//   }

//   /// الحصول على الحركات القانونية الحالية (نستدعي ChessLogic الموجود لديك).
//   /// ملاحظة: هنا ننشئ Board خفيفة الوزن دون نسخ عميق للقطع لتوليد الحركات فقط.
//   List<Move> getAllLegalMovesForCurrentPlayer() {
//     return ChessLogic.getAllLegalMovesForCurrentPlayer(toBoardSnapshot());
//   }

//   /// فحص كش الملك للّون المحدد.
//   bool isKingInCheck(PieceColor color) {
//     return toBoardSnapshot().isKingInCheck(color);
//   }

//   /// تطبيق نقلة على نفس الكائن (مع تحديث zobristKey بشكل تدريجي).
//   void makeMove(Move m) {
//     // 1) حفظ الحالة قبل أي تعديل للتراجع السريع.
//     final undo = _Undo(
//       move: m,
//       captured: _capturePieceIfAny(m), // نكتشف القطعة المأسورة (مع en-passant)
//       movedBefore: squares[m.start.row][m.start.col],
//       movedAfter: null, // سنعبئها بعد الترقي إن وجد
//       kingBefore: kingPos[sideToMove]!,
//       castlingBefore: {
//         PieceColor.white: {
//           CastlingSide.kingSide: castlingRights[PieceColor.white]![CastlingSide.kingSide]!,
//           CastlingSide.queenSide: castlingRights[PieceColor.white]![CastlingSide.queenSide]!,
//         },
//         PieceColor.black: {
//           CastlingSide.kingSide: castlingRights[PieceColor.black]![CastlingSide.kingSide]!,
//           CastlingSide.queenSide: castlingRights[PieceColor.black]![CastlingSide.queenSide]!,
//         },
//       },
//       epBefore: enPassantTarget,
//       halfMoveBefore: halfMoveClock,
//       fullMoveBefore: fullMoveNumber,
//       zobristBefore: zobristKey,
//       didCastle: false,
//       rookFrom: null,
//       rookTo: null,
//     );

//     final moving = undo.movedBefore!;
//     final from = m.start;
//     final to = m.end;

//     // 2) إزالة مفتاح en-passant السابق من الزوبريست (إن وجد).
//     if (enPassantTarget != null) {
//       zobristKey ^= ZobristHashing.enPassantFileKey(enPassantTarget!.col);
//     }

//     // 3) إزالة القطعة المتحركة من خانة الانطلاق من الزوبريست.
//     zobristKey ^= ZobristHashing.pieceSquareKey(moving, from.row, from.col);

//     // 4) لو هناك أسر: أزل القطعة المأسورة من الزوبريست (انتبه لـ en-passant).
//     if (undo.captured != null) {
//       final capCell = (m.isEnPassant)
//           ? Cell(row: from.row, col: to.col) // البيدق المأخوذ خلف الهدف
//           : to;
//       zobristKey ^= ZobristHashing.pieceSquareKey(undo.captured!, capCell.row, capCell.col);
//     }

//     // 5) تحريك القطعة على المصفوفة.
//     squares[to.row][to.col] = moving;
//     squares[from.row][from.col] = null;

//     // 6) الترقي إن وجد: بدّل نوع القطعة وأضف مفتاح الزوبريست للقطعة الجديدة.
//     Piece? movedAfter = moving;
//     if (m.isPromotion && m.promotionType != null && moving is Pawn) {
//       movedAfter = Piece.create(color: moving.color, type: m.promotionType!, hasMoved: true);
//       squares[to.row][to.col] = movedAfter;
//     }

//     // 7) أضف القطعة المتحركة (أو المرقّاة) في الخانة الجديدة إلى الزوبريست.
//     zobristKey ^= ZobristHashing.pieceSquareKey(movedAfter!, to.row, to.col);

//     // 8) تحديث موضع الملك إن كان الملك هو المتحرك.
//     if (moving is King) {
//       kingPos[sideToMove] = to;
//       // فقدان حقوق التبييت للطرف المتحرك.
//       _disableCastlingFor(sideToMove);
//     }

//     // 9) تحديث حقوق التبييت إذا تحرك رخ من خانته الأصلية أو إذا أُسر رخ من خانته الأصلية.
//     _updateCastlingRightsByRookMove(sideToMove, from);
//     if (undo.captured != null) {
//       _updateCastlingRightsByRookCapture(sideToMove == PieceColor.white ? PieceColor.black : PieceColor.white, to, m);
//     }

//     // 10) لو تبييت: حرّك الرخ وحدث الزوبريست accordingly.
//     if (m.isCastling && moving is King) {
//       undo.didCastle = true;
//       if (to.col == 6) {
//         // تبييت جهه الملك (O-O)
//         final rookFrom = Cell(row: to.row, col: 7);
//         final rookTo = Cell(row: to.row, col: 5);
//         undo.rookFrom = rookFrom;
//         undo.rookTo = rookTo;
//         final rook = squares[rookFrom.row][rookFrom.col] as Rook?;
//         if (rook != null) {
//           // إزالة رخ من مكانه القديم من الزوبريست
//           zobristKey ^= ZobristHashing.pieceSquareKey(rook, rookFrom.row, rookFrom.col);
//           // نقله على اللوح
//           squares[rookTo.row][rookTo.col] = rook;
//           squares[rookFrom.row][rookFrom.col] = null;
//           // إضافة رخ في مكانه الجديد للزوبريست
//           zobristKey ^= ZobristHashing.pieceSquareKey(rook, rookTo.row, rookTo.col);
//         }
//       } else if (to.col == 2) {
//         // تبييت جهه الوزير (O-O-O)
//         final rookFrom = Cell(row: to.row, col: 0);
//         final rookTo = Cell(row: to.row, col: 3);
//         undo.rookFrom = rookFrom;
//         undo.rookTo = rookTo;
//         final rook = squares[rookFrom.row][rookFrom.col] as Rook?;
//         if (rook != null) {
//           zobristKey ^= ZobristHashing.pieceSquareKey(rook, rookFrom.row, rookFrom.col);
//           squares[rookTo.row][rookTo.col] = rook;
//           squares[rookFrom.row][rookFrom.col] = null;
//           zobristKey ^= ZobristHashing.pieceSquareKey(rook, rookTo.row, rookTo.col);
//         }
//       }
//     }

//     // 11) إعداد en-passant الجديد: فقط إذا تحرك بيدق خطوتين.
//     enPassantTarget = null;
//     if (moving is Pawn && (from.row - to.row).abs() == 2) {
//       // المربع خلف البيدق كهدف للأخذ بالمرور
//       final epRow = (from.row + to.row) ~/ 2;
//       enPassantTarget = Cell(row: epRow, col: from.col);
//       // أضف مفتاح en-passant إلى الزوبريست
//       zobristKey ^= ZobristHashing.enPassantFileKey(enPassantTarget!.col);
//     }

//     // 12) عداد أنصاف النقلات (50 حركة): يصفر عند أخذ أو حركة بيدق، وإلا يزيد.
//     if (moving is Pawn || undo.captured != null) {
//       halfMoveClock = 0;
//     } else {
//       halfMoveClock += 1;
//     }

//     // 13) زيادة رقم الحركة الكاملة بعد حركة الأسود.
//     if (sideToMove == PieceColor.black) {
//       fullMoveNumber += 1;
//     }

//     // 14) تبديل الدور + تبديل مفتاح الزوبريست للدور.
//     zobristKey ^= ZobristHashing.sideToMoveKey(sideToMove); // إزالة المفتاح للجانب الحالي
//     sideToMove = (sideToMove == PieceColor.white) ? PieceColor.black : PieceColor.white;
//     zobristKey ^= ZobristHashing.sideToMoveKey(sideToMove); // إضافة مفتاح للجانب الجديد

//     // 15) خزن حالة ما بعد النقل (بعد حساب movedAfter) داخل الـ undo.
//     _stack.add(undo..movedAfter = movedAfter);
//   }

//   /// التراجع عن آخر نقلة: يستعيد كل شيء (اللوحة + الحقوق + en-passant + العدادات + zobrist).
//   void unmakeMove() {
//     final u = _stack.removeLast();

//     // استرجاع الزوبريست مباشرة دون حساب: أسرع وأدق.
//     zobristKey = u.zobristBefore;

//     // استرجاع العدادات.
//     halfMoveClock = u.halfMoveBefore;
//     fullMoveNumber = u.fullMoveBefore;

//     // استرجاع en-passant.
//     enPassantTarget = u.epBefore;

//     // استرجاع الحقوق.
//     castlingRights[PieceColor.white]![CastlingSide.kingSide] =
//         u.castlingBefore[PieceColor.white]![CastlingSide.kingSide]!;
//     castlingRights[PieceColor.white]![CastlingSide.queenSide] =
//         u.castlingBefore[PieceColor.white]![CastlingSide.queenSide]!;
//     castlingRights[PieceColor.black]![CastlingSide.kingSide] =
//         u.castlingBefore[PieceColor.black]![CastlingSide.kingSide]!;
//     castlingRights[PieceColor.black]![CastlingSide.queenSide] =
//         u.castlingBefore[PieceColor.black]![CastlingSide.queenSide]!;

//     // استرجاع الدور.
//     sideToMove = (u.move.movedPieceColor ?? _inferColor(u.movedBefore)) ?? sideToMove;
//     // ملاحظة: إن لم يكن لديك movedPieceColor داخل Move، نستنتج من القطعة نفسها.

//     // استرجاع مواقع القطع على اللوح.
//     final from = u.move.start;
//     final to = u.move.end;

//     // لو كان هناك تبييت قم بإرجاع الرخ.
//     if (u.didCastle && u.rookFrom != null && u.rookTo != null) {
//       final rook = squares[u.rookTo!.row][u.rookTo!.col];
//       squares[u.rookFrom!.row][u.rookFrom!.col] = rook;
//       squares[u.rookTo!.row][u.rookTo!.col] = null;
//     }

//     // عكس الحركة: ارجع القطعة المتحركة إلى خانة البداية.
//     squares[from.row][from.col] = u.movedBefore;
//     squares[to.row][to.col] = u.captured; // إن لم يكن أسر فستعود null

//     // لو كان الملك هو الذي تحرك: استرجع موضعه.
//     if (u.movedBefore is King) {
//       kingPos[sideToMove] = u.kingBefore;
//     }

//     // انتهى.
//   }

//   // ======= أدوات داخلية لتحديث الحقوق/الأسر/المفاتيح =======

//   /// اكتشاف القطعة المأسورة لهذه النقلة (مع التعامل مع en-passant).
//   Piece? _capturePieceIfAny(Move m) {
//     final from = m.start;
//     final to = m.end;
//     if (m.isEnPassant) {
//       // في en-passant، القطعة المأخوذة ليست على "to" بل خلفه في عمود البيدق.
//       final capCell = Cell(row: from.row, col: to.col);
//       return squares[capCell.row][capCell.col];
//     }
//     return squares[to.row][to.col];
//   }

//   /// تعطيل حقوق التبييت للجانب حين يتحرك الملك.
//   void _disableCastlingFor(PieceColor side) {
//     final beforeK = castlingRights[side]![CastlingSide.kingSide]!;
//     final beforeQ = castlingRights[side]![CastlingSide.queenSide]!;
//     if (beforeK) zobristKey ^= ZobristHashing.castlingKey(side, CastlingSide.kingSide);
//     if (beforeQ) zobristKey ^= ZobristHashing.castlingKey(side, CastlingSide.queenSide);
//     castlingRights[side]![CastlingSide.kingSide] = false;
//     castlingRights[side]![CastlingSide.queenSide] = false;
//   }

//   /// إذا تحرك رخ من خانته الأصلية، يفقد ذلك الجانب حق التبييت المناسب.
//   void _updateCastlingRightsByRookMove(PieceColor side, Cell from) {
//     if (side == PieceColor.white && from.row == 7) {
//       if (from.col == 7 && castlingRights[side]![CastlingSide.kingSide]!) {
//         castlingRights[side]![CastlingSide.kingSide] = false;
//         zobristKey ^= ZobristHashing.castlingKey(side, CastlingSide.kingSide);
//       } else if (from.col == 0 && castlingRights[side]![CastlingSide.queenSide]!) {
//         castlingRights
//       }}