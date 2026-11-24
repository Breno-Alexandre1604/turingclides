import 'dart:math';

import '../domain/games/quiz_compartilhado/quiz_question.dart';
import '../domain/games/quiz_compartilhado/quiz_session.dart';
import '../domain/games/quiz_compartilhado/quiz_strategy.dart';
import '../domain/models/quiz_result.dart';

// Coordenação de rodada adaptada do PartidaController de Lucas.
class PartidaController {
  PartidaController({
    required this.strategy,
    required this.difficulty,
    required int count,
  }) : _questions = strategy.select(difficulty, count) {
    session = QuizSession(_questions.first);
    _timer.start();
  }

  final QuizStrategy strategy;
  final QuizDifficulty difficulty;
  final List<QuizQuestion> _questions;
  final String id = _newId();
  final _timer = Stopwatch();
  final _answers = <QuizAnswerResult>[];
  late QuizSession session;
  QuizResult? _result;
  int _index = 0;
  int _streak = 0;

  int get number => _index + 1;
  int get count => _questions.length;
  bool get isLast => number == count;
  int get points => _answers.fold(0, (sum, answer) => sum + answer.points);

  bool confirm() {
    if (!session.confirmSelection()) return false;
    _timer.stop();
    final question = session.question;
    final earned = strategy.scoring.points(
      correct: session.isCorrect,
      previousStreak: _streak,
      elapsed: _timer.elapsed,
      usedHint: session.usedHint,
    );
    _streak = session.isCorrect ? _streak + 1 : 0;
    _answers.add(
      QuizAnswerResult(
        topic: question.topic,
        prompt: question.prompt,
        selected: question.options[session.confirmedOptionIndex!],
        correct: question.options[question.correctOptionIndex],
        points: earned,
        elapsedMs: _timer.elapsedMilliseconds,
        usedHint: session.usedHint,
      ),
    );
    return true;
  }

  bool advance() {
    if (!session.isConfirmed || isLast) return false;
    session = QuizSession(_questions[++_index]);
    _timer
      ..reset()
      ..start();
    return true;
  }

  QuizResult finish() {
    if (!isLast || !session.isConfirmed) {
      throw StateError('Conclua todas as questões para encerrar a partida.');
    }
    return _result ??= QuizResult(
      id: id,
      mode: strategy.title,
      difficulty: difficulty.label,
      finishedAt: DateTime.now().toUtc(),
      answers: List.unmodifiable(_answers),
    );
  }

  static String _newId() {
    final random = Random.secure();
    return List.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }
}
