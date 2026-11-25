import '../dados_locais.dart';
import '../sqlite/banco_local.dart';
import '../sqlite/jogadores_sqlite.dart';
import '../sqlite/partidas_sqlite.dart';
import '../sqlite/preferencias_sqlite.dart';
import '../sqlite/progresso_sqlite.dart';

/// Android (e testes na VM): os repositórios no mesmo arquivo SQLite.
DadosLocais criarDadosLocais() {
  final banco = BancoLocal();
  return DadosLocais(
    jogadores: JogadoresSQLite(banco),
    partidas: PartidasSQLite(banco),
    progresso: ProgressoSQLite(banco),
    preferencias: PreferenciasSQLite(banco),
  );
}
