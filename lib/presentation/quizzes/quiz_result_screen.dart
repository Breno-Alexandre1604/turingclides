import 'package:material_ui/material_ui.dart';

import '../../app/app_theme.dart';
import '../../data/quiz_history_repository.dart';
import '../../domain/models/quiz_result.dart';
import '../widgets/pagina.dart';
import '../widgets/resultado.dart';

// Resultado do protótipo de Leonardo e Lucas, ligado ao repositório local.
class QuizResultScreen extends StatefulWidget {
  const QuizResultScreen({
    super.key,
    required this.result,
    required this.repository,
  });
  final QuizResult result;
  final QuizHistoryRepository repository;

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

enum _SaveState { saving, saved, failed }

class _QuizResultScreenState extends State<QuizResultScreen> {
  var _state = _SaveState.saving;

  @override
  void initState() {
    super.initState();
    _save();
  }

  Future<void> _save() async {
    try {
      await widget.repository.save(widget.result);
      if (mounted) setState(() => _state = _SaveState.saved);
    } catch (_) {
      if (mounted) setState(() => _state = _SaveState.failed);
    }
  }

  void _retry() {
    if (_state != _SaveState.failed) return;
    setState(() => _state = _SaveState.saving);
    _save();
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final tema = Theme.of(context);
    final recorde = CoresDoApp.of(context).recorde;
    return Scaffold(
      appBar: AppBar(title: const Text('Resultado')),
      body: PaginaRolavel(
        larguraMaxima: Largura.jogo,
        children: [
          const SizedBox(height: Espaco.m),
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: recorde.fundo,
              child: Icon(
                Icons.emoji_events_rounded,
                size: 48,
                color: recorde.sobreFundo,
              ),
            ),
          ),
          const SizedBox(height: Espaco.m),
          Text(
            'Atividade concluída!',
            textAlign: TextAlign.center,
            style: tema.textTheme.headlineSmall,
          ),
          const SizedBox(height: Espaco.xl),
          ResumoDoResultado(
            linhas: [
              '${result.mode} · ${result.difficulty}',
              '${result.correctCount} de ${result.answers.length} acertos',
            ],
            pontuacao: 'Pontuação: ${result.points} pontos',
          ),
          const SizedBox(height: Espaco.m),
          switch (_state) {
            _SaveState.saving => const EstadoDoSalvamento.salvando(),
            _SaveState.saved => const EstadoDoSalvamento.salvo(),
            _SaveState.failed => EstadoDoSalvamento.falhou(
              tentarDeNovo: _retry,
            ),
          },
          const SizedBox(height: Espaco.xl),
          FilledButton(
            key: const Key('result-home'),
            onPressed: _state == _SaveState.saving
                ? null
                : () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
            child: const Text('Voltar ao início'),
          ),
        ],
      ),
    );
  }
}
