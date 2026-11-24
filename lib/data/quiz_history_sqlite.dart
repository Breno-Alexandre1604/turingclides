import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../domain/models/quiz_result.dart';
import 'quiz_history_repository.dart';

QuizHistoryRepository createRepository() => SqliteQuizHistoryRepository();

class SqliteQuizHistoryRepository implements QuizHistoryRepository {
  SqliteQuizHistoryRepository({
    this.databasePath = 'turingclides_quizzes.db',
    this.factory,
  });

  final String databasePath;
  final DatabaseFactory? factory;

  Future<Database> _open() => (factory ?? databaseFactory).openDatabase(
    databasePath,
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (database, _) async {
        await database.execute('''
          CREATE TABLE quiz_results (
            id TEXT PRIMARY KEY NOT NULL,
            player_id TEXT NOT NULL,
            finished_at INTEGER NOT NULL,
            payload TEXT NOT NULL
          )
        ''');
      },
    ),
  );

  @override
  Future<void> save(QuizResult result) async {
    final database = await _open();
    // O resultado e todas as respostas são inseridos em uma operação atômica.
    await database.insert('quiz_results', {
      'id': result.id,
      'player_id': 'local',
      'finished_at': result.finishedAt.millisecondsSinceEpoch,
      'payload': jsonEncode(result.toJson()),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  @override
  Future<List<QuizResult>> all() async {
    final database = await _open();
    final rows = await database.query(
      'quiz_results',
      columns: ['payload'],
      where: 'player_id = ?',
      whereArgs: ['local'],
      orderBy: 'finished_at DESC, id DESC',
    );
    return [
      for (final row in rows)
        QuizResult.fromJson(
          jsonDecode(row['payload'] as String) as Map<String, dynamic>,
        ),
    ];
  }
}
