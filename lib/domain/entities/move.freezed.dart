// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'move.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Move {

 Cell get start;// Starting cell of the piece
 Cell get end;// Ending cell of the piece
 bool get isCapture;// True if this move is a capture
 bool get isCastling;// True if this move is castling
 bool get isEnPassant;// True if this move is an en passant capture
 bool get isPromotion;// True if this move is a pawn promotion
 PieceType? get promotedPieceType;// The type of piece the pawn promotes to (if isPromotion is true)
 bool get isTwoStepPawnMove;// True if a pawn moved two squares (for en passant tracking)
 Piece get movedPiece; Piece? get capturedPiece; Piece? get promotedTo;// Cell? enPassantTargetBefore,
// bool? wasFirstMoveKing,
// bool? wasFirstMoveRook,
 int? get halfMoveClockBefore; int? get fullMoveNumberBefore;// Cell? castlingRookFrom,
// Cell? castlingRookTo,
// === Reversible payload for fast unMake (ignored by JSON) ===
// @JsonKey(ignore: true) Piece? capturedPiece,
@JsonKey(ignore: true) Cell? get capturedCell;@JsonKey(ignore: true) Piece? get movedPieceBefore;// Castling rook info
@JsonKey(ignore: true) Cell? get rookFrom;@JsonKey(ignore: true) Cell? get rookTo;@JsonKey(ignore: true) Piece? get rookBefore;// Snapshot of prior board state
@JsonKey(ignore: true) Map<PieceColor, Map<CastlingSide, bool>>? get previousCastlingRights;@JsonKey(ignore: true) Cell? get previousEnPassantTarget;@JsonKey(ignore: true) int? get previousHalfMoveClock;@JsonKey(ignore: true) int? get previousFullMoveNumber;@JsonKey(ignore: true) Map<PieceColor, Cell>? get previousKingPositions;@JsonKey(ignore: true) int? get previousZobristKey;
/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MoveCopyWith<Move> get copyWith => _$MoveCopyWithImpl<Move>(this as Move, _$identity);

  /// Serializes this Move to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Move&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.isCapture, isCapture) || other.isCapture == isCapture)&&(identical(other.isCastling, isCastling) || other.isCastling == isCastling)&&(identical(other.isEnPassant, isEnPassant) || other.isEnPassant == isEnPassant)&&(identical(other.isPromotion, isPromotion) || other.isPromotion == isPromotion)&&(identical(other.promotedPieceType, promotedPieceType) || other.promotedPieceType == promotedPieceType)&&(identical(other.isTwoStepPawnMove, isTwoStepPawnMove) || other.isTwoStepPawnMove == isTwoStepPawnMove)&&(identical(other.movedPiece, movedPiece) || other.movedPiece == movedPiece)&&(identical(other.capturedPiece, capturedPiece) || other.capturedPiece == capturedPiece)&&(identical(other.promotedTo, promotedTo) || other.promotedTo == promotedTo)&&(identical(other.halfMoveClockBefore, halfMoveClockBefore) || other.halfMoveClockBefore == halfMoveClockBefore)&&(identical(other.fullMoveNumberBefore, fullMoveNumberBefore) || other.fullMoveNumberBefore == fullMoveNumberBefore)&&(identical(other.capturedCell, capturedCell) || other.capturedCell == capturedCell)&&(identical(other.movedPieceBefore, movedPieceBefore) || other.movedPieceBefore == movedPieceBefore)&&(identical(other.rookFrom, rookFrom) || other.rookFrom == rookFrom)&&(identical(other.rookTo, rookTo) || other.rookTo == rookTo)&&(identical(other.rookBefore, rookBefore) || other.rookBefore == rookBefore)&&const DeepCollectionEquality().equals(other.previousCastlingRights, previousCastlingRights)&&(identical(other.previousEnPassantTarget, previousEnPassantTarget) || other.previousEnPassantTarget == previousEnPassantTarget)&&(identical(other.previousHalfMoveClock, previousHalfMoveClock) || other.previousHalfMoveClock == previousHalfMoveClock)&&(identical(other.previousFullMoveNumber, previousFullMoveNumber) || other.previousFullMoveNumber == previousFullMoveNumber)&&const DeepCollectionEquality().equals(other.previousKingPositions, previousKingPositions)&&(identical(other.previousZobristKey, previousZobristKey) || other.previousZobristKey == previousZobristKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,start,end,isCapture,isCastling,isEnPassant,isPromotion,promotedPieceType,isTwoStepPawnMove,movedPiece,capturedPiece,promotedTo,halfMoveClockBefore,fullMoveNumberBefore,capturedCell,movedPieceBefore,rookFrom,rookTo,rookBefore,const DeepCollectionEquality().hash(previousCastlingRights),previousEnPassantTarget,previousHalfMoveClock,previousFullMoveNumber,const DeepCollectionEquality().hash(previousKingPositions),previousZobristKey]);

@override
String toString() {
  return 'Move(start: $start, end: $end, isCapture: $isCapture, isCastling: $isCastling, isEnPassant: $isEnPassant, isPromotion: $isPromotion, promotedPieceType: $promotedPieceType, isTwoStepPawnMove: $isTwoStepPawnMove, movedPiece: $movedPiece, capturedPiece: $capturedPiece, promotedTo: $promotedTo, halfMoveClockBefore: $halfMoveClockBefore, fullMoveNumberBefore: $fullMoveNumberBefore, capturedCell: $capturedCell, movedPieceBefore: $movedPieceBefore, rookFrom: $rookFrom, rookTo: $rookTo, rookBefore: $rookBefore, previousCastlingRights: $previousCastlingRights, previousEnPassantTarget: $previousEnPassantTarget, previousHalfMoveClock: $previousHalfMoveClock, previousFullMoveNumber: $previousFullMoveNumber, previousKingPositions: $previousKingPositions, previousZobristKey: $previousZobristKey)';
}


}

/// @nodoc
abstract mixin class $MoveCopyWith<$Res>  {
  factory $MoveCopyWith(Move value, $Res Function(Move) _then) = _$MoveCopyWithImpl;
@useResult
$Res call({
 Cell start, Cell end, bool isCapture, bool isCastling, bool isEnPassant, bool isPromotion, PieceType? promotedPieceType, bool isTwoStepPawnMove, Piece movedPiece, Piece? capturedPiece, Piece? promotedTo, int? halfMoveClockBefore, int? fullMoveNumberBefore,@JsonKey(ignore: true) Cell? capturedCell,@JsonKey(ignore: true) Piece? movedPieceBefore,@JsonKey(ignore: true) Cell? rookFrom,@JsonKey(ignore: true) Cell? rookTo,@JsonKey(ignore: true) Piece? rookBefore,@JsonKey(ignore: true) Map<PieceColor, Map<CastlingSide, bool>>? previousCastlingRights,@JsonKey(ignore: true) Cell? previousEnPassantTarget,@JsonKey(ignore: true) int? previousHalfMoveClock,@JsonKey(ignore: true) int? previousFullMoveNumber,@JsonKey(ignore: true) Map<PieceColor, Cell>? previousKingPositions,@JsonKey(ignore: true) int? previousZobristKey
});


$CellCopyWith<$Res> get start;$CellCopyWith<$Res> get end;$PieceCopyWith<$Res> get movedPiece;$PieceCopyWith<$Res>? get capturedPiece;$PieceCopyWith<$Res>? get promotedTo;$CellCopyWith<$Res>? get capturedCell;$PieceCopyWith<$Res>? get movedPieceBefore;$CellCopyWith<$Res>? get rookFrom;$CellCopyWith<$Res>? get rookTo;$PieceCopyWith<$Res>? get rookBefore;$CellCopyWith<$Res>? get previousEnPassantTarget;

}
/// @nodoc
class _$MoveCopyWithImpl<$Res>
    implements $MoveCopyWith<$Res> {
  _$MoveCopyWithImpl(this._self, this._then);

  final Move _self;
  final $Res Function(Move) _then;

/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? start = null,Object? end = null,Object? isCapture = null,Object? isCastling = null,Object? isEnPassant = null,Object? isPromotion = null,Object? promotedPieceType = freezed,Object? isTwoStepPawnMove = null,Object? movedPiece = null,Object? capturedPiece = freezed,Object? promotedTo = freezed,Object? halfMoveClockBefore = freezed,Object? fullMoveNumberBefore = freezed,Object? capturedCell = freezed,Object? movedPieceBefore = freezed,Object? rookFrom = freezed,Object? rookTo = freezed,Object? rookBefore = freezed,Object? previousCastlingRights = freezed,Object? previousEnPassantTarget = freezed,Object? previousHalfMoveClock = freezed,Object? previousFullMoveNumber = freezed,Object? previousKingPositions = freezed,Object? previousZobristKey = freezed,}) {
  return _then(_self.copyWith(
start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as Cell,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as Cell,isCapture: null == isCapture ? _self.isCapture : isCapture // ignore: cast_nullable_to_non_nullable
as bool,isCastling: null == isCastling ? _self.isCastling : isCastling // ignore: cast_nullable_to_non_nullable
as bool,isEnPassant: null == isEnPassant ? _self.isEnPassant : isEnPassant // ignore: cast_nullable_to_non_nullable
as bool,isPromotion: null == isPromotion ? _self.isPromotion : isPromotion // ignore: cast_nullable_to_non_nullable
as bool,promotedPieceType: freezed == promotedPieceType ? _self.promotedPieceType : promotedPieceType // ignore: cast_nullable_to_non_nullable
as PieceType?,isTwoStepPawnMove: null == isTwoStepPawnMove ? _self.isTwoStepPawnMove : isTwoStepPawnMove // ignore: cast_nullable_to_non_nullable
as bool,movedPiece: null == movedPiece ? _self.movedPiece : movedPiece // ignore: cast_nullable_to_non_nullable
as Piece,capturedPiece: freezed == capturedPiece ? _self.capturedPiece : capturedPiece // ignore: cast_nullable_to_non_nullable
as Piece?,promotedTo: freezed == promotedTo ? _self.promotedTo : promotedTo // ignore: cast_nullable_to_non_nullable
as Piece?,halfMoveClockBefore: freezed == halfMoveClockBefore ? _self.halfMoveClockBefore : halfMoveClockBefore // ignore: cast_nullable_to_non_nullable
as int?,fullMoveNumberBefore: freezed == fullMoveNumberBefore ? _self.fullMoveNumberBefore : fullMoveNumberBefore // ignore: cast_nullable_to_non_nullable
as int?,capturedCell: freezed == capturedCell ? _self.capturedCell : capturedCell // ignore: cast_nullable_to_non_nullable
as Cell?,movedPieceBefore: freezed == movedPieceBefore ? _self.movedPieceBefore : movedPieceBefore // ignore: cast_nullable_to_non_nullable
as Piece?,rookFrom: freezed == rookFrom ? _self.rookFrom : rookFrom // ignore: cast_nullable_to_non_nullable
as Cell?,rookTo: freezed == rookTo ? _self.rookTo : rookTo // ignore: cast_nullable_to_non_nullable
as Cell?,rookBefore: freezed == rookBefore ? _self.rookBefore : rookBefore // ignore: cast_nullable_to_non_nullable
as Piece?,previousCastlingRights: freezed == previousCastlingRights ? _self.previousCastlingRights : previousCastlingRights // ignore: cast_nullable_to_non_nullable
as Map<PieceColor, Map<CastlingSide, bool>>?,previousEnPassantTarget: freezed == previousEnPassantTarget ? _self.previousEnPassantTarget : previousEnPassantTarget // ignore: cast_nullable_to_non_nullable
as Cell?,previousHalfMoveClock: freezed == previousHalfMoveClock ? _self.previousHalfMoveClock : previousHalfMoveClock // ignore: cast_nullable_to_non_nullable
as int?,previousFullMoveNumber: freezed == previousFullMoveNumber ? _self.previousFullMoveNumber : previousFullMoveNumber // ignore: cast_nullable_to_non_nullable
as int?,previousKingPositions: freezed == previousKingPositions ? _self.previousKingPositions : previousKingPositions // ignore: cast_nullable_to_non_nullable
as Map<PieceColor, Cell>?,previousZobristKey: freezed == previousZobristKey ? _self.previousZobristKey : previousZobristKey // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CellCopyWith<$Res> get start {
  
  return $CellCopyWith<$Res>(_self.start, (value) {
    return _then(_self.copyWith(start: value));
  });
}/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CellCopyWith<$Res> get end {
  
  return $CellCopyWith<$Res>(_self.end, (value) {
    return _then(_self.copyWith(end: value));
  });
}/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PieceCopyWith<$Res> get movedPiece {
  
  return $PieceCopyWith<$Res>(_self.movedPiece, (value) {
    return _then(_self.copyWith(movedPiece: value));
  });
}/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PieceCopyWith<$Res>? get capturedPiece {
    if (_self.capturedPiece == null) {
    return null;
  }

  return $PieceCopyWith<$Res>(_self.capturedPiece!, (value) {
    return _then(_self.copyWith(capturedPiece: value));
  });
}/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PieceCopyWith<$Res>? get promotedTo {
    if (_self.promotedTo == null) {
    return null;
  }

  return $PieceCopyWith<$Res>(_self.promotedTo!, (value) {
    return _then(_self.copyWith(promotedTo: value));
  });
}/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CellCopyWith<$Res>? get capturedCell {
    if (_self.capturedCell == null) {
    return null;
  }

  return $CellCopyWith<$Res>(_self.capturedCell!, (value) {
    return _then(_self.copyWith(capturedCell: value));
  });
}/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PieceCopyWith<$Res>? get movedPieceBefore {
    if (_self.movedPieceBefore == null) {
    return null;
  }

  return $PieceCopyWith<$Res>(_self.movedPieceBefore!, (value) {
    return _then(_self.copyWith(movedPieceBefore: value));
  });
}/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CellCopyWith<$Res>? get rookFrom {
    if (_self.rookFrom == null) {
    return null;
  }

  return $CellCopyWith<$Res>(_self.rookFrom!, (value) {
    return _then(_self.copyWith(rookFrom: value));
  });
}/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CellCopyWith<$Res>? get rookTo {
    if (_self.rookTo == null) {
    return null;
  }

  return $CellCopyWith<$Res>(_self.rookTo!, (value) {
    return _then(_self.copyWith(rookTo: value));
  });
}/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PieceCopyWith<$Res>? get rookBefore {
    if (_self.rookBefore == null) {
    return null;
  }

  return $PieceCopyWith<$Res>(_self.rookBefore!, (value) {
    return _then(_self.copyWith(rookBefore: value));
  });
}/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CellCopyWith<$Res>? get previousEnPassantTarget {
    if (_self.previousEnPassantTarget == null) {
    return null;
  }

  return $CellCopyWith<$Res>(_self.previousEnPassantTarget!, (value) {
    return _then(_self.copyWith(previousEnPassantTarget: value));
  });
}
}


/// @nodoc
@JsonSerializable()

class _Move implements Move {
  const _Move({required this.start, required this.end, this.isCapture = false, this.isCastling = false, this.isEnPassant = false, this.isPromotion = false, this.promotedPieceType, this.isTwoStepPawnMove = false, required this.movedPiece, this.capturedPiece, this.promotedTo, this.halfMoveClockBefore, this.fullMoveNumberBefore, @JsonKey(ignore: true) this.capturedCell, @JsonKey(ignore: true) this.movedPieceBefore, @JsonKey(ignore: true) this.rookFrom, @JsonKey(ignore: true) this.rookTo, @JsonKey(ignore: true) this.rookBefore, @JsonKey(ignore: true) final  Map<PieceColor, Map<CastlingSide, bool>>? previousCastlingRights, @JsonKey(ignore: true) this.previousEnPassantTarget, @JsonKey(ignore: true) this.previousHalfMoveClock, @JsonKey(ignore: true) this.previousFullMoveNumber, @JsonKey(ignore: true) final  Map<PieceColor, Cell>? previousKingPositions, @JsonKey(ignore: true) this.previousZobristKey}): _previousCastlingRights = previousCastlingRights,_previousKingPositions = previousKingPositions;
  factory _Move.fromJson(Map<String, dynamic> json) => _$MoveFromJson(json);

@override final  Cell start;
// Starting cell of the piece
@override final  Cell end;
// Ending cell of the piece
@override@JsonKey() final  bool isCapture;
// True if this move is a capture
@override@JsonKey() final  bool isCastling;
// True if this move is castling
@override@JsonKey() final  bool isEnPassant;
// True if this move is an en passant capture
@override@JsonKey() final  bool isPromotion;
// True if this move is a pawn promotion
@override final  PieceType? promotedPieceType;
// The type of piece the pawn promotes to (if isPromotion is true)
@override@JsonKey() final  bool isTwoStepPawnMove;
// True if a pawn moved two squares (for en passant tracking)
@override final  Piece movedPiece;
@override final  Piece? capturedPiece;
@override final  Piece? promotedTo;
// Cell? enPassantTargetBefore,
// bool? wasFirstMoveKing,
// bool? wasFirstMoveRook,
@override final  int? halfMoveClockBefore;
@override final  int? fullMoveNumberBefore;
// Cell? castlingRookFrom,
// Cell? castlingRookTo,
// === Reversible payload for fast unMake (ignored by JSON) ===
// @JsonKey(ignore: true) Piece? capturedPiece,
@override@JsonKey(ignore: true) final  Cell? capturedCell;
@override@JsonKey(ignore: true) final  Piece? movedPieceBefore;
// Castling rook info
@override@JsonKey(ignore: true) final  Cell? rookFrom;
@override@JsonKey(ignore: true) final  Cell? rookTo;
@override@JsonKey(ignore: true) final  Piece? rookBefore;
// Snapshot of prior board state
 final  Map<PieceColor, Map<CastlingSide, bool>>? _previousCastlingRights;
// Snapshot of prior board state
@override@JsonKey(ignore: true) Map<PieceColor, Map<CastlingSide, bool>>? get previousCastlingRights {
  final value = _previousCastlingRights;
  if (value == null) return null;
  if (_previousCastlingRights is EqualUnmodifiableMapView) return _previousCastlingRights;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey(ignore: true) final  Cell? previousEnPassantTarget;
@override@JsonKey(ignore: true) final  int? previousHalfMoveClock;
@override@JsonKey(ignore: true) final  int? previousFullMoveNumber;
 final  Map<PieceColor, Cell>? _previousKingPositions;
@override@JsonKey(ignore: true) Map<PieceColor, Cell>? get previousKingPositions {
  final value = _previousKingPositions;
  if (value == null) return null;
  if (_previousKingPositions is EqualUnmodifiableMapView) return _previousKingPositions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey(ignore: true) final  int? previousZobristKey;

/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MoveCopyWith<_Move> get copyWith => __$MoveCopyWithImpl<_Move>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MoveToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Move&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.isCapture, isCapture) || other.isCapture == isCapture)&&(identical(other.isCastling, isCastling) || other.isCastling == isCastling)&&(identical(other.isEnPassant, isEnPassant) || other.isEnPassant == isEnPassant)&&(identical(other.isPromotion, isPromotion) || other.isPromotion == isPromotion)&&(identical(other.promotedPieceType, promotedPieceType) || other.promotedPieceType == promotedPieceType)&&(identical(other.isTwoStepPawnMove, isTwoStepPawnMove) || other.isTwoStepPawnMove == isTwoStepPawnMove)&&(identical(other.movedPiece, movedPiece) || other.movedPiece == movedPiece)&&(identical(other.capturedPiece, capturedPiece) || other.capturedPiece == capturedPiece)&&(identical(other.promotedTo, promotedTo) || other.promotedTo == promotedTo)&&(identical(other.halfMoveClockBefore, halfMoveClockBefore) || other.halfMoveClockBefore == halfMoveClockBefore)&&(identical(other.fullMoveNumberBefore, fullMoveNumberBefore) || other.fullMoveNumberBefore == fullMoveNumberBefore)&&(identical(other.capturedCell, capturedCell) || other.capturedCell == capturedCell)&&(identical(other.movedPieceBefore, movedPieceBefore) || other.movedPieceBefore == movedPieceBefore)&&(identical(other.rookFrom, rookFrom) || other.rookFrom == rookFrom)&&(identical(other.rookTo, rookTo) || other.rookTo == rookTo)&&(identical(other.rookBefore, rookBefore) || other.rookBefore == rookBefore)&&const DeepCollectionEquality().equals(other._previousCastlingRights, _previousCastlingRights)&&(identical(other.previousEnPassantTarget, previousEnPassantTarget) || other.previousEnPassantTarget == previousEnPassantTarget)&&(identical(other.previousHalfMoveClock, previousHalfMoveClock) || other.previousHalfMoveClock == previousHalfMoveClock)&&(identical(other.previousFullMoveNumber, previousFullMoveNumber) || other.previousFullMoveNumber == previousFullMoveNumber)&&const DeepCollectionEquality().equals(other._previousKingPositions, _previousKingPositions)&&(identical(other.previousZobristKey, previousZobristKey) || other.previousZobristKey == previousZobristKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,start,end,isCapture,isCastling,isEnPassant,isPromotion,promotedPieceType,isTwoStepPawnMove,movedPiece,capturedPiece,promotedTo,halfMoveClockBefore,fullMoveNumberBefore,capturedCell,movedPieceBefore,rookFrom,rookTo,rookBefore,const DeepCollectionEquality().hash(_previousCastlingRights),previousEnPassantTarget,previousHalfMoveClock,previousFullMoveNumber,const DeepCollectionEquality().hash(_previousKingPositions),previousZobristKey]);

@override
String toString() {
  return 'Move(start: $start, end: $end, isCapture: $isCapture, isCastling: $isCastling, isEnPassant: $isEnPassant, isPromotion: $isPromotion, promotedPieceType: $promotedPieceType, isTwoStepPawnMove: $isTwoStepPawnMove, movedPiece: $movedPiece, capturedPiece: $capturedPiece, promotedTo: $promotedTo, halfMoveClockBefore: $halfMoveClockBefore, fullMoveNumberBefore: $fullMoveNumberBefore, capturedCell: $capturedCell, movedPieceBefore: $movedPieceBefore, rookFrom: $rookFrom, rookTo: $rookTo, rookBefore: $rookBefore, previousCastlingRights: $previousCastlingRights, previousEnPassantTarget: $previousEnPassantTarget, previousHalfMoveClock: $previousHalfMoveClock, previousFullMoveNumber: $previousFullMoveNumber, previousKingPositions: $previousKingPositions, previousZobristKey: $previousZobristKey)';
}


}

/// @nodoc
abstract mixin class _$MoveCopyWith<$Res> implements $MoveCopyWith<$Res> {
  factory _$MoveCopyWith(_Move value, $Res Function(_Move) _then) = __$MoveCopyWithImpl;
@override @useResult
$Res call({
 Cell start, Cell end, bool isCapture, bool isCastling, bool isEnPassant, bool isPromotion, PieceType? promotedPieceType, bool isTwoStepPawnMove, Piece movedPiece, Piece? capturedPiece, Piece? promotedTo, int? halfMoveClockBefore, int? fullMoveNumberBefore,@JsonKey(ignore: true) Cell? capturedCell,@JsonKey(ignore: true) Piece? movedPieceBefore,@JsonKey(ignore: true) Cell? rookFrom,@JsonKey(ignore: true) Cell? rookTo,@JsonKey(ignore: true) Piece? rookBefore,@JsonKey(ignore: true) Map<PieceColor, Map<CastlingSide, bool>>? previousCastlingRights,@JsonKey(ignore: true) Cell? previousEnPassantTarget,@JsonKey(ignore: true) int? previousHalfMoveClock,@JsonKey(ignore: true) int? previousFullMoveNumber,@JsonKey(ignore: true) Map<PieceColor, Cell>? previousKingPositions,@JsonKey(ignore: true) int? previousZobristKey
});


@override $CellCopyWith<$Res> get start;@override $CellCopyWith<$Res> get end;@override $PieceCopyWith<$Res> get movedPiece;@override $PieceCopyWith<$Res>? get capturedPiece;@override $PieceCopyWith<$Res>? get promotedTo;@override $CellCopyWith<$Res>? get capturedCell;@override $PieceCopyWith<$Res>? get movedPieceBefore;@override $CellCopyWith<$Res>? get rookFrom;@override $CellCopyWith<$Res>? get rookTo;@override $PieceCopyWith<$Res>? get rookBefore;@override $CellCopyWith<$Res>? get previousEnPassantTarget;

}
/// @nodoc
class __$MoveCopyWithImpl<$Res>
    implements _$MoveCopyWith<$Res> {
  __$MoveCopyWithImpl(this._self, this._then);

  final _Move _self;
  final $Res Function(_Move) _then;

/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? start = null,Object? end = null,Object? isCapture = null,Object? isCastling = null,Object? isEnPassant = null,Object? isPromotion = null,Object? promotedPieceType = freezed,Object? isTwoStepPawnMove = null,Object? movedPiece = null,Object? capturedPiece = freezed,Object? promotedTo = freezed,Object? halfMoveClockBefore = freezed,Object? fullMoveNumberBefore = freezed,Object? capturedCell = freezed,Object? movedPieceBefore = freezed,Object? rookFrom = freezed,Object? rookTo = freezed,Object? rookBefore = freezed,Object? previousCastlingRights = freezed,Object? previousEnPassantTarget = freezed,Object? previousHalfMoveClock = freezed,Object? previousFullMoveNumber = freezed,Object? previousKingPositions = freezed,Object? previousZobristKey = freezed,}) {
  return _then(_Move(
start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as Cell,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as Cell,isCapture: null == isCapture ? _self.isCapture : isCapture // ignore: cast_nullable_to_non_nullable
as bool,isCastling: null == isCastling ? _self.isCastling : isCastling // ignore: cast_nullable_to_non_nullable
as bool,isEnPassant: null == isEnPassant ? _self.isEnPassant : isEnPassant // ignore: cast_nullable_to_non_nullable
as bool,isPromotion: null == isPromotion ? _self.isPromotion : isPromotion // ignore: cast_nullable_to_non_nullable
as bool,promotedPieceType: freezed == promotedPieceType ? _self.promotedPieceType : promotedPieceType // ignore: cast_nullable_to_non_nullable
as PieceType?,isTwoStepPawnMove: null == isTwoStepPawnMove ? _self.isTwoStepPawnMove : isTwoStepPawnMove // ignore: cast_nullable_to_non_nullable
as bool,movedPiece: null == movedPiece ? _self.movedPiece : movedPiece // ignore: cast_nullable_to_non_nullable
as Piece,capturedPiece: freezed == capturedPiece ? _self.capturedPiece : capturedPiece // ignore: cast_nullable_to_non_nullable
as Piece?,promotedTo: freezed == promotedTo ? _self.promotedTo : promotedTo // ignore: cast_nullable_to_non_nullable
as Piece?,halfMoveClockBefore: freezed == halfMoveClockBefore ? _self.halfMoveClockBefore : halfMoveClockBefore // ignore: cast_nullable_to_non_nullable
as int?,fullMoveNumberBefore: freezed == fullMoveNumberBefore ? _self.fullMoveNumberBefore : fullMoveNumberBefore // ignore: cast_nullable_to_non_nullable
as int?,capturedCell: freezed == capturedCell ? _self.capturedCell : capturedCell // ignore: cast_nullable_to_non_nullable
as Cell?,movedPieceBefore: freezed == movedPieceBefore ? _self.movedPieceBefore : movedPieceBefore // ignore: cast_nullable_to_non_nullable
as Piece?,rookFrom: freezed == rookFrom ? _self.rookFrom : rookFrom // ignore: cast_nullable_to_non_nullable
as Cell?,rookTo: freezed == rookTo ? _self.rookTo : rookTo // ignore: cast_nullable_to_non_nullable
as Cell?,rookBefore: freezed == rookBefore ? _self.rookBefore : rookBefore // ignore: cast_nullable_to_non_nullable
as Piece?,previousCastlingRights: freezed == previousCastlingRights ? _self._previousCastlingRights : previousCastlingRights // ignore: cast_nullable_to_non_nullable
as Map<PieceColor, Map<CastlingSide, bool>>?,previousEnPassantTarget: freezed == previousEnPassantTarget ? _self.previousEnPassantTarget : previousEnPassantTarget // ignore: cast_nullable_to_non_nullable
as Cell?,previousHalfMoveClock: freezed == previousHalfMoveClock ? _self.previousHalfMoveClock : previousHalfMoveClock // ignore: cast_nullable_to_non_nullable
as int?,previousFullMoveNumber: freezed == previousFullMoveNumber ? _self.previousFullMoveNumber : previousFullMoveNumber // ignore: cast_nullable_to_non_nullable
as int?,previousKingPositions: freezed == previousKingPositions ? _self._previousKingPositions : previousKingPositions // ignore: cast_nullable_to_non_nullable
as Map<PieceColor, Cell>?,previousZobristKey: freezed == previousZobristKey ? _self.previousZobristKey : previousZobristKey // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CellCopyWith<$Res> get start {
  
  return $CellCopyWith<$Res>(_self.start, (value) {
    return _then(_self.copyWith(start: value));
  });
}/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CellCopyWith<$Res> get end {
  
  return $CellCopyWith<$Res>(_self.end, (value) {
    return _then(_self.copyWith(end: value));
  });
}/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PieceCopyWith<$Res> get movedPiece {
  
  return $PieceCopyWith<$Res>(_self.movedPiece, (value) {
    return _then(_self.copyWith(movedPiece: value));
  });
}/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PieceCopyWith<$Res>? get capturedPiece {
    if (_self.capturedPiece == null) {
    return null;
  }

  return $PieceCopyWith<$Res>(_self.capturedPiece!, (value) {
    return _then(_self.copyWith(capturedPiece: value));
  });
}/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PieceCopyWith<$Res>? get promotedTo {
    if (_self.promotedTo == null) {
    return null;
  }

  return $PieceCopyWith<$Res>(_self.promotedTo!, (value) {
    return _then(_self.copyWith(promotedTo: value));
  });
}/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CellCopyWith<$Res>? get capturedCell {
    if (_self.capturedCell == null) {
    return null;
  }

  return $CellCopyWith<$Res>(_self.capturedCell!, (value) {
    return _then(_self.copyWith(capturedCell: value));
  });
}/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PieceCopyWith<$Res>? get movedPieceBefore {
    if (_self.movedPieceBefore == null) {
    return null;
  }

  return $PieceCopyWith<$Res>(_self.movedPieceBefore!, (value) {
    return _then(_self.copyWith(movedPieceBefore: value));
  });
}/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CellCopyWith<$Res>? get rookFrom {
    if (_self.rookFrom == null) {
    return null;
  }

  return $CellCopyWith<$Res>(_self.rookFrom!, (value) {
    return _then(_self.copyWith(rookFrom: value));
  });
}/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CellCopyWith<$Res>? get rookTo {
    if (_self.rookTo == null) {
    return null;
  }

  return $CellCopyWith<$Res>(_self.rookTo!, (value) {
    return _then(_self.copyWith(rookTo: value));
  });
}/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PieceCopyWith<$Res>? get rookBefore {
    if (_self.rookBefore == null) {
    return null;
  }

  return $PieceCopyWith<$Res>(_self.rookBefore!, (value) {
    return _then(_self.copyWith(rookBefore: value));
  });
}/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CellCopyWith<$Res>? get previousEnPassantTarget {
    if (_self.previousEnPassantTarget == null) {
    return null;
  }

  return $CellCopyWith<$Res>(_self.previousEnPassantTarget!, (value) {
    return _then(_self.copyWith(previousEnPassantTarget: value));
  });
}
}

// dart format on
