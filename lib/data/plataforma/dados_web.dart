import 'package:web/web.dart' as web;

import '../dados_locais.dart';
import '../memoria/armazem_em_memoria.dart';

const _chave = 'turingclides.dados.v2';

/// Navegador (demonstração no Chrome): mesmos contratos, guardados no
/// localStorage desta origem.
///
/// Se o navegador bloquear o armazenamento (janela anônima, iframe isolado,
/// dados do site bloqueados), o app continua funcionando só em memória.
DadosLocais criarDadosLocais() {
  final storage = _armazenamentoDisponivel();
  if (storage == null) return DadosLocais.emMemoria();
  return DadosLocais.emMemoria(
    ArmazemEmMemoria(
      carregar: () => storage.getItem(_chave),
      gravar: (json) => storage.setItem(_chave, json),
    ),
  );
}

web.Storage? _armazenamentoDisponivel() {
  try {
    final storage = web.window.localStorage;
    storage.getItem(_chave);
    return storage;
  } catch (_) {
    return null;
  }
}
