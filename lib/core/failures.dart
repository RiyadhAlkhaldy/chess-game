// lib/core/failures.dart
import 'package:equatable/equatable.dart';

// Abstract base class for all failures in the application
abstract class Failure extends Equatable {
  final String message; // A human-readable message describing the failure
  const Failure({required this.message});

  @override
  List<Object> get props => [message]; // Used by Equatable for value comparison
}

// Represents a failure that occurred on the server side
class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

// Represents a failure related to caching or local storage operations
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

// Represents a general game-related failure
class GameFailure extends Failure {
  const GameFailure({required super.message});
}

// Represents an invalid move attempt within the game
class InvalidMoveFailure extends GameFailure {
  const InvalidMoveFailure({required super.message});
}

// Represents an invalid input provided to a function or service
class InvalidInputFailure extends Failure {
  const InvalidInputFailure({required super.message});
}