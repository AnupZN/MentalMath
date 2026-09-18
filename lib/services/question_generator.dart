import 'dart:math' as math;
import '../models/enums.dart';
import '../models/question.dart';

class QuestionGenerator {
  static final _random = math.Random();

  static List<Question> generate({
    required Operation operation,
    required DifficultyLevel difficulty,
    required int count,
    int? targetNumber,
  }) {
    final int maxUnique = (targetNumber != null && difficulty == DifficultyLevel.level1) ? 10 : 200;
    final poolSize = math.min(count * 3, maxUnique);
    final Set<String> seen = {};
    final List<Question> candidates = [];
    int attempts = 0;

    while (candidates.length < poolSize && attempts < poolSize * 5) {
      attempts++;
      int op1 = 0;
      int op2 = 0;

      if (targetNumber != null && (operation == Operation.tables || operation == Operation.multiplication)) {
        op1 = targetNumber;
        op2 = _generateSecondOperandForTable(difficulty);
      } else {
        switch (operation) {
          case Operation.addition:
            final pair = _generateAddition(difficulty);
            op1 = pair.$1;
            op2 = pair.$2;
            break;
          case Operation.subtraction:
            final pair = _generateSubtraction(difficulty);
            op1 = pair.$1;
            op2 = pair.$2;
            break;
          case Operation.multiplication:
            final pair = _generateMultiplication(difficulty);
            op1 = pair.$1;
            op2 = pair.$2;
            break;
          case Operation.division:
            final pair = _generateDivision(difficulty);
            op1 = pair.$1;
            op2 = pair.$2;
            break;
          case Operation.tables:
            final pair = _generateTables(difficulty);
            op1 = pair.$1;
            op2 = pair.$2;
            break;
          case Operation.square:
            final pair = _generateSquare(difficulty);
            op1 = pair.$1;
            op2 = pair.$2;
            break;
          case Operation.cube:
            final pair = _generateCube(difficulty);
            op1 = pair.$1;
            op2 = pair.$2;
            break;
        }
      }

      if (_validate(operation, op1, op2)) {
        final key = '$op1,$op2';
        if (!seen.contains(key)) {
          seen.add(key);
          candidates.add(_createQuestion(operation, difficulty, op1, op2, candidates.length));
        }
      }
    }

    candidates.shuffle(_random);

    if (candidates.length < count) {
      final additionalNeeded = count - candidates.length;
      for (int i = 0; i < additionalNeeded; i++) {
        final base = candidates[i % candidates.length];
        candidates.add(_createQuestion(operation, difficulty, base.operand1, base.operand2, candidates.length));
      }
    }

    return candidates.take(count).toList();
  }

  static Question _createQuestion(Operation op, DifficultyLevel diff, int op1, int op2, int index) {
    int ans = 0;
    switch (op) {
      case Operation.addition: ans = op1 + op2; break;
      case Operation.subtraction: ans = op1 - op2; break;
      case Operation.multiplication:
      case Operation.tables: ans = op1 * op2; break;
      case Operation.division: ans = op1 ~/ op2; break;
      case Operation.square: ans = op1 * op1; break;
      case Operation.cube: ans = op1 * op1 * op1; break;
    }
    return Question(
      id: '${op.name}_${diff.name}_${index}_${DateTime.now().microsecondsSinceEpoch}',
      operation: op,
      operand1: op1,
      operand2: op2,
      correctAnswer: ans,
      difficulty: diff,
    );
  }

  static bool _validate(Operation op, int op1, int op2) {
    if (op == Operation.division && op2 == 0) return false;
    int ans = 0;
    switch (op) {
      case Operation.addition: ans = op1 + op2; break;
      case Operation.subtraction: ans = op1 - op2; break;
      case Operation.multiplication:
      case Operation.tables: ans = op1 * op2; break;
      case Operation.division: 
        if (op1 % op2 != 0) return false;
        ans = op1 ~/ op2; 
        break;
      case Operation.square: ans = op1 * op1; break;
      case Operation.cube: ans = op1 * op1 * op1; break;
    }
    if (ans < 0) return false;
    return true;
  }

  static (int, int) _generateAddition(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.level1:
        return (_rand(1, 9), _rand(1, 9));
      case DifficultyLevel.level2:
        return _random.nextBool() ? (_rand(1, 9), _rand(10, 99)) : (_rand(10, 99), _rand(1, 9));
      case DifficultyLevel.level3:
        return (_rand(10, 99), _rand(10, 99));
      case DifficultyLevel.level4:
        return _random.nextBool() ? (_rand(1, 9), _rand(100, 999)) : (_rand(100, 999), _rand(1, 9));
      case DifficultyLevel.level5:
        return _random.nextBool() ? (_rand(10, 99), _rand(100, 999)) : (_rand(100, 999), _rand(10, 99));
      case DifficultyLevel.level6:
        return (_rand(100, 999), _rand(100, 999));
    }
  }

  static (int, int) _generateSubtraction(DifficultyLevel level) {
    int op1, op2;
    switch (level) {
      case DifficultyLevel.level1:
        op2 = _rand(1, 8);
        op1 = _rand(op2 + 1, 9);
        break;
      case DifficultyLevel.level2:
        op1 = _rand(11, 99);
        op2 = _rand(1, math.min(9, op1 - 1));
        break;
      case DifficultyLevel.level3:
        op2 = _rand(10, 98);
        op1 = _rand(op2 + 1, 99);
        break;
      case DifficultyLevel.level4:
        op1 = _rand(101, 999);
        op2 = _rand(1, 9);
        break;
      case DifficultyLevel.level5:
        op1 = _rand(101, 999);
        op2 = _rand(10, 99);
        break;
      case DifficultyLevel.level6:
        op2 = _rand(100, 998);
        op1 = _rand(op2 + 1, 999);
        break;
    }
    return (op1, op2);
  }

  static const _primes = [2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97];

  static (int, int) _generateMultiplication(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.level1:
        return (_rand(1, 5), _rand(2, 10));
      case DifficultyLevel.level2:
        return (_rand(6, 12), _rand(2, 10));
      case DifficultyLevel.level3:
        return (_rand(11, 15), _rand(2, 10));
      case DifficultyLevel.level4:
        return (_rand(16, 25), _rand(2, 10));
      case DifficultyLevel.level5:
        return (_primes[_rand(0, _primes.length - 1)], _rand(2, 10));
      case DifficultyLevel.level6:
        return (_rand(12, 99), _rand(2, 9));
    }
  }

  static (int, int) _generateDivision(DifficultyLevel level) {
    int divisor, quotient;
    switch (level) {
      case DifficultyLevel.level1:
        divisor = _rand(2, 5); quotient = _rand(2, 10); break;
      case DifficultyLevel.level2:
        divisor = _rand(2, 10); quotient = _rand(2, 12); break;
      case DifficultyLevel.level3:
        divisor = _rand(11, 15); quotient = _rand(2, 10); break;
      case DifficultyLevel.level4:
        divisor = _rand(16, 25); quotient = _rand(2, 10); break;
      case DifficultyLevel.level5:
        divisor = _rand(2, 9); quotient = _rand(10, 99); break;
      case DifficultyLevel.level6:
        final smallPrimes = [2,3,5,7,11,13,17,19,23,29,31,37,41,43,47];
        divisor = smallPrimes[_rand(0, smallPrimes.length - 1)];
        quotient = _rand(2, 10);
        break;
    }
    return (divisor * quotient, divisor);
  }

  static (int, int) _generateTables(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.level1:
        return (_rand(2, 5), _rand(1, 10));
      case DifficultyLevel.level2:
        return (_rand(6, 10), _rand(1, 10));
      case DifficultyLevel.level3:
        return (_rand(11, 15), _rand(1, 10));
      case DifficultyLevel.level4:
        return (_rand(16, 20), _rand(1, 10));
      case DifficultyLevel.level5:
        return (_rand(21, 25), _rand(1, 10));
      case DifficultyLevel.level6:
        return (_primes[_rand(0, _primes.length - 1)], _rand(1, 10));
    }
  }

  static int _generateSecondOperandForTable(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.level1:
        // Basic facts: 1 to 10 (e.g. 19 × 6)
        return _rand(1, 10);
      case DifficultyLevel.level2:
        // Extended table facts: 2 to 15 (e.g. 19 × 12)
        return _rand(2, 15);
      case DifficultyLevel.level3:
        // Teens and early 20s: 11 to 25 (e.g. 19 × 14, 19 × 23)
        return _rand(11, 25);
      case DifficultyLevel.level4:
        // 2-digit intermediate: 11 to 50 (e.g. 19 × 32)
        return _rand(11, 50);
      case DifficultyLevel.level5:
        // 2-digit advanced: 20 to 99 (e.g. 19 × 67, 19 × 84)
        return _rand(20, 99);
      case DifficultyLevel.level6:
        // Mixed range across 2 to 99 (e.g. 19 × 6, 19 × 12, 19 × 32, 19 × 78)
        final roll = _random.nextInt(100);
        if (roll < 30) {
          return _rand(2, 12);
        } else if (roll < 65) {
          return _rand(12, 50);
        } else {
          return _rand(51, 99);
        }
    }
  }

  static (int, int) _generateSquare(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.level1:
        return (_rand(1, 10), 2);
      case DifficultyLevel.level2:
        return (_rand(1, 15), 2);
      case DifficultyLevel.level3:
        return (_rand(1, 20), 2);
      case DifficultyLevel.level4:
        return (_rand(1, 25), 2);
      case DifficultyLevel.level5:
        return (_rand(1, 30), 2);
      case DifficultyLevel.level6:
        return (_rand(1, 50), 2);
    }
  }

  static (int, int) _generateCube(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.level1:
        return (_rand(1, 5), 3);
      case DifficultyLevel.level2:
        return (_rand(1, 10), 3);
      case DifficultyLevel.level3:
        return (_rand(1, 15), 3);
      case DifficultyLevel.level4:
        return (_rand(1, 20), 3);
      case DifficultyLevel.level5:
        return (_rand(1, 25), 3);
      case DifficultyLevel.level6:
        return (_rand(1, 30), 3);
    }
  }

  static int _rand(int min, int max) => min + _random.nextInt(max - min + 1);
}