import 'package:flutter_test/flutter_test.dart';
import 'package:mental_math/models/enums.dart';
import 'package:mental_math/models/question.dart';
import 'package:mental_math/services/question_generator.dart';

void main() {
  group('QuestionGenerator', () {
    // Helper to verify count
    void expectCount(List<Question> questions, int expected) {
      expect(questions.length, equals(expected),
          reason: 'Expected $expected questions, got ${questions.length}');
    }

    // Helper to verify all answers are correct
    void expectCorrectAnswers(List<Question> questions) {
      for (final q in questions) {
        int expected;
        switch (q.operation) {
          case Operation.addition:
            expected = q.operand1 + q.operand2;
            break;
          case Operation.subtraction:
            expected = q.operand1 - q.operand2;
            break;
          case Operation.multiplication:
            expected = q.operand1 * q.operand2;
            break;
          case Operation.division:
            expected = q.operand1 ~/ q.operand2;
            break;
        }
        expect(q.correctAnswer, equals(expected),
            reason: '${q.displayString} should = $expected, got ${q.correctAnswer}');
      }
    }

    group('Addition', () {
      for (final level in DifficultyLevel.values) {
        test('Level ${level.index + 1} produces 10 questions with correct answers', () {
          final questions = QuestionGenerator.generate(
            operation: Operation.addition,
            difficulty: level,
            count: 10,
          );
          expectCount(questions, 10);
          expectCorrectAnswers(questions);
          for (final q in questions) {
            expect(q.correctAnswer, greaterThanOrEqualTo(0));
          }
        });
      }

      test('Level 1: both operands 1-9', () {
        final questions = QuestionGenerator.generate(
          operation: Operation.addition,
          difficulty: DifficultyLevel.level1,
          count: 30,
        );
        for (final q in questions) {
          expect(q.operand1, inInclusiveRange(1, 9));
          expect(q.operand2, inInclusiveRange(1, 9));
        }
      });

      test('Level 3: both operands 10-99', () {
        final questions = QuestionGenerator.generate(
          operation: Operation.addition,
          difficulty: DifficultyLevel.level3,
          count: 20,
        );
        for (final q in questions) {
          expect(q.operand1, inInclusiveRange(10, 99));
          expect(q.operand2, inInclusiveRange(10, 99));
        }
      });

      test('Level 6: both operands 100-999', () {
        final questions = QuestionGenerator.generate(
          operation: Operation.addition,
          difficulty: DifficultyLevel.level6,
          count: 20,
        );
        for (final q in questions) {
          expect(q.operand1, inInclusiveRange(100, 999));
          expect(q.operand2, inInclusiveRange(100, 999));
        }
      });
    });

    group('Subtraction', () {
      for (final level in DifficultyLevel.values) {
        test('Level ${level.index + 1} produces 10 questions with non-negative results', () {
          final questions = QuestionGenerator.generate(
            operation: Operation.subtraction,
            difficulty: level,
            count: 10,
          );
          expectCount(questions, 10);
          expectCorrectAnswers(questions);
          for (final q in questions) {
            expect(q.correctAnswer, greaterThanOrEqualTo(0),
                reason: 'Subtraction result must be ≥ 0: ${q.displayString} = ${q.correctAnswer}');
            expect(q.operand1, greaterThanOrEqualTo(q.operand2));
          }
        });
      }
    });

    group('Multiplication', () {
      for (final level in DifficultyLevel.values) {
        test('Level ${level.index + 1} produces 10 questions with correct answers', () {
          final questions = QuestionGenerator.generate(
            operation: Operation.multiplication,
            difficulty: level,
            count: 10,
          );
          expectCount(questions, 10);
          expectCorrectAnswers(questions);
        });
      }

      test('Level 1: operand1 in 1-5, operand2 in 2-10', () {
        final questions = QuestionGenerator.generate(
          operation: Operation.multiplication,
          difficulty: DifficultyLevel.level1,
          count: 30,
        );
        for (final q in questions) {
          expect(q.operand1, inInclusiveRange(1, 5));
          expect(q.operand2, inInclusiveRange(2, 10));
        }
      });

      test('Level 5: operand1 is a prime ≤ 97', () {
        const primes = {2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97};
        final questions = QuestionGenerator.generate(
          operation: Operation.multiplication,
          difficulty: DifficultyLevel.level5,
          count: 25,
        );
        for (final q in questions) {
          expect(primes.contains(q.operand1), isTrue,
              reason: '${q.operand1} should be prime');
        }
      });
    });

    group('Division', () {
      for (final level in DifficultyLevel.values) {
        test('Level ${level.index + 1} produces clean integer results', () {
          final questions = QuestionGenerator.generate(
            operation: Operation.division,
            difficulty: level,
            count: 10,
          );
          expectCount(questions, 10);
          for (final q in questions) {
            expect(q.operand2, greaterThan(0), reason: 'No division by zero');
            expect(q.operand1 % q.operand2, equals(0),
                reason: '${q.operand1} ÷ ${q.operand2} must be a clean integer');
            expect(q.correctAnswer, greaterThan(0));
            expectCorrectAnswers(questions);
          }
        });
      }

      test('Level 1: divisor in 2-5, quotient in 2-10', () {
        final questions = QuestionGenerator.generate(
          operation: Operation.division,
          difficulty: DifficultyLevel.level1,
          count: 30,
        );
        for (final q in questions) {
          expect(q.operand2, inInclusiveRange(2, 5)); // divisor
          expect(q.correctAnswer, inInclusiveRange(2, 10)); // quotient
        }
      });
    });

    test('Generates exact count for various sizes', () {
      for (final count in [5, 10, 15, 20, 25, 30]) {
        final questions = QuestionGenerator.generate(
          operation: Operation.addition,
          difficulty: DifficultyLevel.level2,
          count: count,
        );
        expect(questions.length, equals(count), reason: 'Should generate exactly $count questions');
      }
    });

    test('All questions have non-empty ids', () {
      final questions = QuestionGenerator.generate(
        operation: Operation.multiplication,
        difficulty: DifficultyLevel.level2,
        count: 10,
      );
      for (final q in questions) {
        expect(q.id, isNotEmpty);
      }
    });
  });
}
