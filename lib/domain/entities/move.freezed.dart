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
 Piece get movedPiece; Piece? get capturedPiece; Piece? get promotedTo; Cell? get enPassantTargetBefore; bool? get wasFirstMoveKing; bool? get wasFirstMoveRook; int? get halfMoveClockBefore; int? get fullMoveNumberBefore; Cell? get castlingRookFrom; Cell? get castlingRookTo;
/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MoveCopyWith<Move> get copyWith => _$MoveCopyWithImpl<Move>(this as Move, _$identity);

  /// Serializes this Move to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Move&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.isCapture, isCapture) || other.isCapture == isCapture)&&(identical(other.isCastling, isCastling) || other.isCastling == isCastling)&&(identical(other.isEnPassant, isEnPassant) || other.isEnPassant == isEnPassant)&&(identical(other.isPromotion, isPromotion) || other.isPromotion == isPromotion)&&(identical(other.promotedPieceType, promotedPieceType) || other.promotedPieceType == promotedPieceType)&&(identical(other.isTwoStepPawnMove, isTwoStepPawnMove) || other.isTwoStepPawnMove == isTwoStepPawnMove)&&(identical(other.movedPiece, movedPiece) || other.movedPiece == movedPiece)&&(identical(other.capturedPiece, capturedPiece) || other.capturedPiece == capturedPiece)&&(identical(other.promotedTo, promotedTo) || other.promotedTo == promotedTo)&&(identical(other.enPassantTargetBefore, enPassantTargetBefore) || other.enPassantTargetBefore == enPassantTargetBefore)&&(identical(other.wasFirstMoveKing, wasFirstMoveKing) || other.wasFirstMoveKing == wasFirstMoveKing)&&(identical(other.wasFirstMoveRook, wasFirstMoveRook) || other.wasFirstMoveRook == wasFirstMoveRook)&&(identical(other.halfMoveClockBefore, halfMoveClockBefore) || other.halfMoveClockBefore == halfMoveClockBefore)&&(identical(other.fullMoveNumberBefore, fullMoveNumberBefore) || other.fullMoveNumberBefore == fullMoveNumberBefore)&&(identical(other.castlingRookFrom, castlingRookFrom) || other.castlingRookFrom == castlingRookFrom)&&(identical(other.castlingRookTo, castlingRookTo) || other.castlingRookTo == castlingRookTo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,start,end,isCapture,isCastling,isEnPassant,isPromotion,promotedPieceType,isTwoStepPawnMove,movedPiece,capturedPiece,promotedTo,enPassantTargetBefore,wasFirstMoveKing,wasFirstMoveRook,halfMoveClockBefore,fullMoveNumberBefore,castlingRookFrom,castlingRookTo);

@override
String toString() {
  return 'Move(start: $start, end: $end, isCapture: $isCapture, isCastling: $isCastling, isEnPassant: $isEnPassant, isPromotion: $isPromotion, promotedPieceType: $promotedPieceType, isTwoStepPawnMove: $isTwoStepPawnMove, movedPiece: $movedPiece, capturedPiece: $capturedPiece, promotedTo: $promotedTo, enPassantTargetBefore: $enPassantTargetBefore, wasFirstMoveKing: $wasFirstMoveKing, wasFirstMoveRook: $wasFirstMoveRook, halfMoveClockBefore: $halfMoveClockBefore, fullMoveNumberBefore: $fullMoveNumberBefore, castlingRookFrom: $castlingRookFrom, castlingRookTo: $castlingRookTo)';
}


}

/// @nodoc
abstract mixin class $MoveCopyWith<$Res>  {
  factory $MoveCopyWith(Move value, $Res Function(Move) _then) = _$MoveCopyWithImpl;
@useResult
$Res call({
 Cell start, Cell end, bool isCapture, bool isCastling, bool isEnPassant, bool isPromotion, PieceType? promotedPieceType, bool isTwoStepPawnMove, Piece movedPiece, Piece? capturedPiece, Piece? promotedTo, Cell? enPassantTargetBefore, bool? wasFirstMoveKing, bool? wasFirstMoveRook, int? halfMoveClockBefore, int? fullMoveNumberBefore, Cell? castlingRookFrom, Cell? castlingRookTo
});


$CellCopyWith<$Res> get start;$CellCopyWith<$Res> get end;$PieceCopyWith<$Res> get movedPiece;$PieceCopyWith<$Res>? get capturedPiece;$PieceCopyWith<$Res>? get promotedTo;$CellCopyWith<$Res>? get enPassantTargetBefore;$CellCopyWith<$Res>? get castlingRookFrom;$CellCopyWith<$Res>? get castlingRookTo;

}
/// @nodoc
class _$MoveCopyWithImpl<$Res>
    implements $MoveCopyWith<$Res> {
  _$MoveCopyWithImpl(this._self, this._then);

  final Move _self;
  final $Res Function(Move) _then;

/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? start = null,Object? end = null,Object? isCapture = null,Object? isCastling = null,Object? isEnPassant = null,Object? isPromotion = null,Object? promotedPieceType = freezed,Object? isTwoStepPawnMove = null,Object? movedPiece = null,Object? capturedPiece = freezed,Object? promotedTo = freezed,Object? enPassantTargetBefore = freezed,Object? wasFirstMoveKing = freezed,Object? wasFirstMoveRook = freezed,Object? halfMoveClockBefore = freezed,Object? fullMoveNumberBefore = freezed,Object? castlingRookFrom = freezed,Object? castlingRookTo = freezed,}) {
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
as Piece?,enPassantTargetBefore: freezed == enPassantTargetBefore ? _self.enPassantTargetBefore : enPassantTargetBefore // ignore: cast_nullable_to_non_nullable
as Cell?,wasFirstMoveKing: freezed == wasFirstMoveKing ? _self.wasFirstMoveKing : wasFirstMoveKing // ignore: cast_nullable_to_non_nullable
as bool?,wasFirstMoveRook: freezed == wasFirstMoveRook ? _self.wasFirstMoveRook : wasFirstMoveRook // ignore: cast_nullable_to_non_nullable
as bool?,halfMoveClockBefore: freezed == halfMoveClockBefore ? _self.halfMoveClockBefore : halfMoveClockBefore // ignore: cast_nullable_to_non_nullable
as int?,fullMoveNumberBefore: freezed == fullMoveNumberBefore ? _self.fullMoveNumberBefore : fullMoveNumberBefore // ignore: cast_nullable_to_non_nullable
as int?,castlingRookFrom: freezed == castlingRookFrom ? _self.castlingRookFrom : castlingRookFrom // ignore: cast_nullable_to_non_nullable
as Cell?,castlingRookTo: freezed == castlingRookTo ? _self.castlingRookTo : castlingRookTo // ignore: cast_nullable_to_non_nullable
as Cell?,
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
$CellCopyWith<$Res>? get enPassantTargetBefore {
    if (_self.enPassantTargetBefore == null) {
    return null;
  }

  return $CellCopyWith<$Res>(_self.enPassantTargetBefore!, (value) {
    return _then(_self.copyWith(enPassantTargetBefore: value));
  });
}/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CellCopyWith<$Res>? get castlingRookFrom {
    if (_self.castlingRookFrom == null) {
    return null;
  }

  return $CellCopyWith<$Res>(_self.castlingRookFrom!, (value) {
    return _then(_self.copyWith(castlingRookFrom: value));
  });
}/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CellCopyWith<$Res>? get castlingRookTo {
    if (_self.castlingRookTo == null) {
    return null;
  }

  return $CellCopyWith<$Res>(_self.castlingRookTo!, (value) {
    return _then(_self.copyWith(castlingRookTo: value));
  });
}
}


/// @nodoc
@JsonSerializable()

class _Move implements Move {
  const _Move({required this.start, required this.end, this.isCapture = false, this.isCastling = false, this.isEnPassant = false, this.isPromotion = false, this.promotedPieceType, this.isTwoStepPawnMove = false, required this.movedPiece, this.capturedPiece, this.promotedTo, this.enPassantTargetBefore, this.wasFirstMoveKing, this.wasFirstMoveRook, this.halfMoveClockBefore, this.fullMoveNumberBefore, this.castlingRookFrom, this.castlingRookTo});
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
@override final  Cell? enPassantTargetBefore;
@override final  bool? wasFirstMoveKing;
@override final  bool? wasFirstMoveRook;
@override final  int? halfMoveClockBefore;
@override final  int? fullMoveNumberBefore;
@override final  Cell? castlingRookFrom;
@override final  Cell? castlingRookTo;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Move&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.isCapture, isCapture) || other.isCapture == isCapture)&&(identical(other.isCastling, isCastling) || other.isCastling == isCastling)&&(identical(other.isEnPassant, isEnPassant) || other.isEnPassant == isEnPassant)&&(identical(other.isPromotion, isPromotion) || other.isPromotion == isPromotion)&&(identical(other.promotedPieceType, promotedPieceType) || other.promotedPieceType == promotedPieceType)&&(identical(other.isTwoStepPawnMove, isTwoStepPawnMove) || other.isTwoStepPawnMove == isTwoStepPawnMove)&&(identical(other.movedPiece, movedPiece) || other.movedPiece == movedPiece)&&(identical(other.capturedPiece, capturedPiece) || other.capturedPiece == capturedPiece)&&(identical(other.promotedTo, promotedTo) || other.promotedTo == promotedTo)&&(identical(other.enPassantTargetBefore, enPassantTargetBefore) || other.enPassantTargetBefore == enPassantTargetBefore)&&(identical(other.wasFirstMoveKing, wasFirstMoveKing) || other.wasFirstMoveKing == wasFirstMoveKing)&&(identical(other.wasFirstMoveRook, wasFirstMoveRook) || other.wasFirstMoveRook == wasFirstMoveRook)&&(identical(other.halfMoveClockBefore, halfMoveClockBefore) || other.halfMoveClockBefore == halfMoveClockBefore)&&(identical(other.fullMoveNumberBefore, fullMoveNumberBefore) || other.fullMoveNumberBefore == fullMoveNumberBefore)&&(identical(other.castlingRookFrom, castlingRookFrom) || other.castlingRookFrom == castlingRookFrom)&&(identical(other.castlingRookTo, castlingRookTo) || other.castlingRookTo == castlingRookTo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,start,end,isCapture,isCastling,isEnPassant,isPromotion,promotedPieceType,isTwoStepPawnMove,movedPiece,capturedPiece,promotedTo,enPassantTargetBefore,wasFirstMoveKing,wasFirstMoveRook,halfMoveClockBefore,fullMoveNumberBefore,castlingRookFrom,castlingRookTo);

@override
String toString() {
  return 'Move(start: $start, end: $end, isCapture: $isCapture, isCastling: $isCastling, isEnPassant: $isEnPassant, isPromotion: $isPromotion, promotedPieceType: $promotedPieceType, isTwoStepPawnMove: $isTwoStepPawnMove, movedPiece: $movedPiece, capturedPiece: $capturedPiece, promotedTo: $promotedTo, enPassantTargetBefore: $enPassantTargetBefore, wasFirstMoveKing: $wasFirstMoveKing, wasFirstMoveRook: $wasFirstMoveRook, halfMoveClockBefore: $halfMoveClockBefore, fullMoveNumberBefore: $fullMoveNumberBefore, castlingRookFrom: $castlingRookFrom, castlingRookTo: $castlingRookTo)';
}


}

/// @nodoc
abstract mixin class _$MoveCopyWith<$Res> implements $MoveCopyWith<$Res> {
  factory _$MoveCopyWith(_Move value, $Res Function(_Move) _then) = __$MoveCopyWithImpl;
@override @useResult
$Res call({
 Cell start, Cell end, bool isCapture, bool isCastling, bool isEnPassant, bool isPromotion, PieceType? promotedPieceType, bool isTwoStepPawnMove, Piece movedPiece, Piece? capturedPiece, Piece? promotedTo, Cell? enPassantTargetBefore, bool? wasFirstMoveKing, bool? wasFirstMoveRook, int? halfMoveClockBefore, int? fullMoveNumberBefore, Cell? castlingRookFrom, Cell? castlingRookTo
});


@override $CellCopyWith<$Res> get start;@override $CellCopyWith<$Res> get end;@override $PieceCopyWith<$Res> get movedPiece;@override $PieceCopyWith<$Res>? get capturedPiece;@override $PieceCopyWith<$Res>? get promotedTo;@override $CellCopyWith<$Res>? get enPassantTargetBefore;@override $CellCopyWith<$Res>? get castlingRookFrom;@override $CellCopyWith<$Res>? get castlingRookTo;

}
/// @nodoc
class __$MoveCopyWithImpl<$Res>
    implements _$MoveCopyWith<$Res> {
  __$MoveCopyWithImpl(this._self, this._then);

  final _Move _self;
  final $Res Function(_Move) _then;

/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? start = null,Object? end = null,Object? isCapture = null,Object? isCastling = null,Object? isEnPassant = null,Object? isPromotion = null,Object? promotedPieceType = freezed,Object? isTwoStepPawnMove = null,Object? movedPiece = null,Object? capturedPiece = freezed,Object? promotedTo = freezed,Object? enPassantTargetBefore = freezed,Object? wasFirstMoveKing = freezed,Object? wasFirstMoveRook = freezed,Object? halfMoveClockBefore = freezed,Object? fullMoveNumberBefore = freezed,Object? castlingRookFrom = freezed,Object? castlingRookTo = freezed,}) {
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
as Piece?,enPassantTargetBefore: freezed == enPassantTargetBefore ? _self.enPassantTargetBefore : enPassantTargetBefore // ignore: cast_nullable_to_non_nullable
as Cell?,wasFirstMoveKing: freezed == wasFirstMoveKing ? _self.wasFirstMoveKing : wasFirstMoveKing // ignore: cast_nullable_to_non_nullable
as bool?,wasFirstMoveRook: freezed == wasFirstMoveRook ? _self.wasFirstMoveRook : wasFirstMoveRook // ignore: cast_nullable_to_non_nullable
as bool?,halfMoveClockBefore: freezed == halfMoveClockBefore ? _self.halfMoveClockBefore : halfMoveClockBefore // ignore: cast_nullable_to_non_nullable
as int?,fullMoveNumberBefore: freezed == fullMoveNumberBefore ? _self.fullMoveNumberBefore : fullMoveNumberBefore // ignore: cast_nullable_to_non_nullable
as int?,castlingRookFrom: freezed == castlingRookFrom ? _self.castlingRookFrom : castlingRookFrom // ignore: cast_nullable_to_non_nullable
as Cell?,castlingRookTo: freezed == castlingRookTo ? _self.castlingRookTo : castlingRookTo // ignore: cast_nullable_to_non_nullable
as Cell?,
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
$CellCopyWith<$Res>? get enPassantTargetBefore {
    if (_self.enPassantTargetBefore == null) {
    return null;
  }

  return $CellCopyWith<$Res>(_self.enPassantTargetBefore!, (value) {
    return _then(_self.copyWith(enPassantTargetBefore: value));
  });
}/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CellCopyWith<$Res>? get castlingRookFrom {
    if (_self.castlingRookFrom == null) {
    return null;
  }

  return $CellCopyWith<$Res>(_self.castlingRookFrom!, (value) {
    return _then(_self.copyWith(castlingRookFrom: value));
  });
}/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CellCopyWith<$Res>? get castlingRookTo {
    if (_self.castlingRookTo == null) {
    return null;
  }

  return $CellCopyWith<$Res>(_self.castlingRookTo!, (value) {
    return _then(_self.copyWith(castlingRookTo: value));
  });
}
}

// dart format on
