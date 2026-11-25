import 'package:flutter_test/flutter_test.dart';
import 'package:turingclides/domain/models/apelido.dart';
import 'package:turingclides/domain/models/partida.dart';
import 'package:turingclides/domain/models/progresso_topico.dart';
import 'package:turingclides/domain/models/quiz_result.dart';

void main() {
  group('Apelido', () {
    test('limpa espaços e aceita letras acentuadas, números e _ . -', () {
      expect(Apelido.normalizar('  João   da Silva '), 'João da Silva');
      expect(Apelido.normalizar('turing_2.0-b'), 'turing_2.0-b');
      expect(Apelido.normalizar('Éle'), 'Éle');
    });

    test('recusa vazio, curto, longo, símbolos e caracteres de controle', () {
      for (final invalido in [
        '',
        '   ',
        'A',
        'A' * 21,
        '<script>',
        "x' OR 1=1 --",
        'nome\u0000oculto',
        '_começa com símbolo',
      ]) {
        expect(Apelido.erro(invalido), isNotNull, reason: invalido);
        expect(
          () => Apelido.normalizar(invalido),
          throwsA(isA<ApelidoInvalido>()),
        );
      }
      expect(Apelido.erro('Ana'), isNull);
    });
  });

  group('Partida', () {
    final resultado = QuizResult(
      id: 'abc123',
      mode: 'Quiz de Matemática',
      difficulty: 'Fácil',
      finishedAt: DateTime.utc(2026, 11, 23),
      answers: const [
        QuizAnswerResult(
          topic: 'Porcentagem',
          prompt: '10% de 50',
          selected: '5',
          correct: '5',
          points: 140,
          elapsedMs: 3000,
          usedHint: false,
        ),
        QuizAnswerResult(
          topic: 'Frações',
          prompt: '1/2 + 1/4',
          selected: '2/6',
          correct: '3/4',
          points: 0,
          elapsedMs: 9000,
          usedHint: true,
        ),
      ],
    );

    test('converte o resultado do quiz e calcula pontos e acertos', () {
      final partida = Partida.deQuiz(resultado, jogadorId: 1)..validar();
      expect(partida.pontuacao, 140);
      expect(partida.acertos, 1);
      expect(partida.qtdQuestoes, 2);
      expect(partida.respostas.map((r) => r.ordem), [0, 1]);
      expect(partida.paraQuiz().toJson(), resultado.toJson());
      expect(
        Partida.fromJson(partida.toJson()).paraQuiz().toJson(),
        resultado.toJson(),
      );
    });

    test('recusa partida sem respostas ou com início depois do fim', () {
      expect(
        () => Partida(
          id: 'vazia',
          jogadorId: 1,
          modo: 'Quiz',
          dificuldade: 'Fácil',
          finalizadaEm: DateTime.utc(2026),
          respostas: const [],
        ).validar(),
        throwsA(isA<PartidaInvalida>()),
      );
      final partida = Partida.deQuiz(resultado, jogadorId: 1);
      expect(
        () => Partida(
          id: partida.id,
          jogadorId: 1,
          modo: partida.modo,
          dificuldade: partida.dificuldade,
          iniciadaEm: partida.finalizadaEm.add(const Duration(seconds: 1)),
          finalizadaEm: partida.finalizadaEm,
          respostas: partida.respostas,
        ).validar(),
        throwsA(isA<PartidaInvalida>()),
      );
    });
  });

  test('progresso por tópico soma respostas e guarda a última vez', () {
    final primeira = Partida.deQuiz(
      QuizResult(
        id: 'p1',
        mode: 'Quiz de Lógica',
        difficulty: 'Fácil',
        finishedAt: DateTime.utc(2026, 11, 20),
        answers: const [
          QuizAnswerResult(
            topic: 'Laços',
            prompt: 'a',
            selected: '1',
            correct: '1',
            points: 100,
            elapsedMs: 1,
            usedHint: false,
          ),
        ],
      ),
      jogadorId: 1,
    );
    final segunda = Partida(
      id: 'p2',
      jogadorId: 1,
      modo: 'Quiz de Lógica',
      dificuldade: 'Fácil',
      finalizadaEm: DateTime.utc(2026, 11, 22),
      respostas: const [
        RespostaPartida(
          ordem: 0,
          topico: 'Laços',
          enunciado: 'b',
          respostaDada: '2',
          respostaCorreta: '3',
          correta: false,
          tempoGastoMs: 1,
          pontos: 0,
        ),
      ],
    );
    final progresso = ProgressoTopico.calcular([segunda, primeira]).single;
    expect(progresso.totalRespondidas, 2);
    expect(progresso.totalAcertos, 1);
    expect(progresso.taxaDeAcerto, 0.5);
    expect(progresso.ultimaVez, DateTime.utc(2026, 11, 22));
    expect(ProgressoTopico.recordes([primeira, segunda]), {
      'Quiz de Lógica': 100,
    });
  });
}
