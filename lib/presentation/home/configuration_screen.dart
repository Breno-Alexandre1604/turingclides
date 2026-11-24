import 'package:material_ui/material_ui.dart';

import '../../domain/games/quiz_compartilhado/quiz_question.dart';
import '../../domain/games/quiz_logica/logica_question.dart';
import '../../domain/games/quiz_matematica/matematica_question.dart';
import '../quizzes/quiz_screen.dart';
import '../widgets/game_controls.dart';

enum QuizMode {
  matematica('Quiz de Matemática', matematicaQuestion),
  logica('Quiz de Lógica', logicaQuestion);

  const QuizMode(this.title, this.question);
  final String title;
  final QuizQuestion question;
}

// Configuração de Leonardo e navegação de Lucas para o banco de cada modo.
class ConfigurationScreen extends StatelessWidget {
  const ConfigurationScreen({super.key, required this.mode});

  final QuizMode mode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurar atividade')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                mode.title,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              const Text('Dificuldade: Fácil'),
              const SizedBox(height: 16),
              const Text('1 pergunta'),
              const SizedBox(height: 28),
              PrimaryButton(
                texto: 'Começar',
                onPressed: () => Navigator.of(context)
                    .pushReplacement<void, void>(
                      MaterialPageRoute<void>(
                        settings: const RouteSettings(name: '/partida'),
                        builder: (_) => QuizScreen(
                          title: mode.title,
                          question: mode.question,
                        ),
                      ),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
