import 'partida.dart';

/// Resumo de quantas perguntas o jogador respondeu e acertou em um tópico
/// de um modo de jogo (diagrama 6B).
///
/// Os tópicos dos quizzes vivem no código de Breno, não em tabela, por isso o
/// tópico é identificado pelo par modo + nome.
class ProgressoTopico {
  const ProgressoTopico({
    required this.jogadorId,
    required this.modo,
    required this.topico,
    required this.totalRespondidas,
    required this.totalAcertos,
    required this.ultimaVez,
  });

  final int jogadorId;
  final String modo;
  final String topico;
  final int totalRespondidas;
  final int totalAcertos;
  final DateTime ultimaVez;

  double get taxaDeAcerto =>
      totalRespondidas == 0 ? 0 : totalAcertos / totalRespondidas;

  /// Recalcula o progresso a partir do histórico. Usado pela versão em
  /// memória e pelos testes que conferem a versão gravada no SQLite.
  static List<ProgressoTopico> calcular(Iterable<Partida> partidas) {
    final porChave = <(int, String, String), ProgressoTopico>{};
    for (final partida in partidas) {
      for (final resposta in partida.respostas) {
        final chave = (partida.jogadorId, partida.modo, resposta.topico);
        final atual = porChave[chave];
        porChave[chave] = ProgressoTopico(
          jogadorId: partida.jogadorId,
          modo: partida.modo,
          topico: resposta.topico,
          totalRespondidas: (atual?.totalRespondidas ?? 0) + 1,
          totalAcertos: (atual?.totalAcertos ?? 0) + (resposta.correta ? 1 : 0),
          ultimaVez:
              atual == null || partida.finalizadaEm.isAfter(atual.ultimaVez)
              ? partida.finalizadaEm
              : atual.ultimaVez,
        );
      }
    }
    return ordenar(porChave.values);
  }

  /// Ordem única para todas as implementações: modo e depois tópico.
  static List<ProgressoTopico> ordenar(Iterable<ProgressoTopico> itens) =>
      itens.toList()..sort((a, b) {
        final modo = a.modo.compareTo(b.modo);
        return modo != 0 ? modo : a.topico.compareTo(b.topico);
      });

  /// Maior pontuação de uma partida em cada modo.
  static Map<String, int> recordes(Iterable<Partida> partidas) {
    final recordes = <String, int>{};
    for (final partida in partidas) {
      final atual = recordes[partida.modo];
      if (atual == null || partida.pontuacao > atual) {
        recordes[partida.modo] = partida.pontuacao;
      }
    }
    return recordes;
  }
}
