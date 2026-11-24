import 'package:material_ui/material_ui.dart';

import '../widgets/game_controls.dart';
import 'configuration_screen.dart';

// Home e cartões de Leonardo com o percurso Home → configuração de Lucas.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _abrirConfiguracao(BuildContext context, QuizMode mode) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: '/configuracao'),
        builder: (_) => ConfigurationScreen(mode: mode),
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
        actions: const [
          IconButton(
            tooltip: 'Perfil',
            onPressed: null,
            icon: Icon(Icons.person_outline),
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
              const ModeCard(
                titulo: 'Conta Rápida',
                descricao:
                    'Aguardando integração das operações com cronômetro.',
                icone: Icons.calculate_outlined,
                cor: Colors.deepOrange,
              ),
              ModeCard(
                key: const Key('quiz-mode-math'),
                titulo: 'Quiz de Matemática',
                descricao: 'Responda perguntas e veja dicas.',
                icone: Icons.functions,
                cor: Colors.indigo,
                onTap: () => _abrirConfiguracao(context, QuizMode.matematica),
              ),
              ModeCard(
                key: const Key('quiz-mode-logic'),
                titulo: 'Quiz de Lógica',
                descricao: 'Resolva desafios de programação.',
                icone: Icons.code,
                cor: Colors.teal,
                onTap: () => _abrirConfiguracao(context, QuizMode.logica),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.history),
                label: const Text('Ver histórico'),
              ),
              OutlinedButton.icon(
                onPressed: null,
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
