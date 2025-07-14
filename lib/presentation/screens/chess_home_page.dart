import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';
import 'package:flutter/material.dart';

class ChessHomePage extends StatelessWidget {
  const ChessHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Checkmate!',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: ChessHomeScreen(),
    );
  }
}

class ChessHomeScreen extends StatelessWidget {
  const ChessHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // خلفية الشطرنج المعتمة
          Opacity(opacity: 0.1, child: BlackKing()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  // اللوجو والعنوان
                  Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blueGrey[800],
                        radius: 40,
                        child: BlackKnight(), // يمكنك استبداله بصورة فعلية
                      ),
                      SizedBox(height: 10),
                      Text(
                        'CHECKMATE!',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'The Ultimate Chess Experience',
                        style: TextStyle(fontSize: 16, color: Colors.grey[300]),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),

                  // الإحصائيات
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.brightness_2), // الوضع الليلي
                      Row(
                        children: [
                          Text(
                            '565,837',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          Text(' Games in 24h'),
                          SizedBox(width: 20),
                          Text(
                            '33,873',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          Text(' Playing Now'),
                        ],
                      ),
                      Icon(Icons.music_note), // الموسيقى
                    ],
                  ),

                  SizedBox(height: 30),

                  // الأزرار الرئيسية
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                      childAspectRatio: 1.8,
                      children: [
                        buildButton(Icons.public, "Play Online"),
                        buildButton(Icons.smart_toy, "Play with Computer"),
                        buildButton(Icons.group, "Play with Friends"),
                        buildButton(Icons.extension, "Chess Puzzles"),
                        buildButton(Icons.bar_chart, "Rankings", light: true),
                        buildButton(Icons.settings, "Settings", light: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildButton(IconData icon, String label, {bool light = false}) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: light ? Colors.blue[100] : Colors.blueGrey[700],
        foregroundColor: light ? Colors.black : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.all(12),
        alignment: Alignment.centerLeft,
      ),
      icon: Icon(icon),
      label: Text(label, style: TextStyle(fontSize: 16)),
      onPressed: () {},
    );
  }
}
