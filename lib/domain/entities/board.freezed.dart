// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'board.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Board {

 List<List<Piece?>> get squares;// 8x8 grid representing the board cells
 List<Move> get moveHistory;// History of moves made in the game
 PieceColor get currentPlayer;// Current player to move
 Map<PieceColor, Cell> get kingPositions;// Tracks the current position of each king
 Map<PieceColor, Map<CastlingSide, bool>> get castlingRights;// Tracks castling rights for each player
 Cell? get enPassantTarget;// The cell where an en passant capture is possible
 int get halfMoveClock;// Number of half-moves since the last capture or pawn advance (for fifty-move rule)
 int get fullMoveNumber;
/// Create a copy of Board
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BoardCopyWith<Board> get copyWith => _$BoardCopyWithImpl<Board>(this as Board, _$identity);

  /// Serializes this Board to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Board&&const DeepCollectionEquality().equals(other.squares, squares)&&const DeepCollectionEquality().equals(other.moveHistory, moveHistory)&&(identical(other.currentPlayer, currentPlayer) || other.currentPlayer == currentPlayer)&&const DeepCollectionEquality().equals(other.kingPositions, kingPositions)&&const DeepCollectionEquality().equals(other.castlingRights, castlingRights)&&(identical(other.enPassantTarget, enPassantTarget) || other.enPassantTarget == enPassantTarget)&&(identical(other.halfMoveClock, halfMoveClock) || other.halfMoveClock == halfMoveClock)&&(identical(other.fullMoveNumber, fullMoveNumber) || other.fullMoveNumber == fullMoveNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(squares),const DeepCollectionEquality().hash(moveHistory),currentPlayer,const DeepCollectionEquality().hash(kingPositions),const DeepCollectionEquality().hash(castlingRights),enPassantTarget,halfMoveClock,fullMoveNumber);

@override
String toString() {
  return 'Board(squares: $squares, moveHistory: $moveHistory, currentPlayer: $currentPlayer, kingPositions: $kingPositions, castlingRights: $castlingRights, enPassantTarget: $enPassantTarget, halfMoveClock: $halfMoveClock, fullMoveNumber: $fullMoveNumber)';
}


}

/// @nodoc
abstract mixin class $BoardCopyWith<$Res>  {
  factory $BoardCopyWith(Board value, $Res Function(Board) _then) = _$BoardCopyWithImpl;
@useResult
$Res call({
 List<List<Piece?>> squares, List<Move> moveHistory, PieceColor currentPlayer, Map<PieceColor, Cell> kingPositions, Map<PieceColor, Map<CastlingSide, bool>> castlingRights, Cell? enPassantTarget, int halfMoveClock, int fullMoveNumber
});


$CellCopyWith<$Res>? get enPassantTarget;

}
/// @nodoc
class _$BoardCopyWithImpl<$Res>
    implements $BoardCopyWith<$Res> {
  _$BoardCopyWithImpl(this._self, this._then);

  final Board _self;
  final $Res Function(Board) _then;

/// Create a copy of Board
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? squares = null,Object? moveHistory = null,Object? currentPlayer = null,Object? kingPositions = null,Object? castlingRights = null,Object? enPassantTarget = freezed,Object? halfMoveClock = null,Object? fullMoveNumber = null,}) {
  return _then(_self.copyWith(
squares: null == squares ? _self.squares : squares // ignore: cast_nullable_to_non_nullable
as List<List<Piece?>>,moveHistory: null == moveHistory ? _self.moveHistory : moveHistory // ignore: cast_nullable_to_non_nullable
as List<Move>,currentPlayer: null == currentPlayer ? _self.currentPlayer : currentPlayer // ignore: cast_nullable_to_non_nullable
as PieceColor,kingPositions: null == kingPositions ? _self.kingPositions : kingPositions // ignore: cast_nullable_to_non_nullable
as Map<PieceColor, Cell>,castlingRights: null == castlingRights ? _self.castlingRights : castlingRights // ignore: cast_nullable_to_non_nullable
as Map<PieceColor, Map<CastlingSide, bool>>,enPassantTarget: freezed == enPassantTarget ? _self.enPassantTarget : enPassantTarget // ignore: cast_nullable_to_non_nullable
as Cell?,halfMoveClock: null == halfMoveClock ? _self.halfMoveClock : halfMoveClock // ignore: cast_nullable_to_non_nullable
as int,fullMoveNumber: null == fullMoveNumber ? _self.fullMoveNumber : fullMoveNumber // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of Board
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CellCopyWith<$Res>? get enPassantTarget {
    if (_self.enPassantTarget == null) {
    return null;
  }

  return $CellCopyWith<$Res>(_self.enPassantTarget!, (value) {
    return _then(_self.copyWith(enPassantTarget: value));
  });
}
}


/// @nodoc
@JsonSerializable()

class _Board implements Board {
  const _Board({required final  List<List<Piece?>> squares, final  List<Move> moveHistory = const [], this.currentPlayer = PieceColor.white, required final  Map<PieceColor, Cell> kingPositions, final  Map<PieceColor, Map<CastlingSide, bool>> castlingRights = const {PieceColor.white : {CastlingSide.kingSide : true, CastlingSide.queenSide : true}, PieceColor.black : {CastlingSide.kingSide : true, CastlingSide.queenSide : true}}, this.enPassantTarget, this.halfMoveClock = 0, this.fullMoveNumber = 1}): _squares = squares,_moveHistory = moveHistory,_kingPositions = kingPositions,_castlingRights = castlingRights;
  factory _Board.fromJson(Map<String, dynamic> json) => _$BoardFromJson(json);

 final  List<List<Piece?>> _squares;
@override List<List<Piece?>> get squares {
  if (_squares is EqualUnmodifiableListView) return _squares;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_squares);
}

// 8x8 grid representing the board cells
 final  List<Move> _moveHistory;
// 8x8 grid representing the board cells
@override@JsonKey() List<Move> get moveHistory {
  if (_moveHistory is EqualUnmodifiableListView) return _moveHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_moveHistory);
}

// History of moves made in the game
@override@JsonKey() final  PieceColor currentPlayer;
// Current player to move
 final  Map<PieceColor, Cell> _kingPositions;
// Current player to move
@override Map<PieceColor, Cell> get kingPositions {
  if (_kingPositions is EqualUnmodifiableMapView) return _kingPositions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_kingPositions);
}

// Tracks the current position of each king
 final  Map<PieceColor, Map<CastlingSide, bool>> _castlingRights;
// Tracks the current position of each king
@override@JsonKey() Map<PieceColor, Map<CastlingSide, bool>> get castlingRights {
  if (_castlingRights is EqualUnmodifiableMapView) return _castlingRights;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_castlingRights);
}

// Tracks castling rights for each player
@override final  Cell? enPassantTarget;
// The cell where an en passant capture is possible
@override@JsonKey() final  int halfMoveClock;
// Number of half-moves since the last capture or pawn advance (for fifty-move rule)
@override@JsonKey() final  int fullMoveNumber;

/// Create a copy of Board
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BoardCopyWith<_Board> get copyWith => __$BoardCopyWithImpl<_Board>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BoardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Board&&const DeepCollectionEquality().equals(other._squares, _squares)&&const DeepCollectionEquality().equals(other._moveHistory, _moveHistory)&&(identical(other.currentPlayer, currentPlayer) || other.currentPlayer == currentPlayer)&&const DeepCollectionEquality().equals(other._kingPositions, _kingPositions)&&const DeepCollectionEquality().equals(other._castlingRights, _castlingRights)&&(identical(other.enPassantTarget, enPassantTarget) || other.enPassantTarget == enPassantTarget)&&(identical(other.halfMoveClock, halfMoveClock) || other.halfMoveClock == halfMoveClock)&&(identical(other.fullMoveNumber, fullMoveNumber) || other.fullMoveNumber == fullMoveNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_squares),const DeepCollectionEquality().hash(_moveHistory),currentPlayer,const DeepCollectionEquality().hash(_kingPositions),const DeepCollectionEquality().hash(_castlingRights),enPassantTarget,halfMoveClock,fullMoveNumber);

@override
String toString() {
  return 'Board(squares: $squares, moveHistory: $moveHistory, currentPlayer: $currentPlayer, kingPositions: $kingPositions, castlingRights: $castlingRights, enPassantTarget: $enPassantTarget, halfMoveClock: $halfMoveClock, fullMoveNumber: $fullMoveNumber)';
}


}

/// @nodoc
abstract mixin class _$BoardCopyWith<$Res> implements $BoardCopyWith<$Res> {
  factory _$BoardCopyWith(_Board value, $Res Function(_Board) _then) = __$BoardCopyWithImpl;
@override @useResult
$Res call({
 List<List<Piece?>> squares, List<Move> moveHistory, PieceColor currentPlayer, Map<PieceColor, Cell> kingPositions, Map<PieceColor, Map<CastlingSide, bool>> castlingRights, Cell? enPassantTarget, int halfMoveClock, int fullMoveNumber
});


@override $CellCopyWith<$Res>? get enPassantTarget;

}
/// @nodoc
class __$BoardCopyWithImpl<$Res>
    implements _$BoardCopyWith<$Res> {
  __$BoardCopyWithImpl(this._self, this._then);

  final _Board _self;
  final $Res Function(_Board) _then;

/// Create a copy of Board
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? squares = null,Object? moveHistory = null,Object? currentPlayer = null,Object? kingPositions = null,Object? castlingRights = null,Object? enPassantTarget = freezed,Object? halfMoveClock = null,Object? fullMoveNumber = null,}) {
  return _then(_Board(
squares: null == squares ? _self._squares : squares // ignore: cast_nullable_to_non_nullable
as List<List<Piece?>>,moveHistory: null == moveHistory ? _self._moveHistory : moveHistory // ignore: cast_nullable_to_non_nullable
as List<Move>,currentPlayer: null == currentPlayer ? _self.currentPlayer : currentPlayer // ignore: cast_nullable_to_non_nullable
as PieceColor,kingPositions: null == kingPositions ? _self._kingPositions : kingPositions // ignore: cast_nullable_to_non_nullable
as Map<PieceColor, Cell>,castlingRights: null == castlingRights ? _self._castlingRights : castlingRights // ignore: cast_nullable_to_non_nullable
as Map<PieceColor, Map<CastlingSide, bool>>,enPassantTarget: freezed == enPassantTarget ? _self.enPassantTarget : enPassantTarget // ignore: cast_nullable_to_non_nullable
as Cell?,halfMoveClock: null == halfMoveClock ? _self.halfMoveClock : halfMoveClock // ignore: cast_nullable_to_non_nullable
as int,fullMoveNumber: null == fullMoveNumber ? _self.fullMoveNumber : fullMoveNumber // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of Board
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CellCopyWith<$Res>? get enPassantTarget {
    if (_self.enPassantTarget == null) {
    return null;
  }

  return $CellCopyWith<$Res>(_self.enPassantTarget!, (value) {
    return _then(_self.copyWith(enPassantTarget: value));
  });
}
}

// dart format on
