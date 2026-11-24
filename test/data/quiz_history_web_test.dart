@TestOn('browser')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:turingclides/data/quiz_history_sqlite.dart'
    if (dart.library.js_interop) 'package:turingclides/data/quiz_history_web.dart';
import 'package:turingclides/domain/models/quiz_result.dart';

void main() {
  test(
    'navegador conserva cada partida uma vez entre instâncias do repositório',
    () async {
      final now = DateTime.now().toUtc();
      final result = QuizResult(
        id: 'teste-web-${now.microsecondsSinceEpoch}',
        mode: 'Lógica',
        difficulty: 'Fácil',
        finishedAt: now,
        answers: const [
          QuizAnswerResult(
            topic: 'Laços',
            prompt: 'Qual a saída?',
            selected: '4',
            correct: '10',
            points: 0,
            elapsedMs: 1100,
            usedHint: false,
          ),
        ],
      );
      final repository = createRepository();
      await Future.wait([repository.save(result), repository.save(result)]);
      final reopened = createRepository();
      await reopened.save(result);
      final matches = (await reopened.all()).where((r) => r.id == result.id);
      expect(matches.single.toJson(), result.toJson());
      expect(QuizPlayerStats(matches).byTopic['Laços'], (
        correct: 0,
        answered: 1,
      ));
    },
  );
}
