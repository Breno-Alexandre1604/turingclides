import 'package:material_ui/material_ui.dart';

import '../../app/app_theme.dart';

// Peças comuns às telas de resultado dos três jogos.

/// Cartão com o resumo da partida, usado nos resultados dos três jogos.
class ResumoDoResultado extends StatelessWidget {
  const ResumoDoResultado({
    super.key,
    required this.linhas,
    required this.pontuacao,
    this.pontuacaoKey,
  });

  final List<String> linhas;
  final String pontuacao;
  final Key? pontuacaoKey;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Espaco.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final linha in linhas)
              Padding(
                padding: const EdgeInsets.only(bottom: Espaco.xxs),
                child: Text(
                  linha,
                  style: tema.textTheme.bodyLarge?.copyWith(
                    color: tema.colorScheme.onSurfaceVariant,
                    fontFeatures: numerosTabulares,
                  ),
                ),
              ),
            const SizedBox(height: Espaco.xs),
            Text(
              pontuacao,
              key: pontuacaoKey,
              style: tema.textTheme.titleLarge?.copyWith(
                fontFeatures: numerosTabulares,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Situação da gravação da partida, com a ação de tentar de novo.
class EstadoDoSalvamento extends StatelessWidget {
  const EstadoDoSalvamento.salvando({super.key})
    : _situacao = _Situacao.salvando,
      tentarDeNovo = null;
  const EstadoDoSalvamento.salvo({super.key})
    : _situacao = _Situacao.salvo,
      tentarDeNovo = null;
  const EstadoDoSalvamento.falhou({super.key, required this.tentarDeNovo})
    : _situacao = _Situacao.falhou;

  final _Situacao _situacao;
  final VoidCallback? tentarDeNovo;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final acerto = CoresDoApp.of(context).acerto;
    final (icone, cor, texto) = switch (_situacao) {
      _Situacao.salvando => (
        Icons.sync_rounded,
        esquema.onSurfaceVariant,
        'Salvando partida…',
      ),
      _Situacao.salvo => (
        Icons.check_circle_rounded,
        acerto.cor,
        'Partida salva no histórico.',
      ),
      _Situacao.falhou => (
        Icons.error_outline_rounded,
        esquema.error,
        'Não foi possível confirmar o salvamento da partida.',
      ),
    };
    return Semantics(
      liveRegion: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, color: cor, size: 20),
              const SizedBox(width: Espaco.xs),
              Expanded(child: Text(texto)),
            ],
          ),
          if (tentarDeNovo case final tentar?)
            TextButton(
              onPressed: tentar,
              child: const Text('Tentar salvar novamente'),
            ),
        ],
      ),
    );
  }
}

enum _Situacao { salvando, salvo, falhou }
