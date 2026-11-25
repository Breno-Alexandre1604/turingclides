import 'package:flutter_test/flutter_test.dart';
import 'package:turingclides/data/dados_locais.dart';
import 'package:turingclides/domain/models/apelido.dart';
import 'package:turingclides/domain/models/jogador.dart';
import 'package:turingclides/domain/models/partida.dart';
import 'package:turingclides/domain/models/progresso_topico.dart';
import 'package:turingclides/domain/models/quiz_result.dart';

/// Comportamento que toda implementação dos dados locais precisa cumprir
/// (SQLite no Android, memória/localStorage no navegador).
///
/// [abrir] devolve os dados de uma origem nova e vazia. [reabrir] fecha e
/// abre de novo a mesma origem, como acontece ao fechar e abrir o app.
void contratoDosDadosLocais({
  required Future<DadosLocais> Function() abrir,
  required Future<DadosLocais> Function() reabrir,
}) {
  test('primeiro uso cria o perfil padrão sem partidas', () async {
    final dados = await abrir();
    final jogador = await dados.perfil.obterJogadorAtual();
    expect(jogador.id, Jogador.idLocal);
    expect(jogador.apelido, Jogador.apelidoPadrao);
    expect(jogador.pontosTotais, 0);
    expect(await dados.progresso.historico(jogador.id), isEmpty);
    expect(await dados.progresso.consultarProgresso(jogador.id), isEmpty);
    expect(await dados.progresso.recordes(jogador.id), isEmpty);
    expect(await dados.all(), isEmpty);
  });

  test('mesma partida enviada duas vezes, ao mesmo tempo e após reabrir, conta uma vez', () async {
    final dados = await abrir();
    final a = resultado(
      'a',
      minuto: 1,
      respostas: [('Porcentagem', true, 100)],
    );
    await Future.wait([dados.save(a), dados.save(a)]);
    await dados.save(
      resultado(
        'b',
        minuto: 2,
        respostas: [('Porcentagem', true, 150), ('Frações', false, 0)],
      ),
    );

    final reaberto = await reabrir();
    await reaberto.save(a);
    final jogador = await reaberto.perfil.obterJogadorAtual();
    expect(
      await reaberto.progresso.registrarPartida(
        Partida.deQuiz(a, jogadorId: jogador.id),
      ),
      isFalse,
    );

    final historico = await reaberto.progresso.historico(jogador.id);
    expect(historico.map((p) => p.id), ['b', 'a']);
    expect(jogador.pontosTotais, 250);
    expect(await reaberto.progresso.recordes(jogador.id), {
      'Quiz de Matemática': 150,
    });
    final progresso = await reaberto.progresso.consultarProgresso(jogador.id);
    expect(resumir(progresso), [
      ('Quiz de Matemática', 'Frações', 1, 0),
      ('Quiz de Matemática', 'Porcentagem', 2, 2),
    ]);
  });

  test(
    'pontos e progresso gravados batem com o recálculo do histórico',
    () async {
      final dados = await abrir();
      await dados.save(
        resultado(
          'm1',
          minuto: 1,
          respostas: [('Porcentagem', true, 120), ('Equações', false, 0)],
        ),
      );
      await dados.save(
        resultado(
          'l1',
          modo: 'Quiz de Lógica',
          minuto: 2,
          respostas: [('Laços', true, 180), ('Laços', true, 190)],
        ),
      );
      await dados.save(
        resultado('m2', minuto: 3, respostas: [('Equações', true, 70)]),
      );

      final reaberto = await reabrir();
      final jogador = await reaberto.perfil.obterJogadorAtual();
      final historico = await reaberto.progresso.historico(jogador.id);
      expect(historico, hasLength(3));
      expect(
        jogador.pontosTotais,
        historico.fold(0, (soma, p) => soma + p.pontuacao),
      );
      expect(
        resumir(await reaberto.progresso.consultarProgresso(jogador.id)),
        resumir(ProgressoTopico.calcular(historico)),
      );
      expect(
        await reaberto.progresso.recordes(jogador.id),
        ProgressoTopico.recordes(historico),
      );
      expect(
        await reaberto.progresso.obterRecorde(jogador.id, 'Quiz de Lógica'),
        370,
      );
      expect(await reaberto.progresso.historico(jogador.id, limite: 1), [
        isA<Partida>().having((p) => p.id, 'id', 'm2'),
      ]);
    },
  );

  test('resultado do quiz volta igual pelo contrato das telas', () async {
    final dados = await abrir();
    final original = resultado(
      'ida-e-volta',
      minuto: 5,
      respostas: [('Porcentagem', true, 130), ('Frações', false, 0)],
      usouDica: true,
    );
    await dados.save(original);
    final reaberto = await reabrir();
    expect((await reaberto.all()).single.toJson(), original.toJson());
  });

  test('apelido válido persiste e apelido inválido não altera nada', () async {
    final dados = await abrir();
    await dados.save(resultado('a', respostas: [('Porcentagem', true, 100)]));
    final renomeado = await dados.perfil.alterarApelido('  Ana   Clara ');
    expect(renomeado.apelido, 'Ana Clara');
    expect(renomeado.pontosTotais, 100);

    await expectLater(
      dados.perfil.alterarApelido("x'); DROP TABLE jogador;--"),
      throwsA(isA<ApelidoInvalido>()),
    );
    await expectLater(
      dados.perfil.alterarApelido('A'),
      throwsA(isA<ApelidoInvalido>()),
    );

    final reaberto = await reabrir();
    final jogador = await reaberto.perfil.obterJogadorAtual();
    expect(jogador.apelido, 'Ana Clara');
    expect(jogador.pontosTotais, 100);
  });

  test('apagar dados remove perfil, partidas, recordes e progresso', () async {
    final dados = await abrir();
    await dados.perfil.alterarApelido('Turing');
    await dados.save(resultado('a', respostas: [('Porcentagem', true, 100)]));
    await dados.perfil.apagarDados();

    final reaberto = await reabrir();
    final jogador = await reaberto.perfil.obterJogadorAtual();
    expect(jogador.apelido, Jogador.apelidoPadrao);
    expect(jogador.pontosTotais, 0);
    expect(await reaberto.progresso.historico(jogador.id), isEmpty);
    expect(await reaberto.progresso.consultarProgresso(jogador.id), isEmpty);
    expect(await reaberto.progresso.recordes(jogador.id), isEmpty);
  });

  test('partida com dados impossíveis é recusada sem gravar nada', () async {
    final dados = await abrir();
    final jogador = await dados.perfil.obterJogadorAtual();
    for (final invalida in [
      partidaCom(jogador.id, pontos: -10, correta: true),
      partidaCom(jogador.id, pontos: 50, correta: false),
      partidaCom(jogador.id, pontos: 100, correta: true, id: 'id com espaço'),
    ]) {
      await expectLater(
        dados.progresso.registrarPartida(invalida),
        throwsA(isA<PartidaInvalida>()),
      );
    }
    expect(await dados.progresso.historico(jogador.id), isEmpty);
    expect((await dados.perfil.obterJogadorAtual()).pontosTotais, 0);
  });

  test('aspas e comandos SQL nos textos são guardados como texto', () async {
    final dados = await abrir();
    const perigoso = "'; DROP TABLE partida; --";
    final original = QuizResult(
      id: 'texto-livre',
      mode: "Quiz d'Lógica",
      difficulty: 'Fácil',
      finishedAt: DateTime.utc(2026, 11, 25),
      answers: const [
        QuizAnswerResult(
          topic: 'Saída "de" texto',
          prompt: 'print($perigoso)',
          selected: perigoso,
          correct: perigoso,
          points: 100,
          elapsedMs: 10,
          usedHint: false,
        ),
      ],
    );
    await dados.save(original);
    final reaberto = await reabrir();
    expect((await reaberto.all()).single.toJson(), original.toJson());
  });
}

/// Monta um resultado de quiz como o PartidaController entrega.
QuizResult resultado(
  String id, {
  required List<(String, bool, int)> respostas,
  String modo = 'Quiz de Matemática',
  int minuto = 0,
  bool usouDica = false,
}) => QuizResult(
  id: id,
  mode: modo,
  difficulty: 'Fácil',
  finishedAt: DateTime.utc(2026, 11, 23, 10, minuto),
  answers: [
    for (final (topico, correta, pontos) in respostas)
      QuizAnswerResult(
        topic: topico,
        prompt: 'Pergunta sobre $topico',
        selected: correta ? 'certa' : 'errada',
        correct: 'certa',
        points: pontos,
        elapsedMs: 4300,
        usedHint: usouDica,
      ),
  ],
);

Partida partidaCom(
  int jogadorId, {
  required int pontos,
  required bool correta,
  String id = 'invalida',
}) => Partida(
  id: id,
  jogadorId: jogadorId,
  modo: 'Quiz de Matemática',
  dificuldade: 'Fácil',
  finalizadaEm: DateTime.utc(2026, 11, 23),
  respostas: [
    RespostaPartida(
      ordem: 0,
      topico: 'Porcentagem',
      enunciado: 'Quanto é 10% de 50?',
      respostaDada: '5',
      respostaCorreta: '5',
      correta: correta,
      tempoGastoMs: 100,
      pontos: pontos,
    ),
  ],
);

List<(String, String, int, int)> resumir(List<ProgressoTopico> progresso) => [
  for (final p in progresso)
    (p.modo, p.topico, p.totalRespondidas, p.totalAcertos),
];
