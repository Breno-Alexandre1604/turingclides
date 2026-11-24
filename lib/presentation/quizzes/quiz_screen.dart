import 'package:material_ui/material_ui.dart';

import '../../domain/games/quiz_compartilhado/quiz_question.dart';
import '../../domain/games/quiz_compartilhado/quiz_session.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    required this.title,
    required this.question,
  });

  final String title;
  final QuizQuestion question;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final QuizSession _session;
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    _session = QuizSession(widget.question);
  }

  void _selectOption(int index) {
    setState(() {
      _session.selectOption(index);
    });
  }

  void _confirmSelection() {
    setState(() {
      _session.confirmSelection();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            key: const Key('quiz-scroll-view'),
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                widget.question.prompt,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (widget.question.codeSnippet case final code?) ...[
                const SizedBox(height: 16),
                _CodeSnippet(code: code),
              ],
              if (widget.question.traceSteps.isNotEmpty) ...[
                const SizedBox(height: 16),
                _TraceTable(steps: widget.question.traceSteps),
              ],
              const SizedBox(height: 24),
              for (var index = 0;
                  index < widget.question.options.length;
                  index++) ...[
                _AnswerOption(
                  key: Key('option-$index'),
                  label: widget.question.options[index],
                  index: index,
                  isSelected: _session.selectedOptionIndex == index,
                  isConfirmed: _session.isConfirmed,
                  isCorrectAnswer:
                      widget.question.correctOptionIndex == index,
                  onTap: () => _selectOption(index),
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 12),
              if (!_session.isConfirmed)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    key: const Key('show-hint'),
                    onPressed: () => setState(() => _showHint = true),
                    icon: const Icon(Icons.lightbulb_outline),
                    label: const Text('Mostrar dica'),
                  ),
                ),
              if (_showHint || _session.isConfirmed) ...[
                const SizedBox(height: 8),
                _InfoCard(
                  title: 'Dica',
                  content: widget.question.hint,
                  icon: Icons.lightbulb_outline,
                ),
              ],
              const SizedBox(height: 16),
              if (_session.isConfirmed)
                _AnswerFeedback(
                  isCorrect: _session.isCorrect,
                  selectedAnswer:
                      widget.question.options[_session.confirmedOptionIndex!],
                  explanation: widget.question.explanation,
                )
              else
                FilledButton(
                  key: const Key('confirm-answer'),
                  onPressed:
                      _session.canConfirm ? _confirmSelection : null,
                  child: const Text('Confirmar resposta'),
                ),
              if (_session.isConfirmed) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  key: const Key('finish-quiz'),
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.check),
                  label: const Text('Encerrar quiz'),
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

class _TraceTable extends StatelessWidget {
  const _TraceTable({required this.steps});

  final List<QuizTraceStep> steps;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('logic-trace'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Teste de mesa', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final step in steps)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'i = ${step.iteration}: valor ${step.valueBefore} → '
                  '${step.valueAfter}; total ${step.totalBefore} → '
                  '${step.totalAfter}',
                ),
              ),
          ],
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
    required this.explanation,
  });

  final bool isCorrect;
  final String selectedAnswer;
  final String explanation;

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: isCorrect ? 'Resposta correta!' : 'Resposta incorreta.',
      content:
          'Resposta selecionada: $selectedAnswer\n\n$explanation',
      icon: isCorrect ? Icons.check_circle_outline : Icons.info_outline,
    );
  }
}
