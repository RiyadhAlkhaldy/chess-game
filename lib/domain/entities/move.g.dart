// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'move.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Move _$MoveFromJson(Map<String, dynamic> json) => _Move(
  start: Cell.fromJson(json['start'] as Map<String, dynamic>),
  end: Cell.fromJson(json['end'] as Map<String, dynamic>),
  isCapture: json['isCapture'] as bool? ?? false,
  isCastling: json['isCastling'] as bool? ?? false,
  isEnPassant: json['isEnPassant'] as bool? ?? false,
  isPromotion: json['isPromotion'] as bool? ?? false,
  promotedPieceType: $enumDecodeNullable(
    _$PieceTypeEnumMap,
    json['promotedPieceType'],
  ),
  isTwoStepPawnMove: json['isTwoStepPawnMove'] as bool? ?? false,
  movedPiece: Piece.fromJson(json['movedPiece'] as Map<String, dynamic>),
  capturedPiece:
      json['capturedPiece'] == null
          ? null
          : Piece.fromJson(json['capturedPiece'] as Map<String, dynamic>),
  promotedTo:
      json['promotedTo'] == null
          ? null
          : Piece.fromJson(json['promotedTo'] as Map<String, dynamic>),
  halfMoveClockBefore: (json['halfMoveClockBefore'] as num?)?.toInt(),
  fullMoveNumberBefore: (json['fullMoveNumberBefore'] as num?)?.toInt(),
);

Map<String, dynamic> _$MoveToJson(_Move instance) => <String, dynamic>{
  'start': instance.start,
  'end': instance.end,
  'isCapture': instance.isCapture,
  'isCastling': instance.isCastling,
  'isEnPassant': instance.isEnPassant,
  'isPromotion': instance.isPromotion,
  'promotedPieceType': _$PieceTypeEnumMap[instance.promotedPieceType],
  'isTwoStepPawnMove': instance.isTwoStepPawnMove,
  'movedPiece': instance.movedPiece,
  'capturedPiece': instance.capturedPiece,
  'promotedTo': instance.promotedTo,
  'halfMoveClockBefore': instance.halfMoveClockBefore,
  'fullMoveNumberBefore': instance.fullMoveNumberBefore,
};

const _$PieceTypeEnumMap = {
  PieceType.king: 'king',
  PieceType.queen: 'queen',
  PieceType.rook: 'rook',
  PieceType.bishop: 'bishop',
  PieceType.knight: 'knight',
  PieceType.pawn: 'pawn',
};
