import 'package:material_ui/material_ui.dart';

import '../../data/dados_locais.dart';
import '../../domain/games/quiz_compartilhado/quiz_strategy.dart';
import '../conta_rapida/configuracao_conta_rapida_screen.dart';
import '../progresso/player_screen.dart';
import '../widgets/game_controls.dart';
import 'configuration_screen.dart';

// Home e cartões de Leonardo com o percurso Home → configuração de Lucas.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.dados});

  /// Dados do jogador. Vazio usa o banco do aparelho; os testes injetam
  /// [DadosLocais.emMemoria].
  final DadosLocais? dados;

  void _abrirConfiguracao(BuildContext context, QuizStrategy strategy) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: '/configuracao'),
        builder: (_) =>
            ConfigurationScreen(strategy: strategy, repository: dados),
      ),
    );
  }

  void _abrirContaRapida(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: '/conta-rapida/configuracao'),
        builder: (_) => ConfiguracaoContaRapidaScreen(dados: dados),
      ),
    );
  }

  void _abrirDados(BuildContext context, PlayerSection section) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => PlayerScreen(section: section, dados: dados),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Turingclides',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Perfil',
            onPressed: () => _abrirDados(context, PlayerSection.profile),
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Aprenda jogando!',
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Escolha uma atividade para começar.',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
              ),
              const SizedBox(height: 25),
              ModeCard(
                key: const Key('quick-mode'),
                titulo: 'Conta Rápida',
                descricao: 'Contas de cabeça com 10 segundos cada.',
                icone: Icons.calculate_outlined,
                cor: Colors.deepOrange,
                onTap: () => _abrirContaRapida(context),
              ),
              ModeCard(
                key: const Key('quiz-mode-math'),
                titulo: 'Quiz de Matemática',
                descricao: 'Responda perguntas e veja dicas.',
                icone: Icons.functions,
                cor: Colors.indigo,
                onTap: () => _abrirConfiguracao(context, matematicaStrategy),
              ),
              ModeCard(
                key: const Key('quiz-mode-logic'),
                titulo: 'Quiz de Lógica',
                descricao: 'Resolva desafios de programação.',
                icone: Icons.code,
                cor: Colors.teal,
                onTap: () => _abrirConfiguracao(context, logicaStrategy),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () => _abrirDados(context, PlayerSection.history),
                icon: const Icon(Icons.history),
                label: const Text('Ver histórico'),
              ),
              OutlinedButton.icon(
                onPressed: () => _abrirDados(context, PlayerSection.progress),
                icon: const Icon(Icons.trending_up),
                label: const Text('Ver progresso'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
