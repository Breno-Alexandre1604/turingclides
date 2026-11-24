import 'package:material_ui/material_ui.dart';

import '../../data/quiz_history_repository.dart';
import '../../domain/models/quiz_result.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Resultado')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(24),
            children: [
              const Icon(Icons.emoji_events, size: 64, color: Colors.amber),
              const SizedBox(height: 16),
              Text(
                'Atividade concluída!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text('${result.mode} · ${result.difficulty}'),
              Text(
                '${result.correctCount} de ${result.answers.length} acertos',
              ),
              Text('Pontuação: ${result.points} pontos'),
              const SizedBox(height: 16),
              switch (_state) {
                _SaveState.saving => const Text('Salvando partida…'),
                _SaveState.saved => const Text('Partida salva no histórico.'),
                _SaveState.failed => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Não foi possível confirmar o salvamento da partida.',
                    ),
                    TextButton(
                      onPressed: _retry,
                      child: const Text('Tentar salvar novamente'),
                    ),
                  ],
                ),
              },
              const SizedBox(height: 16),
              FilledButton(
                key: const Key('result-home'),
                onPressed: _state == _SaveState.saving
                    ? null
                    : () =>
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst),
                child: const Text('Voltar ao início'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
