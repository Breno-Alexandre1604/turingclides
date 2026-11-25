import '../quiz_logica/logica_question.dart';
import '../quiz_matematica/matematica_question.dart';
import 'quiz_question.dart';

extension QuizDifficultyLabel on QuizDifficulty {
  String get label => switch (this) {
    QuizDifficulty.facil => 'Fácil',
    QuizDifficulty.medio => 'Médio',
    QuizDifficulty.dificil => 'Difícil',
  };
}

class QuizScoringRule {
  const QuizScoringRule();

  int points({
    required bool correct,
    required int previousStreak,
    required Duration elapsed,
    required bool usedHint,
  }) {
    if (!correct) return 0;
    final timeBonus = (50 - elapsed.inSeconds).clamp(0, 50);
    final comboBonus = 10 * previousStreak.clamp(0, 5);
    return 100 + timeBonus + comboBonus - (usedHint ? 30 : 0);
  }
}

class QuizFeedback {
  const QuizFeedback(this.explanation, {this.canTrace = false});

  final String explanation;
  final bool canTrace;
}

// Cada modo fornece seu banco e seu feedback; os quizzes compartilham a regra de pontos.
class QuizStrategy {
  const QuizStrategy(
    this.title,
    this.bank,
    this.feedback, {
    this.scoring = const QuizScoringRule(),
  });

  final String title;
  final List<QuizQuestion> bank;
  final QuizFeedback Function(QuizQuestion) feedback;
  final QuizScoringRule scoring;

  List<QuizQuestion> questions(QuizDifficulty difficulty) =>
      bank.where((question) => question.difficulty == difficulty).toList();

  List<QuizQuestion> select(QuizDifficulty difficulty, int count) {
    final available = questions(difficulty);
    RangeError.checkValueInInterval(count, 1, available.length, 'count');
    return available.take(count).toList(growable: false);
  }
}

QuizFeedback _mathFeedback(QuizQuestion question) =>
    QuizFeedback(question.explanation);
QuizFeedback _logicFeedback(QuizQuestion question) => QuizFeedback(
  question.explanation,
  canTrace: question.executionSteps.isNotEmpty,
);

const matematicaStrategy = QuizStrategy(
  'Quiz de Matemática',
  matematicaQuestions,
  _mathFeedback,
);
final logicaStrategy = QuizStrategy(
  'Quiz de Lógica',
  logicaQuestions,
  _logicFeedback,
);
