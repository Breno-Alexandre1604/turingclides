@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:turingclides/data/quiz_history_sqlite.dart';
import 'package:turingclides/domain/models/quiz_result.dart';

void main() {
  sqfliteFfiInit();
  late Directory directory;
  late String path;
  late SqliteQuizHistoryRepository repository;
  final factory = databaseFactoryFfi;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('turingclides-quiz-');
    path = '${directory.path}/partidas.db';
    repository = SqliteQuizHistoryRepository(
      databasePath: path,
      factory: factory,
    );
  });

  tearDown(() async {
    await (await factory.openDatabase(path)).close();
    await directory.delete(recursive: true);
  });

  test(
    'reenvio simultâneo e reabertura mantêm uma partida e um progresso',
    () async {
      final result = _round('a', points: 100);
      await Future.wait([repository.save(result), repository.save(result)]);
      await repository.save(_round('b', points: 150));
      await (await factory.openDatabase(path)).close();

      final reopened = SqliteQuizHistoryRepository(
        databasePath: path,
        factory: factory,
      );
      await reopened.save(result);
      final history = await reopened.all();
      expect(history.map((r) => r.id), ['b', 'a']);
      expect(history.last.toJson(), result.toJson());

      final stats = QuizPlayerStats(history);
      expect(stats.byTopic['Porcentagem'], (correct: 2, answered: 2));
      expect(stats.records['Matemática'], 150);
      expect(stats.points, 250);
    },
  );

  test(
    'falha de escrita deixa histórico vazio e permite nova tentativa',
    () async {
      final result = _round('a', points: 100);
      expect(await repository.all(), isEmpty);
      final database = await factory.openDatabase(path);
      await database.execute(
        "CREATE TRIGGER falhar BEFORE INSERT ON quiz_results BEGIN SELECT RAISE(ABORT, 'falha simulada'); END",
      );
      await expectLater(
        repository.save(result),
        throwsA(isA<DatabaseException>()),
      );
      expect(await repository.all(), isEmpty);

      await database.execute('DROP TRIGGER falhar');
      await repository.save(result);
      await repository.save(result);
      expect((await repository.all()).single.toJson(), result.toJson());
    },
  );
}

QuizResult _round(String id, {required int points}) => QuizResult(
  id: id,
  mode: 'Matemática',
  difficulty: 'Fácil',
  finishedAt: DateTime.utc(2026, 11, 23),
  answers: [
    QuizAnswerResult(
      topic: 'Porcentagem',
      prompt: 'Quanto é 10% de 50?',
      selected: '5',
      correct: '5',
      points: points,
      elapsedMs: 4300,
      usedHint: true,
    ),
  ],
);
