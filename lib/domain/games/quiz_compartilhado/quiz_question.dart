enum QuizDifficulty { facil, medio, dificil }

class QuizTraceStep {
  const QuizTraceStep({
    required this.iteration,
    required this.valueBefore,
    required this.valueAfter,
    required this.totalBefore,
    required this.totalAfter,
  });

  final int iteration;
  final int valueBefore;
  final int valueAfter;
  final int totalBefore;
  final int totalAfter;
}

/// Os valores descrevem o estado logo após a linha indicada (contada de 1).
class QuizExecutionStep {
  const QuizExecutionStep({
    required this.line,
    required this.stage,
    required this.variables,
    required this.explanation,
    this.output,
  });

  final int line;
  final String stage;
  final String variables;
  final String explanation;
  final String? output;
}

class QuizQuestion {
  const QuizQuestion({
    required this.prompt,
    required this.options,
    required this.correctOptionIndex,
    required this.hint,
    required this.explanation,
    this.topic = 'Geral',
    this.difficulty = QuizDifficulty.facil,
    this.codeSnippet,
    this.traceSteps = const [],
    this.executionSteps = const [],
  }) : assert(correctOptionIndex >= 0 && correctOptionIndex < 4);

  final String prompt;
  final List<String> options;
  final int correctOptionIndex;
  final String hint;
  final String explanation;
  final String topic;
  final QuizDifficulty difficulty;
  final String? codeSnippet;
  final List<QuizTraceStep> traceSteps;
  final List<QuizExecutionStep> executionSteps;
}
