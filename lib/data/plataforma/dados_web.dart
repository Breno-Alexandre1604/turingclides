import 'package:web/web.dart' as web;

import '../dados_locais.dart';
import '../memoria/armazem_em_memoria.dart';

const _chave = 'turingclides.dados.v2';

/// Navegador (demonstração no Chrome): mesmos contratos, guardados no
/// localStorage desta origem.
DadosLocais criarDadosLocais() => DadosLocais.emMemoria(
  ArmazemEmMemoria(
    carregar: () => web.window.localStorage.getItem(_chave),
    gravar: (json) => web.window.localStorage.setItem(_chave, json),
  ),
);
