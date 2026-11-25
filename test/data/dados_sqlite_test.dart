@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:turingclides/data/dados_locais.dart';
import 'package:turingclides/data/sqlite/banco_local.dart';
import 'package:turingclides/data/sqlite/jogadores_sqlite.dart';
import 'package:turingclides/data/sqlite/partidas_sqlite.dart';
import 'package:turingclides/data/sqlite/progresso_sqlite.dart';

import 'contrato_dados.dart';

void main() {
  sqfliteFfiInit();
  final fabrica = databaseFactoryFfi;
  late Directory pasta;
  late String caminho;
  BancoLocal? banco;

  Future<DadosLocais> abrir() async {
    await banco?.fechar();
    final novo = banco = BancoLocal(caminho: caminho, fabrica: fabrica);
    return DadosLocais(
      jogadores: JogadoresSQLite(novo),
      partidas: PartidasSQLite(novo),
      progresso: ProgressoSQLite(novo),
    );
  }

  setUp(() async {
    pasta = await Directory.systemTemp.createTemp('turingclides-dados-');
    caminho = '${pasta.path}${Platform.pathSeparator}turingclides.db';
  });

  tearDown(() async {
    await banco?.fechar();
    banco = null;
    await pasta.delete(recursive: true);
  });

  group('SQLite', () {
    contratoDosDadosLocais(abrir: abrir, reabrir: abrir);

    test('falha no meio da gravação não deixa registro parcial', () async {
      final dados = await abrir();
      final conexao = await banco!.abrir();
      // A partida e as respostas entram antes; o progresso falha depois.
      await conexao.execute(
        'CREATE TRIGGER falhar BEFORE INSERT ON progresso_topico '
        "BEGIN SELECT RAISE(ABORT, 'falha simulada'); END",
      );
      final a = resultado('a', respostas: [('Porcentagem', true, 100)]);
      await expectLater(dados.save(a), throwsA(isA<DatabaseException>()));

      for (final tabela in [
        'partida',
        'resposta_partida',
        'progresso_topico',
      ]) {
        final linhas = await conexao.rawQuery(
          'SELECT COUNT(*) AS total FROM $tabela',
        );
        expect(linhas.single['total'], 0, reason: tabela);
      }
      expect((await dados.perfil.obterJogadorAtual()).pontosTotais, 0);

      await conexao.execute('DROP TRIGGER falhar');
      await dados.save(a);
      await dados.save(a);
      expect(await dados.all(), hasLength(1));
      expect((await dados.perfil.obterJogadorAtual()).pontosTotais, 100);
    });

    test(
      'migra o histórico da versão 1 e descarta registro corrompido',
      () async {
        final antigo = await fabrica.openDatabase(
          caminho,
          options: OpenDatabaseOptions(
            version: 1,
            onCreate: (db, _) => db.execute(
              'CREATE TABLE quiz_results (id TEXT PRIMARY KEY NOT NULL, '
              'player_id TEXT NOT NULL, finished_at INTEGER NOT NULL, '
              'payload TEXT NOT NULL)',
            ),
          ),
        );
        final validos = [
          resultado('v1-a', minuto: 1, respostas: [('Porcentagem', true, 100)]),
          resultado(
            'v1-b',
            modo: 'Quiz de Lógica',
            minuto: 2,
            respostas: [('Laços', false, 0), ('Laços', true, 160)],
          ),
        ];
        for (final r in validos) {
          await antigo.insert('quiz_results', {
            'id': r.id,
            'player_id': 'local',
            'finished_at': r.finishedAt.millisecondsSinceEpoch,
            'payload': jsonEncode(r.toJson()),
          });
        }
        await antigo.insert('quiz_results', {
          'id': 'quebrado',
          'player_id': 'local',
          'finished_at': 0,
          'payload': '{"id": "quebrado"',
        });
        await antigo.close();

        final dados = await abrir();
        final jogador = await dados.perfil.obterJogadorAtual();
        expect(jogador.pontosTotais, 260);
        expect((await dados.all()).map((r) => r.toJson()), [
          validos[1].toJson(),
          validos[0].toJson(),
        ]);
        final conexao = await banco!.abrir();
        expect(await conexao.getVersion(), BancoLocal.versao);
        final antigas = await conexao.rawQuery(
          "SELECT name FROM sqlite_master WHERE name = 'quiz_results'",
        );
        expect(antigas, isEmpty);
      },
    );

    test('chaves estrangeiras e apagamento seguro ficam ligados', () async {
      await abrir();
      final conexao = await banco!.abrir();
      expect(
        (await conexao.rawQuery('PRAGMA foreign_keys')).single.values.single,
        1,
      );
      expect(
        (await conexao.rawQuery('PRAGMA secure_delete')).single.values.single,
        1,
      );
      await expectLater(
        conexao.insert('partida', {
          'id': 'orfa',
          'jogador_id': 99,
          'modo': 'Quiz',
          'dificuldade': 'Fácil',
          'qtd_questoes': 1,
          'finalizada_em': 0,
          'pontuacao': 0,
          'acertos': 0,
        }),
        throwsA(isA<DatabaseException>()),
      );
    });
  });
}
