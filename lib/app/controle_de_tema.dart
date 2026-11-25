import 'package:material_ui/material_ui.dart';

import '../domain/contracts/repositorios.dart';
import '../domain/models/preferencias.dart';

/// Tema escolhido no Perfil: segue o celular, claro ou escuro.
///
/// Começa seguindo o celular e troca assim que a escolha salva é lida. Uma
/// escolha feita na tela vale na hora; se a gravação falhar, vale até o app
/// fechar.
class ControleDeTema extends ValueNotifier<ThemeMode> {
  ControleDeTema(this._preferencias) : super(ThemeMode.system);

  final RepositorioDePreferencias _preferencias;
  bool _escolhidoNaTela = false;

  Future<void> carregar() async {
    try {
      final salvo = await _preferencias.ler(Preferencias.tema);
      // Não desfaz uma escolha feita enquanto o arquivo era lido.
      if (!_escolhidoNaTela) value = _deTexto(salvo);
    } catch (_) {
      // Sem acesso ao armazenamento: continua seguindo o celular.
    }
  }

  /// Devolve `false` se a escolha não pôde ser salva no aparelho.
  Future<bool> escolher(ThemeMode modo) async {
    _escolhidoNaTela = true;
    value = modo;
    try {
      await _preferencias.gravar(Preferencias.tema, modo.name);
      return true;
    } catch (_) {
      return false;
    }
  }

  static ThemeMode _deTexto(String? texto) => ThemeMode.values.firstWhere(
    (modo) => modo.name == texto,
    orElse: () => ThemeMode.system,
  );
}

/// Deixa o [ControleDeTema] ao alcance de qualquer tela do app.
class TemaEscolhido extends InheritedNotifier<ControleDeTema> {
  const TemaEscolhido({
    super.key,
    required ControleDeTema controle,
    required super.child,
  }) : super(notifier: controle);

  /// `null` quando a tela foi montada fora do app (testes de uma tela só).
  static ControleDeTema? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TemaEscolhido>()?.notifier;
}
