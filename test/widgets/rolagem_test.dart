@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:turingclides/data/dados_locais.dart';
import 'package:turingclides/domain/models/quiz_result.dart';
import 'package:turingclides/main.dart';

/// O teste mede alturas de verdade: troca a fonte quadrada dos testes pela
/// Roboto que vem com o Flutter, a mesma do app no Android.
Future<void> _carregarRoboto() async {
  final pasta =
      '${Platform.environment['FLUTTER_ROOT']}/bin/cache/artifacts/material_fonts';
  final roboto = FontLoader('Roboto');
  for (final peso in ['light', 'regular', 'medium', 'bold', 'black']) {
    final bytes = File('$pasta/roboto-$peso.ttf').readAsBytesSync();
    roboto.addFont(Future.value(bytes.buffer.asByteData()));
  }
  await roboto.load();
}

/// Celular comum: 1080 × 2340 px com densidade 2,75 (≈ 393 × 851 dp).
void _celular(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(1080, 2340)
    ..devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);
}

/// A lista da tela não rola nem estica quando o conteúdo cabe nela.
Future<void> _semRolagem(
  WidgetTester tester,
  String tela, {
  Key? listaKey,
}) async {
  final lista = listaKey == null
      ? find.byType(Scrollable).first
      : find
            .descendant(
              of: find.byKey(listaKey),
              matching: find.byType(Scrollable),
            )
            .first;
  final posicao = tester.state<ScrollableState>(lista).position;
  expect(posicao.maxScrollExtent, 0, reason: '$tela cabe na tela');
  expect(
    posicao.physics.shouldAcceptUserOffset(posicao),
    isFalse,
    reason: '$tela não deve aceitar arrasto sem ter o que rolar',
  );
  await tester.drag(lista, const Offset(0, -300));
  await tester.pumpAndSettle();
  expect(posicao.pixels, 0);
}

Future<void> _voltar(WidgetTester tester) async {
  await tester.tap(find.byType(BackButton));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(_carregarRoboto);

  testWidgets('telas que cabem no celular não rolam', (tester) async {
    _celular(tester);
    await tester.pumpWidget(TuringclidesApp(dados: DadosLocais.emMemoria()));
    await tester.pumpAndSettle();
    await _semRolagem(tester, 'Home');

    await tester.tap(find.byKey(const Key('quick-mode')));
    await tester.pumpAndSettle();
    await _semRolagem(tester, 'Configurar Conta Rápida');

    await tester.tap(find.text('Começar'));
    // A partida tem cronômetro: espera a transição sem esperar a conta acabar.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    final lista = find.byType(Scrollable).first;
    final posicao = tester.state<ScrollableState>(lista).position;
    expect(posicao.maxScrollExtent, 0, reason: 'Conta Rápida cabe na tela');
    expect(posicao.physics.shouldAcceptUserOffset(posicao), isFalse);
    await _voltar(tester);

    await tester.tap(find.byKey(const Key('quiz-mode-math')));
    await tester.pumpAndSettle();
    await _semRolagem(tester, 'Configurar atividade');
    await _voltar(tester);

    await tester.tap(find.byTooltip('Perfil'));
    await tester.pumpAndSettle();
    await _semRolagem(
      tester,
      'Perfil',
      listaKey: const PageStorageKey('aba-perfil'),
    );
  });

  testWidgets('lista que não cabe continua rolando', (tester) async {
    _celular(tester);
    final dados = DadosLocais.emMemoria();
    for (var i = 0; i < 12; i++) {
      await dados.save(
        QuizResult(
          id: 'longa-$i',
          mode: 'Quiz de Matemática',
          difficulty: 'Fácil',
          finishedAt: DateTime.utc(2026, 11, 25, 10, i),
          answers: const [
            QuizAnswerResult(
              topic: 'Porcentagem',
              prompt: '15% de 80',
              selected: '12',
              correct: '12',
              points: 100,
              elapsedMs: 1000,
              usedHint: false,
            ),
          ],
        ),
      );
    }
    await tester.pumpWidget(TuringclidesApp(dados: dados));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Ver histórico'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ver histórico'));
    await tester.pumpAndSettle();

    final lista = find.byKey(const PageStorageKey('aba-historico'));
    final posicao = tester
        .state<ScrollableState>(
          find.descendant(of: lista, matching: find.byType(Scrollable)).first,
        )
        .position;
    expect(posicao.maxScrollExtent, greaterThan(0));
    await tester.drag(lista, const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(posicao.pixels, greaterThan(0));
  });
}
