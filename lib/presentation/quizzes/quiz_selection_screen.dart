import 'package:material_ui/material_ui.dart';

import '../../domain/games/quiz_compartilhado/quiz_question.dart';
import '../../domain/games/quiz_logica/logica_question.dart';
import '../../domain/games/quiz_matematica/matematica_question.dart';
import 'quiz_screen.dart';

class QuizSelectionScreen extends StatelessWidget {
  const QuizSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Turingclides')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Escolha seu quiz',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Responda uma questão e confira como chegou ao resultado.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              _QuizModeCard(
                key: const Key('quiz-mode-math'),
                title: 'Quiz de Matemática',
                description: 'Pratique porcentagens e cálculos do dia a dia.',
                icon: Icons.calculate_outlined,
                onTap: () => _openQuiz(
                  context,
                  title: 'Quiz de Matemática',
                  question: matematicaQuestion,
                ),
              ),
              const SizedBox(height: 16),
              _QuizModeCard(
                key: const Key('quiz-mode-logic'),
                title: 'Quiz de Lógica',
                description: 'Leia o código, faça o teste de mesa e descubra a saída.',
                icon: Icons.code,
                onTap: () => _openQuiz(
                  context,
                  title: 'Quiz de Lógica',
                  question: logicaQuestion,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openQuiz(
    BuildContext context, {
    required String title,
    required QuizQuestion question,
  }) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => QuizScreen(title: title, question: question),
      ),
    );
  }
}

class _QuizModeCard extends StatelessWidget {
  const _QuizModeCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(icon, size: 32),
        title: Text(title),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(description),
        ),
        trailing: const Icon(Icons.arrow_forward),
        onTap: onTap,
      ),
    );
  }
}
