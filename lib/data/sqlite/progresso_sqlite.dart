import '../../domain/contracts/repositorios.dart';
import '../../domain/models/progresso_topico.dart';
import 'banco_local.dart';

/// Leitura do progresso. A escrita acontece em [PartidasSQLite.salvar],
/// na mesma transação da partida, para nunca contar respostas pela metade.
class ProgressoSQLite implements RepositorioDeProgresso {
  ProgressoSQLite(this._banco);

  final BancoLocal _banco;

  @override
  Future<List<ProgressoTopico>> listarPorJogador(int jogadorId) async {
    final banco = await _banco.abrir();
    final linhas = await banco.query(
      'progresso_topico',
      where: 'jogador_id = ?',
      whereArgs: [jogadorId],
    );
    return ProgressoTopico.ordenar([
      for (final linha in linhas)
        ProgressoTopico(
          jogadorId: linha['jogador_id'] as int,
          modo: linha['modo'] as String,
          topico: linha['topico'] as String,
          totalRespondidas: linha['total_respondidas'] as int,
          totalAcertos: linha['total_acertos'] as int,
          ultimaVez: DateTime.fromMillisecondsSinceEpoch(
            linha['ultima_vez'] as int,
            isUtc: true,
          ),
        ),
    ]);
  }
}
