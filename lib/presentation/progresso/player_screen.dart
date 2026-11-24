import 'package:material_ui/material_ui.dart';

import '../../data/quiz_history_repository.dart';
import '../../domain/models/quiz_result.dart';

enum PlayerSection {
  history('Histórico'),
  profile('Perfil'),
  progress('Progresso');

  const PlayerSection(this.title);
  final String title;
}

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key, required this.section, this.repository});

  final PlayerSection section;
  final QuizHistoryRepository? repository;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late Future<List<QuizResult>> _history;

  @override
  void initState() {
    super.initState();
    _history = _load();
  }

  Future<List<QuizResult>> _load() =>
      (widget.repository ?? quizHistoryRepository).all();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.section.title)),
      body: FutureBuilder<List<QuizResult>>(
        future: _history,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Não foi possível ler as partidas.'),
                  TextButton(
                    onPressed: () => setState(() => _history = _load()),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }
          final history = snapshot.requireData;
          final stats = QuizPlayerStats(history);
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: switch (widget.section) {
                  PlayerSection.history => [
                    if (history.isEmpty)
                      const Text('Nenhuma partida de quiz concluída.'),
                    for (final result in history) _HistoryCard(result: result),
                  ],
                  PlayerSection.profile => [
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: const Text('Jogador local'),
                      subtitle: Text(
                        '${stats.points} pontos • ${history.length} partida(s) de quiz',
                      ),
                    ),
                    const Divider(),
                    const ListTile(title: Text('Recordes por modo')),
                    if (stats.records.isEmpty)
                      const ListTile(
                        title: Text(
                          'Conclua um quiz para registrar seu primeiro recorde.',
                        ),
                      ),
                    for (final record in stats.records.entries)
                      ListTile(
                        title: Text(record.key),
                        trailing: Text('${record.value} pts'),
                      ),
                  ],
                  PlayerSection.progress => [
                    if (stats.byTopic.isEmpty)
                      const Text(
                        'Conclua um quiz para ver seus acertos por assunto.',
                      ),
                    for (final topic in stats.byTopic.entries)
                      ListTile(
                        title: Text(topic.key),
                        subtitle: Text(
                          '${topic.value.correct} de ${topic.value.answered} respostas corretas',
                        ),
                      ),
                  ],
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.result});
  final QuizResult result;

  @override
  Widget build(BuildContext context) {
    final time = result.finishedAt.toLocal();
    final date = MaterialLocalizations.of(context).formatShortDate(time);
    final hour = TimeOfDay.fromDateTime(time).format(context);
    return Card(
      child: ExpansionTile(
        title: Text('${result.mode} • ${result.points} pts'),
        subtitle: Text(
          '${result.difficulty} • $date, $hour\n${result.correctCount}/${result.answers.length} acertos',
        ),
        children: [
          for (final answer in result.answers)
            ListTile(
              title: Text(answer.prompt),
              subtitle: Text(
                'Sua resposta: ${answer.selected}\nGabarito: ${answer.correct}',
              ),
            ),
        ],
      ),
    );
  }
}
