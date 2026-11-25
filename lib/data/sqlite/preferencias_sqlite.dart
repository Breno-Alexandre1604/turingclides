import '../../domain/contracts/repositorios.dart';
import '../../domain/models/preferencias.dart';
import 'banco_local.dart';

/// Preferências do app no mesmo arquivo SQLite dos dados do jogador.
class PreferenciasSQLite implements RepositorioDePreferencias {
  PreferenciasSQLite(this._banco);

  final BancoLocal _banco;

  @override
  Future<String?> ler(String chave) async {
    final banco = await _banco.abrir();
    final linhas = await banco.query(
      'preferencia',
      columns: ['valor'],
      where: 'chave = ?',
      whereArgs: [chave],
      limit: 1,
    );
    return linhas.isEmpty ? null : linhas.single['valor'] as String;
  }

  @override
  Future<void> gravar(String chave, String valor) async {
    Preferencias.validar(chave, valor);
    final banco = await _banco.abrir();
    // INSERT OR REPLACE existe em todo SQLite de Android; UPSERT não.
    await banco.rawInsert(
      'INSERT OR REPLACE INTO preferencia (chave, valor) VALUES (?, ?)',
      [chave, valor],
    );
  }
}
