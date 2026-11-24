import 'dart:convert';

import 'package:web/web.dart' as web;

import '../domain/models/quiz_result.dart';
import 'quiz_history_repository.dart';

QuizHistoryRepository createRepository() => BrowserQuizHistoryRepository();

class BrowserQuizHistoryRepository implements QuizHistoryRepository {
  static const _prefix = 'turingclides.quizzes.v1.local.';

  @override
  Future<void> save(QuizResult result) async {
    final storage = web.window.localStorage;
    final key = '$_prefix${result.id}';
    if (storage.getItem(key) == null) {
      storage.setItem(key, jsonEncode(result.toJson()));
    }
  }

  @override
  Future<List<QuizResult>> all() async {
    final storage = web.window.localStorage;
    final results = <QuizResult>[];
    for (var i = 0; i < storage.length; i++) {
      final key = storage.key(i);
      if (key == null || !key.startsWith(_prefix)) continue;
      final payload = storage.getItem(key);
      if (payload != null) {
        results.add(
          QuizResult.fromJson(jsonDecode(payload) as Map<String, dynamic>),
        );
      }
    }
    results.sort((a, b) {
      final order = b.finishedAt.compareTo(a.finishedAt);
      return order == 0 ? b.id.compareTo(a.id) : order;
    });
    return results;
  }
}
