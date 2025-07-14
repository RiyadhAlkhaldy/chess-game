// lib/data/local_storage_service.dart
import 'dart:convert'; // For json.encode and json.decode

import 'package:shared_preferences/shared_preferences.dart';

/// A service for interacting with local storage (e.g., SharedPreferences).
class LocalStorageService {
  static const _gameKey = 'saved_chess_game'; // Key for storing game data

  /// Saves game data to local storage as a JSON string.
  Future<void> saveGame(Map<String, dynamic> gameData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_gameKey, json.encode(gameData));
  }

  /// Loads game data from local storage and parses it back into a Map.
  /// Returns null if no game data is found.
  Future<Map<String, dynamic>?> loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    final gameDataString = prefs.getString(_gameKey);
    if (gameDataString != null) {
      return json.decode(gameDataString) as Map<String, dynamic>;
    }
    return null;
  }
}
