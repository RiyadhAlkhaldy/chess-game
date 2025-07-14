// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'piece.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Piece _$PieceFromJson(Map<String, dynamic> json) => _Piece(
  color: $enumDecode(_$PieceColorEnumMap, json['color']),
  type: $enumDecode(_$PieceTypeEnumMap, json['type']),
  hasMoved: json['hasMoved'] as bool? ?? false,
);

Map<String, dynamic> _$PieceToJson(_Piece instance) => <String, dynamic>{
  'color': _$PieceColorEnumMap[instance.color]!,
  'type': _$PieceTypeEnumMap[instance.type]!,
  'hasMoved': instance.hasMoved,
};

const _$PieceColorEnumMap = {
  PieceColor.white: 'white',
  PieceColor.black: 'black',
};

const _$PieceTypeEnumMap = {
  PieceType.king: 'king',
  PieceType.queen: 'queen',
  PieceType.rook: 'rook',
  PieceType.bishop: 'bishop',
  PieceType.knight: 'knight',
  PieceType.pawn: 'pawn',
};

_King _$KingFromJson(Map<String, dynamic> json) => _King(
  color: $enumDecode(_$PieceColorEnumMap, json['color']),
  type: $enumDecode(_$PieceTypeEnumMap, json['type']),
  hasMoved: json['hasMoved'] as bool? ?? false,
);

Map<String, dynamic> _$KingToJson(_King instance) => <String, dynamic>{
  'color': _$PieceColorEnumMap[instance.color]!,
  'type': _$PieceTypeEnumMap[instance.type]!,
  'hasMoved': instance.hasMoved,
};

_Queen _$QueenFromJson(Map<String, dynamic> json) => _Queen(
  color: $enumDecode(_$PieceColorEnumMap, json['color']),
  type: $enumDecode(_$PieceTypeEnumMap, json['type']),
  hasMoved: json['hasMoved'] as bool? ?? false,
);

Map<String, dynamic> _$QueenToJson(_Queen instance) => <String, dynamic>{
  'color': _$PieceColorEnumMap[instance.color]!,
  'type': _$PieceTypeEnumMap[instance.type]!,
  'hasMoved': instance.hasMoved,
};

_Rook _$RookFromJson(Map<String, dynamic> json) => _Rook(
  color: $enumDecode(_$PieceColorEnumMap, json['color']),
  type: $enumDecode(_$PieceTypeEnumMap, json['type']),
  hasMoved: json['hasMoved'] as bool? ?? false,
);

Map<String, dynamic> _$RookToJson(_Rook instance) => <String, dynamic>{
  'color': _$PieceColorEnumMap[instance.color]!,
  'type': _$PieceTypeEnumMap[instance.type]!,
  'hasMoved': instance.hasMoved,
};

_Bishop _$BishopFromJson(Map<String, dynamic> json) => _Bishop(
  color: $enumDecode(_$PieceColorEnumMap, json['color']),
  type: $enumDecode(_$PieceTypeEnumMap, json['type']),
  hasMoved: json['hasMoved'] as bool? ?? false,
);

Map<String, dynamic> _$BishopToJson(_Bishop instance) => <String, dynamic>{
  'color': _$PieceColorEnumMap[instance.color]!,
  'type': _$PieceTypeEnumMap[instance.type]!,
  'hasMoved': instance.hasMoved,
};

_Knight _$KnightFromJson(Map<String, dynamic> json) => _Knight(
  color: $enumDecode(_$PieceColorEnumMap, json['color']),
  type: $enumDecode(_$PieceTypeEnumMap, json['type']),
  hasMoved: json['hasMoved'] as bool? ?? false,
);

Map<String, dynamic> _$KnightToJson(_Knight instance) => <String, dynamic>{
  'color': _$PieceColorEnumMap[instance.color]!,
  'type': _$PieceTypeEnumMap[instance.type]!,
  'hasMoved': instance.hasMoved,
};

_Pawn _$PawnFromJson(Map<String, dynamic> json) => _Pawn(
  color: $enumDecode(_$PieceColorEnumMap, json['color']),
  type: $enumDecode(_$PieceTypeEnumMap, json['type']),
  hasMoved: json['hasMoved'] as bool? ?? false,
);

Map<String, dynamic> _$PawnToJson(_Pawn instance) => <String, dynamic>{
  'color': _$PieceColorEnumMap[instance.color]!,
  'type': _$PieceTypeEnumMap[instance.type]!,
  'hasMoved': instance.hasMoved,
};
