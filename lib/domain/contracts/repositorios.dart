import '../models/jogador.dart';
import '../models/partida.dart';
import '../models/progresso_topico.dart';

// Contratos dos "bibliotecários" do diagrama 7. Os jogos e os serviços só
// conhecem estas interfaces, nunca o SQLite (inversão de dependência).

abstract interface class RepositorioDeJogadores {
  /// Jogador desta instalação, ou `null` no primeiro uso.
  Future<Jogador?> obterAtual();

  /// Cria o jogador se ainda não existir e atualiza o apelido se existir.
  /// Os pontos totais nunca mudam por aqui.
  Future<Jogador> salvar(Jogador jogador);

  /// Apaga perfil, partidas, respostas e progresso deste aparelho.
  Future<void> apagarTudo();
}

abstract interface class RepositorioDePartidas {
  /// Grava partida, respostas, progresso por tópico e pontos do jogador em
  /// uma única transação. Devolve `false`, sem mudar nada, se a partida com
  /// o mesmo id já estava gravada.
  Future<bool> salvar(Partida partida);

  /// Partidas mais recentes primeiro.
  Future<List<Partida>> listarPorJogador(int jogadorId, {int? limite});

  /// Maior pontuação de uma partida em cada modo.
  Future<Map<String, int>> recordesPorModo(int jogadorId);
}

abstract interface class RepositorioDeProgresso {
  /// Progresso por modo e tópico, ordenado por modo e depois tópico.
  Future<List<ProgressoTopico>> listarPorJogador(int jogadorId);
}

abstract interface class RepositorioDePreferencias {
  /// Valor guardado para [chave], ou `null` se nunca foi gravado.
  Future<String?> ler(String chave);

  /// Grava ou substitui o valor de [chave]. Lança [ArgumentError] se a
  /// chave ou o valor estiverem fora das regras de `Preferencias`.
  Future<void> gravar(String chave, String valor);
}
