import 'package:material_ui/material_ui.dart';

import '../../app/app_theme.dart';
import '../../application/partida_controller.dart';
import '../../data/quiz_history_repository.dart';
import '../../domain/games/quiz_compartilhado/quiz_question.dart';
import '../../domain/games/quiz_compartilhado/quiz_strategy.dart';
import '../widgets/game_controls.dart';
import '../widgets/pagina.dart';
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
    final tema = Theme.of(context);
    final cores = CoresDoApp.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.strategy.title)),
      body: PaginaRolavel(
        controller: _scroll,
        listaKey: const Key('quiz-scroll-view'),
        children: [
          CabecalhoDaPartida(
            posicao:
                'Questão ${_round.number} de ${_round.count} · '
                '${widget.difficulty.label}',
            pontos: '${_round.points} pontos',
            pontosKey: const Key('round-points'),
            atual: _round.number,
            total: _round.count,
            cores: cores.doModo(widget.strategy.title),
          ),
          const SizedBox(height: Espaco.xl),
          Text(question.prompt, style: tema.textTheme.headlineSmall),
          if (question.codeSnippet case final code?) ...[
            const SizedBox(height: Espaco.m),
            _CodeSnippet(code: code),
          ],
          const SizedBox(height: Espaco.l),
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
            const SizedBox(height: Espaco.xs),
          ],
          if (!session.isConfirmed && !session.usedHint)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                key: const Key('show-hint'),
                onPressed: () => setState(session.revealHint),
                icon: const Icon(Icons.lightbulb_outline_rounded),
                label: const Text('Mostrar dica (−30 no acerto)'),
              ),
            ),
          if (session.usedHint || session.isConfirmed) ...[
            const SizedBox(height: Espaco.xs),
            CartaoDeAviso(
              titulo: 'Dica',
              conteudo: question.hint,
              icone: Icons.lightbulb_outline_rounded,
            ),
          ],
          const SizedBox(height: Espaco.m),
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
              selectedAnswer: question.options[session.confirmedOptionIndex!],
              correctAnswer: question.options[question.correctOptionIndex],
              explanation: feedback.explanation,
            ),
            const SizedBox(height: Espaco.s),
            if (feedback.canTrace) ...[
              OutlinedButton.icon(
                key: const Key('view-execution'),
                onPressed: () => Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => QuizExecutionScreen(question: question),
                  ),
                ),
                icon: const Icon(Icons.code_rounded),
                label: const Text('Ver execução'),
              ),
              const SizedBox(height: Espaco.s),
            ],
            FilledButton(
              key: Key(_round.isLast ? 'finish-quiz' : 'next-question'),
              onPressed: _continueRound,
              child: Text(_round.isLast ? 'Ver resultado' : 'Próxima questão'),
            ),
          ],
        ],
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
    final tema = Theme.of(context);
    final esquema = tema.colorScheme;
    final acerto = CoresDoApp.of(context).acerto;

    final Color fundo;
    final Color borda;
    final Color texto;
    final IconData? icone;
    if (isConfirmed && isCorrectAnswer) {
      (fundo, borda, texto) = (acerto.fundo, acerto.cor, acerto.sobreFundo);
      icone = Icons.check_circle_rounded;
    } else if (isConfirmed && isSelected) {
      (fundo, borda, texto) = (
        esquema.errorContainer,
        esquema.error,
        esquema.onErrorContainer,
      );
      icone = Icons.cancel_rounded;
    } else if (isSelected) {
      (fundo, borda, texto) = (
        esquema.secondaryContainer,
        esquema.primary,
        esquema.onSecondaryContainer,
      );
      icone = Icons.radio_button_checked_rounded;
    } else {
      fundo = tema.cardTheme.color ?? esquema.surface;
      borda = esquema.outlineVariant;
      texto = esquema.onSurface;
      icone = null;
    }
    final destacada = isSelected || (isConfirmed && isCorrectAnswer);

    return Semantics(
      selected: isSelected,
      child: Material(
        color: fundo,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: borda, width: destacada ? 2 : 1),
          borderRadius: BorderRadius.circular(Raio.controle),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isConfirmed ? null : onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Espaco.m,
                vertical: Espaco.s,
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: borda),
                    ),
                    child: Text(
                      String.fromCharCode(65 + index),
                      style: tema.textTheme.labelLarge?.copyWith(
                        color: texto,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: Espaco.s),
                  Expanded(
                    child: Text(
                      label,
                      style: tema.textTheme.bodyLarge?.copyWith(color: texto),
                    ),
                  ),
                  if (icone != null) ...[
                    const SizedBox(width: Espaco.xs),
                    Icon(icone, color: borda),
                  ],
                ],
              ),
            ),
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
    final esquema = Theme.of(context).colorScheme;
    return Card(
      key: const Key('logic-code'),
      color: esquema.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(Espaco.m),
        child: SelectableText(
          code,
          style: TextStyle(
            fontFamily: 'monospace',
            height: 1.5,
            color: esquema.onSurface,
          ),
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
    final esquema = Theme.of(context).colorScheme;
    final acerto = CoresDoApp.of(context).acerto;
    return CartaoDeAviso(
      titulo: isCorrect ? 'Resposta correta!' : 'Resposta incorreta.',
      conteudo:
          'Resposta selecionada: $selectedAnswer\nGabarito: $correctAnswer\n\n$explanation',
      icone: isCorrect
          ? Icons.check_circle_rounded
          : Icons.info_outline_rounded,
      fundo: isCorrect ? acerto.fundo : esquema.errorContainer,
      sobreFundo: isCorrect ? acerto.sobreFundo : esquema.onErrorContainer,
    );
  }
}
