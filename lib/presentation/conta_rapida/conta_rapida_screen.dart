import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/dados_locais.dart';
import '../../domain/games/conta_rapida/conta_rapida.dart';
import '../../domain/games/quiz_compartilhado/quiz_strategy.dart';
import 'resultado_conta_rapida_screen.dart';

/// Partida de Conta Rápida com cronômetro de 10 segundos (cartões C2 e C3).
class ContaRapidaScreen extends StatefulWidget {
  const ContaRapidaScreen({
    super.key,
    required this.rodada,
    this.dados,
    this.random,
  });

  final RodadaContaRapida rodada;
  final DadosLocais? dados;
  final Random? random;

  @override
  State<ContaRapidaScreen> createState() => _ContaRapidaScreenState();
}

class _ContaRapidaScreenState extends State<ContaRapidaScreen> {
  static const _passo = Duration(milliseconds: 100);
  static final _totalPassos =
      RodadaContaRapida.limite.inMilliseconds ~/ _passo.inMilliseconds;

  final _campo = TextEditingController();
  final _foco = FocusNode();
  Timer? _cronometro;
  int _passos = 0;
  RespostaConta? _resposta;
  bool _saindo = false;

  RodadaContaRapida get _rodada => widget.rodada;
  Duration get _tempo => _passo * _passos;

  @override
  void initState() {
    super.initState();
    _campo.addListener(() => setState(() {}));
    _iniciarCronometro();
  }

  @override
  void dispose() {
    // Sair da tela no meio da conta não deixa cronômetro rodando.
    _cronometro?.cancel();
    _campo.dispose();
    _foco.dispose();
    super.dispose();
  }

  void _iniciarCronometro() {
    _cronometro?.cancel();
    _passos = 0;
    _cronometro = Timer.periodic(_passo, (_) {
      if (!mounted) return;
      setState(() => _passos++);
      if (_passos >= _totalPassos) _mostrar(_rodada.esgotarTempo());
    });
  }

  void _responder() {
    if (_campo.text.trim().isEmpty) return;
    _mostrar(_rodada.responder(_campo.text, tempo: _tempo));
  }

  /// A rodada devolve `null` se a conta já foi processada: o clique e o fim
  /// do tempo nunca contam duas vezes.
  void _mostrar(RespostaConta? resposta) {
    if (resposta == null) return;
    _cronometro?.cancel();
    setState(() => _resposta = resposta);
  }

  void _continuar() {
    if (_saindo || _resposta == null) return;
    if (_rodada.avancar()) {
      _campo.clear();
      setState(() => _resposta = null);
      _iniciarCronometro();
      // O campo só volta a ficar habilitado no próximo frame; pedir o foco
      // antes disso é ignorado e o jogador teria de clicar a cada conta.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _foco.requestFocus();
      });
      return;
    }
    _saindo = true;
    Navigator.of(context).pushReplacement<void, void>(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: '/conta-rapida/resultado'),
        builder: (_) => ResultadoContaRapidaScreen(
          rodada: _rodada,
          dados: widget.dados,
          random: widget.random,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final conta = _rodada.contaAtual;
    final resposta = _resposta;
    final restante = (_totalPassos - _passos).clamp(0, _totalPassos);
    final segundos = (restante * _passo.inMilliseconds / 1000).ceil();
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Conta Rápida')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Conta ${_rodada.numero} de ${_rodada.quantidade} · '
                '${_rodada.nivel.label}',
              ),
              Text('${_rodada.pontos} pontos', key: const Key('conta-pontos')),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                key: const Key('conta-cronometro'),
                value: resposta == null ? restante / _totalPassos : 0,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Text(resposta == null ? '$segundos s' : ''),
              ),
              const SizedBox(height: 24),
              Text(
                conta.enunciado,
                key: const Key('conta-enunciado'),
                textAlign: TextAlign.center,
                style: tema.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                key: const Key('conta-resposta'),
                controller: _campo,
                focusNode: _foco,
                autofocus: true,
                enabled: resposta == null,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: tema.textTheme.headlineMedium,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: const InputDecoration(
                  labelText: 'Sua resposta',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _responder(),
              ),
              const SizedBox(height: 16),
              if (resposta == null)
                FilledButton(
                  key: const Key('conta-responder'),
                  onPressed: _campo.text.trim().isEmpty ? null : _responder,
                  child: const Text('Responder'),
                )
              else ...[
                Card(
                  key: const Key('conta-feedback'),
                  color: resposta.correta
                      ? tema.colorScheme.primaryContainer
                      : tema.colorScheme.errorContainer,
                  child: ListTile(
                    leading: Icon(
                      resposta.correta
                          ? Icons.check_circle
                          : resposta.tempoEsgotado
                          ? Icons.timer_off
                          : Icons.cancel,
                    ),
                    title: Text(FeedbackRapido.titulo(resposta)),
                    subtitle: Text(FeedbackRapido.detalhe(resposta)),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  key: Key(
                    _rodada.ultima ? 'conta-finalizar' : 'conta-proxima',
                  ),
                  onPressed: _continuar,
                  child: Text(
                    _rodada.ultima ? 'Ver resultado' : 'Próxima conta',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
