import 'package:material_ui/material_ui.dart';

import '../../domain/games/quiz_compartilhado/quiz_question.dart';

class QuizExecutionScreen extends StatefulWidget {
  const QuizExecutionScreen({super.key, required this.question});

  final QuizQuestion question;

  @override
  State<QuizExecutionScreen> createState() => _QuizExecutionScreenState();
}

class _QuizExecutionScreenState extends State<QuizExecutionScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final steps = widget.question.executionSteps;
    final step = steps[_index];
    final lines = widget.question.codeSnippet!.split('\n');
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Teste de mesa')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Semantics(
                        liveRegion: true,
                        header: true,
                        child: Text(
                          'Passo ${_index + 1} de ${steps.length} · ${step.stage}',
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Linha ${step.line} · ${step.variables}'),
                      const SizedBox(height: 8),
                      Text(step.explanation),
                      if (step.output case final output?) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Saída: $output',
                          key: const Key('trace-output'),
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            children: [
                              for (var i = 0; i < lines.length; i++)
                                _CodeLine(
                                  number: i + 1,
                                  code: lines[i],
                                  active: i + 1 == step.line,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          key: const Key('trace-previous'),
                          onPressed: _index == 0
                              ? null
                              : () => setState(() => _index--),
                          child: const Text('Anterior'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          key: const Key('trace-next'),
                          onPressed: _index + 1 == steps.length
                              ? null
                              : () => setState(() => _index++),
                          child: const Text('Próximo'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CodeLine extends StatelessWidget {
  const _CodeLine({
    required this.number,
    required this.code,
    required this.active,
  });

  final int number;
  final String code;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Linha $number${active ? ', etapa atual' : ''}: $code',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        color: active ? scheme.secondaryContainer : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              child: Text('$number', textAlign: TextAlign.center),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                code,
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: active
                      ? scheme.onSecondaryContainer
                      : scheme.onSurface,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
