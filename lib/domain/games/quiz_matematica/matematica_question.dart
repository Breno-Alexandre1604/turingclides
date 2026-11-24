import '../quiz_compartilhado/quiz_question.dart';

const matematicaQuestion = QuizQuestion(
  prompt:
      'Uma camiseta custa R\$ 80,00 e recebe um desconto de 15%. Qual é o preço final?',
  options: ['R\$ 68,00', 'R\$ 72,00', 'R\$ 65,00', 'R\$ 92,00'],
  correctOptionIndex: 0,
  hint: 'Calcule 10% e 5% de R\$ 80,00 separadamente e some os descontos.',
  explanation:
      '10% de R\$ 80,00 são R\$ 8,00 e 5% são R\$ 4,00. O desconto total é '
      'R\$ 12,00; então R\$ 80,00 - R\$ 12,00 = R\$ 68,00.',
);
