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

class QuizQuestion {
  const QuizQuestion({
    required this.prompt,
    required this.options,
    required this.correctOptionIndex,
    required this.hint,
    required this.explanation,
    this.codeSnippet,
    this.traceSteps = const [],
  }) : assert(correctOptionIndex >= 0 && correctOptionIndex < 4);

  final String prompt;
  final List<String> options;
  final int correctOptionIndex;
  final String hint;
  final String explanation;
  final String? codeSnippet;
  final List<QuizTraceStep> traceSteps;
}
