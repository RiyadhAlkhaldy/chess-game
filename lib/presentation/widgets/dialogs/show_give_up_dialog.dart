import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> showGiveUpDialog({Function()? onPressedYesButton}) async {
  await Get.defaultDialog(
    title: '',
    // contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Give up game?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed:
                  onPressedYesButton ??
                  () {
                    // Handle "Yes" logic
                    Get.back(); // Close dialog
                    debugPrint('Game Given Up');
                  },
              child: Text(
                'Yes',
                style: TextStyle(color: Colors.redAccent.shade100),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back(); // Just close the dialog
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[300],
                shape: StadiumBorder(),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text('No'),
            ),
          ],
        ),
      ],
    ),
    radius: 10,
    barrierDismissible: false,
    backgroundColor: Color(0xFF192841), // Dark background similar to image
  );
}
