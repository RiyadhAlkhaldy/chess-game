import 'package:flutter/material.dart';

class GameOnlineScreen extends StatelessWidget {
  const GameOnlineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("اللعب أونلاين")),
      body: const Center(child: Text("قريباً")),
    );
  }
}