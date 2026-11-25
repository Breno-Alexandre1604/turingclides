import '../application/servico_de_perfil.dart';
import '../application/servico_de_progresso.dart';
import '../domain/contracts/repositorios.dart';
import '../domain/models/partida.dart';
import '../domain/models/quiz_result.dart';
import 'memoria/armazem_em_memoria.dart';
import 'plataforma/dados_io.dart'
    if (dart.library.js_interop) 'plataforma/dados_web.dart'
    as plataforma;
import 'quiz_history_repository.dart';

/// Dados do jogador usados pelo app: SQLite no Android e localStorage no
/// navegador. Criados só no primeiro acesso.
final DadosLocais dadosLocais = plataforma.criarDadosLocais();

/// Ponto único de acesso à frente Dados e progresso.
///
/// Reúne os serviços de perfil e de progresso e continua cumprindo o
/// contrato [QuizHistoryRepository], usado pelas telas dos quizzes.
class DadosLocais implements QuizHistoryRepository {
  DadosLocais({
    required RepositorioDeJogadores jogadores,
    required RepositorioDePartidas partidas,
    required RepositorioDeProgresso progresso,
  }) : perfil = ServicoDePerfil(jogadores),
       progresso = ServicoDeProgresso(partidas: partidas, progresso: progresso);

  /// Versão sem banco para testes e para desenvolver telas.
  DadosLocais.emMemoria([ArmazemEmMemoria? armazem])
    : this._comArmazem(armazem ?? ArmazemEmMemoria());

  DadosLocais._comArmazem(ArmazemEmMemoria armazem)
    : this(
        jogadores: JogadoresEmMemoria(armazem),
        partidas: PartidasEmMemoria(armazem),
        progresso: ProgressoEmMemoria(armazem),
      );

  final ServicoDePerfil perfil;
  final ServicoDeProgresso progresso;

  /// Recebe o resultado de um quiz e grava como partida do jogador atual.
  /// Repetir com o mesmo resultado não duplica pontos.
  @override
  Future<void> save(QuizResult result) async {
    final jogador = await perfil.obterJogadorAtual();
    await progresso.registrarPartida(
      Partida.deQuiz(result, jogadorId: jogador.id),
    );
  }

  @override
  Future<List<QuizResult>> all() async {
    final jogador = await perfil.obterJogadorAtual();
    return [
      for (final partida in await progresso.historico(jogador.id))
        partida.paraQuiz(),
    ];
  }
}
