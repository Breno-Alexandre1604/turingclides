import '../quiz_compartilhado/quiz_question.dart';

const _produtoTrace = [
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
];

final logicaQuestion = QuizQuestion(
  topic: 'Laços de repetição',
  prompt: 'Qual valor será impresso por print(total)?',
  codeSnippet: '''var valor = 3;
var total = 0;
for (var i = 1; i <= 3; i++) {
  total += valor * i;
  valor--;
}
print(total);''',
  options: const ['9', '10', '12', '6'],
  correctOptionIndex: 1,
  hint: 'A cada volta, some valor * i ao total e só depois diminua valor.',
  explanation:
      'O total acumula 3, depois 4 e por fim 3. Assim, 3 + 4 + 3 = 10.',
  traceSteps: _produtoTrace,
  executionSteps: List.unmodifiable([
    for (final step in _produtoTrace)
      QuizExecutionStep(
        line: 5,
        stage: 'Fim da iteração ${step.iteration}',
        variables:
            'i = ${step.iteration} · valor = ${step.valueAfter} · total = ${step.totalAfter}',
        explanation:
            'Somamos ${step.valueBefore} × ${step.iteration} ao acumulador: '
            'total ${step.totalBefore} → ${step.totalAfter}. Depois valor diminui para ${step.valueAfter}.',
      ),
    const QuizExecutionStep(
      line: 7,
      stage: 'Saída do programa',
      variables: 'valor = 0 · total = 10',
      explanation: 'O laço terminou após as três parcelas, 3 + 4 + 3. O print exibe o total 10.',
      output: '10',
    ),
  ]),
);

final logicaQuestions = List<QuizQuestion>.unmodifiable([
  logicaQuestion,
  ...const [
    QuizQuestion(
      topic: 'Laços de repetição',
      difficulty: QuizDifficulty.facil,
      prompt: 'Qual é a saída depois de somar os números de 1 a 4?',
      codeSnippet: '''var soma = 0;
for (var i = 1; i <= 4; i++) {
  soma += i;
}
print(soma);''',
      options: ['4', '6', '10', '15'],
      correctOptionIndex: 2,
      hint:
          'O sinal <= inclui o número 4. Anote a soma ao fim de cada passagem.',
      explanation: 'A soma começa em 0. Adicionando 1, 2, 3 e 4, ela passa por 1, 3, 6 e 10. O print mostra 10.',
      executionSteps: [
        QuizExecutionStep(
          line: 1,
          stage: 'Inicialização',
          variables: 'soma = 0',
          explanation: 'Antes do laço, a soma vale zero.',
        ),
        QuizExecutionStep(
          line: 3,
          stage: 'Fim da iteração 1',
          variables: 'i = 1 · soma = 1',
          explanation: 'Somamos 1 ao zero inicial e obtemos 1.',
        ),
        QuizExecutionStep(
          line: 3,
          stage: 'Fim da iteração 2',
          variables: 'i = 2 · soma = 3',
          explanation: 'A soma anterior era 1. Agora 1 + 2 = 3.',
        ),
        QuizExecutionStep(
          line: 3,
          stage: 'Fim da iteração 3',
          variables: 'i = 3 · soma = 6',
          explanation: 'Somamos 3 ao total anterior e obtemos 6.',
        ),
        QuizExecutionStep(
          line: 3,
          stage: 'Fim da iteração 4',
          variables: 'i = 4 · soma = 10',
          explanation: 'O limite inclui 4. A última soma é 6 + 4 = 10.',
        ),
        QuizExecutionStep(
          line: 5,
          stage: 'Saída do programa',
          variables: 'soma = 10',
          explanation: 'As quatro parcelas já foram somadas. O print exibe o total final, 10.',
          output: '10',
        ),
      ],
    ),
    QuizQuestion(
      topic: 'Condicionais',
      difficulty: QuizDifficulty.facil,
      prompt: 'Qual mensagem aparece para uma nota igual a 7?',
      codeSnippet: '''var nota = 7;
if (nota >= 7) {
  print('Aprovado');
} else {
  print('Revisar');
}''',
      options: ['Revisar', 'Aprovado', '7', 'true'],
      correctOptionIndex: 1,
      hint: 'O operador >= também aceita a igualdade.',
      explanation: 'A expressão 7 >= 7 é verdadeira. O primeiro bloco executa e imprime Aprovado.',
      executionSteps: [
        QuizExecutionStep(
          line: 1,
          stage: 'Atribuição',
          variables: 'nota = 7',
          explanation: 'A variável recebe a nota 7.',
        ),
        QuizExecutionStep(
          line: 2,
          stage: 'Teste da condição',
          variables: 'nota = 7',
          explanation: 'Como 7 é igual ao limite, a condição >= é verdadeira.',
        ),
        QuizExecutionStep(
          line: 3,
          stage: 'Saída do programa',
          variables: 'nota = 7',
          explanation:
              'O ramo verdadeiro executa seu print e o bloco else é pulado.',
          output: 'Aprovado',
        ),
      ],
    ),
    QuizQuestion(
      topic: 'Saída de texto',
      difficulty: QuizDifficulty.facil,
      prompt: 'Qual texto será impresso ao juntar os dois valores?',
      codeSnippet: r'''var turma = 'B';
var sala = 2;
print('$turma-$sala');''',
      options: ['B2', 'turma-sala', '2-B', 'B-2'],
      correctOptionIndex: 3,
      hint: 'O Dart insere o valor de cada variável no lugar do \$ seguido do seu nome.',
      explanation: 'A primeira variável contém B e a segunda contém 2. O hífen permanece entre os valores, produzindo B-2.',
      executionSteps: [
        QuizExecutionStep(
          line: 1,
          stage: 'Primeira atribuição',
          variables: 'turma = B',
          explanation: 'A letra B fica guardada em turma.',
        ),
        QuizExecutionStep(
          line: 2,
          stage: 'Segunda atribuição',
          variables: 'turma = B · sala = 2',
          explanation: 'A variável sala recebe o número 2.',
        ),
        QuizExecutionStep(
          line: 3,
          stage: 'Saída do programa',
          variables: 'turma = B · sala = 2',
          explanation:
              'A interpolação monta B-2, com o hífen presente no texto.',
          output: 'B-2',
        ),
      ],
    ),
    QuizQuestion(
      topic: 'Laço while',
      difficulty: QuizDifficulty.medio,
      prompt: 'Qual é o valor de n ao terminar o while?',
      codeSnippet: '''var n = 2;
while (n < 10) {
  n *= 2;
}
print(n);''',
      options: ['8', '10', '16', '32'],
      correctOptionIndex: 2,
      hint: 'O teste acontece antes de cada multiplicação.',
      explanation: 'O laço dobra 2 para 4, depois 4 para 8 e 8 para 16. Como 16 < 10 é falso, imprime 16.',
      executionSteps: [
        QuizExecutionStep(
          line: 1,
          stage: 'Inicialização',
          variables: 'n = 2',
          explanation: 'O valor inicial é 2.',
        ),
        QuizExecutionStep(
          line: 3,
          stage: 'Fim da iteração 1',
          variables: 'n = 4',
          explanation: '2 é menor que 10, então dobramos 2.',
        ),
        QuizExecutionStep(
          line: 3,
          stage: 'Fim da iteração 2',
          variables: 'n = 8',
          explanation: '4 ainda é menor que 10, então dobramos 4.',
        ),
        QuizExecutionStep(
          line: 3,
          stage: 'Fim da iteração 3',
          variables: 'n = 16',
          explanation: '8 ainda é menor que 10. O último dobro leva a 16.',
        ),
        QuizExecutionStep(
          line: 5,
          stage: 'Saída do programa',
          variables: 'n = 16',
          explanation:
              'O teste com 16 é falso. O print usa o último valor calculado.',
          output: '16',
        ),
      ],
    ),
    QuizQuestion(
      topic: 'Resto da divisão',
      difficulty: QuizDifficulty.medio,
      prompt: 'Quantos números são contados pelo programa?',
      codeSnippet: '''var contagem = 0;
for (var i = 1; i <= 4; i++) {
  if (i % 2 == 0) {
    contagem++;
  }
}
print(contagem);''',
      options: ['2', '3', '4', '6'],
      correctOptionIndex: 0,
      hint: 'O resto da divisão por 2 é zero apenas nos números pares.',
      explanation: 'O laço visita 1, 2, 3 e 4. A condição é verdadeira para 2 e 4, aumentando a contagem duas vezes.',
      executionSteps: [
        QuizExecutionStep(
          line: 3,
          stage: 'Iteração 1',
          variables: 'i = 1 · contagem = 0',
          explanation:
              'O resto de 1 por 2 é 1, então o contador permanece em zero.',
        ),
        QuizExecutionStep(
          line: 4,
          stage: 'Iteração 2',
          variables: 'i = 2 · contagem = 1',
          explanation: 'O resto é zero e o contador aumenta para 1.',
        ),
        QuizExecutionStep(
          line: 3,
          stage: 'Iteração 3',
          variables: 'i = 3 · contagem = 1',
          explanation: 'Como 3 é ímpar, o contador continua em 1.',
        ),
        QuizExecutionStep(
          line: 4,
          stage: 'Iteração 4',
          variables: 'i = 4 · contagem = 2',
          explanation: '4 é par e o contador aumenta para 2.',
        ),
        QuizExecutionStep(
          line: 7,
          stage: 'Saída do programa',
          variables: 'contagem = 2',
          explanation:
              'Houve dois valores pares no intervalo. O print exibe 2.',
          output: '2',
        ),
      ],
    ),
    QuizQuestion(
      topic: 'Condicionais encadeadas',
      difficulty: QuizDifficulty.medio,
      prompt: 'Qual faixa o programa imprime para x igual a 10?',
      codeSnippet: '''var x = 10;
if (x < 5) {
  print('A');
} else if (x < 10) {
  print('B');
} else {
  print('C');
}''',
      options: ['A', 'B', 'C', '10'],
      correctOptionIndex: 2,
      hint: 'Observe se os limites usam < ou <=.',
      explanation: '10 < 5 é falso e 10 < 10 também é falso. Só o último ramo executa, imprimindo C.',
      executionSteps: [
        QuizExecutionStep(
          line: 2,
          stage: 'Primeiro teste',
          variables: 'x = 10',
          explanation: '10 é maior que 5. O primeiro ramo é pulado.',
        ),
        QuizExecutionStep(
          line: 4,
          stage: 'Segundo teste',
          variables: 'x = 10',
          explanation:
              '10 é igual ao limite e o teste exige um valor menor que 10.',
        ),
        QuizExecutionStep(
          line: 7,
          stage: 'Saída do programa',
          variables: 'x = 10',
          explanation: 'Os dois testes falharam. O ramo else imprime C.',
          output: 'C',
        ),
      ],
    ),
    QuizQuestion(
      topic: 'Laços aninhados',
      difficulty: QuizDifficulty.dificil,
      prompt: 'Quantas vezes o contador é incrementado?',
      codeSnippet: '''var total = 0;
for (var i = 1; i <= 3; i++) {
  for (var j = 1; j <= i; j++) {
    total++;
  }
}
print(total);''',
      options: ['3', '6', '9', '12'],
      correctOptionIndex: 1,
      hint: 'Para cada i, conte quantos valores de j satisfazem j <= i.',
      explanation: 'Quando i vale 1, 2 e 3, o laço interno soma 1, 2 e 3 unidades. O total é 1 + 2 + 3 = 6.',
      executionSteps: [
        QuizExecutionStep(
          line: 4,
          stage: 'Última soma para i = 1',
          variables: 'i = 1 · j = 1 · total = 1',
          explanation: 'O primeiro laço interno acrescentou uma unidade.',
        ),
        QuizExecutionStep(
          line: 4,
          stage: 'Última soma para i = 2',
          variables: 'i = 2 · j = 2 · total = 3',
          explanation:
              'O segundo laço interno acrescentou duas unidades ao 1 anterior.',
        ),
        QuizExecutionStep(
          line: 4,
          stage: 'Última soma para i = 3',
          variables: 'i = 3 · j = 3 · total = 6',
          explanation: 'O terceiro acrescentou três unidades. O total passou de 3 para 6.',
        ),
        QuizExecutionStep(
          line: 7,
          stage: 'Saída do programa',
          variables: 'total = 6',
          explanation: 'Os dois laços terminaram. O print exibe as seis unidades acumuladas.',
          output: '6',
        ),
      ],
    ),
    QuizQuestion(
      topic: 'Interrupção do laço',
      difficulty: QuizDifficulty.dificil,
      prompt: 'Qual soma o programa imprime ao usar break?',
      codeSnippet: '''var soma = 0;
for (var i = 1; i <= 5; i++) {
  if (i == 4) break;
  soma += i;
}
print(soma);''',
      options: ['10', '15', '4', '6'],
      correctOptionIndex: 3,
      hint: 'Verifique se a interrupção acontece antes ou depois da soma.',
      explanation: 'As três primeiras passagens somam 1 + 2 + 3 = 6. Quando i vale 4, o break encerra o laço antes da soma.',
      executionSteps: [
        QuizExecutionStep(
          line: 4,
          stage: 'Fim da iteração 1',
          variables: 'i = 1 · soma = 1',
          explanation: '1 é somado ao zero inicial.',
        ),
        QuizExecutionStep(
          line: 4,
          stage: 'Fim da iteração 2',
          variables: 'i = 2 · soma = 3',
          explanation: 'A segunda soma dá 1 + 2 = 3.',
        ),
        QuizExecutionStep(
          line: 4,
          stage: 'Fim da iteração 3',
          variables: 'i = 3 · soma = 6',
          explanation: 'A terceira soma dá 3 + 3 = 6.',
        ),
        QuizExecutionStep(
          line: 3,
          stage: 'Interrupção',
          variables: 'i = 4 · soma = 6',
          explanation: 'O break é executado antes de acrescentar 4.',
        ),
        QuizExecutionStep(
          line: 6,
          stage: 'Saída do programa',
          variables: 'soma = 6',
          explanation: 'A soma ficou em 6 quando o laço foi interrompido. Esse é o valor impresso.',
          output: '6',
        ),
      ],
    ),
    QuizQuestion(
      topic: 'Divisão inteira',
      difficulty: QuizDifficulty.dificil,
      prompt: 'Qual é a soma dos dígitos calculada pelo programa?',
      codeSnippet: '''var n = 42;
var soma = 0;
while (n > 0) {
  soma += n % 10;
  n ~/= 10;
}
print(soma);''',
      options: ['2', '4', '6', '42'],
      correctOptionIndex: 2,
      hint:
          'n % 10 fornece o último dígito. A divisão inteira por 10 o remove.',
      explanation: 'O primeiro resto é 2 e 42 ~/ 10 vale 4. O próximo resto é 4 e 4 ~/ 10 vale 0. A soma dos restos é 2 + 4 = 6.',
      executionSteps: [
        QuizExecutionStep(
          line: 2,
          stage: 'Inicialização',
          variables: 'n = 42 · soma = 0',
          explanation: 'O número ainda contém os dois dígitos.',
        ),
        QuizExecutionStep(
          line: 5,
          stage: 'Fim da iteração 1',
          variables: 'n = 4 · soma = 2',
          explanation:
              'O resto 2 foi somado e a divisão inteira deixou 4 em n.',
        ),
        QuizExecutionStep(
          line: 5,
          stage: 'Fim da iteração 2',
          variables: 'n = 0 · soma = 6',
          explanation: 'O resto 4 foi somado, resultando em 6. A nova divisão inteira zerou n.',
        ),
        QuizExecutionStep(
          line: 7,
          stage: 'Saída do programa',
          variables: 'n = 0 · soma = 6',
          explanation:
              'Com n igual a zero o laço termina, e o print exibe a soma 6.',
          output: '6',
        ),
      ],
    ),
  ],
]);
