import 'package:flutter_test/flutter_test.dart';
import 'package:mental_math/models/enums.dart';
import 'package:mental_math/models/question.dart';
import 'package:mental_math/models/question_attempt.dart';
import 'package:mental_math/services/scoring_service.dart';

QuestionAttempt _makeAttempt(bool correct, {int responseMs = 5000}) {
  const q = Question(
    id: 'test',
    operation: Operation.addition,
    operand1: 3,
    operand2: 4,
    correctAnswer: 7,
    difficulty: DifficultyLevel.level1,
  );
  return QuestionAttempt(
    question: q,
    userAnswer: correct ? 7 : 5,
    isCorrect: correct,
    responseTime: Duration(milliseconds: responseMs),
  );
}

void main() {
  group('ScoringService', () {
    group('calculateGrade', () {
      test('S grade for accuracy >= 95%', () {
        expect(ScoringService.calculateGrade(0.95), equals(Grade.s));
        expect(ScoringService.calculateGrade(1.0), equals(Grade.s));
      });

      test('A grade for 85% <= accuracy < 95%', () {
        expect(ScoringService.calculateGrade(0.85), equals(Grade.a));
        expect(ScoringService.calculateGrade(0.94), equals(Grade.a));
      });

      test('B grade for 70% <= accuracy < 85%', () {
        expect(ScoringService.calculateGrade(0.70), equals(Grade.b));
        expect(ScoringService.calculateGrade(0.84), equals(Grade.b));
      });

      test('C grade for 55% <= accuracy < 70%', () {
        expect(ScoringService.calculateGrade(0.55), equals(Grade.c));
        expect(ScoringService.calculateGrade(0.69), equals(Grade.c));
      });

      test('D grade for accuracy < 55%', () {
        expect(ScoringService.calculateGrade(0.0), equals(Grade.d));
        expect(ScoringService.calculateGrade(0.54), equals(Grade.d));
      });
    });

    group('calculateAccuracy', () {
      test('100% for all correct', () {
        expect(ScoringService.calculateAccuracy(10, 10), equals(1.0));
      });

      test('0% for none correct', () {
        expect(ScoringService.calculateAccuracy(0, 10), equals(0.0));
      });

      test('50% for half correct', () {
        expect(ScoringService.calculateAccuracy(5, 10), equals(0.5));
      });

      test('0% for empty session', () {
        expect(ScoringService.calculateAccuracy(0, 0), equals(0.0));
      });
    });

    group('calculateStreak', () {
      test('streak of 0 for empty list', () {
        expect(ScoringService.calculateStreak([]), equals(0));
      });

      test('streak of 3 for 3 correct at end', () {
        final attempts = [
          _makeAttempt(false),
          _makeAttempt(true),
          _makeAttempt(true),
          _makeAttempt(true),
        ];
        expect(ScoringService.calculateStreak(attempts), equals(3));
      });

      test('streak of 0 if last answer is wrong', () {
        final attempts = [
          _makeAttempt(true),
          _makeAttempt(true),
          _makeAttempt(false),
        ];
        expect(ScoringService.calculateStreak(attempts), equals(0));
      });

      test('streak equals total when all correct', () {
        final attempts = List.generate(5, (_) => _makeAttempt(true));
        expect(ScoringService.calculateStreak(attempts), equals(5));
      });
    });

    group('calculateBestStreak', () {
      test('best streak from mixed pattern', () {
        final attempts = [
          _makeAttempt(true),
          _makeAttempt(true),
          _makeAttempt(true),
          _makeAttempt(false),
          _makeAttempt(true),
          _makeAttempt(true),
        ];
        expect(ScoringService.calculateBestStreak(attempts), equals(3));
      });

      test('best streak of 0 for all wrong', () {
        final attempts = List.generate(5, (_) => _makeAttempt(false));
        expect(ScoringService.calculateBestStreak(attempts), equals(0));
      });

      test('best streak equals total when all correct', () {
        final attempts = List.generate(7, (_) => _makeAttempt(true));
        expect(ScoringService.calculateBestStreak(attempts), equals(7));
      });
    });

    group('calculateAvgResponseTime', () {
      test('returns zero for empty list', () {
        expect(ScoringService.calculateAvgResponseTime([]), equals(Duration.zero));
      });

      test('returns correct average', () {
        final attempts = [
          _makeAttempt(true, responseMs: 2000),
          _makeAttempt(true, responseMs: 4000),
          _makeAttempt(false, responseMs: 6000),
        ];
        final avg = ScoringService.calculateAvgResponseTime(attempts);
        expect(avg.inMilliseconds, equals(4000));
      });
    });
  });
}
