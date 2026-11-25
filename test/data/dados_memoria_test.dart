import 'package:flutter_test/flutter_test.dart';
import 'package:turingclides/data/dados_locais.dart';
import 'package:turingclides/data/memoria/armazem_em_memoria.dart';

import 'contrato_dados.dart';

void main() {
  // Simula o localStorage do navegador: um texto JSON por origem.
  String? guardado;

  Future<DadosLocais> abrir() async => DadosLocais.emMemoria(
    ArmazemEmMemoria(
      carregar: () => guardado,
      gravar: (json) => guardado = json,
    ),
  );

  setUp(() => guardado = null);

  group('Memória e navegador', () {
    contratoDosDadosLocais(abrir: abrir, reabrir: abrir);

    test('conteúdo corrompido ou adulterado começa vazio', () async {
      guardado = '{"versao": 2, "jogador": {"id": "x"}';
      var dados = await abrir();
      expect(await dados.all(), isEmpty);

      guardado = '{"versao": 2, "jogador": null, "partidas": [{"id": "a b"}]}';
      dados = await abrir();
      expect(await dados.all(), isEmpty);
    });

    test('falha ao gravar desfaz a alteração em memória', () async {
      var falhar = false;
      final dados = DadosLocais.emMemoria(
        ArmazemEmMemoria(
          gravar: (_) {
            if (falhar) throw StateError('cota cheia');
          },
        ),
      );
      final jogador = await dados.perfil.obterJogadorAtual();
      falhar = true;
      await expectLater(
        dados.save(resultado('a', respostas: [('Porcentagem', true, 100)])),
        throwsStateError,
      );
      expect(await dados.progresso.historico(jogador.id), isEmpty);
      expect((await dados.perfil.obterJogadorAtual()).pontosTotais, 0);
    });
  });
}
