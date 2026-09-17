import 'package:flutter_test/flutter_test.dart';
import 'package:mental_math/models/enums.dart';
import 'package:mental_math/services/question_generator.dart';
import 'package:mental_math/services/scoring_service.dart';

// Smoke test — verifies core logic can run in test environment
void main() {
  test('QuestionGenerator produces correct count', () {
    final questions = QuestionGenerator.generate(
      operation: Operation.addition,
      difficulty: DifficultyLevel.level1,
      count: 10,
    );
    expect(questions.length, equals(10));
  });

  test('ScoringService grade thresholds', () {
    expect(ScoringService.calculateGrade(0.95), equals(Grade.s));
    expect(ScoringService.calculateGrade(0.85), equals(Grade.a));
    expect(ScoringService.calculateGrade(0.70), equals(Grade.b));
    expect(ScoringService.calculateGrade(0.55), equals(Grade.c));
    expect(ScoringService.calculateGrade(0.54), equals(Grade.d));
  });
}
