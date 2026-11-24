import 'package:flutter_test/flutter_test.dart';
import 'package:turingclides/application/partida_controller.dart';
import 'package:turingclides/domain/games/quiz_compartilhado/quiz_question.dart';
import 'package:turingclides/domain/games/quiz_compartilhado/quiz_strategy.dart';

void main() {
  test(
    'A pontuação compartilha os limites de tempo, dica e combo dos quizzes',
    () {
      final rule = matematicaStrategy.scoring;
      expect(rule, same(logicaStrategy.scoring));
      int points(
        int seconds,
        int streak, {
        bool hint = false,
        bool correct = true,
      }) => rule.points(
        correct: correct,
        previousStreak: streak,
        elapsed: Duration(seconds: seconds),
        usedHint: hint,
      );

      expect(points(0, 0), 150);
      expect(points(25, 1), 135);
      expect(points(90, 12), 150);
      expect(points(0, 0, hint: true), 120);
      expect(points(90, 0, hint: true), 70);
      expect(points(0, 4, correct: false), 0);
    },
  );

  test(
    'Configuração chega à rodada e cada questão gera uma única resposta',
    () {
      final round = PartidaController(
        strategy: logicaStrategy,
        difficulty: QuizDifficulty.medio,
        count: 2,
      );
      expect(round.session.question.difficulty, QuizDifficulty.medio);
      expect(round.count, 2);
      expect(round.advance(), isFalse);
      expect(round.finish, throwsStateError);
      final first = round.session;
      first.revealHint();
      first.selectOption(first.question.correctOptionIndex);
      expect(round.confirm(), isTrue);
      final score = round.points;
      expect(round.confirm(), isFalse);
      first.selectOption((first.question.correctOptionIndex + 1) % 4);
      expect(first.isCorrect, isTrue);
      expect(round.points, score);
      expect(round.advance(), isTrue);
      expect(round.number, 2);
      expect(round.advance(), isFalse);
      expect(round.session.usedHint, isFalse);
      round.session.selectOption(
        (round.session.question.correctOptionIndex + 1) % 4,
      );
      expect(round.confirm(), isTrue);
      expect(round.points, score);
      expect(round.advance(), isFalse);
      final result = round.finish();
      expect(round.finish(), same(result));
      expect(result.answers, hasLength(2));
      expect(result.id, round.id);
      expect(result.correctCount, 1);
      expect(result.answers.first.usedHint, isTrue);
      expect(result.answers.last.points, 0);
      expect(result.difficulty, 'Médio');
      expect(result.points, score);
      expect(
        () => logicaStrategy.select(QuizDifficulty.facil, 999),
        throwsRangeError,
      );
    },
  );
}
