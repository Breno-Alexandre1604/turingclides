import 'quiz_result.dart';

/// Partida recusada antes de chegar ao banco.
class PartidaInvalida implements Exception {
  const PartidaInvalida(this.motivo);

  final String motivo;

  @override
  String toString() => 'Partida inválida: $motivo';
}

/// Uma resposta dada dentro de uma partida (diagrama 6B).
///
/// Na Conta Rápida a conta é criada na hora, então [questaoId] fica vazio e o
/// texto da conta vai em [enunciado] (o "enunciadoGerado" do UML).
class RespostaPartida {
  const RespostaPartida({
    required this.ordem,
    required this.topico,
    required this.enunciado,
    required this.respostaDada,
    required this.respostaCorreta,
    required this.correta,
    required this.tempoGastoMs,
    required this.pontos,
    this.usouDica = false,
    this.questaoId,
  });

  final int ordem;
  final String topico;
  final String enunciado;
  final String respostaDada;
  final String respostaCorreta;
  final bool correta;
  final int tempoGastoMs;
  final int pontos;
  final bool usouDica;
  final String? questaoId;

  Map<String, Object?> toJson() => {
    'ordem': ordem,
    'topico': topico,
    'enunciado': enunciado,
    'respostaDada': respostaDada,
    'respostaCorreta': respostaCorreta,
    'correta': correta,
    'tempoGastoMs': tempoGastoMs,
    'pontos': pontos,
    'usouDica': usouDica,
    'questaoId': questaoId,
  };

  factory RespostaPartida.fromJson(Map<String, dynamic> json) =>
      RespostaPartida(
        ordem: json['ordem'] as int,
        topico: json['topico'] as String,
        enunciado: json['enunciado'] as String,
        respostaDada: json['respostaDada'] as String,
        respostaCorreta: json['respostaCorreta'] as String,
        correta: json['correta'] as bool,
        tempoGastoMs: json['tempoGastoMs'] as int,
        pontos: json['pontos'] as int,
        usouDica: json['usouDica'] as bool,
        questaoId: json['questaoId'] as String?,
      );
}

/// Uma rodada jogada (diagrama 6B). Pontuação, acertos e quantidade de
/// questões são calculados a partir das respostas, para nunca divergirem.
class Partida {
  Partida({
    required this.id,
    required this.jogadorId,
    required this.modo,
    required this.dificuldade,
    required this.finalizadaEm,
    required List<RespostaPartida> respostas,
    this.iniciadaEm,
    this.tempoPorQuestao,
    List<String> operacoes = const [],
  }) : respostas = List.unmodifiable(respostas),
       operacoes = List.unmodifiable(operacoes);

  /// Converte o resultado entregue pelo PartidaController dos quizzes.
  factory Partida.deQuiz(QuizResult resultado, {required int jogadorId}) =>
      Partida(
        id: resultado.id,
        jogadorId: jogadorId,
        modo: resultado.mode,
        dificuldade: resultado.difficulty,
        finalizadaEm: resultado.finishedAt.toUtc(),
        respostas: [
          for (final (ordem, resposta) in resultado.answers.indexed)
            RespostaPartida(
              ordem: ordem,
              topico: resposta.topic,
              enunciado: resposta.prompt,
              respostaDada: resposta.selected,
              respostaCorreta: resposta.correct,
              correta: resposta.isCorrect,
              tempoGastoMs: resposta.elapsedMs,
              pontos: resposta.points,
              usouDica: resposta.usedHint,
            ),
        ],
      );

  static const maxPontosPorResposta = 1000;
  static const maxTexto = 4000;
  static final _formatoId = RegExp(r'^[A-Za-z0-9_-]{1,64}$');

  /// Identificador gerado pelo controlador. É ele que impede gravar duas
  /// vezes a mesma partida.
  final String id;
  final int jogadorId;
  final String modo;
  final String dificuldade;
  final DateTime? iniciadaEm;
  final DateTime finalizadaEm;
  final int? tempoPorQuestao;
  final List<String> operacoes;
  final List<RespostaPartida> respostas;

  int get qtdQuestoes => respostas.length;
  int get pontuacao => respostas.fold(0, (soma, r) => soma + r.pontos);
  int get acertos => respostas.where((r) => r.correta).length;

  /// Regras de integridade conferidas antes de qualquer gravação.
  void validar() {
    void exigir(bool condicao, String motivo) {
      if (!condicao) throw PartidaInvalida(motivo);
    }

    bool textoValido(String texto, int limite) =>
        texto.trim().isNotEmpty && texto.length <= limite;

    exigir(_formatoId.hasMatch(id), 'identificador fora do formato');
    exigir(jogadorId > 0, 'jogador inexistente');
    exigir(textoValido(modo, 60), 'modo vazio ou longo demais');
    exigir(textoValido(dificuldade, 30), 'dificuldade vazia ou longa demais');
    exigir(respostas.isNotEmpty, 'partida sem respostas');
    exigir(
      iniciadaEm == null || !iniciadaEm!.isAfter(finalizadaEm),
      'início depois do fim',
    );
    exigir(
      tempoPorQuestao == null || tempoPorQuestao! > 0,
      'tempo por questão inválido',
    );
    for (final operacao in operacoes) {
      exigir(textoValido(operacao, 30), 'operação inválida');
    }
    for (final (indice, r) in respostas.indexed) {
      exigir(r.ordem == indice, 'ordem das respostas fora de sequência');
      exigir(textoValido(r.topico, 120), 'tópico vazio ou longo demais');
      exigir(textoValido(r.enunciado, maxTexto), 'enunciado inválido');
      exigir(r.respostaDada.length <= maxTexto, 'resposta longa demais');
      exigir(textoValido(r.respostaCorreta, maxTexto), 'gabarito inválido');
      exigir(r.tempoGastoMs >= 0, 'tempo negativo');
      exigir(
        r.pontos >= 0 && r.pontos <= maxPontosPorResposta,
        'pontos fora do limite',
      );
      exigir(r.correta || r.pontos == 0, 'resposta errada não pontua');
    }
  }

  /// Formato usado pelas telas dos quizzes de Breno.
  QuizResult paraQuiz() => QuizResult(
    id: id,
    mode: modo,
    difficulty: dificuldade,
    finishedAt: finalizadaEm,
    answers: [
      for (final r in respostas)
        QuizAnswerResult(
          topic: r.topico,
          prompt: r.enunciado,
          selected: r.respostaDada,
          correct: r.respostaCorreta,
          points: r.pontos,
          elapsedMs: r.tempoGastoMs,
          usedHint: r.usouDica,
        ),
    ],
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'jogadorId': jogadorId,
    'modo': modo,
    'dificuldade': dificuldade,
    'iniciadaEm': iniciadaEm?.toUtc().toIso8601String(),
    'finalizadaEm': finalizadaEm.toUtc().toIso8601String(),
    'tempoPorQuestao': tempoPorQuestao,
    'operacoes': operacoes,
    'respostas': [for (final r in respostas) r.toJson()],
  };

  factory Partida.fromJson(Map<String, dynamic> json) => Partida(
    id: json['id'] as String,
    jogadorId: json['jogadorId'] as int,
    modo: json['modo'] as String,
    dificuldade: json['dificuldade'] as String,
    iniciadaEm: switch (json['iniciadaEm']) {
      final String texto => DateTime.parse(texto),
      _ => null,
    },
    finalizadaEm: DateTime.parse(json['finalizadaEm'] as String),
    tempoPorQuestao: json['tempoPorQuestao'] as int?,
    operacoes: [
      for (final operacao in json['operacoes'] as List<dynamic>)
        operacao as String,
    ],
    respostas: [
      for (final r in json['respostas'] as List<dynamic>)
        RespostaPartida.fromJson(r as Map<String, dynamic>),
    ],
  );
}
