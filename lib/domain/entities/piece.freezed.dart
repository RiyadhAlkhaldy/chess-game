// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'piece.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Piece {

 PieceColor get color;// Color of the piece (white or black)
 PieceType get type;// Type of the piece (king, queen, etc.)
 bool get hasMoved;
/// Create a copy of Piece
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PieceCopyWith<Piece> get copyWith => _$PieceCopyWithImpl<Piece>(this as Piece, _$identity);

  /// Serializes this Piece to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Piece&&(identical(other.color, color) || other.color == color)&&(identical(other.type, type) || other.type == type)&&(identical(other.hasMoved, hasMoved) || other.hasMoved == hasMoved));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,color,type,hasMoved);

@override
String toString() {
  return 'Piece(color: $color, type: $type, hasMoved: $hasMoved)';
}


}

/// @nodoc
abstract mixin class $PieceCopyWith<$Res>  {
  factory $PieceCopyWith(Piece value, $Res Function(Piece) _then) = _$PieceCopyWithImpl;
@useResult
$Res call({
 PieceColor color, PieceType type, bool hasMoved
});




}
/// @nodoc
class _$PieceCopyWithImpl<$Res>
    implements $PieceCopyWith<$Res> {
  _$PieceCopyWithImpl(this._self, this._then);

  final Piece _self;
  final $Res Function(Piece) _then;

/// Create a copy of Piece
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? color = null,Object? type = null,Object? hasMoved = null,}) {
  return _then(_self.copyWith(
color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as PieceColor,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PieceType,hasMoved: null == hasMoved ? _self.hasMoved : hasMoved // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _Piece extends Piece {
   _Piece({required this.color, required this.type, this.hasMoved = false}): super._();
  factory _Piece.fromJson(Map<String, dynamic> json) => _$PieceFromJson(json);

@override final  PieceColor color;
// Color of the piece (white or black)
@override final  PieceType type;
// Type of the piece (king, queen, etc.)
@override@JsonKey() final  bool hasMoved;

/// Create a copy of Piece
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PieceCopyWith<_Piece> get copyWith => __$PieceCopyWithImpl<_Piece>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PieceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Piece&&(identical(other.color, color) || other.color == color)&&(identical(other.type, type) || other.type == type)&&(identical(other.hasMoved, hasMoved) || other.hasMoved == hasMoved));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,color,type,hasMoved);

@override
String toString() {
  return 'Piece(color: $color, type: $type, hasMoved: $hasMoved)';
}


}

/// @nodoc
abstract mixin class _$PieceCopyWith<$Res> implements $PieceCopyWith<$Res> {
  factory _$PieceCopyWith(_Piece value, $Res Function(_Piece) _then) = __$PieceCopyWithImpl;
@override @useResult
$Res call({
 PieceColor color, PieceType type, bool hasMoved
});




}
/// @nodoc
class __$PieceCopyWithImpl<$Res>
    implements _$PieceCopyWith<$Res> {
  __$PieceCopyWithImpl(this._self, this._then);

  final _Piece _self;
  final $Res Function(_Piece) _then;

/// Create a copy of Piece
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? color = null,Object? type = null,Object? hasMoved = null,}) {
  return _then(_Piece(
color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as PieceColor,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PieceType,hasMoved: null == hasMoved ? _self.hasMoved : hasMoved // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$King {

 PieceColor get color; PieceType get type;// Type of the piece (king, queen, etc.)
 bool get hasMoved;
/// Create a copy of King
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KingCopyWith<King> get copyWith => _$KingCopyWithImpl<King>(this as King, _$identity);

  /// Serializes this King to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is King&&(identical(other.color, color) || other.color == color)&&(identical(other.type, type) || other.type == type)&&(identical(other.hasMoved, hasMoved) || other.hasMoved == hasMoved));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,color,type,hasMoved);

@override
String toString() {
  return 'King(color: $color, type: $type, hasMoved: $hasMoved)';
}


}

/// @nodoc
abstract mixin class $KingCopyWith<$Res> implements $PieceCopyWith<$Res> {
  factory $KingCopyWith(King value, $Res Function(King) _then) = _$KingCopyWithImpl;
@useResult
$Res call({
 PieceColor color, PieceType type, bool hasMoved
});




}
/// @nodoc
class _$KingCopyWithImpl<$Res>
    implements $KingCopyWith<$Res> {
  _$KingCopyWithImpl(this._self, this._then);

  final King _self;
  final $Res Function(King) _then;

/// Create a copy of King
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? color = null,Object? type = null,Object? hasMoved = null,}) {
  return _then(_self.copyWith(
color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as PieceColor,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PieceType,hasMoved: null == hasMoved ? _self.hasMoved : hasMoved // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _King extends King {
  const _King({required this.color, required this.type, this.hasMoved = false}): super._();
  factory _King.fromJson(Map<String, dynamic> json) => _$KingFromJson(json);

@override final  PieceColor color;
@override final  PieceType type;
// Type of the piece (king, queen, etc.)
@override@JsonKey() final  bool hasMoved;

/// Create a copy of King
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KingCopyWith<_King> get copyWith => __$KingCopyWithImpl<_King>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _King&&(identical(other.color, color) || other.color == color)&&(identical(other.type, type) || other.type == type)&&(identical(other.hasMoved, hasMoved) || other.hasMoved == hasMoved));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,color,type,hasMoved);

@override
String toString() {
  return 'King(color: $color, type: $type, hasMoved: $hasMoved)';
}


}

/// @nodoc
abstract mixin class _$KingCopyWith<$Res> implements $KingCopyWith<$Res> {
  factory _$KingCopyWith(_King value, $Res Function(_King) _then) = __$KingCopyWithImpl;
@override @useResult
$Res call({
 PieceColor color, PieceType type, bool hasMoved
});




}
/// @nodoc
class __$KingCopyWithImpl<$Res>
    implements _$KingCopyWith<$Res> {
  __$KingCopyWithImpl(this._self, this._then);

  final _King _self;
  final $Res Function(_King) _then;

/// Create a copy of King
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? color = null,Object? type = null,Object? hasMoved = null,}) {
  return _then(_King(
color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as PieceColor,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PieceType,hasMoved: null == hasMoved ? _self.hasMoved : hasMoved // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$Queen {

 PieceColor get color; PieceType get type;// Type of the piece (king, queen, etc.)
 bool get hasMoved;
/// Create a copy of Queen
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QueenCopyWith<Queen> get copyWith => _$QueenCopyWithImpl<Queen>(this as Queen, _$identity);

  /// Serializes this Queen to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Queen&&(identical(other.color, color) || other.color == color)&&(identical(other.type, type) || other.type == type)&&(identical(other.hasMoved, hasMoved) || other.hasMoved == hasMoved));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,color,type,hasMoved);

@override
String toString() {
  return 'Queen(color: $color, type: $type, hasMoved: $hasMoved)';
}


}

/// @nodoc
abstract mixin class $QueenCopyWith<$Res> implements $PieceCopyWith<$Res> {
  factory $QueenCopyWith(Queen value, $Res Function(Queen) _then) = _$QueenCopyWithImpl;
@useResult
$Res call({
 PieceColor color, PieceType type, bool hasMoved
});




}
/// @nodoc
class _$QueenCopyWithImpl<$Res>
    implements $QueenCopyWith<$Res> {
  _$QueenCopyWithImpl(this._self, this._then);

  final Queen _self;
  final $Res Function(Queen) _then;

/// Create a copy of Queen
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? color = null,Object? type = null,Object? hasMoved = null,}) {
  return _then(_self.copyWith(
color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as PieceColor,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PieceType,hasMoved: null == hasMoved ? _self.hasMoved : hasMoved // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _Queen extends Queen {
  const _Queen({required this.color, required this.type, this.hasMoved = false}): super._();
  factory _Queen.fromJson(Map<String, dynamic> json) => _$QueenFromJson(json);

@override final  PieceColor color;
@override final  PieceType type;
// Type of the piece (king, queen, etc.)
@override@JsonKey() final  bool hasMoved;

/// Create a copy of Queen
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QueenCopyWith<_Queen> get copyWith => __$QueenCopyWithImpl<_Queen>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QueenToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Queen&&(identical(other.color, color) || other.color == color)&&(identical(other.type, type) || other.type == type)&&(identical(other.hasMoved, hasMoved) || other.hasMoved == hasMoved));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,color,type,hasMoved);

@override
String toString() {
  return 'Queen(color: $color, type: $type, hasMoved: $hasMoved)';
}


}

/// @nodoc
abstract mixin class _$QueenCopyWith<$Res> implements $QueenCopyWith<$Res> {
  factory _$QueenCopyWith(_Queen value, $Res Function(_Queen) _then) = __$QueenCopyWithImpl;
@override @useResult
$Res call({
 PieceColor color, PieceType type, bool hasMoved
});




}
/// @nodoc
class __$QueenCopyWithImpl<$Res>
    implements _$QueenCopyWith<$Res> {
  __$QueenCopyWithImpl(this._self, this._then);

  final _Queen _self;
  final $Res Function(_Queen) _then;

/// Create a copy of Queen
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? color = null,Object? type = null,Object? hasMoved = null,}) {
  return _then(_Queen(
color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as PieceColor,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PieceType,hasMoved: null == hasMoved ? _self.hasMoved : hasMoved // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$Rook {

 PieceColor get color; PieceType get type; bool get hasMoved;
/// Create a copy of Rook
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RookCopyWith<Rook> get copyWith => _$RookCopyWithImpl<Rook>(this as Rook, _$identity);

  /// Serializes this Rook to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Rook&&(identical(other.color, color) || other.color == color)&&(identical(other.type, type) || other.type == type)&&(identical(other.hasMoved, hasMoved) || other.hasMoved == hasMoved));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,color,type,hasMoved);

@override
String toString() {
  return 'Rook(color: $color, type: $type, hasMoved: $hasMoved)';
}


}

/// @nodoc
abstract mixin class $RookCopyWith<$Res> implements $PieceCopyWith<$Res> {
  factory $RookCopyWith(Rook value, $Res Function(Rook) _then) = _$RookCopyWithImpl;
@useResult
$Res call({
 PieceColor color, PieceType type, bool hasMoved
});




}
/// @nodoc
class _$RookCopyWithImpl<$Res>
    implements $RookCopyWith<$Res> {
  _$RookCopyWithImpl(this._self, this._then);

  final Rook _self;
  final $Res Function(Rook) _then;

/// Create a copy of Rook
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? color = null,Object? type = null,Object? hasMoved = null,}) {
  return _then(_self.copyWith(
color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as PieceColor,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PieceType,hasMoved: null == hasMoved ? _self.hasMoved : hasMoved // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _Rook extends Rook {
  const _Rook({required this.color, required this.type, this.hasMoved = false}): super._();
  factory _Rook.fromJson(Map<String, dynamic> json) => _$RookFromJson(json);

@override final  PieceColor color;
@override final  PieceType type;
@override@JsonKey() final  bool hasMoved;

/// Create a copy of Rook
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RookCopyWith<_Rook> get copyWith => __$RookCopyWithImpl<_Rook>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RookToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Rook&&(identical(other.color, color) || other.color == color)&&(identical(other.type, type) || other.type == type)&&(identical(other.hasMoved, hasMoved) || other.hasMoved == hasMoved));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,color,type,hasMoved);

@override
String toString() {
  return 'Rook(color: $color, type: $type, hasMoved: $hasMoved)';
}


}

/// @nodoc
abstract mixin class _$RookCopyWith<$Res> implements $RookCopyWith<$Res> {
  factory _$RookCopyWith(_Rook value, $Res Function(_Rook) _then) = __$RookCopyWithImpl;
@override @useResult
$Res call({
 PieceColor color, PieceType type, bool hasMoved
});




}
/// @nodoc
class __$RookCopyWithImpl<$Res>
    implements _$RookCopyWith<$Res> {
  __$RookCopyWithImpl(this._self, this._then);

  final _Rook _self;
  final $Res Function(_Rook) _then;

/// Create a copy of Rook
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? color = null,Object? type = null,Object? hasMoved = null,}) {
  return _then(_Rook(
color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as PieceColor,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PieceType,hasMoved: null == hasMoved ? _self.hasMoved : hasMoved // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$Bishop {

 PieceColor get color; PieceType get type; bool get hasMoved;
/// Create a copy of Bishop
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BishopCopyWith<Bishop> get copyWith => _$BishopCopyWithImpl<Bishop>(this as Bishop, _$identity);

  /// Serializes this Bishop to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Bishop&&(identical(other.color, color) || other.color == color)&&(identical(other.type, type) || other.type == type)&&(identical(other.hasMoved, hasMoved) || other.hasMoved == hasMoved));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,color,type,hasMoved);

@override
String toString() {
  return 'Bishop(color: $color, type: $type, hasMoved: $hasMoved)';
}


}

/// @nodoc
abstract mixin class $BishopCopyWith<$Res> implements $PieceCopyWith<$Res> {
  factory $BishopCopyWith(Bishop value, $Res Function(Bishop) _then) = _$BishopCopyWithImpl;
@useResult
$Res call({
 PieceColor color, PieceType type, bool hasMoved
});




}
/// @nodoc
class _$BishopCopyWithImpl<$Res>
    implements $BishopCopyWith<$Res> {
  _$BishopCopyWithImpl(this._self, this._then);

  final Bishop _self;
  final $Res Function(Bishop) _then;

/// Create a copy of Bishop
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? color = null,Object? type = null,Object? hasMoved = null,}) {
  return _then(_self.copyWith(
color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as PieceColor,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PieceType,hasMoved: null == hasMoved ? _self.hasMoved : hasMoved // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _Bishop extends Bishop {
  const _Bishop({required this.color, required this.type, this.hasMoved = false}): super._();
  factory _Bishop.fromJson(Map<String, dynamic> json) => _$BishopFromJson(json);

@override final  PieceColor color;
@override final  PieceType type;
@override@JsonKey() final  bool hasMoved;

/// Create a copy of Bishop
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BishopCopyWith<_Bishop> get copyWith => __$BishopCopyWithImpl<_Bishop>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BishopToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Bishop&&(identical(other.color, color) || other.color == color)&&(identical(other.type, type) || other.type == type)&&(identical(other.hasMoved, hasMoved) || other.hasMoved == hasMoved));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,color,type,hasMoved);

@override
String toString() {
  return 'Bishop(color: $color, type: $type, hasMoved: $hasMoved)';
}


}

/// @nodoc
abstract mixin class _$BishopCopyWith<$Res> implements $BishopCopyWith<$Res> {
  factory _$BishopCopyWith(_Bishop value, $Res Function(_Bishop) _then) = __$BishopCopyWithImpl;
@override @useResult
$Res call({
 PieceColor color, PieceType type, bool hasMoved
});




}
/// @nodoc
class __$BishopCopyWithImpl<$Res>
    implements _$BishopCopyWith<$Res> {
  __$BishopCopyWithImpl(this._self, this._then);

  final _Bishop _self;
  final $Res Function(_Bishop) _then;

/// Create a copy of Bishop
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? color = null,Object? type = null,Object? hasMoved = null,}) {
  return _then(_Bishop(
color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as PieceColor,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PieceType,hasMoved: null == hasMoved ? _self.hasMoved : hasMoved // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$Knight {

 PieceColor get color; PieceType get type; bool get hasMoved;
/// Create a copy of Knight
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KnightCopyWith<Knight> get copyWith => _$KnightCopyWithImpl<Knight>(this as Knight, _$identity);

  /// Serializes this Knight to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Knight&&(identical(other.color, color) || other.color == color)&&(identical(other.type, type) || other.type == type)&&(identical(other.hasMoved, hasMoved) || other.hasMoved == hasMoved));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,color,type,hasMoved);

@override
String toString() {
  return 'Knight(color: $color, type: $type, hasMoved: $hasMoved)';
}


}

/// @nodoc
abstract mixin class $KnightCopyWith<$Res> implements $PieceCopyWith<$Res> {
  factory $KnightCopyWith(Knight value, $Res Function(Knight) _then) = _$KnightCopyWithImpl;
@useResult
$Res call({
 PieceColor color, PieceType type, bool hasMoved
});




}
/// @nodoc
class _$KnightCopyWithImpl<$Res>
    implements $KnightCopyWith<$Res> {
  _$KnightCopyWithImpl(this._self, this._then);

  final Knight _self;
  final $Res Function(Knight) _then;

/// Create a copy of Knight
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? color = null,Object? type = null,Object? hasMoved = null,}) {
  return _then(_self.copyWith(
color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as PieceColor,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PieceType,hasMoved: null == hasMoved ? _self.hasMoved : hasMoved // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _Knight extends Knight {
  const _Knight({required this.color, required this.type, this.hasMoved = false}): super._();
  factory _Knight.fromJson(Map<String, dynamic> json) => _$KnightFromJson(json);

@override final  PieceColor color;
@override final  PieceType type;
@override@JsonKey() final  bool hasMoved;

/// Create a copy of Knight
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KnightCopyWith<_Knight> get copyWith => __$KnightCopyWithImpl<_Knight>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KnightToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Knight&&(identical(other.color, color) || other.color == color)&&(identical(other.type, type) || other.type == type)&&(identical(other.hasMoved, hasMoved) || other.hasMoved == hasMoved));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,color,type,hasMoved);

@override
String toString() {
  return 'Knight(color: $color, type: $type, hasMoved: $hasMoved)';
}


}

/// @nodoc
abstract mixin class _$KnightCopyWith<$Res> implements $KnightCopyWith<$Res> {
  factory _$KnightCopyWith(_Knight value, $Res Function(_Knight) _then) = __$KnightCopyWithImpl;
@override @useResult
$Res call({
 PieceColor color, PieceType type, bool hasMoved
});




}
/// @nodoc
class __$KnightCopyWithImpl<$Res>
    implements _$KnightCopyWith<$Res> {
  __$KnightCopyWithImpl(this._self, this._then);

  final _Knight _self;
  final $Res Function(_Knight) _then;

/// Create a copy of Knight
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? color = null,Object? type = null,Object? hasMoved = null,}) {
  return _then(_Knight(
color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as PieceColor,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PieceType,hasMoved: null == hasMoved ? _self.hasMoved : hasMoved // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$Pawn {

 PieceColor get color; PieceType get type; bool get hasMoved;
/// Create a copy of Pawn
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PawnCopyWith<Pawn> get copyWith => _$PawnCopyWithImpl<Pawn>(this as Pawn, _$identity);

  /// Serializes this Pawn to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Pawn&&(identical(other.color, color) || other.color == color)&&(identical(other.type, type) || other.type == type)&&(identical(other.hasMoved, hasMoved) || other.hasMoved == hasMoved));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,color,type,hasMoved);

@override
String toString() {
  return 'Pawn(color: $color, type: $type, hasMoved: $hasMoved)';
}


}

/// @nodoc
abstract mixin class $PawnCopyWith<$Res> implements $PieceCopyWith<$Res> {
  factory $PawnCopyWith(Pawn value, $Res Function(Pawn) _then) = _$PawnCopyWithImpl;
@useResult
$Res call({
 PieceColor color, PieceType type, bool hasMoved
});




}
/// @nodoc
class _$PawnCopyWithImpl<$Res>
    implements $PawnCopyWith<$Res> {
  _$PawnCopyWithImpl(this._self, this._then);

  final Pawn _self;
  final $Res Function(Pawn) _then;

/// Create a copy of Pawn
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? color = null,Object? type = null,Object? hasMoved = null,}) {
  return _then(_self.copyWith(
color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as PieceColor,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PieceType,hasMoved: null == hasMoved ? _self.hasMoved : hasMoved // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _Pawn extends Pawn {
  const _Pawn({required this.color, required this.type, this.hasMoved = false}): super._();
  factory _Pawn.fromJson(Map<String, dynamic> json) => _$PawnFromJson(json);

@override final  PieceColor color;
@override final  PieceType type;
@override@JsonKey() final  bool hasMoved;

/// Create a copy of Pawn
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PawnCopyWith<_Pawn> get copyWith => __$PawnCopyWithImpl<_Pawn>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PawnToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Pawn&&(identical(other.color, color) || other.color == color)&&(identical(other.type, type) || other.type == type)&&(identical(other.hasMoved, hasMoved) || other.hasMoved == hasMoved));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,color,type,hasMoved);

@override
String toString() {
  return 'Pawn(color: $color, type: $type, hasMoved: $hasMoved)';
}


}

/// @nodoc
abstract mixin class _$PawnCopyWith<$Res> implements $PawnCopyWith<$Res> {
  factory _$PawnCopyWith(_Pawn value, $Res Function(_Pawn) _then) = __$PawnCopyWithImpl;
@override @useResult
$Res call({
 PieceColor color, PieceType type, bool hasMoved
});




}
/// @nodoc
class __$PawnCopyWithImpl<$Res>
    implements _$PawnCopyWith<$Res> {
  __$PawnCopyWithImpl(this._self, this._then);

  final _Pawn _self;
  final $Res Function(_Pawn) _then;

/// Create a copy of Pawn
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? color = null,Object? type = null,Object? hasMoved = null,}) {
  return _then(_Pawn(
color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as PieceColor,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PieceType,hasMoved: null == hasMoved ? _self.hasMoved : hasMoved // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
