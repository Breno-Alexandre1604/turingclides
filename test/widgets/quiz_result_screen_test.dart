import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:turingclides/data/quiz_history_repository.dart';
import 'package:turingclides/domain/models/quiz_result.dart';
import 'package:turingclides/presentation/quizzes/quiz_result_screen.dart';

class _LostAcknowledgement implements QuizHistoryRepository {
  final rows = <String, QuizResult>{};
  final attempts = <QuizResult>[];

  @override
  Future<void> save(QuizResult result) async {
    attempts.add(result);
    rows.putIfAbsent(result.id, () => result);
    if (attempts.length == 1) throw StateError('Confirmação perdida');
  }

  @override
  Future<List<QuizResult>> all() async => rows.values.toList();
}

void main() {
  testWidgets(
    'Repetir um salvamento usa a mesma partida após perder a confirmação',
    (tester) async {
      final repository = _LostAcknowledgement();
      final result = QuizResult(
        id: 'partida-teste',
        mode: 'Quiz de Matemática',
        difficulty: 'Fácil',
        finishedAt: DateTime.utc(2026, 11, 24),
        answers: [
          QuizAnswerResult(
            topic: 'Porcentagem',
            prompt: '15% de 80',
            selected: '12',
            correct: '12',
            points: 100,
            elapsedMs: 3000,
            usedHint: false,
          ),
        ],
      );
      await tester.pumpWidget(
        MaterialApp(
          home: QuizResultScreen(result: result, repository: repository),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Partida salva no histórico.'), findsNothing);
      await tester.tap(find.text('Tentar salvar novamente'));
      await tester.pumpAndSettle();
      expect(find.text('Partida salva no histórico.'), findsOneWidget);
      expect(repository.attempts, [same(result), same(result)]);
      expect(await repository.all(), hasLength(1));
    },
  );
}
