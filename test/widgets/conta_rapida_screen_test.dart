import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:turingclides/data/dados_locais.dart';
import 'package:turingclides/main.dart';

/// Lê a conta na tela e calcula a resposta certa.
String _respostaCerta(WidgetTester tester) {
  final texto = tester
      .widget<Text>(find.byKey(const Key('conta-enunciado')))
      .data!;
  final partes = texto.split(' ');
  final a = int.parse(partes[0]);
  final b = int.parse(partes[2]);
  return switch (partes[1]) {
    '+' => '${a + b}',
    '−' => '${a - b}',
    '×' => '${a * b}',
    _ => '${a ~/ b}',
  };
}

Future<void> _tocar(WidgetTester tester, Finder alvo) async {
  await tester.ensureVisible(alvo);
  await tester.pump();
  await tester.tap(alvo);
  await tester.pump();
}

void main() {
  testWidgets(
    'partida completa com acerto e tempo esgotado é gravada uma vez',
    (tester) async {
      final dados = DadosLocais.emMemoria();
      await tester.pumpWidget(TuringclidesApp(dados: dados));
      await _tocar(tester, find.byKey(const Key('quick-mode')));
      await tester.pumpAndSettle();
      expect(find.text('Configurar Conta Rápida'), findsOneWidget);
      await _tocar(tester, find.text('Começar'));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Conta 1 de 5 · Fácil'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('conta-responder')))
            .onPressed,
        isNull,
        reason: 'resposta vazia não pode ser enviada',
      );
      await tester.enterText(
        find.byKey(const Key('conta-resposta')),
        _respostaCerta(tester),
      );
      await tester.pump();
      await _tocar(tester, find.byKey(const Key('conta-responder')));
      expect(find.text('Acertou!'), findsOneWidget);

      // Depois de responder, o tempo acabar não muda nada.
      await tester.pump(const Duration(seconds: 12));
      expect(find.text('Acertou!'), findsOneWidget);

      for (var i = 2; i <= 5; i++) {
        await _tocar(tester, find.byKey(const Key('conta-proxima')));
        expect(find.text('Conta $i de 5 · Fácil'), findsOneWidget);
        await tester.pump();
        // O campo de resposta volta com foco: dá para digitar direto.
        expect(
          find.byWidgetPredicate(
            (w) => w is EditableText && w.focusNode.hasFocus,
          ),
          findsOneWidget,
        );
        await tester.pump(const Duration(seconds: 10));
        expect(find.text('Tempo esgotado!'), findsOneWidget);
      }

      await _tocar(tester, find.byKey(const Key('conta-finalizar')));
      await tester.pumpAndSettle();
      expect(find.text('Conta Rápida concluída!'), findsOneWidget);
      expect(find.text('Partida salva no histórico.'), findsOneWidget);
      expect(find.text('1 de 5 acertos · Fácil'), findsOneWidget);

      final jogador = await dados.perfil.obterJogadorAtual();
      final historico = await dados.progresso.historico(jogador.id);
      expect(historico.single.modo, 'Conta Rápida');
      expect(historico.single.acertos, 1);
      expect(historico.single.respostas.skip(1).map((r) => r.pontos), [
        0,
        0,
        0,
        0,
      ]);
      expect(jogador.pontosTotais, historico.single.pontuacao);
    },
  );

  testWidgets('sair no meio da conta cancela o cronômetro', (tester) async {
    final dados = DadosLocais.emMemoria();
    await tester.pumpWidget(TuringclidesApp(dados: dados));
    await _tocar(tester, find.byKey(const Key('quick-mode')));
    await tester.pumpAndSettle();
    await _tocar(tester, find.byKey(const Key('operacao-divisao')));
    await _tocar(tester, find.text('Começar'));
    await tester.pump(const Duration(seconds: 2));
    await tester.tap(
      find.byType(BackButton),
    ); // o app está em pt-BR: o rótulo é "Voltar"
    await tester.pumpAndSettle();
    expect(find.text('Aprenda jogando!'), findsOneWidget);

    // Se o cronômetro continuasse, haveria erro de setState após dispose.
    await tester.pump(const Duration(seconds: 15));
    final jogador = await dados.perfil.obterJogadorAtual();
    expect(await dados.progresso.historico(jogador.id), isEmpty);
  });

  testWidgets('pelo menos uma operação continua marcada', (tester) async {
    await tester.pumpWidget(TuringclidesApp(dados: DadosLocais.emMemoria()));
    await _tocar(tester, find.byKey(const Key('quick-mode')));
    await tester.pumpAndSettle();
    await _tocar(tester, find.byKey(const Key('operacao-soma')));
    await _tocar(tester, find.byKey(const Key('operacao-subtracao')));
    final chip = tester.widget<FilterChip>(
      find.byKey(const Key('operacao-subtracao')),
    );
    expect(chip.selected, isTrue);
  });
}
