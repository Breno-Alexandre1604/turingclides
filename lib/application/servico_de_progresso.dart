import '../domain/contracts/repositorios.dart';
import '../domain/models/partida.dart';
import '../domain/models/progresso_topico.dart';

/// Registra partidas e consulta histórico, recordes e progresso (diagrama 7).
class ServicoDeProgresso {
  ServicoDeProgresso({required this._partidas, required this._progresso});

  final RepositorioDePartidas _partidas;
  final RepositorioDeProgresso _progresso;

  /// Grava a partida, as respostas, o progresso e os pontos de uma vez.
  /// Devolve `false` se a mesma partida já tinha sido gravada; nesse caso
  /// nada muda. Lança [PartidaInvalida] se os dados não fecharem.
  Future<bool> registrarPartida(Partida partida) async {
    partida.validar();
    return _partidas.salvar(partida);
  }

  Future<List<Partida>> historico(int jogadorId, {int? limite}) =>
      _partidas.listarPorJogador(jogadorId, limite: limite);

  Future<List<ProgressoTopico>> consultarProgresso(int jogadorId) =>
      _progresso.listarPorJogador(jogadorId);

  Future<Map<String, int>> recordes(int jogadorId) =>
      _partidas.recordesPorModo(jogadorId);

  Future<int?> obterRecorde(int jogadorId, String modo) async =>
      (await recordes(jogadorId))[modo];
}
