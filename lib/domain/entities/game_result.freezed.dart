// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GameResult {

 GameOutcome get outcome;// The outcome of the game
 PieceColor? get winner;// The color of the winning player (if checkmate)
 DrawReason? get drawReason;
/// Create a copy of GameResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameResultCopyWith<GameResult> get copyWith => _$GameResultCopyWithImpl<GameResult>(this as GameResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameResult&&(identical(other.outcome, outcome) || other.outcome == outcome)&&(identical(other.winner, winner) || other.winner == winner)&&(identical(other.drawReason, drawReason) || other.drawReason == drawReason));
}


@override
int get hashCode => Object.hash(runtimeType,outcome,winner,drawReason);

@override
String toString() {
  return 'GameResult(outcome: $outcome, winner: $winner, drawReason: $drawReason)';
}


}

/// @nodoc
abstract mixin class $GameResultCopyWith<$Res>  {
  factory $GameResultCopyWith(GameResult value, $Res Function(GameResult) _then) = _$GameResultCopyWithImpl;
@useResult
$Res call({
 GameOutcome outcome, PieceColor? winner, DrawReason? drawReason
});




}
/// @nodoc
class _$GameResultCopyWithImpl<$Res>
    implements $GameResultCopyWith<$Res> {
  _$GameResultCopyWithImpl(this._self, this._then);

  final GameResult _self;
  final $Res Function(GameResult) _then;

/// Create a copy of GameResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? outcome = null,Object? winner = freezed,Object? drawReason = freezed,}) {
  return _then(_self.copyWith(
outcome: null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as GameOutcome,winner: freezed == winner ? _self.winner : winner // ignore: cast_nullable_to_non_nullable
as PieceColor?,drawReason: freezed == drawReason ? _self.drawReason : drawReason // ignore: cast_nullable_to_non_nullable
as DrawReason?,
  ));
}

}


/// @nodoc


class _GameResult implements GameResult {
  const _GameResult({required this.outcome, this.winner, this.drawReason});
  

@override final  GameOutcome outcome;
// The outcome of the game
@override final  PieceColor? winner;
// The color of the winning player (if checkmate)
@override final  DrawReason? drawReason;

/// Create a copy of GameResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameResultCopyWith<_GameResult> get copyWith => __$GameResultCopyWithImpl<_GameResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameResult&&(identical(other.outcome, outcome) || other.outcome == outcome)&&(identical(other.winner, winner) || other.winner == winner)&&(identical(other.drawReason, drawReason) || other.drawReason == drawReason));
}


@override
int get hashCode => Object.hash(runtimeType,outcome,winner,drawReason);

@override
String toString() {
  return 'GameResult(outcome: $outcome, winner: $winner, drawReason: $drawReason)';
}


}

/// @nodoc
abstract mixin class _$GameResultCopyWith<$Res> implements $GameResultCopyWith<$Res> {
  factory _$GameResultCopyWith(_GameResult value, $Res Function(_GameResult) _then) = __$GameResultCopyWithImpl;
@override @useResult
$Res call({
 GameOutcome outcome, PieceColor? winner, DrawReason? drawReason
});




}
/// @nodoc
class __$GameResultCopyWithImpl<$Res>
    implements _$GameResultCopyWith<$Res> {
  __$GameResultCopyWithImpl(this._self, this._then);

  final _GameResult _self;
  final $Res Function(_GameResult) _then;

/// Create a copy of GameResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? outcome = null,Object? winner = freezed,Object? drawReason = freezed,}) {
  return _then(_GameResult(
outcome: null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as GameOutcome,winner: freezed == winner ? _self.winner : winner // ignore: cast_nullable_to_non_nullable
as PieceColor?,drawReason: freezed == drawReason ? _self.drawReason : drawReason // ignore: cast_nullable_to_non_nullable
as DrawReason?,
  ));
}


}

// dart format on
