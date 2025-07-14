// main.dart
import 'package:chess_gemini_2/l10n/app_translation.dart';
import 'package:chess_gemini_2/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import 'presentation/bindings/game_binding.dart';

void main() {
  runApp(const ChessApp());
}

class ChessApp extends StatelessWidget {
  const ChessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Chess',
      debugShowCheckedModeBanner: false,
      locale: Get.deviceLocale, // Use device locale for localization
      translations: AppTranslations(),
      supportedLocales: const [
        Locale('en', 'US'), // English
        Locale('ar', 'EG'), // Arabic
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      defaultTransition: Transition.fade,
      initialBinding: GameBinding(), // Bind dependencies globally
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.brown[700],
        colorScheme: ColorScheme.light(
          primary: Colors.brown[700]!, // Selected cell, legal move dot
          secondary: Colors.lightGreen[600]!,
          surface: Colors.grey[200]!, // White cell background
          onSurface: Colors.brown[200]!,
          // Black cell background
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.blueGrey[700],
        colorScheme: ColorScheme.dark(
          primary: Colors.blueGrey[700]!,
          secondary: Colors.teal[400]!,
          surface: Colors.blueGrey[800]!, // Dark cell background
          onSurface: Colors.blueGrey[900]!, // Lighter dark cell background
        ),
      ),
      themeMode: ThemeMode.system, // Default to system theme
      getPages: AppPages.routes,
    );
  }
}



// pubspec.yaml (add these dependencies)
// dependencies:
//   flutter:
//     sdk: flutter
//   get: ^4.6.5
//   freezed_annotation: ^2.4.1
//   json_annotation: ^4.8.1
//   equatable: ^2.0.5 # Optional, used by Failure base class
//   dartz: ^0.10.1 # For functional programming (Either, Tuple2)
//   shared_preferences: ^2.2.3 # For local storage
//   tuple: ^2.0.1 # Used for Tuple2 in some GetX versions, dartz also provides it

// dev_dependencies:
//   flutter_test:
//     sdk: flutter
//   build_runner: ^2.4.9
//   freezed: ^2.5.2
//   json_serializable: ^6.7.1

// flutter:
//   uses-material-design: true
//   assets:
//     - assets/images/ # Make sure you create this folder and put chess piece images
// ```json
// lib/domain/entities/piece.g.dart (Example of generated file - will be created by build_runner)
// GENERATED CODE - DO NOT MODIFY BY HAND
 