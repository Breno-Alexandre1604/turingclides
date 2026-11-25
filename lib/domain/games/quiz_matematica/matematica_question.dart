import '../quiz_compartilhado/quiz_question.dart';

const matematicaQuestion = QuizQuestion(
  topic: 'Porcentagem',
  prompt: 'Uma camiseta custa R\$ 80,00 e recebe um desconto de 15%. Qual é o preço final?',
  options: ['R\$ 68,00', 'R\$ 72,00', 'R\$ 65,00', 'R\$ 92,00'],
  correctOptionIndex: 0,
  hint: 'Calcule 10% e 5% de R\$ 80,00 separadamente e some os descontos.',
  explanation:
      '10% de R\$ 80,00 são R\$ 8,00 e 5% são R\$ 4,00. O desconto total é '
      'R\$ 12,00; então R\$ 80,00 - R\$ 12,00 = R\$ 68,00.',
);

const matematicaQuestions = [
  matematicaQuestion,
  QuizQuestion(
    topic: 'Frações',
    difficulty: QuizDifficulty.facil,
    prompt: 'Para uma receita, Ana usa 1/2 xícara de leite e depois mais 1/4 de xícara. Quanto leite ela usa ao todo?',
    options: ['1/6 de xícara', '2/6 de xícara', '3/4 de xícara', '1 xícara'],
    correctOptionIndex: 2,
    hint: 'Escreva meio como uma fração de denominador 4.',
    explanation:
        'Meia xícara equivale a 2/4. Ao somar 2/4 e 1/4, temos 3/4 de xícara.',
  ),
  QuizQuestion(
    topic: 'Geometria',
    difficulty: QuizDifficulty.facil,
    prompt:
        'Um canteiro retangular mede 6 m por 4 m. Qual é a área do canteiro?',
    options: ['10 m²', '20 m²', '24 m²', '36 m²'],
    correctOptionIndex: 2,
    hint: 'A área conta quantos quadrados de 1 m por 1 m cabem na superfície.',
    explanation: 'Cabem 6 quadrados em cada fileira e há 4 fileiras. A área é 6 × 4 = 24 m².',
  ),
  QuizQuestion(
    topic: 'Média aritmética',
    difficulty: QuizDifficulty.facil,
    prompt: 'Lia tirou notas 6, 7 e 8 em três provas de mesmo peso. Qual é a média aritmética?',
    options: ['6,5', '7', '7,5', '21'],
    correctOptionIndex: 1,
    hint: 'Some as notas e divida o total pela quantidade de provas.',
    explanation: 'A soma das notas é 6 + 7 + 8 = 21. Dividindo por 3 provas, a média é 7.',
  ),
  QuizQuestion(
    topic: 'Equações',
    difficulty: QuizDifficulty.medio,
    prompt: 'Uma corrida tem taxa fixa de R\$ 5,00 mais R\$ 3,00 por quilômetro. Se custou R\$ 26,00, quantos quilômetros foram percorridos?',
    options: ['6 km', '8 km', '7 km', '9 km'],
    correctOptionIndex: 2,
    hint: 'Separe a taxa fixa da parte que depende da distância.',
    explanation: 'Tirando a taxa fixa, restam R\$ 26,00 − R\$ 5,00 = R\$ 21,00. A R\$ 3,00 por quilômetro, a distância foi 21 ÷ 3 = 7 km.',
  ),
  QuizQuestion(
    topic: 'Probabilidade',
    difficulty: QuizDifficulty.medio,
    prompt: 'Uma sacola tem 3 bolinhas azuis e 2 vermelhas. Se cada bolinha tem a mesma chance de ser sorteada, qual é a probabilidade de retirar uma azul?',
    options: ['2/3', '3/2', '2/5', '3/5'],
    correctOptionIndex: 3,
    hint: 'Compare o número de bolinhas azuis com o total na sacola.',
    explanation: 'Há 3 + 2 = 5 bolinhas ao todo. Como 3 das 5 são azuis, a probabilidade é 3/5.',
  ),
  QuizQuestion(
    topic: 'Função afim',
    difficulty: QuizDifficulty.medio,
    prompt: 'A temperatura de uma amostra segue T(h) = 18 + 2h, em °C, após h horas. Qual é T(5)?',
    options: ['20 °C', '25 °C', '28 °C', '100 °C'],
    correctOptionIndex: 2,
    hint: 'Substitua h por 5 e calcule a multiplicação primeiro.',
    explanation: 'Em 5 horas o acréscimo é 2 × 5 = 10 °C. Somando à temperatura inicial de 18 °C, obtemos 28 °C.',
  ),
  QuizQuestion(
    topic: 'Porcentagens sucessivas',
    difficulty: QuizDifficulty.dificil,
    prompt: 'Um livro de R\$ 100,00 recebe um desconto de 20% e, depois, um aumento de 20% sobre o preço com desconto. Qual é o novo preço?',
    options: ['R\$ 96,00', 'R\$ 100,00', 'R\$ 80,00', 'R\$ 104,00'],
    correctOptionIndex: 0,
    hint: 'Calcule o novo preço antes de aplicar o segundo percentual.',
    explanation: 'O desconto reduz o preço para R\$ 80,00. O aumento é 20% de R\$ 80,00, ou R\$ 16,00. O novo preço é R\$ 96,00.',
  ),
  QuizQuestion(
    topic: 'Progressão aritmética',
    difficulty: QuizDifficulty.dificil,
    prompt: 'A primeira fileira de um auditório tem 8 lugares e cada fileira seguinte tem 3 a mais. Quantos lugares há na quinta fileira?',
    options: ['15', '20', '23', '70'],
    correctOptionIndex: 1,
    hint: 'Conte quantos aumentos ocorrem da primeira até a quinta fileira.',
    explanation: 'Da primeira à quinta fileira há 4 aumentos. Acrescentamos 4 × 3 = 12 lugares aos 8 iniciais e chegamos a 20.',
  ),
  QuizQuestion(
    topic: 'Análise combinatória',
    difficulty: QuizDifficulty.dificil,
    prompt: 'Uma turma tem 5 representantes. De quantas maneiras é possível escolher uma dupla entre eles, sem distinguir a ordem?',
    options: ['5', '20', '25', '10'],
    correctOptionIndex: 3,
    hint: 'Ao escolher uma pessoa e depois a outra, cada dupla aparece em duas ordens.',
    explanation: 'Há 5 escolhas para a primeira pessoa e 4 para a segunda, totalizando 20 pares ordenados. Cada dupla é contada duas vezes, então há 20 ÷ 2 = 10 duplas.',
  ),
];
