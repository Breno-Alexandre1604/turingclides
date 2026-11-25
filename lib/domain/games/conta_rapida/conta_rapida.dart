import 'dart:math';

import '../../models/partida.dart';
import '../quiz_compartilhado/quiz_question.dart';
import '../quiz_compartilhado/quiz_strategy.dart';

// Conta Rápida (frente de Eduardo, cartões C1 a C4), seguindo o guia UML:
// GeradorDeContas (fonte das perguntas), PontuacaoRapida (regra de pontos)
// e FeedbackRapido (explicação curta), coordenados por RodadaContaRapida.

/// Operações disponíveis (enumeração Operacao do diagrama 6B).
enum Operacao {
  soma('+', 'Soma'),
  subtracao('−', 'Subtração'),
  multiplicacao('×', 'Multiplicação'),
  divisao('÷', 'Divisão');

  const Operacao(this.simbolo, this.nome);

  final String simbolo;
  final String nome;

  /// Nome gravado no banco, igual ao do UML (SOMA, SUBTRACAO...).
  String get codigo => switch (this) {
    Operacao.soma => 'SOMA',
    Operacao.subtracao => 'SUBTRACAO',
    Operacao.multiplicacao => 'MULTIPLICACAO',
    Operacao.divisao => 'DIVISAO',
  };
}

/// Uma conta criada na hora. Cumpre só o contrato mínimo de pergunta:
/// enunciado, conferir a resposta e informar a resposta certa.
class ContaGerada {
  const ContaGerada(this.a, this.operacao, this.b);

  final int a;
  final Operacao operacao;
  final int b;

  int get resultado => switch (operacao) {
    Operacao.soma => a + b,
    Operacao.subtracao => a - b,
    Operacao.multiplicacao => a * b,
    Operacao.divisao => a ~/ b,
  };

  String get enunciado => '$a ${operacao.simbolo} $b';

  /// `true` só para um número inteiro igual ao resultado.
  bool confere(String entrada) => int.tryParse(entrada.trim()) == resultado;
}

/// Faixas numéricas por nível (cartão C1).
class FaixaDoNivel {
  const FaixaDoNivel({
    required this.somaMin,
    required this.somaMax,
    required this.fatorMin,
    required this.fatorMax,
  });

  /// Parcelas da soma e da subtração.
  final int somaMin;
  final int somaMax;

  /// Fatores da multiplicação e divisor/quociente da divisão.
  final int fatorMin;
  final int fatorMax;

  static FaixaDoNivel de(QuizDifficulty nivel) => switch (nivel) {
    QuizDifficulty.facil => const FaixaDoNivel(
      somaMin: 1,
      somaMax: 10,
      fatorMin: 1,
      fatorMax: 10,
    ),
    QuizDifficulty.medio => const FaixaDoNivel(
      somaMin: 10,
      somaMax: 99,
      fatorMin: 2,
      fatorMax: 15,
    ),
    QuizDifficulty.dificil => const FaixaDoNivel(
      somaMin: 100,
      somaMax: 999,
      fatorMin: 6,
      fatorMax: 30,
    ),
  };
}

/// Cria contas ao acaso respeitando operações e nível. Nunca gera
/// subtração negativa nem divisão por zero ou com resto.
class GeradorDeContas {
  GeradorDeContas({
    required List<Operacao> operacoes,
    required this.nivel,
    Random? random,
  }) : operacoes = List.unmodifiable(operacoes),
       _random = random ?? Random() {
    if (operacoes.isEmpty) {
      throw ArgumentError.value(operacoes, 'operacoes', 'escolha uma');
    }
  }

  final List<Operacao> operacoes;
  final QuizDifficulty nivel;
  final Random _random;
  ContaGerada? _anterior;

  int _entre(int min, int max) => min + _random.nextInt(max - min + 1);

  ContaGerada proxima() {
    final faixa = FaixaDoNivel.de(nivel);
    ContaGerada conta;
    var tentativas = 0;
    do {
      final operacao = operacoes[_random.nextInt(operacoes.length)];
      conta = switch (operacao) {
        Operacao.soma => ContaGerada(
          _entre(faixa.somaMin, faixa.somaMax),
          operacao,
          _entre(faixa.somaMin, faixa.somaMax),
        ),
        Operacao.subtracao => () {
          final x = _entre(faixa.somaMin, faixa.somaMax);
          final y = _entre(faixa.somaMin, faixa.somaMax);
          return ContaGerada(max(x, y), operacao, min(x, y));
        }(),
        Operacao.multiplicacao => ContaGerada(
          _entre(faixa.fatorMin, faixa.fatorMax),
          operacao,
          _entre(faixa.fatorMin, faixa.fatorMax),
        ),
        Operacao.divisao => () {
          final divisor = _entre(max(1, faixa.fatorMin), faixa.fatorMax);
          final quociente = _entre(faixa.fatorMin, faixa.fatorMax);
          return ContaGerada(divisor * quociente, operacao, divisor);
        }(),
      };
      tentativas++;
    } while (conta.enunciado == _anterior?.enunciado && tentativas < 5);
    return _anterior = conta;
  }
}

/// Pontos da Conta Rápida (tabela do guia UML, seção 5.4).
class PontuacaoRapida {
  const PontuacaoRapida();

  static const base = 100;
  static const bonusMaximo = 50;
  static const comboPorAcerto = 10;
  static const comboMaximo = 50;

  /// Bônus de tempo proporcional ao tempo que sobrou; combo de +10 por
  /// acerto seguido anterior, até +50. Erro ou tempo esgotado: zero.
  int pontos({
    required bool correta,
    required int sequenciaAnterior,
    required Duration tempo,
    required Duration limite,
  }) {
    if (!correta) return 0;
    final total = limite.inMilliseconds;
    final sobra = (total - tempo.inMilliseconds).clamp(0, total);
    final bonus = (bonusMaximo * sobra / total).round();
    final combo = (comboPorAcerto * sequenciaAnterior).clamp(0, comboMaximo);
    return base + bonus + combo;
  }
}

/// Uma resposta já processada.
class RespostaConta {
  const RespostaConta({
    required this.conta,
    required this.entrada,
    required this.correta,
    required this.tempo,
    required this.pontos,
    required this.tempoEsgotado,
  });

  final ContaGerada conta;
  final String entrada;
  final bool correta;
  final Duration tempo;
  final int pontos;
  final bool tempoEsgotado;
}

/// Explicação curta: não há tempo para ler na Conta Rápida.
abstract final class FeedbackRapido {
  static String titulo(RespostaConta r) => r.tempoEsgotado
      ? 'Tempo esgotado!'
      : r.correta
      ? 'Acertou!'
      : 'Errou.';

  static String detalhe(RespostaConta r) =>
      '${r.conta.enunciado} = ${r.conta.resultado}'
      '${r.correta ? '  (+${r.pontos} pontos)' : ''}';
}

/// Coordena uma partida de Conta Rápida. Cada conta é processada uma única
/// vez: o clique em "Responder" e o fim do tempo não contam em dobro.
class RodadaContaRapida {
  RodadaContaRapida({
    required this.nivel,
    required Set<Operacao> operacoes,
    required this.quantidade,
    Random? random,
    DateTime? inicio,
    this.regra = const PontuacaoRapida(),
  }) : operacoes = Operacao.values.where(operacoes.contains).toList(),
       iniciadaEm = (inicio ?? DateTime.now()).toUtc(),
       _random = random ?? Random() {
    if (quantidade < 1) throw ArgumentError.value(quantidade, 'quantidade');
    _gerador = GeradorDeContas(
      operacoes: this.operacoes,
      nivel: nivel,
      random: _random,
    );
    _atual = _gerador.proxima();
  }

  static const limite = Duration(seconds: 10);
  static const modo = 'Conta Rápida';

  final QuizDifficulty nivel;
  final List<Operacao> operacoes;
  final int quantidade;
  final DateTime iniciadaEm;
  final PontuacaoRapida regra;
  final Random _random;
  final String id = _novoId();
  late final GeradorDeContas _gerador;
  late ContaGerada _atual;
  final _respostas = <RespostaConta>[];
  int _sequencia = 0;
  Partida? _partida;

  ContaGerada get contaAtual => _atual;
  int get numero => _indice + 1;
  bool get respondida => _respostas.length == _indice + 1;
  bool get ultima => _indice == quantidade - 1;
  bool get terminou => ultima && respondida;
  int get pontos => _respostas.fold(0, (soma, r) => soma + r.pontos);
  int get acertos => _respostas.where((r) => r.correta).length;
  List<RespostaConta> get respostas => List.unmodifiable(_respostas);
  int _indice = 0;

  /// Processa a resposta digitada. Devolve `null` se a conta já tinha sido
  /// respondida (clique repetido ou depois do tempo esgotado).
  RespostaConta? responder(String entrada, {required Duration tempo}) {
    if (respondida) return null;
    final gasto = tempo > limite ? limite : tempo;
    final correta = _atual.confere(entrada);
    return _registrar(
      RespostaConta(
        conta: _atual,
        entrada: entrada.trim(),
        correta: correta,
        tempo: gasto,
        pontos: regra.pontos(
          correta: correta,
          sequenciaAnterior: _sequencia,
          tempo: gasto,
          limite: limite,
        ),
        tempoEsgotado: false,
      ),
    );
  }

  /// O cronômetro chegou a zero. Devolve `null` se já havia resposta.
  RespostaConta? esgotarTempo() {
    if (respondida) return null;
    return _registrar(
      RespostaConta(
        conta: _atual,
        entrada: '',
        correta: false,
        tempo: limite,
        pontos: 0,
        tempoEsgotado: true,
      ),
    );
  }

  RespostaConta _registrar(RespostaConta resposta) {
    _respostas.add(resposta);
    _sequencia = resposta.correta ? _sequencia + 1 : 0;
    return resposta;
  }

  /// Vai para a próxima conta. Só funciona depois de responder a atual.
  bool avancar() {
    if (!respondida || ultima) return false;
    _indice++;
    _atual = _gerador.proxima();
    return true;
  }

  /// Monta a partida para gravar. Repetir devolve sempre a mesma partida,
  /// com o mesmo id, para que tentar salvar de novo não duplique pontos.
  Partida finalizar({required int jogadorId, DateTime? agora}) {
    if (!terminou) {
      throw StateError('Responda todas as contas para encerrar a partida.');
    }
    return _partida ??= Partida(
      id: id,
      jogadorId: jogadorId,
      modo: modo,
      dificuldade: nivel.label,
      tempoPorQuestao: limite.inSeconds,
      operacoes: [for (final o in operacoes) o.codigo],
      iniciadaEm: iniciadaEm,
      finalizadaEm: (agora ?? DateTime.now()).toUtc(),
      respostas: [
        for (final (ordem, r) in _respostas.indexed)
          RespostaPartida(
            ordem: ordem,
            topico: r.conta.operacao.nome,
            enunciado: r.conta.enunciado,
            respostaDada: r.entrada,
            respostaCorreta: '${r.conta.resultado}',
            correta: r.correta,
            tempoGastoMs: r.tempo.inMilliseconds,
            pontos: r.pontos,
          ),
      ],
    );
  }

  static String _novoId() {
    final random = Random.secure();
    return List.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }
}
