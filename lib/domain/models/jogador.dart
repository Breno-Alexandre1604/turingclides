/// Perfil local do jogador (diagrama 6B).
///
/// Não há login nesta versão: cada instalação tem um único jogador, sempre
/// com o identificador [idLocal]. Os pontos totais só mudam quando uma
/// partida é gravada, nunca pela edição do perfil.
class Jogador {
  const Jogador({
    required this.id,
    required this.apelido,
    required this.pontosTotais,
    required this.criadoEm,
  });

  /// Jogador criado no primeiro uso, antes de o usuário escolher um apelido.
  factory Jogador.novo({DateTime? criadoEm}) => Jogador(
    id: idLocal,
    apelido: apelidoPadrao,
    pontosTotais: 0,
    criadoEm: (criadoEm ?? DateTime.now()).toUtc(),
  );

  static const idLocal = 1;
  static const apelidoPadrao = 'Jogador';

  final int id;
  final String apelido;
  final int pontosTotais;
  final DateTime criadoEm;

  Jogador copyWith({String? apelido, int? pontosTotais}) => Jogador(
    id: id,
    apelido: apelido ?? this.apelido,
    pontosTotais: pontosTotais ?? this.pontosTotais,
    criadoEm: criadoEm,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'apelido': apelido,
    'criadoEm': criadoEm.toUtc().toIso8601String(),
  };

  /// Os pontos não são lidos do JSON: quem lê calcula a partir das partidas.
  factory Jogador.fromJson(Map<String, dynamic> json, {int pontosTotais = 0}) =>
      Jogador(
        id: json['id'] as int,
        apelido: json['apelido'] as String,
        pontosTotais: pontosTotais,
        criadoEm: DateTime.parse(json['criadoEm'] as String),
      );
}
