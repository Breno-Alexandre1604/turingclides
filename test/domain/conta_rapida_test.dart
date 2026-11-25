import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:turingclides/domain/games/conta_rapida/conta_rapida.dart';
import 'package:turingclides/domain/games/quiz_compartilhado/quiz_question.dart';

void main() {
  test('gerador respeita operações e nível, sem negativos nem resto', () {
    for (final nivel in QuizDifficulty.values) {
      final faixa = FaixaDoNivel.de(nivel);
      final gerador = GeradorDeContas(
        operacoes: Operacao.values,
        nivel: nivel,
        random: Random(7),
      );
      final vistas = <Operacao>{};
      for (var i = 0; i < 400; i++) {
        final conta = gerador.proxima();
        vistas.add(conta.operacao);
        expect(
          conta.resultado,
          greaterThanOrEqualTo(0),
          reason: conta.enunciado,
        );
        switch (conta.operacao) {
          case Operacao.soma || Operacao.subtracao:
            expect(conta.a, inInclusiveRange(faixa.somaMin, faixa.somaMax));
            expect(conta.b, inInclusiveRange(faixa.somaMin, faixa.somaMax));
          case Operacao.multiplicacao:
            expect(conta.a, inInclusiveRange(faixa.fatorMin, faixa.fatorMax));
            expect(conta.b, inInclusiveRange(faixa.fatorMin, faixa.fatorMax));
          case Operacao.divisao:
            expect(conta.b, isNot(0));
            expect(conta.a % conta.b, 0, reason: conta.enunciado);
            expect(
              conta.resultado,
              inInclusiveRange(faixa.fatorMin, faixa.fatorMax),
            );
        }
      }
      expect(vistas, Operacao.values.toSet());
    }
    expect(
      () => GeradorDeContas(operacoes: const [], nivel: QuizDifficulty.facil),
      throwsArgumentError,
    );
  });

  test('conferência aceita só o número inteiro certo', () {
    const conta = ContaGerada(7, Operacao.multiplicacao, 8);
    expect(conta.enunciado, '7 × 8');
    expect(conta.confere(' 56 '), isTrue);
    expect(conta.confere('56.0'), isFalse);
    expect(conta.confere('-56'), isFalse);
    expect(conta.confere(''), isFalse);
    expect(conta.confere('abc'), isFalse);
  });

  test('pontuação: base, bônus de tempo, combo limitado e erro zera', () {
    const regra = PontuacaoRapida();
    const limite = Duration(seconds: 10);
    int pontos(int ms, int sequencia, {bool correta = true}) => regra.pontos(
      correta: correta,
      sequenciaAnterior: sequencia,
      tempo: Duration(milliseconds: ms),
      limite: limite,
    );
    expect(pontos(0, 0), 150);
    expect(pontos(5000, 0), 125);
    expect(pontos(10000, 0), 100);
    expect(pontos(10000, 2), 120);
    expect(pontos(0, 9), 200);
    expect(pontos(0, 3, correta: false), 0);
  });

  group('rodada', () {
    RodadaContaRapida nova({int quantidade = 3}) => RodadaContaRapida(
      nivel: QuizDifficulty.facil,
      operacoes: {Operacao.soma},
      quantidade: quantidade,
      random: Random(1),
      inicio: DateTime.utc(2026, 11, 25, 10),
    );

    test(
      'clique repetido e tempo esgotado não processam a conta duas vezes',
      () {
        final rodada = nova();
        final certa = '${rodada.contaAtual.resultado}';
        expect(
          rodada.responder(certa, tempo: const Duration(seconds: 1)),
          isNotNull,
        );
        expect(
          rodada.responder(certa, tempo: const Duration(seconds: 2)),
          isNull,
        );
        expect(rodada.esgotarTempo(), isNull);
        expect(rodada.respostas, hasLength(1));
        expect(rodada.pontos, 145);
      },
    );

    test('erro e tempo esgotado zeram o combo', () {
      final rodada = nova(quantidade: 3);
      rodada.responder('${rodada.contaAtual.resultado}', tempo: Duration.zero);
      rodada.avancar();
      final tempo = rodada.esgotarTempo()!;
      expect(tempo.tempoEsgotado, isTrue);
      expect(tempo.pontos, 0);
      rodada.avancar();
      final terceira = rodada.responder(
        '${rodada.contaAtual.resultado}',
        tempo: Duration.zero,
      )!;
      expect(
        terceira.pontos,
        150,
        reason: 'sem combo depois do tempo esgotado',
      );
      expect(rodada.acertos, 2);
    });

    test('não avança sem responder e só finaliza no fim', () {
      final rodada = nova(quantidade: 2);
      expect(rodada.avancar(), isFalse);
      expect(() => rodada.finalizar(jogadorId: 1), throwsStateError);
      rodada.esgotarTempo();
      expect(rodada.avancar(), isTrue);
      expect(rodada.numero, 2);
      rodada.responder('0', tempo: const Duration(seconds: 3));
      expect(rodada.terminou, isTrue);
      expect(rodada.avancar(), isFalse);
    });

    test('partida final é válida, completa e sempre a mesma', () {
      final rodada = nova(quantidade: 2);
      rodada.responder('${rodada.contaAtual.resultado}', tempo: Duration.zero);
      rodada.avancar();
      rodada.responder('999', tempo: const Duration(seconds: 15));
      final partida = rodada.finalizar(
        jogadorId: 1,
        agora: DateTime.utc(2026, 11, 25, 10, 1),
      )..validar();
      expect(identical(partida, rodada.finalizar(jogadorId: 1)), isTrue);
      expect(partida.modo, 'Conta Rápida');
      expect(partida.tempoPorQuestao, 10);
      expect(partida.operacoes, ['SOMA']);
      expect(partida.pontuacao, 150);
      expect(partida.acertos, 1);
      expect(partida.respostas.last.tempoGastoMs, 10000);
      expect(partida.respostas.first.topico, 'Soma');
    });
  });
}
