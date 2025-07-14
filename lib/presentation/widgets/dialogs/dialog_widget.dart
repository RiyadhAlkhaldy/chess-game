import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DrawDialog extends StatelessWidget {
  final String whitePlayerName;
  final String blackPlayerName;
  final int whiteElo;
  final int blackElo;
  final String resultReason;
  final String timeWhite;
  final String timeBlack;
  final int eloLevel;

  const DrawDialog({
    super.key,
    required this.whitePlayerName,
    required this.blackPlayerName,
    required this.whiteElo,
    required this.blackElo,
    required this.resultReason,
    required this.timeWhite,
    required this.timeBlack,
    required this.eloLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Color(0xFF192841),
      child: Container(
        padding: EdgeInsets.all(16),
        width: Get.width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Draw",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text("by $resultReason", style: TextStyle(color: Colors.grey[600])),
            Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage(
                        'assets/images/white_player.png',
                      ), // أو صورة ديناميكية
                      radius: 24,
                    ),
                    SizedBox(height: 4),
                    Text(
                      whitePlayerName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text("($whiteElo)", style: TextStyle(color: Colors.grey)),
                    Text(timeWhite, style: TextStyle(fontSize: 12)),
                  ],
                ),
                Text(
                  "VS",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Column(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage(
                        'assets/images/black_player.png',
                      ),
                      radius: 24,
                    ),
                    SizedBox(height: 4),
                    Text(
                      blackPlayerName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text("($blackElo)", style: TextStyle(color: Colors.grey)),
                    Text(timeBlack, style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            Text("ELO Level", style: TextStyle(color: Colors.grey[600])),
            Text(
              "$eloLevel",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Get.back(); // أو إعادة التشغيل
                  },
                  icon: Icon(Icons.refresh),
                  label: Text("Rematch"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.back(); // ثم بدء لعبة جديدة
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: Text("New Game"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
