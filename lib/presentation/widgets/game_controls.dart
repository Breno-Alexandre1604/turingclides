import 'package:material_ui/material_ui.dart';

import '../../app/app_theme.dart';
import 'pagina.dart';

// Componentes de Leonardo em Trabalhomobilejunto.txt, ligados aos tokens do
// tema para funcionar no modo claro e no escuro.

/// Cartão de um modo de jogo na Home.
class ModeCard extends StatelessWidget {
  const ModeCard({
    super.key,
    required this.titulo,
    required this.descricao,
    required this.icone,
    required this.cores,
    this.recorde,
    this.onTap,
  });

  final String titulo;
  final String descricao;
  final IconData icone;
  final CorDeModo cores;

  /// Maior pontuação do jogador neste modo, se já jogou.
  final int? recorde;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final recorde = this.recorde;
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Espaco.m),
          child: Row(
            children: [
              IconeDoModo(icone: icone, cores: cores),
              const SizedBox(width: Espaco.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo, style: tema.textTheme.titleMedium),
                    const SizedBox(height: Espaco.xxs),
                    Text(
                      descricao,
                      style: tema.textTheme.bodyMedium?.copyWith(
                        color: tema.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (recorde != null) ...[
                      const SizedBox(height: Espaco.xs),
                      Etiqueta(
                        icone: Icons.emoji_events_outlined,
                        texto: 'Recorde ${milhar(recorde)} pts',
                        cores: cores,
                      ),
                    ],
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right_rounded,
                  color: tema.colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ícone de um modo num quadrado arredondado, como o ícone do app.
class IconeDoModo extends StatelessWidget {
  const IconeDoModo({
    super.key,
    required this.icone,
    required this.cores,
    this.tamanho = 56,
  });

  final IconData icone;
  final CorDeModo cores;
  final double tamanho;

  @override
  Widget build(BuildContext context) => Container(
    width: tamanho,
    height: tamanho,
    decoration: BoxDecoration(
      color: cores.fundo,
      borderRadius: BorderRadius.circular(Raio.icone * tamanho / 56),
    ),
    child: Icon(icone, color: cores.sobreFundo, size: tamanho / 2),
  );
}

/// Etiqueta pequena com a cor de um modo (recorde, pontos da partida).
class Etiqueta extends StatelessWidget {
  const Etiqueta({
    super.key,
    required this.texto,
    required this.cores,
    this.icone,
    this.textoKey,
  });

  final String texto;
  final CorDeModo cores;
  final IconData? icone;

  /// Chave do texto, para os testes lerem o valor.
  final Key? textoKey;

  @override
  Widget build(BuildContext context) {
    final estilo = Theme.of(context).textTheme.labelLarge
        ?.copyWith(color: cores.sobreFundo, fontFeatures: numerosTabulares);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Espaco.s,
        vertical: Espaco.xxs,
      ),
      decoration: BoxDecoration(
        color: cores.fundo,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icone case final icone?) ...[
            Icon(icone, size: 16, color: cores.sobreFundo),
            const SizedBox(width: Espaco.xxs),
          ],
          Text(texto, key: textoKey, style: estilo),
        ],
      ),
    );
  }
}

/// Cabeçalho de uma partida em andamento: posição, pontos e barra de
/// progresso na cor do modo.
class CabecalhoDaPartida extends StatelessWidget {
  const CabecalhoDaPartida({
    super.key,
    required this.posicao,
    required this.pontos,
    required this.pontosKey,
    required this.atual,
    required this.total,
    required this.cores,
  });

  /// Ex.: "Questão 2 de 5 · Médio".
  final String posicao;

  /// Ex.: "320 pontos".
  final String pontos;
  final Key pontosKey;
  final int atual;
  final int total;
  final CorDeModo cores;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                posicao,
                style: tema.textTheme.labelLarge?.copyWith(
                  color: tema.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: Espaco.s),
            Etiqueta(texto: pontos, textoKey: pontosKey, cores: cores),
          ],
        ),
        const SizedBox(height: Espaco.xs),
        LinearProgressIndicator(
          value: atual / total,
          color: cores.cor,
          minHeight: 4,
          borderRadius: BorderRadius.circular(2),
          semanticsLabel: 'Progresso da partida: $atual de $total',
        ),
      ],
    );
  }
}

/// Faixa de resultado: ícone, título e texto, na cor do acerto, do erro ou
/// neutra.
class CartaoDeAviso extends StatelessWidget {
  const CartaoDeAviso({
    super.key,
    required this.titulo,
    required this.conteudo,
    required this.icone,
    this.fundo,
    this.sobreFundo,
  });

  final String titulo;
  final String conteudo;
  final IconData icone;
  final Color? fundo;
  final Color? sobreFundo;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cor = sobreFundo ?? tema.colorScheme.onSurface;
    return Card(
      color: fundo,
      shape: fundo == null
          ? null
          : RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Raio.cartao),
            ),
      child: Padding(
        padding: const EdgeInsets.all(Espaco.m),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icone, color: cor),
            const SizedBox(width: Espaco.s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: tema.textTheme.titleSmall?.copyWith(
                      color: cor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: Espaco.xxs),
                  Text(
                    conteudo,
                    style: tema.textTheme.bodyMedium?.copyWith(color: cor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.texto,
    required this.onPressed,
  });

  final String texto;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: FilledButton(onPressed: onPressed, child: Text(texto)),
  );
}
