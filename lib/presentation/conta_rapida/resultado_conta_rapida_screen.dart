import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../../data/dados_locais.dart';
import '../../domain/games/conta_rapida/conta_rapida.dart';
import '../../domain/games/quiz_compartilhado/quiz_strategy.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Resultado')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Icon(Icons.bolt, size: 64, color: Colors.deepOrange),
              const SizedBox(height: 12),
              Text(
                'Conta Rápida concluída!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                '${rodada.acertos} de ${rodada.quantidade} acertos · '
                '${rodada.nivel.label}',
              ),
              Text(
                'Pontuação: ${rodada.pontos} pontos',
                key: const Key('conta-total'),
              ),
              const SizedBox(height: 12),
              switch (_gravacao) {
                _Gravacao.salvando => const Text('Salvando partida…'),
                _Gravacao.salva => const Text('Partida salva no histórico.'),
                _Gravacao.falhou => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Não foi possível confirmar o salvamento da partida.',
                    ),
                    TextButton(
                      onPressed: _tentarDeNovo,
                      child: const Text('Tentar salvar novamente'),
                    ),
                  ],
                ),
              },
              const Divider(height: 32),
              for (final r in rodada.respostas)
                ListTile(
                  dense: true,
                  leading: Icon(
                    r.correta ? Icons.check_circle : Icons.cancel,
                    color: r.correta ? Colors.green : Colors.red,
                  ),
                  title: Text('${r.conta.enunciado} = ${r.conta.resultado}'),
                  subtitle: Text(
                    r.tempoEsgotado
                        ? 'Tempo esgotado'
                        : 'Sua resposta: ${r.entrada} · '
                              '${(r.tempo.inMilliseconds / 1000).toStringAsFixed(1)} s',
                  ),
                  trailing: Text('+${r.pontos}'),
                ),
              const SizedBox(height: 16),
              OutlinedButton(
                key: const Key('conta-jogar-de-novo'),
                onPressed: salvando ? null : _jogarDeNovo,
                child: const Text('Jogar de novo'),
              ),
              const SizedBox(height: 8),
              FilledButton(
                key: const Key('conta-inicio'),
                onPressed: salvando
                    ? null
                    : () =>
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst),
                child: const Text('Voltar ao início'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
