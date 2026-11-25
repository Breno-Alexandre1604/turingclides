import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:turingclides/data/dados_locais.dart';
import 'package:turingclides/data/memoria/armazem_em_memoria.dart';
import 'package:turingclides/domain/models/preferencias.dart';
import 'package:turingclides/domain/models/quiz_result.dart';
import 'package:turingclides/main.dart';

QuizResult _partida() => QuizResult(
  id: 'aparencia',
  mode: 'Quiz de Matemática',
  difficulty: 'Fácil',
  finishedAt: DateTime.utc(2026, 11, 25, 12),
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
  ],
);

Brightness _brilhoAtual(WidgetTester tester) =>
    Theme.of(tester.element(find.text('Seus dados'))).brightness;

void main() {
  testWidgets('tema escolhido no perfil vale na hora e ao reabrir o app', (
    tester,
  ) async {
    String? guardado;
    DadosLocais abrir() => DadosLocais.emMemoria(
      ArmazemEmMemoria(
        carregar: () => guardado,
        gravar: (json) => guardado = json,
      ),
    );

    await tester.pumpWidget(TuringclidesApp(dados: abrir()));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Perfil'));
    await tester.pumpAndSettle();
    expect(_brilhoAtual(tester), Brightness.light);

    await tester.ensureVisible(find.text('Escuro'));
    await tester.tap(find.text('Escuro'));
    await tester.pumpAndSettle();
    expect(_brilhoAtual(tester), Brightness.dark);

    // Fecha e abre o app com os mesmos dados guardados.
    final dados = abrir();
    expect(await dados.preferencias.ler(Preferencias.tema), 'dark');
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(TuringclidesApp(dados: dados));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.text('Aprenda jogando!'))).brightness,
      Brightness.dark,
    );
  });

  testWidgets('a Home mostra o jogador e se atualiza com uma partida nova', (
    tester,
  ) async {
    final dados = DadosLocais.emMemoria();
    await tester.pumpWidget(TuringclidesApp(dados: dados));
    await tester.pumpAndSettle();
    expect(find.text('Jogador'), findsOneWidget);
    expect(find.text('Jogue uma partida para somar pontos.'), findsOneWidget);
    expect(find.textContaining('Recorde'), findsNothing);

    await dados.save(_partida());
    await tester.pumpAndSettle();
    expect(find.text('150 pontos · 1 partida'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    expect(find.text('Recorde 150 pts'), findsOneWidget);
  });

  testWidgets('as abas do jogador trocam deslizando o dedo', (tester) async {
    await tester.pumpWidget(TuringclidesApp(dados: DadosLocais.emMemoria()));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Perfil'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('player-nickname')), findsOneWidget);

    await tester.fling(
      find.byKey(const Key('player-nickname')),
      const Offset(-400, 0),
      1000,
    );
    await tester.pumpAndSettle();
    expect(find.text('Nenhuma partida concluída ainda.'), findsOneWidget);
    expect(find.byKey(const Key('player-nickname')), findsNothing);
  });
}
