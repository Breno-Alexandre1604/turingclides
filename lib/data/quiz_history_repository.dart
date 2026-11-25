import '../domain/models/quiz_result.dart';
import 'dados_locais.dart';

/// Contrato usado pelas telas dos quizzes para gravar e ler resultados.
/// Todas as consultas se referem ao jogador local desta instalação.
abstract interface class QuizHistoryRepository {
  Future<void> save(QuizResult result);
  Future<List<QuizResult>> all();
}

/// Implementação padrão: os dados locais da frente Dados e progresso
/// (SQLite no Android, localStorage no navegador).
QuizHistoryRepository get quizHistoryRepository => dadosLocais;
