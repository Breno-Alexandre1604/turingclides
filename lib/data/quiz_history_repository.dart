import '../domain/models/quiz_result.dart';
import 'quiz_history_sqlite.dart'
    if (dart.library.js_interop) 'quiz_history_web.dart'
    as platform;

/// Todas as consultas se referem ao jogador local desta instalação.
abstract interface class QuizHistoryRepository {
  Future<void> save(QuizResult result);
  Future<List<QuizResult>> all();
}

final QuizHistoryRepository quizHistoryRepository = platform.createRepository();
