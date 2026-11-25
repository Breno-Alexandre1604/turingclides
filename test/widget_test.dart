import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:turingclides/data/dados_locais.dart';
import 'package:turingclides/domain/games/quiz_compartilhado/quiz_question.dart';
import 'package:turingclides/domain/games/quiz_compartilhado/quiz_strategy.dart';
import 'package:turingclides/domain/games/quiz_logica/logica_question.dart';
import 'package:turingclides/domain/games/quiz_matematica/matematica_question.dart';
import 'package:turingclides/domain/models/quiz_result.dart';
import 'package:turingclides/main.dart';

// Dados em memória (cartão D2) que também registram cada resultado recebido.
class _TestHistory extends DadosLocais {
  _TestHistory() : super.emMemoria();

  final results = <QuizResult>[];

  @override
  Future<void> save(QuizResult result) async {
    results.add(result);
    await super.save(result);
  }
}

Future<void> reveal(
  WidgetTester tester,
  Finder finder, {
  bool scrollUp = false,
}) async {
  if (finder.evaluate().isEmpty) {
    final scrollable = find
        .descendant(
          of: find.byKey(const Key('quiz-scroll-view')),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      finder,
      scrollUp ? -220 : 220,
      scrollable: scrollable,
    );
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

Future<void> tapVisible(
  WidgetTester tester,
  Finder finder, {
  bool scrollUp = false,
}) async {
  await reveal(tester, finder, scrollUp: scrollUp);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<_TestHistory> _openConfiguration(
  WidgetTester tester,
  String modeKey,
) async {
  final history = _TestHistory();
  await tester.pumpWidget(TuringclidesApp(dados: history));
  await tapVisible(tester, find.byKey(Key(modeKey)));
  expect(find.text('Configurar atividade'), findsOneWidget);
  return history;
}

Future<void> answer(WidgetTester tester, int index) async {
  await tapVisible(tester, find.byKey(Key('option-$index')));
  await tapVisible(tester, find.byKey(const Key('confirm-answer')));
}

void main() {
  testWidgets('matemática mostra a dica e mantém a resposta confirmada', (
    tester,
  ) async {
    final history = await _openConfiguration(tester, 'quiz-mode-math');
    await tapVisible(tester, find.text('Começar'));
    expect(find.textContaining('desconto de 15%'), findsOneWidget);
    expect(matematicaQuestion.options, hasLength(4));
    await tapVisible(tester, find.byKey(const Key('show-hint')));
    expect(find.textContaining('Calcule 10% e 5%'), findsOneWidget);
    await answer(tester, 0);
    expect(find.text('Resposta correta!'), findsOneWidget);
    final selected = find.textContaining('Resposta selecionada: R\$ 68,00');
    expect(selected, findsOneWidget);

    await tapVisible(tester, find.byKey(const Key('option-1')), scrollUp: true);
    await reveal(tester, selected);
    expect(find.text('Resposta correta!'), findsOneWidget);
    expect(selected, findsOneWidget);

    await tapVisible(tester, find.byKey(const Key('finish-quiz')));
    expect(find.text('Atividade concluída!'), findsOneWidget);
    expect(history.results, hasLength(1));
    await tapVisible(tester, find.byKey(const Key('result-home')));
    expect(find.text('Aprenda jogando!'), findsOneWidget);
    await tapVisible(tester, find.text('Ver histórico'));
    expect(find.textContaining('1/1 acertos'), findsOneWidget);
  });

  testWidgets(
    'lógica libera o rastreio depois da confirmação e preserva a resposta',
    (tester) async {
      final history = await _openConfiguration(tester, 'quiz-mode-logic');
      await tapVisible(tester, find.text('Começar'));
      expect(find.byKey(const Key('logic-code')), findsOneWidget);
      expect(logicaQuestion.options, hasLength(4));
      expect(find.byKey(const Key('view-execution')), findsNothing);
      await answer(tester, 1);
      expect(find.text('Resposta correta!'), findsOneWidget);
      final selected = find.textContaining('Resposta selecionada: 10');
      expect(selected, findsOneWidget);

      final pointLabel = find.byKey(const Key('round-points'));
      await reveal(tester, pointLabel, scrollUp: true);
      final points = tester.widget<Text>(pointLabel).data;
      final viewExecution = find.byKey(const Key('view-execution'));
      await tapVisible(tester, viewExecution);
      expect(find.text('Teste de mesa'), findsOneWidget);
      expect(find.textContaining('total 0 → 3'), findsOneWidget);
      final next = find.byKey(const Key('trace-next'));
      await tapVisible(tester, next);
      await tapVisible(tester, next);
      expect(find.textContaining('total 7 → 10'), findsOneWidget);
      await tapVisible(tester, next);
      expect(find.textContaining('Saída: 10'), findsOneWidget);
      await tapVisible(tester, find.byKey(const Key('trace-previous')));
      expect(find.textContaining('total 7 → 10'), findsOneWidget);
      await tester.tap(
        find.byType(BackButton),
      ); // o app está em pt-BR: o rótulo é "Voltar"
      await tester.pumpAndSettle();
      await tapVisible(tester, viewExecution);
      expect(find.textContaining('total 0 → 3'), findsOneWidget);
      await tester.tap(
        find.byType(BackButton),
      ); // o app está em pt-BR: o rótulo é "Voltar"
      await tester.pumpAndSettle();

      await tapVisible(
        tester,
        find.byKey(const Key('option-0')),
        scrollUp: true,
      );
      await reveal(tester, selected);
      expect(find.text('Resposta correta!'), findsOneWidget);
      expect(selected, findsOneWidget);
      await tapVisible(tester, find.byKey(const Key('finish-quiz')));
      expect(history.results, hasLength(1));
      expect('${history.results.single.points} pontos', points);
    },
  );

  testWidgets(
    'o nível e a quantidade escolhidos determinam as perguntas da rodada',
    (tester) async {
      final history = await _openConfiguration(tester, 'quiz-mode-math');
      await tapVisible(tester, find.byKey(const Key('quiz-difficulty')));
      await tapVisible(tester, find.text('Médio').last);
      await tapVisible(
        tester,
        find.byKey(const ValueKey(QuizDifficulty.medio)),
      );
      await tapVisible(tester, find.text('2 perguntas').last);
      await tapVisible(tester, find.text('Começar'));

      final bank = matematicaStrategy.questions(QuizDifficulty.medio);
      for (var i = 0; i < 2; i++) {
        final question = bank[i];
        expect(find.text(question.prompt), findsOneWidget);
        expect(find.text('Questão ${i + 1} de 2 · Médio'), findsOneWidget);
        await answer(tester, question.correctOptionIndex);
        await tapVisible(
          tester,
          find.byKey(Key(i == 0 ? 'next-question' : 'finish-quiz')),
        );
      }
      expect(find.text('Atividade concluída!'), findsOneWidget);
      expect(history.results, hasLength(1));
    },
  );
}
