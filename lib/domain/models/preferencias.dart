/// Regras das preferências do app guardadas no aparelho, como o tema.
///
/// Preferência não é dado pessoal: "Apagar meus dados" não mexe nelas.
abstract final class Preferencias {
  /// Tema escolhido no Perfil: `system`, `light` ou `dark`.
  static const tema = 'tema';

  static const chaveMaxima = 40;
  static const valorMaximo = 200;
  static final _chave = RegExp(r'^[a-z][a-z0-9_.]*$');

  static bool valida(String chave, String valor) =>
      chave.length <= chaveMaxima &&
      _chave.hasMatch(chave) &&
      valor.length <= valorMaximo;

  static void validar(String chave, String valor) {
    if (!valida(chave, valor)) {
      throw ArgumentError('Preferência fora das regras: $chave');
    }
  }
}
