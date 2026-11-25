import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../../app/app_theme.dart';
import '../../data/dados_locais.dart';
import '../../domain/games/conta_rapida/conta_rapida.dart';
import '../../domain/games/quiz_compartilhado/quiz_strategy.dart';
import '../widgets/pagina.dart';
import '../widgets/resultado.dart';
import 'configuracao_conta_rapida_screen.dart';

/// Resultado da Conta Rápida, gravado pela frente Dados e progresso
/// (cartão C4). Tentar salvar de novo usa a mesma partida e não duplica.
class ResultadoContaRapidaScreen extends StatefulWidget {
  const ResultadoContaRapidaScreen({
    super.key,
    required this.rodada,
    this.dados,
    this.random,
  });

  final RodadaContaRapida rodada;
  final DadosLocais? dados;
  final Random? random;

  @override
  State<ResultadoContaRapidaScreen> createState() =>
      _ResultadoContaRapidaScreenState();
}

enum _Gravacao { salvando, salva, falhou }

class _ResultadoContaRapidaScreenState
    extends State<ResultadoContaRapidaScreen> {
  var _gravacao = _Gravacao.salvando;

  DadosLocais get _dados => widget.dados ?? dadosLocais;

  @override
  void initState() {
    super.initState();
    _salvar();
  }

  Future<void> _salvar() async {
    try {
      final jogador = await _dados.perfil.obterJogadorAtual();
      await _dados.progresso.registrarPartida(
        widget.rodada.finalizar(jogadorId: jogador.id),
      );
      if (mounted) setState(() => _gravacao = _Gravacao.salva);
    } catch (_) {
      if (mounted) setState(() => _gravacao = _Gravacao.falhou);
    }
  }

  void _tentarDeNovo() {
    setState(() => _gravacao = _Gravacao.salvando);
    _salvar();
  }

  void _jogarDeNovo() {
    Navigator.of(context).pushReplacement<void, void>(
      MaterialPageRoute<void>(
        builder: (_) => ConfiguracaoContaRapidaScreen(
          dados: widget.dados,
          random: widget.random,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rodada = widget.rodada;
    final salvando = _gravacao == _Gravacao.salvando;
    final tema = Theme.of(context);
    final cores = CoresDoApp.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Resultado')),
      body: PaginaRolavel(
        larguraMaxima: Largura.jogo,
        children: [
          const SizedBox(height: Espaco.m),
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: cores.contaRapida.fundo,
              child: Icon(
                Icons.bolt_rounded,
                size: 48,
                color: cores.contaRapida.sobreFundo,
              ),
            ),
          ),
          const SizedBox(height: Espaco.m),
          Text(
            'Conta Rápida concluída!',
            textAlign: TextAlign.center,
            style: tema.textTheme.headlineSmall,
          ),
          const SizedBox(height: Espaco.xl),
          ResumoDoResultado(
            linhas: [
              '${rodada.acertos} de ${rodada.quantidade} acertos · '
                  '${rodada.nivel.label}',
            ],
            pontuacao: 'Pontuação: ${rodada.pontos} pontos',
            pontuacaoKey: const Key('conta-total'),
          ),
          const SizedBox(height: Espaco.m),
          switch (_gravacao) {
            _Gravacao.salvando => const EstadoDoSalvamento.salvando(),
            _Gravacao.salva => const EstadoDoSalvamento.salvo(),
            _Gravacao.falhou => EstadoDoSalvamento.falhou(
              tentarDeNovo: _tentarDeNovo,
            ),
          },
          const TituloDeSecao('Contas da partida'),
          Card(
            child: Column(
              children: [
                for (final r in rodada.respostas)
                  ListTile(
                    leading: Icon(
                      r.correta
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      color: r.correta
                          ? cores.acerto.cor
                          : tema.colorScheme.error,
                    ),
                    title: Text(
                      '${r.conta.enunciado} = ${r.conta.resultado}',
                      style: const TextStyle(fontFeatures: numerosTabulares),
                    ),
                    subtitle: Text(
                      r.tempoEsgotado
                          ? 'Tempo esgotado'
                          : 'Sua resposta: ${r.entrada} · '
                                '${(r.tempo.inMilliseconds / 1000).toStringAsFixed(1)} s',
                    ),
                    trailing: Text(
                      '+${r.pontos}',
                      style: tema.textTheme.titleSmall?.copyWith(
                        fontFeatures: numerosTabulares,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Espaco.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  key: const Key('conta-jogar-de-novo'),
                  onPressed: salvando ? null : _jogarDeNovo,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(64, 52),
                  ),
                  child: const Text('Jogar de novo'),
                ),
              ),
              const SizedBox(width: Espaco.s),
              Expanded(
                child: FilledButton(
                  key: const Key('conta-inicio'),
                  onPressed: salvando
                      ? null
                      : () =>
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst),
                  child: const Text('Voltar ao início'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
