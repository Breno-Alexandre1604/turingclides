import 'dart:convert';

import '../../domain/contracts/repositorios.dart';
import '../../domain/models/jogador.dart';
import '../../domain/models/partida.dart';
import '../../domain/models/preferencias.dart';
import '../../domain/models/progresso_topico.dart';

/// Dados de desenvolvimento (cartão D2): os mesmos contratos do SQLite,
/// guardados em memória. Servem para testes, para os colegas trabalharem
/// sem banco e, com [carregar] e [gravar], para o navegador (localStorage).
class ArmazemEmMemoria {
  ArmazemEmMemoria({String? Function()? carregar, this.gravar}) {
    final texto = carregar?.call();
    if (texto != null) _restaurar(texto);
  }

  static const versao = 2;

  /// Recebe o retrato completo em JSON a cada alteração.
  final void Function(String json)? gravar;

  Jogador? _jogador;
  final _partidas = <String, Partida>{};
  final _preferencias = <String, String>{};

  void _restaurar(String texto) {
    try {
      final json = jsonDecode(texto) as Map<String, dynamic>;
      if (json['versao'] != versao) return;
      final jogador = json['jogador'];
      final partidas = [
        for (final p in json['partidas'] as List<dynamic>)
          Partida.fromJson(p as Map<String, dynamic>)..validar(),
      ];
      _jogador = jogador == null
          ? null
          : Jogador.fromJson(jogador as Map<String, dynamic>);
      for (final partida in partidas) {
        _partidas[partida.id] = partida;
      }
      // Campo opcional, ausente nos dados salvos antes do tema. Valores fora
      // das regras são ignorados, um a um.
      final preferencias = json['preferencias'];
      if (preferencias is Map<String, dynamic>) {
        for (final MapEntry(:key, :value) in preferencias.entries) {
          if (value is String && Preferencias.valida(key, value)) {
            _preferencias[key] = value;
          }
        }
      }
    } on Object {
      // Conteúdo corrompido ou adulterado: começa vazio em vez de travar.
      _jogador = null;
      _partidas.clear();
      _preferencias.clear();
    }
  }

  void _persistir() => gravar?.call(
    jsonEncode({
      'versao': versao,
      'jogador': _jogador?.toJson(),
      'partidas': [for (final p in _partidas.values) p.toJson()],
      'preferencias': _preferencias,
    }),
  );

  /// Aplica a alteração e desfaz se a gravação externa falhar.
  void _alterar(void Function() alteracao) {
    final jogador = _jogador;
    final partidas = Map.of(_partidas);
    final preferencias = Map.of(_preferencias);
    alteracao();
    try {
      _persistir();
    } catch (_) {
      _jogador = jogador;
      _partidas
        ..clear()
        ..addAll(partidas);
      _preferencias
        ..clear()
        ..addAll(preferencias);
      rethrow;
    }
  }

  Iterable<Partida> _doJogador(int jogadorId) =>
      _partidas.values.where((p) => p.jogadorId == jogadorId);
}

class JogadoresEmMemoria implements RepositorioDeJogadores {
  JogadoresEmMemoria(this._armazem);

  final ArmazemEmMemoria _armazem;

  @override
  Future<Jogador?> obterAtual() async {
    final jogador = _armazem._jogador;
    if (jogador == null) return null;
    final pontos = _armazem
        ._doJogador(jogador.id)
        .fold(0, (soma, p) => soma + p.pontuacao);
    return jogador.copyWith(pontosTotais: pontos);
  }

  @override
  Future<Jogador> salvar(Jogador jogador) async {
    _armazem._alterar(() {
      final atual = _armazem._jogador;
      _armazem._jogador = atual == null
          ? jogador.copyWith(pontosTotais: 0)
          : atual.copyWith(apelido: jogador.apelido);
    });
    return (await obterAtual())!;
  }

  @override
  Future<void> apagarTudo() async {
    _armazem._alterar(() {
      _armazem._jogador = null;
      _armazem._partidas.clear();
    });
  }
}

class PartidasEmMemoria implements RepositorioDePartidas {
  PartidasEmMemoria(this._armazem);

  final ArmazemEmMemoria _armazem;

  @override
  Future<bool> salvar(Partida partida) async {
    partida.validar();
    if (_armazem._partidas.containsKey(partida.id)) return false;
    if (_armazem._jogador?.id != partida.jogadorId) {
      throw StateError('Jogador ${partida.jogadorId} não encontrado.');
    }
    _armazem._alterar(() => _armazem._partidas[partida.id] = partida);
    return true;
  }

  @override
  Future<List<Partida>> listarPorJogador(int jogadorId, {int? limite}) async {
    final partidas = _armazem._doJogador(jogadorId).toList()
      ..sort((a, b) {
        final data = b.finalizadaEm.compareTo(a.finalizadaEm);
        return data != 0 ? data : b.id.compareTo(a.id);
      });
    return limite == null ? partidas : partidas.take(limite).toList();
  }

  @override
  Future<Map<String, int>> recordesPorModo(int jogadorId) async =>
      ProgressoTopico.recordes(_armazem._doJogador(jogadorId));
}

class ProgressoEmMemoria implements RepositorioDeProgresso {
  ProgressoEmMemoria(this._armazem);

  final ArmazemEmMemoria _armazem;

  @override
  Future<List<ProgressoTopico>> listarPorJogador(int jogadorId) async =>
      ProgressoTopico.calcular(_armazem._doJogador(jogadorId));
}

class PreferenciasEmMemoria implements RepositorioDePreferencias {
  PreferenciasEmMemoria(this._armazem);

  final ArmazemEmMemoria _armazem;

  @override
  Future<String?> ler(String chave) async => _armazem._preferencias[chave];

  @override
  Future<void> gravar(String chave, String valor) async {
    Preferencias.validar(chave, valor);
    _armazem._alterar(() => _armazem._preferencias[chave] = valor);
  }
}
