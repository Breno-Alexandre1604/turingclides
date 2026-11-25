import 'package:material_ui/material_ui.dart';

import '../../app/app_theme.dart';
import '../../data/quiz_history_repository.dart';
import '../../domain/games/quiz_compartilhado/quiz_question.dart';
import '../../domain/games/quiz_compartilhado/quiz_strategy.dart';
import '../quizzes/quiz_screen.dart';
import '../widgets/game_controls.dart';
import '../widgets/pagina.dart';

// Configuração de Leonardo e navegação de Lucas para o banco de cada modo.
class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({
    super.key,
    required this.strategy,
    this.repository,
  });

  final QuizStrategy strategy;
  final QuizHistoryRepository? repository;

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  late final _difficulties = QuizDifficulty.values
      .where((level) => widget.strategy.questions(level).isNotEmpty)
      .toList();
  late QuizDifficulty _difficulty = _difficulties.first;
  int _count = 1;

  void _selectDifficulty(QuizDifficulty? difficulty) {
    if (difficulty == null) return;
    final available = widget.strategy.questions(difficulty).length;
    setState(() {
      _difficulty = difficulty;
      if (_count > available) _count = available;
    });
  }

  @override
  Widget build(BuildContext context) {
    final available = widget.strategy.questions(_difficulty).length;
    final tema = Theme.of(context);
    final titulo = widget.strategy.title;
    return Scaffold(
      appBar: AppBar(title: const Text('Configurar atividade')),
      body: PaginaRolavel(
        children: [
          Row(
            children: [
              IconeDoModo(
                icone: iconeDoModo(titulo),
                cores: CoresDoApp.of(context).doModo(titulo),
                tamanho: 48,
              ),
              const SizedBox(width: Espaco.m),
              Expanded(
                child: Text(titulo, style: tema.textTheme.headlineSmall),
              ),
            ],
          ),
          const SizedBox(height: Espaco.xl),
          DropdownButtonFormField<QuizDifficulty>(
            key: const Key('quiz-difficulty'),
            initialValue: _difficulty,
            decoration: const InputDecoration(labelText: 'Dificuldade'),
            items: [
              for (final level in _difficulties)
                DropdownMenuItem(value: level, child: Text(level.label)),
            ],
            onChanged: _selectDifficulty,
          ),
          const SizedBox(height: Espaco.m),
          DropdownButtonFormField<int>(
            key: ValueKey(_difficulty),
            initialValue: _count,
            decoration: const InputDecoration(
              labelText: 'Quantidade de perguntas',
            ),
            items: [
              for (var n = 1; n <= available; n++)
                DropdownMenuItem(
                  value: n,
                  child: Text(n == 1 ? '1 pergunta' : '$n perguntas'),
                ),
            ],
            onChanged: (count) {
              if (count != null) setState(() => _count = count);
            },
          ),
          const SizedBox(height: Espaco.xl),
          PrimaryButton(
            texto: 'Começar',
            onPressed: () => Navigator.of(context).pushReplacement<void, void>(
              MaterialPageRoute<void>(
                settings: const RouteSettings(name: '/partida'),
                builder: (_) => QuizScreen(
                  strategy: widget.strategy,
                  difficulty: _difficulty,
                  count: _count,
                  repository: widget.repository,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
