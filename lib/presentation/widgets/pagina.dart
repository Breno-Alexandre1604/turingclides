import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../app/app_theme.dart';

/// Corpo rolável padrão das telas: margem lateral fixa no celular,
/// conteúdo centralizado com largura máxima em telas largas e espaço para a
/// barra de gestos do Android no fim.
///
/// A lista ocupa a largura toda, então o dedo rola de qualquer ponto da
/// tela, inclusive das margens do tablet. O app usa `RolagemDoApp`.
class PaginaRolavel extends StatelessWidget {
  const PaginaRolavel({
    super.key,
    required this.children,
    this.larguraMaxima = Largura.conteudo,
    this.controller,
    this.listaKey,
    this.fecharTecladoAoArrastar = true,
  });

  final List<Widget> children;
  final double larguraMaxima;
  final ScrollController? controller;

  /// Chave da lista. Use [PageStorageKey] para guardar a posição da rolagem
  /// ao trocar de aba.
  final Key? listaKey;

  /// Arrastar a lista fecha o teclado. Desligado na Conta Rápida, onde um
  /// toque torto não pode esconder o campo no meio do cronômetro.
  final bool fecharTecladoAoArrastar;

  @override
  Widget build(BuildContext context) {
    final sistema = MediaQuery.paddingOf(context);
    return LayoutBuilder(
      builder: (context, limites) {
        final sobra = (limites.maxWidth - larguraMaxima) / 2;
        return ListView(
          key: listaKey,
          controller: controller,
          // Desliza e estica na borda mesmo quando o conteúdo cabe na tela:
          // o toque sempre responde.
          physics: const AlwaysScrollableScrollPhysics(),
          keyboardDismissBehavior: fecharTecladoAoArrastar
              ? ScrollViewKeyboardDismissBehavior.onDrag
              : ScrollViewKeyboardDismissBehavior.manual,
          padding: EdgeInsets.fromLTRB(
            math.max(Espaco.l + sistema.left, sobra),
            Espaco.s,
            math.max(Espaco.l + sistema.right, sobra),
            Espaco.xxl + sistema.bottom,
          ),
          children: children,
        );
      },
    );
  }
}

/// Título de seção: mais espaço acima do que abaixo, para agrupar com o
/// conteúdo que vem depois.
class TituloDeSecao extends StatelessWidget {
  const TituloDeSecao(this.texto, {super.key, this.primeiro = false});

  final String texto;

  /// Primeiro título da tela: sem o espaço de separação acima.
  final bool primeiro;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: primeiro ? 0 : Espaco.xl, bottom: Espaco.xs),
    child: Semantics(
      header: true,
      child: Text(texto, style: Theme.of(context).textTheme.titleMedium),
    ),
  );
}

/// Estado vazio de uma lista: explica o que fazer, sem esconder a tela.
class AvisoVazio extends StatelessWidget {
  const AvisoVazio(this.texto, {super.key, this.icone = Icons.inbox_outlined});

  final String texto;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Espaco.m),
      child: Row(
        children: [
          Icon(icone, color: esquema.onSurfaceVariant),
          const SizedBox(width: Espaco.s),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(color: esquema.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

/// Números com separador de milhar do português: 12.450.
String milhar(int numero) {
  final digitos = numero.abs().toString();
  final partes = <String>[];
  for (var fim = digitos.length; fim > 0; fim -= 3) {
    partes.insert(0, digitos.substring(math.max(0, fim - 3), fim));
  }
  return '${numero < 0 ? '-' : ''}${partes.join('.')}';
}

String porcento(double taxa) => '${(taxa * 100).round()}%';
