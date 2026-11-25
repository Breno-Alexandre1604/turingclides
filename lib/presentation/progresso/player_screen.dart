import 'package:material_ui/material_ui.dart';

import '../../data/dados_locais.dart';
import '../../domain/models/apelido.dart';
import '../../domain/models/jogador.dart';
import '../../domain/models/partida.dart';
import '../../domain/models/progresso_topico.dart';

enum PlayerSection {
  history('Histórico'),
  profile('Perfil'),
  progress('Progresso');

  const PlayerSection(this.title);
  final String title;
}

class _DadosDaTela {
  const _DadosDaTela({
    required this.jogador,
    required this.partidas,
    required this.recordes,
    required this.progresso,
  });

  final Jogador jogador;
  final List<Partida> partidas;
  final Map<String, int> recordes;
  final List<ProgressoTopico> progresso;
}

/// Perfil, histórico e progresso por assunto (cartão D4).
class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key, required this.section, this.dados});

  final PlayerSection section;

  /// Vazio usa o banco do aparelho.
  final DadosLocais? dados;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late Future<_DadosDaTela> _carregamento = _carregar();

  DadosLocais get _dados => widget.dados ?? dadosLocais;

  Future<_DadosDaTela> _carregar() async {
    final jogador = await _dados.perfil.obterJogadorAtual();
    final progresso = _dados.progresso;
    return _DadosDaTela(
      jogador: jogador,
      partidas: await progresso.historico(jogador.id),
      recordes: await progresso.recordes(jogador.id),
      progresso: await progresso.consultarProgresso(jogador.id),
    );
  }

  void _recarregar() {
    // Bloco com chaves: o setState não pode devolver o Future atribuído.
    setState(() {
      _carregamento = _carregar();
    });
  }

  void _avisar(String mensagem) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensagem)));
  }

  Future<void> _editarApelido(Jogador jogador) async {
    final novo = await showDialog<String>(
      context: context,
      builder: (_) => _DialogoApelido(inicial: jogador.apelido),
    );
    if (novo == null || !mounted) return;
    try {
      await _dados.perfil.alterarApelido(novo);
      if (!mounted) return;
      _recarregar();
      _avisar('Apelido atualizado.');
    } on ApelidoInvalido catch (erro) {
      if (mounted) _avisar(erro.mensagem);
    } catch (_) {
      if (mounted) _avisar('Não foi possível salvar o apelido. Tente de novo.');
    }
  }

  Future<void> _apagarDados() async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (dialogo) => AlertDialog(
        title: const Text('Apagar meus dados?'),
        content: const Text(
          'Apaga o apelido, as partidas, os recordes e o progresso guardados '
          'neste aparelho. Não é possível desfazer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogo).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            key: const Key('confirm-delete-data'),
            onPressed: () => Navigator.of(dialogo).pop(true),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
    if (confirmou != true || !mounted) return;
    try {
      await _dados.perfil.apagarDados();
      if (!mounted) return;
      _recarregar();
      _avisar('Dados apagados deste aparelho.');
    } catch (_) {
      if (mounted) _avisar('Não foi possível apagar os dados. Tente de novo.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.section.title)),
      body: FutureBuilder<_DadosDaTela>(
        future: _carregamento,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            // A mensagem técnica do erro nunca aparece para o jogador.
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Não foi possível ler os seus dados.'),
                  TextButton(
                    onPressed: _recarregar,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }
          final dados = snapshot.requireData;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: switch (widget.section) {
                  PlayerSection.history => _historico(dados),
                  PlayerSection.profile => _perfil(context, dados),
                  PlayerSection.progress => _progresso(context, dados),
                },
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _historico(_DadosDaTela dados) => [
    if (dados.partidas.isEmpty)
      const _Vazio('Nenhuma partida concluída ainda.'),
    for (final partida in dados.partidas) _CartaoPartida(partida: partida),
  ];

  List<Widget> _perfil(BuildContext context, _DadosDaTela dados) {
    final jogador = dados.jogador;
    final respondidas = dados.progresso.fold(
      0,
      (soma, p) => soma + p.totalRespondidas,
    );
    final acertos = dados.progresso.fold(0, (soma, p) => soma + p.totalAcertos);
    final inicial = jogador.apelido.characters.first.toUpperCase();
    return [
      Card(
        child: ListTile(
          leading: CircleAvatar(child: Text(inicial)),
          title: Text(
            jogador.apelido,
            key: const Key('player-nickname'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            '${jogador.pontosTotais} pontos • '
            '${dados.partidas.length} partida(s)',
            key: const Key('player-points'),
          ),
          trailing: IconButton(
            key: const Key('edit-nickname'),
            tooltip: 'Editar apelido',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _editarApelido(jogador),
          ),
        ),
      ),
      if (respondidas > 0)
        ListTile(
          leading: const Icon(Icons.check_circle_outline),
          title: Text('$acertos de $respondidas respostas corretas'),
          subtitle: Text('${_porcento(acertos / respondidas)} de acerto geral'),
        ),
      const SizedBox(height: 8),
      Text('Recordes por modo', style: Theme.of(context).textTheme.titleMedium),
      if (dados.recordes.isEmpty)
        const _Vazio(
          'Conclua uma partida para registrar seu primeiro recorde.',
        ),
      for (final MapEntry(key: modo, value: pontos) in dados.recordes.entries)
        ListTile(
          leading: const Icon(Icons.emoji_events_outlined),
          title: Text(modo),
          trailing: Text('$pontos pts'),
        ),
      const Divider(height: 32),
      Text(
        'Seus dados ficam só neste aparelho. O app não envia nada para a '
        'internet e não pede seu nome real: use um apelido.',
        style: TextStyle(color: Colors.grey.shade700),
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        key: const Key('delete-data'),
        style: OutlinedButton.styleFrom(foregroundColor: Colors.red.shade700),
        onPressed: _apagarDados,
        icon: const Icon(Icons.delete_outline),
        label: const Text('Apagar meus dados'),
      ),
    ];
  }

  List<Widget> _progresso(BuildContext context, _DadosDaTela dados) {
    if (dados.progresso.isEmpty) {
      return const [
        _Vazio('Conclua uma partida para ver seus acertos por assunto.'),
      ];
    }
    final porModo = <String, List<ProgressoTopico>>{};
    for (final item in dados.progresso) {
      porModo.putIfAbsent(item.modo, () => []).add(item);
    }
    return [
      for (final MapEntry(key: modo, value: topicos) in porModo.entries) ...[
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Text(modo, style: Theme.of(context).textTheme.titleMedium),
        ),
        for (final topico in topicos)
          ListTile(
            title: Text(topico.topico),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                LinearProgressIndicator(value: topico.taxaDeAcerto),
                const SizedBox(height: 4),
                Text(
                  '${topico.totalAcertos} de ${topico.totalRespondidas} '
                  'respostas corretas',
                ),
              ],
            ),
            trailing: Text(_porcento(topico.taxaDeAcerto)),
          ),
      ],
    ];
  }
}

String _porcento(double taxa) => '${(taxa * 100).round()}%';

class _Vazio extends StatelessWidget {
  const _Vazio(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Text(texto),
  );
}

class _CartaoPartida extends StatelessWidget {
  const _CartaoPartida({required this.partida});

  final Partida partida;

  @override
  Widget build(BuildContext context) {
    final momento = partida.finalizadaEm.toLocal();
    final data = MaterialLocalizations.of(context).formatShortDate(momento);
    final hora = TimeOfDay.fromDateTime(momento).format(context);
    return Card(
      child: ExpansionTile(
        title: Text('${partida.modo} • ${partida.pontuacao} pts'),
        subtitle: Text(
          '${partida.dificuldade} • $data, $hora\n'
          '${partida.acertos}/${partida.qtdQuestoes} acertos',
        ),
        children: [
          for (final resposta in partida.respostas)
            ListTile(
              leading: Icon(
                resposta.correta ? Icons.check_circle : Icons.cancel,
                color: resposta.correta ? Colors.green : Colors.red,
              ),
              title: Text(resposta.enunciado),
              subtitle: Text(
                'Sua resposta: ${resposta.respostaDada}\n'
                'Gabarito: ${resposta.respostaCorreta}'
                '${resposta.usouDica ? '\nUsou dica' : ''}',
              ),
              trailing: Text('+${resposta.pontos}'),
            ),
        ],
      ),
    );
  }
}

/// Caixa de edição do apelido, com a mesma validação do serviço.
class _DialogoApelido extends StatefulWidget {
  const _DialogoApelido({required this.inicial});

  final String inicial;

  @override
  State<_DialogoApelido> createState() => _DialogoApelidoState();
}

class _DialogoApelidoState extends State<_DialogoApelido> {
  late final _controle = TextEditingController(text: widget.inicial);
  final _formulario = GlobalKey<FormState>();

  @override
  void dispose() {
    _controle.dispose();
    super.dispose();
  }

  void _confirmar() {
    if (_formulario.currentState!.validate()) {
      Navigator.of(context).pop(_controle.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seu apelido'),
      content: Form(
        key: _formulario,
        child: TextFormField(
          key: const Key('nickname-field'),
          controller: _controle,
          autofocus: true,
          maxLength: Apelido.maximo,
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Apelido',
            helperText: 'Não use seu nome completo.',
          ),
          validator: Apelido.erro,
          onFieldSubmitted: (_) => _confirmar(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          key: const Key('save-nickname'),
          onPressed: _confirmar,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
