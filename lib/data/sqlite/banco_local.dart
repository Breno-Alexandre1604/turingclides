import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../domain/models/jogador.dart';
import '../../domain/models/partida.dart';
import '../../domain/models/quiz_result.dart';
import 'partidas_sqlite.dart';

/// Abre o banco SQLite do aparelho e mantém o esquema atualizado.
///
/// O arquivo fica na pasta privada do app (`getDatabasesPath()`), que outros
/// apps não conseguem ler. Todas as consultas usam parâmetros (`?`), nunca
/// texto concatenado.
class BancoLocal {
  BancoLocal({this.caminho = nomeArquivo, this._fabrica});

  /// Mesmo arquivo usado pela primeira versão do histórico dos quizzes,
  /// para que a migração da versão 1 aconteça no aparelho.
  static const nomeArquivo = 'turingclides_quizzes.db';
  static const versao = 2;

  final String caminho;
  final DatabaseFactory? _fabrica;
  Future<Database>? _aberto;

  /// Abre na primeira chamada e reaproveita a conexão nas seguintes. Se a
  /// abertura falhar, a próxima chamada tenta de novo.
  Future<Database> abrir() async {
    final pendente = _aberto ??= _abrirBanco();
    try {
      return await pendente;
    } catch (_) {
      if (identical(_aberto, pendente)) _aberto = null;
      rethrow;
    }
  }

  Future<void> fechar() async {
    final pendente = _aberto;
    _aberto = null;
    if (pendente != null) await (await pendente).close();
  }

  Future<Database> _abrirBanco() => (_fabrica ?? databaseFactory).openDatabase(
    caminho,
    options: OpenDatabaseOptions(
      version: versao,
      onConfigure: (banco) async {
        // Relações obrigatórias e sobrescrita do conteúdo apagado.
        await banco.execute('PRAGMA foreign_keys = ON');
        await banco.execute('PRAGMA secure_delete = ON');
      },
      onCreate: (banco, _) => criarEsquema(banco),
      onUpgrade: (banco, anterior, _) async {
        if (anterior < 2) await _migrarDaVersao1(banco);
      },
    ),
  );
}

/// Tabelas do diagrama 6B. Evita recursos que o SQLite de Androids antigos
/// não tem (UPSERT, RETURNING, funções de janela).
Future<void> criarEsquema(DatabaseExecutor banco) async {
  await banco.execute('''
    CREATE TABLE jogador (
      id INTEGER PRIMARY KEY NOT NULL,
      apelido TEXT NOT NULL CHECK (length(apelido) BETWEEN 2 AND 20),
      pontos_totais INTEGER NOT NULL DEFAULT 0 CHECK (pontos_totais >= 0),
      criado_em INTEGER NOT NULL
    )
  ''');
  await banco.execute('''
    CREATE TABLE partida (
      id TEXT PRIMARY KEY NOT NULL CHECK (length(id) BETWEEN 1 AND 64),
      jogador_id INTEGER NOT NULL REFERENCES jogador (id) ON DELETE CASCADE,
      modo TEXT NOT NULL,
      dificuldade TEXT NOT NULL,
      qtd_questoes INTEGER NOT NULL CHECK (qtd_questoes > 0),
      tempo_por_questao INTEGER CHECK (tempo_por_questao > 0),
      operacoes TEXT NOT NULL DEFAULT '',
      iniciada_em INTEGER,
      finalizada_em INTEGER NOT NULL,
      pontuacao INTEGER NOT NULL CHECK (pontuacao >= 0),
      acertos INTEGER NOT NULL CHECK (acertos BETWEEN 0 AND qtd_questoes)
    )
  ''');
  await banco.execute(
    'CREATE INDEX idx_partida_jogador ON partida (jogador_id, finalizada_em)',
  );
  await banco.execute('''
    CREATE TABLE resposta_partida (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      partida_id TEXT NOT NULL REFERENCES partida (id) ON DELETE CASCADE,
      ordem INTEGER NOT NULL CHECK (ordem >= 0),
      questao_id TEXT,
      topico TEXT NOT NULL,
      enunciado TEXT NOT NULL,
      resposta_dada TEXT NOT NULL,
      resposta_correta TEXT NOT NULL,
      correta INTEGER NOT NULL CHECK (correta IN (0, 1)),
      tempo_gasto_ms INTEGER NOT NULL CHECK (tempo_gasto_ms >= 0),
      pontos INTEGER NOT NULL CHECK (pontos >= 0),
      usou_dica INTEGER NOT NULL CHECK (usou_dica IN (0, 1)),
      UNIQUE (partida_id, ordem)
    )
  ''');
  await banco.execute('''
    CREATE TABLE progresso_topico (
      jogador_id INTEGER NOT NULL REFERENCES jogador (id) ON DELETE CASCADE,
      modo TEXT NOT NULL,
      topico TEXT NOT NULL,
      total_respondidas INTEGER NOT NULL CHECK (total_respondidas > 0),
      total_acertos INTEGER NOT NULL
        CHECK (total_acertos BETWEEN 0 AND total_respondidas),
      ultima_vez INTEGER NOT NULL,
      PRIMARY KEY (jogador_id, modo, topico)
    )
  ''');
}

/// A versão 1 guardava cada partida de quiz como JSON em `quiz_results`.
/// A migração roda dentro da transação de abertura: ou tudo migra, ou o
/// banco continua na versão 1.
Future<void> _migrarDaVersao1(Database banco) async {
  await criarEsquema(banco);
  final linhas = await banco.query(
    'quiz_results',
    columns: ['payload'],
    orderBy: 'finished_at, id',
  );
  if (linhas.isNotEmpty) {
    await banco.insert('jogador', {
      'id': Jogador.idLocal,
      'apelido': Jogador.apelidoPadrao,
      'pontos_totais': 0,
      'criado_em': DateTime.now().toUtc().millisecondsSinceEpoch,
    });
  }
  for (final linha in linhas) {
    final Partida partida;
    try {
      final json = jsonDecode(linha['payload'] as String);
      partida = Partida.deQuiz(
        QuizResult.fromJson(json as Map<String, dynamic>),
        jogadorId: Jogador.idLocal,
      )..validar();
    } on Object {
      // Registro corrompido da versão 1: não entra na versão nova.
      continue;
    }
    await gravarPartida(banco, partida);
  }
  await banco.execute('DROP TABLE quiz_results');
}
