import 'package:flutter/material.dart';

class OnlineView extends StatelessWidget {
  const OnlineView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("اللعب أونلاين")),
      body: const Center(child: Text("قريباً")),
    );
  }
}