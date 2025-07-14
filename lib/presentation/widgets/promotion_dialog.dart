// lib/presentation/widgets/promotion_dialog.dart
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/piece.dart'; // Import PieceType enum

/// A dialog displayed when a pawn reaches the opposite end of the board,
/// prompting the user to choose a piece for promotion.
class PromotionDialog extends StatelessWidget {
  const PromotionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Promote Pawn to:'),
      content: Column(
        mainAxisSize: MainAxisSize.min, // Make the column take minimum space
        children: [
          ListTile(
            title: const Text('Queen'),
            leading: Image.asset(
              'assets/images/w_Q.png',
              width: 30,
              height: 30,
              errorBuilder:
                  (context, error, stackTrace) =>
                      const Icon(Icons.kayaking, size: 30),
            ),
            onTap: () => Get.back(result: PieceType.queen), // Return Queen type
          ),
          ListTile(
            title: const Text('Rook'),
            leading: Image.asset(
              'assets/images/w_R.png',
              width: 30,
              height: 30,
              errorBuilder:
                  (context, error, stackTrace) =>
                      const Icon(Icons.castle, size: 30),
            ),
            onTap: () => Get.back(result: PieceType.rook), // Return Rook type
          ),
          ListTile(
            title: const Text('Bishop'),
            leading: Image.asset(
              'assets/images/w_B.png',
              width: 30,
              height: 30,
              errorBuilder:
                  (context, error, stackTrace) =>
                      const Icon(Icons.school, size: 30),
            ),
            onTap:
                () => Get.back(result: PieceType.bishop), // Return Bishop type
          ),
          ListTile(
            title: const Text('Knight'),
            leading: Image.asset(
              'assets/images/w_N.png',
              width: 30,
              height: 30,
              errorBuilder: (context, error, stackTrace) => WhiteKnight(),
            ),
            onTap:
                () => Get.back(result: PieceType.knight), // Return Knight type
          ),
        ],
      ),
    );
  }
}

Widget promotionDialog() {
  // Show the promotion dialog and return the selected PieceType
  return AlertDialog(
    title: const Text('Promote Pawn to:'),
    content: Column(
      mainAxisSize: MainAxisSize.min, // Make the column take minimum space
      children: [
        ListTile(
          title: const Text('Queen'),
          leading: Image.asset(
            'assets/images/w_Q.png',
            width: 30,
            height: 30,
            errorBuilder:
                (context, error, stackTrace) =>
                    const Icon(Icons.kayaking, size: 30),
          ),
          onTap: () => Get.back(result: PieceType.queen), // Return Queen type
        ),
        ListTile(
          title: const Text('Rook'),
          leading: Image.asset(
            'assets/images/w_R.png',
            width: 30,
            height: 30,
            errorBuilder:
                (context, error, stackTrace) =>
                    const Icon(Icons.castle, size: 30),
          ),
          onTap: () => Get.back(result: PieceType.rook), // Return Rook type
        ),
        ListTile(
          title: const Text('Bishop'),
          leading: Image.asset(
            'assets/images/w_B.png',
            width: 30,
            height: 30,
            errorBuilder:
                (context, error, stackTrace) =>
                    const Icon(Icons.school, size: 30),
          ),
          onTap: () => Get.back(result: PieceType.bishop), // Return Bishop type
        ),
        ListTile(
          title: const Text('Knight'),
          leading: Image.asset(
            'assets/images/w_N.png',
            width: 30,
            height: 30,
            errorBuilder: (context, error, stackTrace) => WhiteKnight(),
          ),
          onTap: () => Get.back(result: PieceType.knight), // Return Knight type
        ),
      ],
    ),
  );
}
