import 'package:material_ui/material_ui.dart';

import '../../app/app_theme.dart';
import '../../data/dados_locais.dart';
import '../../domain/games/conta_rapida/conta_rapida.dart';
import '../../domain/games/quiz_compartilhado/quiz_strategy.dart';
import '../../domain/models/jogador.dart';
import '../conta_rapida/configuracao_conta_rapida_screen.dart';
import '../progresso/player_screen.dart';
import '../widgets/game_controls.dart';
import '../widgets/marca.dart';
import '../widgets/pagina.dart';
import 'configuration_screen.dart';

/// Pontos, partidas, acerto e recordes mostrados na Home.
class _Resumo {
  const _Resumo({
    required this.jogador,
    required this.partidas,
    required this.recordes,
    required this.acertos,
    required this.respondidas,
  });

  final Jogador jogador;
  final int partidas;
  final Map<String, int> recordes;
  final int acertos;
  final int respondidas;
}

// Home e cartões de Leonardo com o percurso Home → configuração de Lucas.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.dados});

  /// Dados do jogador. Vazio usa o banco do aparelho; os testes injetam
  /// [DadosLocais.emMemoria].
  final DadosLocais? dados;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DadosLocais get _dados => widget.dados ?? dadosLocais;
  late Future<_Resumo> _resumo = _carregar();

  @override
  void initState() {
    super.initState();
    // Partida nova, apelido trocado ou dados apagados: a Home se atualiza
    // sozinha, mesmo estando embaixo das outras telas.
    _dados.mudancas.addListener(_recarregar);
  }

  @override
  void dispose() {
    _dados.mudancas.removeListener(_recarregar);
    super.dispose();
  }

  Future<_Resumo> _carregar() async {
    final jogador = await _dados.perfil.obterJogadorAtual();
    final progresso = _dados.progresso;
    final topicos = await progresso.consultarProgresso(jogador.id);
    return _Resumo(
      jogador: jogador,
      partidas: (await progresso.historico(jogador.id)).length,
      recordes: await progresso.recordes(jogador.id),
      acertos: topicos.fold(0, (soma, t) => soma + t.totalAcertos),
      respondidas: topicos.fold(0, (soma, t) => soma + t.totalRespondidas),
    );
  }

  void _recarregar() {
    if (!mounted) return;
    setState(() {
      _resumo = _carregar();
    });
  }

  void _abrirConfiguracao(QuizStrategy strategy) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: '/configuracao'),
        builder: (_) =>
            ConfigurationScreen(strategy: strategy, repository: widget.dados),
      ),
    );
  }

  void _abrirContaRapida() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: '/conta-rapida/configuracao'),
        builder: (_) => ConfiguracaoContaRapidaScreen(dados: widget.dados),
      ),
    );
  }

  void _abrirDados(PlayerSection section) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => PlayerScreen(section: section, dados: widget.dados),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = CoresDoApp.of(context);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: Espaco.l,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MarcaTuringclides(),
            SizedBox(width: Espaco.s),
            Text('Turingclides'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Perfil',
            onPressed: () => _abrirDados(PlayerSection.profile),
            icon: const Icon(Icons.person_outline_rounded),
          ),
          const SizedBox(width: Espaco.xs),
        ],
      ),
      body: FutureBuilder<_Resumo>(
        future: _resumo,
        builder: (context, snapshot) {
          // Ao recarregar, o resumo anterior continua na tela até o novo
          // chegar; se a leitura falhar, o cartão mostra o atalho genérico.
          final resumo = snapshot.data;
          final recordes = resumo?.recordes ?? const <String, int>{};
          return PaginaRolavel(
            children: [
              _CartaoDoJogador(
                resumo: resumo,
                onTap: () => _abrirDados(PlayerSection.profile),
              ),
              const SizedBox(height: Espaco.xxl),
              Text('Aprenda jogando!', style: tema.textTheme.headlineMedium),
              const SizedBox(height: Espaco.xxs),
              Text(
                'Escolha uma atividade para começar.',
                style: tema.textTheme.bodyLarge?.copyWith(
                  color: tema.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Espaco.m),
              ModeCard(
                key: const Key('quick-mode'),
                titulo: 'Conta Rápida',
                descricao: 'Contas de cabeça com 10 segundos cada.',
                icone: iconeDoModo(RodadaContaRapida.modo),
                cores: cores.contaRapida,
                recorde: recordes[RodadaContaRapida.modo],
                onTap: _abrirContaRapida,
              ),
              const SizedBox(height: Espaco.s),
              ModeCard(
                key: const Key('quiz-mode-math'),
                titulo: 'Quiz de Matemática',
                descricao: 'Responda perguntas e veja dicas.',
                icone: iconeDoModo(matematicaStrategy.title),
                cores: cores.matematica,
                recorde: recordes[matematicaStrategy.title],
                onTap: () => _abrirConfiguracao(matematicaStrategy),
              ),
              const SizedBox(height: Espaco.s),
              ModeCard(
                key: const Key('quiz-mode-logic'),
                titulo: 'Quiz de Lógica',
                descricao: 'Resolva desafios de programação.',
                icone: iconeDoModo(logicaStrategy.title),
                cores: cores.logica,
                recorde: recordes[logicaStrategy.title],
                onTap: () => _abrirConfiguracao(logicaStrategy),
              ),
              const SizedBox(height: Espaco.xl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _abrirDados(PlayerSection.history),
                      icon: const Icon(Icons.history_rounded),
                      label: const Text('Ver histórico'),
                    ),
                  ),
                  const SizedBox(width: Espaco.s),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _abrirDados(PlayerSection.progress),
                      icon: const Icon(Icons.trending_up_rounded),
                      label: const Text('Ver progresso'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Quem está jogando: apelido, pontos, partidas e acerto geral. Toque abre
/// o perfil.
class _CartaoDoJogador extends StatelessWidget {
  const _CartaoDoJogador({required this.resumo, required this.onTap});

  final _Resumo? resumo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final esquema = tema.colorScheme;
    final resumo = this.resumo;
    final secundario = tema.textTheme.bodyMedium?.copyWith(
      color: esquema.onSurfaceVariant,
      fontFeatures: numerosTabulares,
    );

    final String titulo;
    final String detalhe;
    if (resumo == null) {
      titulo = 'Seu perfil';
      detalhe = 'Pontos, recordes e histórico';
    } else if (resumo.partidas == 0) {
      titulo = resumo.jogador.apelido;
      detalhe = 'Jogue uma partida para somar pontos.';
    } else {
      final partidas = resumo.partidas == 1
          ? '1 partida'
          : '${milhar(resumo.partidas)} partidas';
      titulo = resumo.jogador.apelido;
      detalhe = '${milhar(resumo.jogador.pontosTotais)} pontos · $partidas';
    }
    final acerto = resumo != null && resumo.respondidas > 0
        ? resumo.acertos / resumo.respondidas
        : null;

    return Card(
      key: const Key('home-player'),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Espaco.m),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: esquema.primaryContainer,
                foregroundColor: esquema.onPrimaryContainer,
                child: resumo == null
                    ? const Icon(Icons.person_outline_rounded)
                    : Text(
                        resumo.jogador.apelido.characters.first.toUpperCase(),
                        style: tema.textTheme.titleMedium?.copyWith(
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
                      titulo,
                      style: tema.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Espaco.xxs),
                    Text(detalhe, style: secundario),
                  ],
                ),
              ),
              if (acerto != null) ...[
                const SizedBox(width: Espaco.s),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      porcento(acerto),
                      style: tema.textTheme.titleLarge?.copyWith(
                        color: esquema.primary,
                        fontWeight: FontWeight.w800,
                        fontFeatures: numerosTabulares,
                      ),
                    ),
                    Text(
                      'de acerto',
                      style: tema.textTheme.labelSmall?.copyWith(
                        color: esquema.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(width: Espaco.xs),
              Icon(
                Icons.chevron_right_rounded,
                color: esquema.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
