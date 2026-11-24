import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:turingclides/domain/games/quiz_logica/logica_question.dart';
import 'package:turingclides/presentation/quizzes/quiz_execution_screen.dart';

void main() {
  testWidgets('soma de 1 a 4 em tela estreita com avanço, retorno e saída', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final question = logicaQuestions.firstWhere(
      (q) =>
          q.codeSnippet!.contains('i <= 4') &&
          q.codeSnippet!.contains('soma += i;'),
    );
    await tester.pumpWidget(
      MaterialApp(home: QuizExecutionScreen(question: question)),
    );
    final previous = find.byKey(const Key('trace-previous'));
    final next = find.byKey(const Key('trace-next'));
    expect(tester.widget<OutlinedButton>(previous).onPressed, isNull);
    expect(find.text('Passo 1 de 6 · Inicialização'), findsOneWidget);
    var sum = 0;
    for (var i = 1; i <= 4; i++) {
      await tester.tap(next);
      await tester.pumpAndSettle();
      sum += i;
      expect(find.text('Linha 3 · i = $i · soma = $sum'), findsOneWidget);
      expect(find.textContaining('Fim da iteração $i'), findsOneWidget);
    }
    await tester.tap(next);
    await tester.pumpAndSettle();
    expect(
      find.text('Saída: ${question.options[question.correctOptionIndex]}'),
      findsOneWidget,
    );
    expect(tester.widget<FilledButton>(next).onPressed, isNull);
    expect(tester.widget<OutlinedButton>(previous).onPressed, isNotNull);
    await tester.tap(previous);
    await tester.pumpAndSettle();
    expect(find.text('Linha 3 · i = 4 · soma = 10'), findsOneWidget);
    expect(find.text('Saída: 10'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
