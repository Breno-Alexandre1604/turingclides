import 'dart:ui' show PointerDeviceKind;

import 'package:material_ui/material_ui.dart';

/// Rolagem única do app: dedo, caneta, trackpad e mouse arrastam as listas
/// e trocam as abas, então o simulador no navegador se comporta como o
/// celular. A física continua a do Android (sem o "quique" do iPhone) e uma
/// tela só rola quando o conteúdo não cabe nela.
class RolagemDoApp extends MaterialScrollBehavior {
  const RolagemDoApp();

  @override
  Set<PointerDeviceKind> get dragDevices => PointerDeviceKind.values.toSet();
}
