import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:turingclides/data/dados_locais.dart';
import 'package:turingclides/domain/models/quiz_result.dart';
import 'package:turingclides/presentation/progresso/player_screen.dart';

QuizResult _partida() => QuizResult(
  id: 'partida-tela',
  mode: 'Quiz de Matemática',
  difficulty: 'Fácil',
  finishedAt: DateTime.utc(2026, 11, 24, 15),
  answers: const [
    QuizAnswerResult(
      topic: 'Porcentagem',
      prompt: '15% de 80',
      selected: '12',
      correct: '12',
      points: 150,
      elapsedMs: 3000,
      usedHint: false,
    ),
    QuizAnswerResult(
      topic: 'Porcentagem',
      prompt: '20% de 50',
      selected: '15',
      correct: '10',
      points: 0,
      elapsedMs: 5000,
      usedHint: true,
    ),
  ],
);

Future<void> _abrir(
  WidgetTester tester,
  PlayerSection secao,
  DadosLocais dados,
) async {
  await tester.pumpWidget(
    // Chave nova a cada abertura: a tela recarrega como ao navegar de novo.
    MaterialApp(
      home: PlayerScreen(key: UniqueKey(), section: secao, dados: dados),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('perfil recusa apelido inválido e salva o válido', (
    tester,
  ) async {
    final dados = DadosLocais.emMemoria();
    await _abrir(tester, PlayerSection.profile, dados);
    expect(find.text('Jogador'), findsOneWidget);
    expect(find.text('0 pontos • 0 partida(s)'), findsOneWidget);

    await tester.tap(find.byKey(const Key('edit-nickname')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('nickname-field')), 'A');
    await tester.tap(find.byKey(const Key('save-nickname')));
    await tester.pumpAndSettle();
    expect(find.text('Use pelo menos 2 caracteres.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('nickname-field')),
      '  Turing   2 ',
    );
    await tester.tap(find.byKey(const Key('save-nickname')));
    await tester.pumpAndSettle();
    expect(find.text('Turing 2'), findsOneWidget);
    expect(find.text('Apelido atualizado.'), findsOneWidget);
    expect((await dados.perfil.obterJogadorAtual()).apelido, 'Turing 2');
  });

  testWidgets('perfil mostra recorde e apaga os dados após confirmar', (
    tester,
  ) async {
    final dados = DadosLocais.emMemoria();
    await dados.save(_partida());
    await _abrir(tester, PlayerSection.profile, dados);
    expect(find.text('150 pontos • 1 partida(s)'), findsOneWidget);
    expect(find.text('150 pts'), findsOneWidget);
    expect(find.text('1 de 2 respostas corretas'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('delete-data')));
    await tester.tap(find.byKey(const Key('delete-data')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.text('150 pontos • 1 partida(s)'), findsOneWidget);

    await tester.tap(find.byKey(const Key('delete-data')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-delete-data')));
    await tester.pumpAndSettle();
    expect(find.text('0 pontos • 0 partida(s)'), findsOneWidget);
    expect(find.text('Dados apagados deste aparelho.'), findsOneWidget);
  });

  testWidgets('progresso agrupa por modo e mostra a taxa de acerto', (
    tester,
  ) async {
    final dados = DadosLocais.emMemoria();
    await _abrir(tester, PlayerSection.progress, dados);
    expect(
      find.text('Conclua uma partida para ver seus acertos por assunto.'),
      findsOneWidget,
    );

    await dados.save(_partida());
    await _abrir(tester, PlayerSection.progress, dados);
    expect(find.text('Quiz de Matemática'), findsOneWidget);
    expect(find.text('Porcentagem'), findsOneWidget);
    expect(find.text('1 de 2 respostas corretas'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
  });

  testWidgets('histórico lista a partida e abre as respostas', (tester) async {
    final dados = DadosLocais.emMemoria();
    await dados.save(_partida());
    await _abrir(tester, PlayerSection.history, dados);
    expect(find.text('Quiz de Matemática • 150 pts'), findsOneWidget);
    expect(find.textContaining('1/2 acertos'), findsOneWidget);

    await tester.tap(find.text('Quiz de Matemática • 150 pts'));
    await tester.pumpAndSettle();
    expect(find.text('15% de 80'), findsOneWidget);
    expect(find.textContaining('Gabarito: 10'), findsOneWidget);
    expect(find.textContaining('Usou dica'), findsOneWidget);
  });
}
