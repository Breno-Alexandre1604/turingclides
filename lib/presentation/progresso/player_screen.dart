import 'package:material_ui/material_ui.dart';

import '../../app/app_theme.dart';
import '../../app/controle_de_tema.dart';
import '../../data/dados_locais.dart';
import '../../domain/models/apelido.dart';
import '../../domain/models/jogador.dart';
import '../../domain/models/partida.dart';
import '../../domain/models/progresso_topico.dart';
import '../widgets/game_controls.dart';
import '../widgets/pagina.dart';

/// Abas da tela do jogador, na ordem em que aparecem.
enum PlayerSection {
  profile('Perfil'),
  history('Histórico'),
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

/// Perfil, histórico e progresso por assunto (cartão D4), em abas que o
/// jogador troca deslizando o dedo para os lados.
class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key, required this.section, this.dados});

  /// Aba aberta primeiro.
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
      builder: (dialogo) {
        final esquema = Theme.of(dialogo).colorScheme;
        return AlertDialog(
          icon: Icon(Icons.delete_outline_rounded, color: esquema.error),
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
              style: FilledButton.styleFrom(
                minimumSize: const Size(64, 40),
                backgroundColor: esquema.error,
                foregroundColor: esquema.onError,
              ),
              onPressed: () => Navigator.of(dialogo).pop(true),
              child: const Text('Apagar'),
            ),
          ],
        );
      },
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

  Future<void> _escolherTema(ControleDeTema controle, ThemeMode modo) async {
    final salvo = await controle.escolher(modo);
    if (!salvo && mounted) {
      _avisar('Não foi possível guardar o tema. Ele vale até fechar o app.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: PlayerSection.values.length,
      initialIndex: widget.section.index,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Seus dados'),
          bottom: TabBar(
            tabs: [
              for (final secao in PlayerSection.values) Tab(text: secao.title),
            ],
          ),
        ),
        body: FutureBuilder<_DadosDaTela>(
          future: _carregamento,
          builder: (context, snapshot) {
            final dados = snapshot.data;
            if (dados == null) {
              if (snapshot.hasError) {
                // A mensagem técnica do erro nunca aparece para o jogador.
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Não foi possível ler os seus dados.'),
                      const SizedBox(height: Espaco.xs),
                      TextButton(
                        onPressed: _recarregar,
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                );
              }
              return const Center(child: CircularProgressIndicator());
            }
            return TabBarView(
              children: [
                PaginaRolavel(
                  listaKey: const PageStorageKey('aba-perfil'),
                  children: _perfil(context, dados),
                ),
                PaginaRolavel(
                  listaKey: const PageStorageKey('aba-historico'),
                  children: _historico(dados),
                ),
                PaginaRolavel(
                  listaKey: const PageStorageKey('aba-progresso'),
                  children: _progresso(context, dados),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _historico(_DadosDaTela dados) => [
    if (dados.partidas.isEmpty)
      const AvisoVazio(
        'Nenhuma partida concluída ainda.',
        icone: Icons.history_rounded,
      ),
    for (final partida in dados.partidas) ...[
      _CartaoPartida(partida: partida),
      const SizedBox(height: Espaco.s),
    ],
  ];

  List<Widget> _perfil(BuildContext context, _DadosDaTela dados) {
    final tema = Theme.of(context);
    final esquema = tema.colorScheme;
    final cores = CoresDoApp.of(context);
    final jogador = dados.jogador;
    final respondidas = dados.progresso.fold(
      0,
      (soma, p) => soma + p.totalRespondidas,
    );
    final acertos = dados.progresso.fold(0, (soma, p) => soma + p.totalAcertos);
    final inicial = jogador.apelido.characters.first.toUpperCase();
    final controleDeTema = TemaEscolhido.maybeOf(context);
    final secundario = tema.textTheme.bodyMedium?.copyWith(
      color: esquema.onSurfaceVariant,
      fontFeatures: numerosTabulares,
    );

    return [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(Espaco.m),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: esquema.primaryContainer,
                    foregroundColor: esquema.onPrimaryContainer,
                    child: Text(
                      inicial,
                      style: tema.textTheme.titleLarge?.copyWith(
                        color: esquema.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: Espaco.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          jogador.apelido,
                          key: const Key('player-nickname'),
                          style: tema.textTheme.titleLarge,
                        ),
                        const SizedBox(height: Espaco.xxs),
                        Text(
                          '${milhar(jogador.pontosTotais)} pontos • '
                          '${dados.partidas.length} partida(s)',
                          key: const Key('player-points'),
                          style: secundario,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    key: const Key('edit-nickname'),
                    tooltip: 'Editar apelido',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _editarApelido(jogador),
                  ),
                ],
              ),
              if (respondidas > 0) ...[
                const SizedBox(height: Espaco.m),
                const Divider(),
                const SizedBox(height: Espaco.m),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$acertos de $respondidas respostas corretas',
                        style: tema.textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      '${porcento(acertos / respondidas)} de acerto geral',
                      style: secundario,
                    ),
                  ],
                ),
                const SizedBox(height: Espaco.xs),
                LinearProgressIndicator(
                  value: acertos / respondidas,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ],
          ),
        ),
      ),
      const TituloDeSecao('Recordes por modo'),
      if (dados.recordes.isEmpty)
        const AvisoVazio(
          'Conclua uma partida para registrar seu primeiro recorde.',
          icone: Icons.emoji_events_outlined,
        )
      else
        Card(
          child: Column(
            children: [
              for (final MapEntry(key: modo, value: pontos)
                  in dados.recordes.entries)
                ListTile(
                  leading: IconeDoModo(
                    icone: iconeDoModo(modo),
                    cores: cores.doModo(modo),
                    tamanho: 40,
                  ),
                  title: Text(modo),
                  trailing: Text(
                    '${milhar(pontos)} pts',
                    style: tema.textTheme.titleMedium?.copyWith(
                      fontFeatures: numerosTabulares,
                    ),
                  ),
                ),
            ],
          ),
        ),
      if (controleDeTema != null) ...[
        const TituloDeSecao('Aparência'),
        SegmentedButton<ThemeMode>(
          key: const Key('tema-escolha'),
          expandedInsets: EdgeInsets.zero,
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(
              value: ThemeMode.system,
              icon: Icon(Icons.brightness_auto_outlined),
              label: Text('Sistema'),
            ),
            ButtonSegment(
              value: ThemeMode.light,
              icon: Icon(Icons.light_mode_outlined),
              label: Text('Claro'),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              icon: Icon(Icons.dark_mode_outlined),
              label: Text('Escuro'),
            ),
          ],
          selected: {controleDeTema.value},
          onSelectionChanged: (escolha) =>
              _escolherTema(controleDeTema, escolha.single),
        ),
      ],
      const TituloDeSecao('Privacidade'),
      Text(
        'Seus dados ficam só neste aparelho. O app não envia nada para a '
        'internet e não pede seu nome real: use um apelido.',
        style: tema.textTheme.bodyMedium?.copyWith(
          color: esquema.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: Espaco.s),
      OutlinedButton.icon(
        key: const Key('delete-data'),
        style: OutlinedButton.styleFrom(
          foregroundColor: esquema.error,
          side: BorderSide(color: esquema.error.withValues(alpha: 0.5)),
        ),
        onPressed: _apagarDados,
        icon: const Icon(Icons.delete_outline_rounded),
        label: const Text('Apagar meus dados'),
      ),
    ];
  }

  List<Widget> _progresso(BuildContext context, _DadosDaTela dados) {
    if (dados.progresso.isEmpty) {
      return const [
        AvisoVazio(
          'Conclua uma partida para ver seus acertos por assunto.',
          icone: Icons.trending_up_rounded,
        ),
      ];
    }
    final porModo = <String, List<ProgressoTopico>>{};
    for (final item in dados.progresso) {
      porModo.putIfAbsent(item.modo, () => []).add(item);
    }
    final cores = CoresDoApp.of(context);
    final grupos = porModo.entries.toList();
    return [
      for (var g = 0; g < grupos.length; g++) ...[
        TituloDeSecao(grupos[g].key, primeiro: g == 0),
        Card(
          child: Column(
            children: [
              for (final (i, topico) in grupos[g].value.indexed) ...[
                if (i > 0) const Divider(indent: Espaco.m, endIndent: Espaco.m),
                _LinhaDeTopico(
                  topico: topico,
                  cores: cores.doModo(grupos[g].key),
                ),
              ],
            ],
          ),
        ),
      ],
    ];
  }
}

class _LinhaDeTopico extends StatelessWidget {
  const _LinhaDeTopico({required this.topico, required this.cores});

  final ProgressoTopico topico;
  final CorDeModo cores;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(Espaco.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(topico.topico, style: tema.textTheme.titleSmall),
              ),
              const SizedBox(width: Espaco.s),
              Text(
                porcento(topico.taxaDeAcerto),
                style: tema.textTheme.titleSmall?.copyWith(
                  color: cores.cor,
                  fontWeight: FontWeight.w800,
                  fontFeatures: numerosTabulares,
                ),
              ),
            ],
          ),
          const SizedBox(height: Espaco.xs),
          LinearProgressIndicator(
            value: topico.taxaDeAcerto,
            color: cores.cor,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: Espaco.xs),
          Text(
            '${topico.totalAcertos} de ${topico.totalRespondidas} '
            'respostas corretas',
            style: tema.textTheme.bodySmall?.copyWith(
              color: tema.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _CartaoPartida extends StatelessWidget {
  const _CartaoPartida({required this.partida});

  final Partida partida;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = CoresDoApp.of(context);
    final momento = partida.finalizadaEm.toLocal();
    final data = MaterialLocalizations.of(context).formatShortDate(momento);
    final hora = TimeOfDay.fromDateTime(momento).format(context);
    return Card(
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(
          horizontal: Espaco.m,
          vertical: Espaco.xxs,
        ),
        leading: IconeDoModo(
          icone: iconeDoModo(partida.modo),
          cores: cores.doModo(partida.modo),
          tamanho: 40,
        ),
        title: Text(
          '${partida.modo} • ${milhar(partida.pontuacao)} pts',
          style: tema.textTheme.titleSmall,
        ),
        subtitle: Text(
          '${partida.dificuldade} • $data, $hora\n'
          '${partida.acertos}/${partida.qtdQuestoes} acertos',
        ),
        children: [
          const Divider(),
          for (final resposta in partida.respostas)
            ListTile(
              leading: Icon(
                resposta.correta
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                color: resposta.correta
                    ? cores.acerto.cor
                    : tema.colorScheme.error,
              ),
              title: Text(resposta.enunciado),
              subtitle: Text(
                'Sua resposta: ${resposta.respostaDada.isEmpty ? 'sem resposta' : resposta.respostaDada}\n'
                'Gabarito: ${resposta.respostaCorreta}'
                '${resposta.usouDica ? '\nUsou dica' : ''}',
              ),
              trailing: Text(
                '+${resposta.pontos}',
                style: const TextStyle(fontFeatures: numerosTabulares),
              ),
            ),
          const SizedBox(height: Espaco.xs),
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
          style: FilledButton.styleFrom(minimumSize: const Size(64, 40)),
          onPressed: _confirmar,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
