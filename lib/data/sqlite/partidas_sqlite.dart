import 'package:sqflite/sqflite.dart';

import '../../domain/contracts/repositorios.dart';
import '../../domain/models/partida.dart';
import 'banco_local.dart';

class PartidasSQLite implements RepositorioDePartidas {
  PartidasSQLite(this._banco);

  final BancoLocal _banco;

  @override
  Future<bool> salvar(Partida partida) async {
    partida.validar();
    final banco = await _banco.abrir();
    return banco.transaction((transacao) => gravarPartida(transacao, partida));
  }

  @override
  Future<List<Partida>> listarPorJogador(int jogadorId, {int? limite}) async {
    final banco = await _banco.abrir();
    final linhas = await banco.query(
      'partida',
      where: 'jogador_id = ?',
      whereArgs: [jogadorId],
      orderBy: 'finalizada_em DESC, id DESC',
      limit: limite,
    );
    if (linhas.isEmpty) return const [];

    // Uma consulta só para as respostas, sem limite de parâmetros no IN.
    final respostas = await banco.rawQuery(
      '''
      SELECT * FROM resposta_partida
      WHERE partida_id IN (
        SELECT id FROM partida WHERE jogador_id = ?
        ORDER BY finalizada_em DESC, id DESC LIMIT ?
      )
      ORDER BY partida_id, ordem
      ''',
      [jogadorId, limite ?? -1],
    );
    final porPartida = <String, List<RespostaPartida>>{};
    for (final r in respostas) {
      porPartida
          .putIfAbsent(r['partida_id'] as String, () => [])
          .add(
            RespostaPartida(
              ordem: r['ordem'] as int,
              questaoId: r['questao_id'] as String?,
              topico: r['topico'] as String,
              enunciado: r['enunciado'] as String,
              respostaDada: r['resposta_dada'] as String,
              respostaCorreta: r['resposta_correta'] as String,
              correta: r['correta'] == 1,
              tempoGastoMs: r['tempo_gasto_ms'] as int,
              pontos: r['pontos'] as int,
              usouDica: r['usou_dica'] == 1,
            ),
          );
    }

    return [
      for (final p in linhas)
        Partida(
          id: p['id'] as String,
          jogadorId: p['jogador_id'] as int,
          modo: p['modo'] as String,
          dificuldade: p['dificuldade'] as String,
          tempoPorQuestao: p['tempo_por_questao'] as int?,
          operacoes: _lerOperacoes(p['operacoes'] as String),
          iniciadaEm: _lerData(p['iniciada_em'] as int?),
          finalizadaEm: _lerData(p['finalizada_em'] as int)!,
          respostas: porPartida[p['id']] ?? const [],
        ),
    ];
  }

  @override
  Future<Map<String, int>> recordesPorModo(int jogadorId) async {
    final banco = await _banco.abrir();
    final linhas = await banco.rawQuery(
      'SELECT modo, MAX(pontuacao) AS recorde FROM partida '
      'WHERE jogador_id = ? GROUP BY modo ORDER BY modo',
      [jogadorId],
    );
    return {
      for (final linha in linhas)
        linha['modo'] as String: linha['recorde'] as int,
    };
  }
}

/// Grava a partida inteira usando a transação recebida. Também é usada pela
/// migração da versão 1. Devolve `false` se a partida já existia.
Future<bool> gravarPartida(DatabaseExecutor banco, Partida partida) async {
  final existente = await banco.query(
    'partida',
    columns: ['id'],
    where: 'id = ?',
    whereArgs: [partida.id],
    limit: 1,
  );
  if (existente.isNotEmpty) return false;

  final finalizadaEm = partida.finalizadaEm.toUtc().millisecondsSinceEpoch;
  await banco.insert('partida', {
    'id': partida.id,
    'jogador_id': partida.jogadorId,
    'modo': partida.modo,
    'dificuldade': partida.dificuldade,
    'qtd_questoes': partida.qtdQuestoes,
    'tempo_por_questao': partida.tempoPorQuestao,
    'operacoes': partida.operacoes.join(','),
    'iniciada_em': partida.iniciadaEm?.toUtc().millisecondsSinceEpoch,
    'finalizada_em': finalizadaEm,
    'pontuacao': partida.pontuacao,
    'acertos': partida.acertos,
  });

  final porTopico = <String, ({int respondidas, int acertos})>{};
  for (final r in partida.respostas) {
    await banco.insert('resposta_partida', {
      'partida_id': partida.id,
      'ordem': r.ordem,
      'questao_id': r.questaoId,
      'topico': r.topico,
      'enunciado': r.enunciado,
      'resposta_dada': r.respostaDada,
      'resposta_correta': r.respostaCorreta,
      'correta': r.correta ? 1 : 0,
      'tempo_gasto_ms': r.tempoGastoMs,
      'pontos': r.pontos,
      'usou_dica': r.usouDica ? 1 : 0,
    });
    final atual = porTopico[r.topico] ?? (respondidas: 0, acertos: 0);
    porTopico[r.topico] = (
      respondidas: atual.respondidas + 1,
      acertos: atual.acertos + (r.correta ? 1 : 0),
    );
  }

  for (final MapEntry(key: topico, value: soma) in porTopico.entries) {
    final atualizados = await banco.rawUpdate(
      '''
      UPDATE progresso_topico
      SET total_respondidas = total_respondidas + ?,
          total_acertos = total_acertos + ?,
          ultima_vez = MAX(ultima_vez, ?)
      WHERE jogador_id = ? AND modo = ? AND topico = ?
      ''',
      [
        soma.respondidas,
        soma.acertos,
        finalizadaEm,
        partida.jogadorId,
        partida.modo,
        topico,
      ],
    );
    if (atualizados == 0) {
      await banco.insert('progresso_topico', {
        'jogador_id': partida.jogadorId,
        'modo': partida.modo,
        'topico': topico,
        'total_respondidas': soma.respondidas,
        'total_acertos': soma.acertos,
        'ultima_vez': finalizadaEm,
      });
    }
  }

  final jogadores = await banco.rawUpdate(
    'UPDATE jogador SET pontos_totais = pontos_totais + ? WHERE id = ?',
    [partida.pontuacao, partida.jogadorId],
  );
  if (jogadores != 1) {
    // Lançar desfaz a transação inteira: nada da partida fica gravado.
    throw StateError('Jogador ${partida.jogadorId} não encontrado.');
  }
  return true;
}

List<String> _lerOperacoes(String texto) =>
    texto.isEmpty ? const [] : texto.split(',');

DateTime? _lerData(int? milissegundos) => milissegundos == null
    ? null
    : DateTime.fromMillisecondsSinceEpoch(milissegundos, isUtc: true);
