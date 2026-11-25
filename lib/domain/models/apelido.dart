/// Erro de validação do apelido, com mensagem pronta para a tela.
class ApelidoInvalido implements Exception {
  const ApelidoInvalido(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

/// Regras do apelido do perfil local.
///
/// O apelido é o único dado pessoal guardado pelo app. Por isso ele é curto,
/// só aceita letras, números, espaço e `_ . -`, e nunca chega ao banco sem
/// passar por [normalizar].
abstract final class Apelido {
  static const minimo = 2;
  static const maximo = 20;

  static final _permitido = RegExp(
    r'^[\p{L}\p{N}][\p{L}\p{N} _.\-]*$',
    unicode: true,
  );
  static final _espacos = RegExp(r'\s+');

  /// Remove espaços nas pontas e junta espaços repetidos.
  static String limpar(String bruto) => bruto.trim().replaceAll(_espacos, ' ');

  /// Mensagem de erro para a tela, ou `null` se o apelido for aceito.
  static String? erro(String? bruto) {
    final texto = limpar(bruto ?? '');
    final tamanho = texto.runes.length;
    if (tamanho < minimo) return 'Use pelo menos $minimo caracteres.';
    if (tamanho > maximo) return 'Use no máximo $maximo caracteres.';
    if (!_permitido.hasMatch(texto)) {
      return 'Use apenas letras, números, espaço e _ . -';
    }
    return null;
  }

  /// Devolve o apelido limpo ou lança [ApelidoInvalido].
  static String normalizar(String bruto) {
    final mensagem = erro(bruto);
    if (mensagem != null) throw ApelidoInvalido(mensagem);
    return limpar(bruto);
  }
}
