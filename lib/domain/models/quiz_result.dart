class QuizAnswerResult {
  const QuizAnswerResult({
    required this.topic,
    required this.prompt,
    required this.selected,
    required this.correct,
    required this.points,
    required this.elapsedMs,
    required this.usedHint,
  });

  final String topic;
  final String prompt;
  final String selected;
  final String correct;
  final int points;
  final int elapsedMs;
  final bool usedHint;

  bool get isCorrect => selected == correct;

  Map<String, Object?> toJson() => {
    'topic': topic,
    'prompt': prompt,
    'selected': selected,
    'correct': correct,
    'points': points,
    'elapsedMs': elapsedMs,
    'usedHint': usedHint,
  };

  factory QuizAnswerResult.fromJson(Map<String, dynamic> json) =>
      QuizAnswerResult(
        topic: json['topic'] as String,
        prompt: json['prompt'] as String,
        selected: json['selected'] as String,
        correct: json['correct'] as String,
        points: json['points'] as int,
        elapsedMs: json['elapsedMs'] as int,
        usedHint: json['usedHint'] as bool,
      );
}

class QuizResult {
  QuizResult({
    required this.id,
    required this.mode,
    required this.difficulty,
    required this.finishedAt,
    required List<QuizAnswerResult> answers,
  }) : answers = List.unmodifiable(answers);

  final String id;
  final String mode;
  final String difficulty;
  final DateTime finishedAt;
  final List<QuizAnswerResult> answers;

  int get points => answers.fold(0, (total, answer) => total + answer.points);
  int get correctCount => answers.where((answer) => answer.isCorrect).length;

  Map<String, Object?> toJson() => {
    'id': id,
    'mode': mode,
    'difficulty': difficulty,
    'finishedAt': finishedAt.toUtc().toIso8601String(),
    'answers': [for (final answer in answers) answer.toJson()],
  };

  factory QuizResult.fromJson(Map<String, dynamic> json) => QuizResult(
    id: json['id'] as String,
    mode: json['mode'] as String,
    difficulty: json['difficulty'] as String,
    finishedAt: DateTime.parse(json['finishedAt'] as String),
    answers: [
      for (final answer in json['answers'] as List<dynamic>)
        QuizAnswerResult.fromJson(answer as Map<String, dynamic>),
    ],
  );
}

class QuizPlayerStats {
  QuizPlayerStats(Iterable<QuizResult> history) {
    for (final result in history) {
      points += result.points;
      final best = records[result.mode];
      if (best == null || result.points > best) {
        records[result.mode] = result.points;
      }
      for (final answer in result.answers) {
        final progress = byTopic[answer.topic] ?? (correct: 0, answered: 0);
        byTopic[answer.topic] = (
          correct: progress.correct + (answer.isCorrect ? 1 : 0),
          answered: progress.answered + 1,
        );
      }
    }
  }

  int points = 0;
  final records = <String, int>{};
  final byTopic = <String, ({int correct, int answered})>{};
}
