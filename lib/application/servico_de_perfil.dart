import '../domain/contracts/repositorios.dart';
import '../domain/models/apelido.dart';
import '../domain/models/jogador.dart';

/// Cria, busca e edita o perfil local (diagrama 7).
class ServicoDePerfil {
  ServicoDePerfil(this._jogadores);

  final RepositorioDeJogadores _jogadores;

  /// Devolve o jogador desta instalação. No primeiro uso cria o perfil com o
  /// apelido padrão, para que a primeira partida já possa ser gravada.
  Future<Jogador> obterJogadorAtual() async =>
      await _jogadores.obterAtual() ?? await _jogadores.salvar(Jogador.novo());

  /// Nome do UML. Como há um único jogador por aparelho, criar e renomear
  /// são a mesma operação.
  Future<Jogador> criarJogador(String apelido) => alterarApelido(apelido);

  /// Valida o apelido antes de gravar. Lança [ApelidoInvalido] se recusado.
  Future<Jogador> alterarApelido(String apelido) async {
    final valido = Apelido.normalizar(apelido);
    final atual = await obterJogadorAtual();
    return _jogadores.salvar(atual.copyWith(apelido: valido));
  }

  /// Apaga todos os dados do jogador neste aparelho.
  Future<void> apagarDados() => _jogadores.apagarTudo();
}
