// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'board.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Board _$BoardFromJson(Map<String, dynamic> json) => _Board(
  squares:
      (json['squares'] as List<dynamic>)
          .map(
            (e) =>
                (e as List<dynamic>)
                    .map(
                      (e) =>
                          e == null
                              ? null
                              : Piece.fromJson(e as Map<String, dynamic>),
                    )
                    .toList(),
          )
          .toList(),
  moveHistory:
      (json['moveHistory'] as List<dynamic>?)
          ?.map((e) => Move.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  currentPlayer:
      $enumDecodeNullable(_$PieceColorEnumMap, json['currentPlayer']) ??
      PieceColor.white,
  kingPositions: (json['kingPositions'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(
      $enumDecode(_$PieceColorEnumMap, k),
      Cell.fromJson(e as Map<String, dynamic>),
    ),
  ),
  castlingRights:
      (json['castlingRights'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          $enumDecode(_$PieceColorEnumMap, k),
          (e as Map<String, dynamic>).map(
            (k, e) =>
                MapEntry($enumDecode(_$CastlingSideEnumMap, k), e as bool),
          ),
        ),
      ) ??
      const {
        PieceColor.white: {
          CastlingSide.kingSide: true,
          CastlingSide.queenSide: true,
        },
        PieceColor.black: {
          CastlingSide.kingSide: true,
          CastlingSide.queenSide: true,
        },
      },
  enPassantTarget:
      json['enPassantTarget'] == null
          ? null
          : Cell.fromJson(json['enPassantTarget'] as Map<String, dynamic>),
  halfMoveClock: (json['halfMoveClock'] as num?)?.toInt() ?? 0,
  fullMoveNumber: (json['fullMoveNumber'] as num?)?.toInt() ?? 1,
);

Map<String, dynamic> _$BoardToJson(_Board instance) => <String, dynamic>{
  'squares': instance.squares,
  'moveHistory': instance.moveHistory,
  'currentPlayer': _$PieceColorEnumMap[instance.currentPlayer]!,
  'kingPositions': instance.kingPositions.map(
    (k, e) => MapEntry(_$PieceColorEnumMap[k]!, e),
  ),
  'castlingRights': instance.castlingRights.map(
    (k, e) => MapEntry(
      _$PieceColorEnumMap[k]!,
      e.map((k, e) => MapEntry(_$CastlingSideEnumMap[k]!, e)),
    ),
  ),
  'enPassantTarget': instance.enPassantTarget,
  'halfMoveClock': instance.halfMoveClock,
  'fullMoveNumber': instance.fullMoveNumber,
};

const _$PieceColorEnumMap = {
  PieceColor.white: 'white',
  PieceColor.random: 'random',
  PieceColor.black: 'black',
};

const _$CastlingSideEnumMap = {
  CastlingSide.kingSide: 'kingSide',
  CastlingSide.queenSide: 'queenSide',
};
