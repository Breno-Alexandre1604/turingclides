import '../quiz_compartilhado/quiz_question.dart';

const logicaQuestion = QuizQuestion(
  prompt: 'Qual valor será impresso por print(total)?',
  codeSnippet: '''var valor = 3;
var total = 0;
for (var i = 1; i <= 3; i++) {
  total += valor * i;
  valor--;
}
print(total);''',
  options: ['9', '10', '12', '6'],
  correctOptionIndex: 1,
  hint: 'A cada volta, some valor * i ao total e só depois diminua valor.',
  explanation:
      'O total acumula 3, depois 4 e por fim 3. Assim, 3 + 4 + 3 = 10.',
  traceSteps: [
    QuizTraceStep(
      iteration: 1,
      valueBefore: 3,
      valueAfter: 2,
      totalBefore: 0,
      totalAfter: 3,
    ),
    QuizTraceStep(
      iteration: 2,
      valueBefore: 2,
      valueAfter: 1,
      totalBefore: 3,
      totalAfter: 7,
    ),
    QuizTraceStep(
      iteration: 3,
      valueBefore: 1,
      valueAfter: 0,
      totalBefore: 7,
      totalAfter: 10,
    ),
  ],
);
