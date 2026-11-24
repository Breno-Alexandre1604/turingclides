import 'package:flutter_test/flutter_test.dart';
import 'package:turingclides/domain/games/quiz_compartilhado/quiz_question.dart';
import 'package:turingclides/domain/games/quiz_logica/logica_question.dart';
import 'package:turingclides/domain/games/quiz_matematica/matematica_question.dart';

void main() {
  test('os dois bancos oferecem quatro alternativas e todos os níveis', () {
    for (final bank in [matematicaQuestions, logicaQuestions]) {
      expect(bank, hasLength(10));
      expect(bank.map((q) => q.prompt).toSet(), hasLength(bank.length));
      for (final difficulty in QuizDifficulty.values) {
        expect(bank.where((q) => q.difficulty == difficulty), isNotEmpty);
      }
      for (final question in bank) {
        expect(question.options, hasLength(4), reason: question.prompt);
        expect(question.options.toSet(), hasLength(4), reason: question.prompt);
        expect(question.topic, isNotEmpty);
        expect(question.hint, isNotEmpty);
        expect(question.explanation, isNotEmpty);
      }
    }
  });

  test(
    'os resultados de matemática conferem com os cálculos de cada assunto',
    () {
      final expected = {
        'Porcentagem': r'R$ 68,00',
        'Frações': '3/4 de xícara',
        'Geometria': '${6 * 4} m²',
        'Média aritmética': '${(6 + 7 + 8) ~/ 3}',
        'Equações': '${(26 - 5) ~/ 3} km',
        'Probabilidade': '3/${3 + 2}',
        'Função afim': '${18 + 2 * 5} °C',
        'Porcentagens sucessivas': r'R$ 96,00',
        'Progressão aritmética': '${8 + 4 * 3}',
        'Análise combinatória': '${5 * 4 ~/ 2}',
      };
      for (final question in matematicaQuestions) {
        expect(
          question.options[question.correctOptionIndex],
          expected[question.topic],
          reason: question.prompt,
        );
      }
    },
  );

  test('cada execução aponta para linhas do trecho e imprime o gabarito', () {
    for (final question in logicaQuestions) {
      final code = question.codeSnippet!.split('\n');
      final steps = question.executionSteps;
      expect(steps, isNotEmpty);
      for (final step in steps) {
        expect(
          step.line,
          inInclusiveRange(1, code.length),
          reason: question.prompt,
        );
      }
      expect(code[steps.last.line - 1], contains('print('));
      expect(
        steps.last.output,
        question.options[question.correctOptionIndex],
        reason: question.prompt,
      );
    }
    expect(logicaQuestion.traceSteps.map((s) => s.totalAfter), [3, 7, 10]);
  });
}
