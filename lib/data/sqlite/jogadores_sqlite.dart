import '../../domain/contracts/repositorios.dart';
import '../../domain/models/jogador.dart';
import 'banco_local.dart';

class JogadoresSQLite implements RepositorioDeJogadores {
  JogadoresSQLite(this._banco);

  final BancoLocal _banco;

  @override
  Future<Jogador?> obterAtual() => _obter(Jogador.idLocal);

  @override
  Future<Jogador> salvar(Jogador jogador) async {
    final banco = await _banco.abrir();
    await banco.transaction((transacao) async {
      // Os dois comandos são seguros se repetidos ou chamados ao mesmo tempo.
      await transacao.rawInsert(
        'INSERT OR IGNORE INTO jogador (id, apelido, pontos_totais, criado_em) '
        'VALUES (?, ?, 0, ?)',
        [
          jogador.id,
          jogador.apelido,
          jogador.criadoEm.toUtc().millisecondsSinceEpoch,
        ],
      );
      await transacao.update(
        'jogador',
        {'apelido': jogador.apelido},
        where: 'id = ?',
        whereArgs: [jogador.id],
      );
    });
    return (await _obter(jogador.id))!;
  }

  @override
  Future<void> apagarTudo() async {
    final banco = await _banco.abrir();
    await banco.transaction((transacao) async {
      // As chaves estrangeiras já apagariam em cascata; aqui fica explícito.
      for (final tabela in const [
        'resposta_partida',
        'partida',
        'progresso_topico',
        'jogador',
      ]) {
        await transacao.delete(tabela);
      }
    });
  }

  Future<Jogador?> _obter(int id) async {
    final banco = await _banco.abrir();
    final linhas = await banco.query(
      'jogador',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (linhas.isEmpty) return null;
    final linha = linhas.single;
    return Jogador(
      id: linha['id'] as int,
      apelido: linha['apelido'] as String,
      pontosTotais: linha['pontos_totais'] as int,
      criadoEm: DateTime.fromMillisecondsSinceEpoch(
        linha['criado_em'] as int,
        isUtc: true,
      ),
    );
  }
}
