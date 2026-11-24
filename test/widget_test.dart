import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turingclides/domain/games/quiz_logica/logica_question.dart';
import 'package:turingclides/domain/games/quiz_matematica/matematica_question.dart';
import 'package:turingclides/main.dart';

void main() {
  testWidgets(
    'mathematics quiz locks the confirmed answer and shows its explanation',
    (WidgetTester tester) async {
      await tester.pumpWidget(const TuringclidesApp());

      await tester.tap(find.byKey(const Key('quiz-mode-math')));
      await tester.pumpAndSettle();
      expect(find.textContaining('desconto de 15%'), findsOneWidget);
      expect(matematicaQuestion.options, hasLength(4));
      await tester.tap(find.byKey(const Key('show-hint')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Calcule 10% e 5%'), findsOneWidget);

      final correctOption = find.byKey(const Key('option-0'));
      await tester.ensureVisible(correctOption);
      await tester.pumpAndSettle();
      await tester.tap(correctOption);
      final confirmButton = find.byKey(const Key('confirm-answer'));
      await tester.ensureVisible(confirmButton);
      await tester.pumpAndSettle();
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      expect(find.text('Resposta correta!'), findsOneWidget);
      expect(
        find.textContaining('Resposta selecionada: R\$ 68,00'),
        findsOneWidget,
      );

      final alternateOption = find.byKey(const Key('option-1'));
      await tester.ensureVisible(alternateOption);
      await tester.pumpAndSettle();
      await tester.tap(alternateOption);
      await tester.pumpAndSettle();

      expect(find.text('Resposta correta!'), findsOneWidget);
      expect(
        find.textContaining('Resposta selecionada: R\$ 68,00'),
        findsOneWidget,
      );

      final finishButton = find.byKey(const Key('finish-quiz'));
      await tester.ensureVisible(finishButton);
      await tester.pumpAndSettle();
      await tester.tap(finishButton);
      await tester.pumpAndSettle();
      expect(find.text('Escolha seu quiz'), findsOneWidget);
    },
  );

  testWidgets('logic quiz shows a table trace and locks the confirmed answer', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TuringclidesApp());

    await tester.tap(find.byKey(const Key('quiz-mode-logic')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('logic-code')), findsOneWidget);
    expect(find.byKey(const Key('logic-trace')), findsOneWidget);
    expect(find.textContaining('total 7 → 10'), findsOneWidget);
    expect(logicaQuestion.options, hasLength(4));

    final quizScrollable = find
        .descendant(
          of: find.byKey(const Key('quiz-scroll-view')),
          matching: find.byType(Scrollable),
        )
        .first;
    final correctOption = find.byKey(const Key('option-1'));
    await tester.scrollUntilVisible(
      correctOption,
      250,
      scrollable: quizScrollable,
    );
    await tester.ensureVisible(correctOption);
    await tester.pumpAndSettle();
    await tester.tap(correctOption);
    final confirmButton = find.byKey(const Key('confirm-answer'));
    await tester.ensureVisible(confirmButton);
    await tester.pumpAndSettle();
    await tester.tap(confirmButton);
    await tester.pumpAndSettle();

    expect(find.text('Resposta correta!'), findsOneWidget);
    expect(find.textContaining('Resposta selecionada: 10'), findsOneWidget);

    final alternateOption = find.byKey(const Key('option-0'));
    await tester.drag(quizScrollable, const Offset(0, 700));
    await tester.pumpAndSettle();
    await tester.ensureVisible(alternateOption);
    await tester.pumpAndSettle();
    await tester.tap(alternateOption);
    await tester.pumpAndSettle();

    expect(find.text('Resposta correta!'), findsOneWidget);
    expect(find.textContaining('Resposta selecionada: 10'), findsOneWidget);
  });
}
