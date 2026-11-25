import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../../data/dados_locais.dart';
import '../../domain/games/conta_rapida/conta_rapida.dart';
import '../../domain/games/quiz_compartilhado/quiz_question.dart';
import '../../domain/games/quiz_compartilhado/quiz_strategy.dart';
import '../widgets/game_controls.dart';
import 'conta_rapida_screen.dart';

/// Escolha de operações, nível e quantidade de contas (cartão C1).
class ConfiguracaoContaRapidaScreen extends StatefulWidget {
  const ConfiguracaoContaRapidaScreen({super.key, this.dados, this.random});

  final DadosLocais? dados;

  /// Só para testes: deixa o sorteio das contas previsível.
  final Random? random;

  @override
  State<ConfiguracaoContaRapidaScreen> createState() =>
      _ConfiguracaoContaRapidaScreenState();
}

class _ConfiguracaoContaRapidaScreenState
    extends State<ConfiguracaoContaRapidaScreen> {
  final _operacoes = {Operacao.soma, Operacao.subtracao};
  var _nivel = QuizDifficulty.facil;
  var _quantidade = 5;

  void _alternar(Operacao operacao, bool marcada) {
    setState(() {
      // Pelo menos uma operação fica sempre marcada.
      if (marcada) {
        _operacoes.add(operacao);
      } else if (_operacoes.length > 1) {
        _operacoes.remove(operacao);
      }
    });
  }

  void _comecar() {
    Navigator.of(context).pushReplacement<void, void>(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: '/conta-rapida'),
        builder: (_) => ContaRapidaScreen(
          rodada: RodadaContaRapida(
            nivel: _nivel,
            operacoes: Set.of(_operacoes),
            quantidade: _quantidade,
            random: widget.random,
          ),
          dados: widget.dados,
          random: widget.random,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurar Conta Rápida')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Conta Rápida',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Resolva de cabeça. Cada conta tem '
                '${RodadaContaRapida.limite.inSeconds} segundos.',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 24),
              const Text('Operações'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final operacao in Operacao.values)
                    FilterChip(
                      key: Key('operacao-${operacao.name}'),
                      label: Text('${operacao.simbolo}  ${operacao.nome}'),
                      selected: _operacoes.contains(operacao),
                      onSelected: (marcada) => _alternar(operacao, marcada),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<QuizDifficulty>(
                key: const Key('conta-nivel'),
                initialValue: _nivel,
                decoration: const InputDecoration(
                  labelText: 'Dificuldade',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final nivel in QuizDifficulty.values)
                    DropdownMenuItem(value: nivel, child: Text(nivel.label)),
                ],
                onChanged: (nivel) {
                  if (nivel != null) setState(() => _nivel = nivel);
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<int>(
                key: const Key('conta-quantidade'),
                initialValue: _quantidade,
                decoration: const InputDecoration(
                  labelText: 'Quantidade de contas',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final n in const [5, 10, 15])
                    DropdownMenuItem(value: n, child: Text('$n contas')),
                ],
                onChanged: (n) {
                  if (n != null) setState(() => _quantidade = n);
                },
              ),
              const SizedBox(height: 28),
              PrimaryButton(texto: 'Começar', onPressed: _comecar),
            ],
          ),
        ),
      ),
    );
  }
}
