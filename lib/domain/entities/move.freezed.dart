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
 bool get isTwoStepPawnMove;
/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MoveCopyWith<Move> get copyWith => _$MoveCopyWithImpl<Move>(this as Move, _$identity);

  /// Serializes this Move to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Move&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.isCapture, isCapture) || other.isCapture == isCapture)&&(identical(other.isCastling, isCastling) || other.isCastling == isCastling)&&(identical(other.isEnPassant, isEnPassant) || other.isEnPassant == isEnPassant)&&(identical(other.isPromotion, isPromotion) || other.isPromotion == isPromotion)&&(identical(other.promotedPieceType, promotedPieceType) || other.promotedPieceType == promotedPieceType)&&(identical(other.isTwoStepPawnMove, isTwoStepPawnMove) || other.isTwoStepPawnMove == isTwoStepPawnMove));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,start,end,isCapture,isCastling,isEnPassant,isPromotion,promotedPieceType,isTwoStepPawnMove);

@override
String toString() {
  return 'Move(start: $start, end: $end, isCapture: $isCapture, isCastling: $isCastling, isEnPassant: $isEnPassant, isPromotion: $isPromotion, promotedPieceType: $promotedPieceType, isTwoStepPawnMove: $isTwoStepPawnMove)';
}


}

/// @nodoc
abstract mixin class $MoveCopyWith<$Res>  {
  factory $MoveCopyWith(Move value, $Res Function(Move) _then) = _$MoveCopyWithImpl;
@useResult
$Res call({
 Cell start, Cell end, bool isCapture, bool isCastling, bool isEnPassant, bool isPromotion, PieceType? promotedPieceType, bool isTwoStepPawnMove
});


$CellCopyWith<$Res> get start;$CellCopyWith<$Res> get end;

}
/// @nodoc
class _$MoveCopyWithImpl<$Res>
    implements $MoveCopyWith<$Res> {
  _$MoveCopyWithImpl(this._self, this._then);

  final Move _self;
  final $Res Function(Move) _then;

/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? start = null,Object? end = null,Object? isCapture = null,Object? isCastling = null,Object? isEnPassant = null,Object? isPromotion = null,Object? promotedPieceType = freezed,Object? isTwoStepPawnMove = null,}) {
  return _then(_self.copyWith(
start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as Cell,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as Cell,isCapture: null == isCapture ? _self.isCapture : isCapture // ignore: cast_nullable_to_non_nullable
as bool,isCastling: null == isCastling ? _self.isCastling : isCastling // ignore: cast_nullable_to_non_nullable
as bool,isEnPassant: null == isEnPassant ? _self.isEnPassant : isEnPassant // ignore: cast_nullable_to_non_nullable
as bool,isPromotion: null == isPromotion ? _self.isPromotion : isPromotion // ignore: cast_nullable_to_non_nullable
as bool,promotedPieceType: freezed == promotedPieceType ? _self.promotedPieceType : promotedPieceType // ignore: cast_nullable_to_non_nullable
as PieceType?,isTwoStepPawnMove: null == isTwoStepPawnMove ? _self.isTwoStepPawnMove : isTwoStepPawnMove // ignore: cast_nullable_to_non_nullable
as bool,
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
}
}


/// @nodoc
@JsonSerializable()

class _Move implements Move {
  const _Move({required this.start, required this.end, this.isCapture = false, this.isCastling = false, this.isEnPassant = false, this.isPromotion = false, this.promotedPieceType, this.isTwoStepPawnMove = false});
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Move&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.isCapture, isCapture) || other.isCapture == isCapture)&&(identical(other.isCastling, isCastling) || other.isCastling == isCastling)&&(identical(other.isEnPassant, isEnPassant) || other.isEnPassant == isEnPassant)&&(identical(other.isPromotion, isPromotion) || other.isPromotion == isPromotion)&&(identical(other.promotedPieceType, promotedPieceType) || other.promotedPieceType == promotedPieceType)&&(identical(other.isTwoStepPawnMove, isTwoStepPawnMove) || other.isTwoStepPawnMove == isTwoStepPawnMove));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,start,end,isCapture,isCastling,isEnPassant,isPromotion,promotedPieceType,isTwoStepPawnMove);

@override
String toString() {
  return 'Move(start: $start, end: $end, isCapture: $isCapture, isCastling: $isCastling, isEnPassant: $isEnPassant, isPromotion: $isPromotion, promotedPieceType: $promotedPieceType, isTwoStepPawnMove: $isTwoStepPawnMove)';
}


}

/// @nodoc
abstract mixin class _$MoveCopyWith<$Res> implements $MoveCopyWith<$Res> {
  factory _$MoveCopyWith(_Move value, $Res Function(_Move) _then) = __$MoveCopyWithImpl;
@override @useResult
$Res call({
 Cell start, Cell end, bool isCapture, bool isCastling, bool isEnPassant, bool isPromotion, PieceType? promotedPieceType, bool isTwoStepPawnMove
});


@override $CellCopyWith<$Res> get start;@override $CellCopyWith<$Res> get end;

}
/// @nodoc
class __$MoveCopyWithImpl<$Res>
    implements _$MoveCopyWith<$Res> {
  __$MoveCopyWithImpl(this._self, this._then);

  final _Move _self;
  final $Res Function(_Move) _then;

/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? start = null,Object? end = null,Object? isCapture = null,Object? isCastling = null,Object? isEnPassant = null,Object? isPromotion = null,Object? promotedPieceType = freezed,Object? isTwoStepPawnMove = null,}) {
  return _then(_Move(
start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as Cell,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as Cell,isCapture: null == isCapture ? _self.isCapture : isCapture // ignore: cast_nullable_to_non_nullable
as bool,isCastling: null == isCastling ? _self.isCastling : isCastling // ignore: cast_nullable_to_non_nullable
as bool,isEnPassant: null == isEnPassant ? _self.isEnPassant : isEnPassant // ignore: cast_nullable_to_non_nullable
as bool,isPromotion: null == isPromotion ? _self.isPromotion : isPromotion // ignore: cast_nullable_to_non_nullable
as bool,promotedPieceType: freezed == promotedPieceType ? _self.promotedPieceType : promotedPieceType // ignore: cast_nullable_to_non_nullable
as PieceType?,isTwoStepPawnMove: null == isTwoStepPawnMove ? _self.isTwoStepPawnMove : isTwoStepPawnMove // ignore: cast_nullable_to_non_nullable
as bool,
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
}
}

// dart format on
