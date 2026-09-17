import 'enums.dart';

class Question {
  final String id;
  final Operation operation;
  final int operand1;
  final int operand2;
  final int correctAnswer;
  final DifficultyLevel difficulty;

  const Question({
    required this.id,
    required this.operation,
    required this.operand1,
    required this.operand2,
    required this.correctAnswer,
    required this.difficulty,
  });

  String get displayString {
    switch (operation) {
      case Operation.square:
        return '$operand1²';
      case Operation.cube:
        return '$operand1³';
      case Operation.tables:
      case Operation.multiplication:
      case Operation.addition:
      case Operation.subtraction:
      case Operation.division:
        return '$operand1 $operatorSymbol $operand2';
    }
  }

  String get operatorSymbol {
    switch (operation) {
      case Operation.addition: return '+';
      case Operation.subtraction: return '-';
      case Operation.multiplication: return '×';
      case Operation.division: return '÷';
      case Operation.tables: return '×';
      case Operation.square: return '²';
      case Operation.cube: return '³';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Question &&
          other.id == id &&
          other.operation == operation &&
          other.operand1 == operand1 &&
          other.operand2 == operand2 &&
          other.correctAnswer == correctAnswer &&
          other.difficulty == difficulty;

  @override
  int get hashCode =>
      id.hashCode ^
      operation.hashCode ^
      operand1.hashCode ^
      operand2.hashCode ^
      correctAnswer.hashCode ^
      difficulty.hashCode;
}