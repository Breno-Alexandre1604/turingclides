import 'package:material_ui/material_ui.dart';

import '../../application/partida_controller.dart';
import '../../data/quiz_history_repository.dart';
import '../../domain/games/quiz_compartilhado/quiz_question.dart';
import '../../domain/games/quiz_compartilhado/quiz_strategy.dart';
import 'quiz_execution_screen.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    required this.strategy,
    required this.difficulty,
    required this.count,
    this.repository,
  });

  final QuizStrategy strategy;
  final QuizDifficulty difficulty;
  final int count;
  final QuizHistoryRepository? repository;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final _round = PartidaController(
    strategy: widget.strategy,
    difficulty: widget.difficulty,
    count: widget.count,
  );
  final _scroll = ScrollController();
  bool _finishing = false;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _continueRound() {
    if (_finishing || !_round.session.isConfirmed) return;
    if (_round.advance()) {
      setState(() {});
      _scroll.jumpTo(0);
      return;
    }
    _finishing = true;
    final result = _round.finish();
    Navigator.of(context).pushReplacement<void, void>(
      MaterialPageRoute(
        builder: (_) => QuizResultScreen(
          result: result,
          repository: widget.repository ?? quizHistoryRepository,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = _round.session;
    final question = session.question;
    final feedback = widget.strategy.feedback(question);
    return Scaffold(
      appBar: AppBar(title: Text(widget.strategy.title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            controller: _scroll,
            key: const Key('quiz-scroll-view'),
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Questão ${_round.number} de ${_round.count} · ${widget.difficulty.label}',
              ),
              Text('${_round.points} pontos', key: const Key('round-points')),
              const SizedBox(height: 16),
              Text(
                question.prompt,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (question.codeSnippet case final code?) ...[
                const SizedBox(height: 12),
                _CodeSnippet(code: code),
              ],
              const SizedBox(height: 16),
              for (var i = 0; i < question.options.length; i++) ...[
                _AnswerOption(
                  key: Key('option-$i'),
                  label: question.options[i],
                  index: i,
                  isSelected: session.selectedOptionIndex == i,
                  isConfirmed: session.isConfirmed,
                  isCorrectAnswer: question.correctOptionIndex == i,
                  onTap: () => setState(() => session.selectOption(i)),
                ),
                const SizedBox(height: 8),
              ],
              if (!session.isConfirmed && !session.usedHint)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    key: const Key('show-hint'),
                    onPressed: () => setState(session.revealHint),
                    icon: const Icon(Icons.lightbulb_outline),
                    label: const Text('Mostrar dica (−30 no acerto)'),
                  ),
                ),
              if (session.usedHint || session.isConfirmed)
                _InfoCard(
                  title: 'Dica',
                  content: question.hint,
                  icon: Icons.lightbulb_outline,
                ),
              const SizedBox(height: 12),
              if (!session.isConfirmed)
                FilledButton(
                  key: const Key('confirm-answer'),
                  onPressed: session.canConfirm
                      ? () => setState(() {
                          _round.confirm();
                        })
                      : null,
                  child: const Text('Confirmar resposta'),
                )
              else ...[
                _AnswerFeedback(
                  isCorrect: session.isCorrect,
                  selectedAnswer:
                      question.options[session.confirmedOptionIndex!],
                  correctAnswer: question.options[question.correctOptionIndex],
                  explanation: feedback.explanation,
                ),
                if (feedback.canTrace)
                  OutlinedButton.icon(
                    key: const Key('view-execution'),
                    onPressed: () => Navigator.of(context).push<void>(
                      MaterialPageRoute(
                        builder: (_) => QuizExecutionScreen(question: question),
                      ),
                    ),
                    icon: const Icon(Icons.code),
                    label: const Text('Ver execução'),
                  ),
                const SizedBox(height: 12),
                FilledButton(
                  key: Key(_round.isLast ? 'finish-quiz' : 'next-question'),
                  onPressed: _continueRound,
                  child: Text(
                    _round.isLast ? 'Ver resultado' : 'Próxima questão',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AnswerOption extends StatelessWidget {
  const _AnswerOption({
    super.key,
    required this.label,
    required this.index,
    required this.isSelected,
    required this.isConfirmed,
    required this.isCorrectAnswer,
    required this.onTap,
  });

  final String label;
  final int index;
  final bool isSelected;
  final bool isConfirmed;
  final bool isCorrectAnswer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color? backgroundColor;
    final Color borderColor;

    if (isConfirmed && isCorrectAnswer) {
      backgroundColor = theme.colorScheme.primaryContainer;
      borderColor = theme.colorScheme.primary;
    } else if (isConfirmed && isSelected) {
      backgroundColor = theme.colorScheme.errorContainer;
      borderColor = theme.colorScheme.error;
    } else if (isSelected) {
      backgroundColor = theme.colorScheme.secondaryContainer;
      borderColor = theme.colorScheme.secondary;
    } else {
      backgroundColor = null;
      borderColor = theme.colorScheme.outlineVariant;
    }

    return Material(
      color: backgroundColor ?? theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isConfirmed ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Text('${String.fromCharCode(65 + index)}.'),
              const SizedBox(width: 12),
              Expanded(child: Text(label)),
              if (isConfirmed && isCorrectAnswer)
                const Icon(Icons.check_circle_outline)
              else if (isConfirmed && isSelected)
                const Icon(Icons.cancel_outlined)
              else if (isSelected)
                const Icon(Icons.radio_button_checked),
            ],
          ),
        ),
      ),
    );
  }
}

class _CodeSnippet extends StatelessWidget {
  const _CodeSnippet({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('logic-code'),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SelectableText(
          code,
          style: const TextStyle(fontFamily: 'monospace'),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.content,
    required this.icon,
  });

  final String title;
  final String content;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(content),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerFeedback extends StatelessWidget {
  const _AnswerFeedback({
    required this.isCorrect,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.explanation,
  });

  final bool isCorrect;
  final String selectedAnswer;
  final String correctAnswer;
  final String explanation;

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: isCorrect ? 'Resposta correta!' : 'Resposta incorreta.',
      content:
          'Resposta selecionada: $selectedAnswer\nGabarito: $correctAnswer\n\n$explanation',
      icon: isCorrect ? Icons.check_circle_outline : Icons.info_outline,
    );
  }
}
