# Dados e progresso (cartões D1 a D5)

Responsável: Renan. Branch: `feat/dados-progresso`, criada a partir de `integracao/quizzes-offline`.

Esta frente guarda no celular tudo o que o jogador faz: perfil, partidas, respostas, recordes e progresso por assunto. Os jogos e as telas nunca falam com o SQLite diretamente. Eles usam contratos (interfaces), como pede o guia UML (diagramas 6B e 7).

## O que foi entregue

| Cartão | Pedido no plano | Entrega |
| --- | --- | --- |
| D1 Modelo e contratos | Modelar jogador, partidas, respostas e progresso; identificadores; formato do resultado | Modelos `Jogador`, `Partida`, `RespostaPartida` e `ProgressoTopico`. Contratos `RepositorioDeJogadores`, `RepositorioDePartidas` e `RepositorioDeProgresso`. O `QuizResult` de Breno continua sendo o formato de entrada dos quizzes |
| D2 Dados de desenvolvimento | Repositórios em memória para testar sem SQLite | `DadosLocais.emMemoria()`, com os mesmos contratos. É usado nos testes e na versão de navegador |
| D3 SQLite e gravação | Tabelas, gravação em transação, id da partida contra pontuação duplicada | `BancoLocal` (esquema v2 com migração da v1), `PartidasSQLite`, `JogadoresSQLite` e `ProgressoSQLite`. Partida, respostas, progresso e pontos são gravados em uma única transação |
| D4 Perfil e histórico | Edição de apelido, consulta de partidas, recordes, progresso, telas | Tela `PlayerScreen` com Perfil (apelido editável, pontos, recordes, apagar dados), Histórico e Progresso, já ligada à Home |
| D5 Integridade | Reabrir o app, salvar duas vezes, falha de gravação, primeiro uso | Testes automatizados para cada um desses casos (veja [Testes](#testes)) |

## Arquivos

```
lib/
  domain/
    models/
      jogador.dart            Jogador (perfil local, id fixo 1)
      apelido.dart            Validação do apelido
      partida.dart            Partida e RespostaPartida, validação e conversão do QuizResult
      progresso_topico.dart   ProgressoTopico, recálculo do progresso e dos recordes
    contracts/
      repositorios.dart       Os três contratos de repositório
  application/
    servico_de_perfil.dart    obterJogadorAtual, criarJogador, alterarApelido, apagarDados
    servico_de_progresso.dart registrarPartida, historico, consultarProgresso, recordes, obterRecorde
  data/
    dados_locais.dart         DadosLocais: porta de entrada usada pelo app (e dadosLocais global)
    quiz_history_repository.dart  Contrato antigo das telas dos quizzes, agora atendido por DadosLocais
    sqlite/
      banco_local.dart        Abertura, esquema, pragmas e migração da versão 1
      jogadores_sqlite.dart
      partidas_sqlite.dart    Gravação atômica da partida
      progresso_sqlite.dart
    memoria/
      armazem_em_memoria.dart Os mesmos contratos em memória (D2) e no localStorage
    plataforma/
      dados_io.dart           Android: SQLite
      dados_web.dart          Navegador: localStorage
  presentation/progresso/
    player_screen.dart        Perfil, Histórico e Progresso
test/
  data/contrato_dados.dart    Comportamento exigido de toda implementação
  data/dados_sqlite_test.dart Contrato no SQLite, falha no meio da gravação, migração, chaves estrangeiras
  data/dados_memoria_test.dart Contrato em memória, conteúdo corrompido, falha ao gravar
  domain/dados_modelos_test.dart Apelido, Partida e cálculo do progresso
  widgets/player_screen_test.dart Telas de Perfil, Histórico e Progresso
```

Arquivos de outros colegas que precisaram de um ajuste pequeno:

- `lib/main.dart` e `lib/presentation/home/home_screen.dart`: o parâmetro `repository` virou `dados` (tipo `DadosLocais`), para que a Home entregue os dados às telas de Perfil, Histórico e Progresso.
- `test/widget_test.dart`: o histórico de teste agora estende `DadosLocais.emMemoria()`. As verificações continuam as mesmas.
- Removidos `lib/data/quiz_history_sqlite.dart`, `lib/data/quiz_history_web.dart` e os testes deles. O comportamento que eles garantiam (não duplicar e não gravar pela metade) continua coberto pelos testes novos.

## Modelo de dados (SQLite, versão 2)

O banco fica no arquivo `turingclides_quizzes.db`, na pasta privada do app. É o mesmo nome da versão 1 de Breno, para que os aparelhos que já tinham partidas sejam migrados.

```
jogador (1) ──< partida (1) ──< resposta_partida
   │
   └──< progresso_topico
```

| Tabela | Colunas | Regras no banco |
| --- | --- | --- |
| `jogador` | `id`, `apelido`, `pontos_totais`, `criado_em` | Apelido com 2 a 20 caracteres; pontos ≥ 0 |
| `partida` | `id` (texto), `jogador_id`, `modo`, `dificuldade`, `qtd_questoes`, `tempo_por_questao`, `operacoes`, `iniciada_em`, `finalizada_em`, `pontuacao`, `acertos` | Id único; jogador precisa existir; acertos entre 0 e a quantidade de questões |
| `resposta_partida` | `id`, `partida_id`, `ordem`, `questao_id`, `topico`, `enunciado`, `resposta_dada`, `resposta_correta`, `correta`, `tempo_gasto_ms`, `pontos`, `usou_dica` | Uma resposta por posição na partida; pontos ≥ 0; tempo ≥ 0 |
| `progresso_topico` | `jogador_id`, `modo`, `topico`, `total_respondidas`, `total_acertos`, `ultima_vez` | Chave (jogador, modo, tópico); acertos ≤ respondidas |

Datas são gravadas em milissegundos UTC. Apagar o jogador apaga em cascata as partidas, as respostas e o progresso.

### Diferenças em relação ao diagrama 6B

| UML | Implementação | Motivo |
| --- | --- | --- |
| `Partida.id` inteiro | Texto (gerado pelo `PartidaController`) | O id nasce no celular antes de gravar e é o que impede contar a mesma partida duas vezes |
| `ModoJogo` e `Topico` como tabelas | Texto em `modo` e `topico` | As questões e os tópicos estão no código Dart de Breno, não no banco |
| `Partida.dificuldade` inteiro | Texto ("Fácil", "Médio", "Difícil") | É o rótulo que os quizzes já usam |
| `ProgressoTopico` ligado a `Topico` | Chave jogador + modo + tópico | Mesmo motivo de `Topico` |
| `pontuacao`, `acertos`, `qtdQuestoes` guardados | Calculados a partir das respostas no modelo e gravados no banco para consulta | Evita que pontos e respostas discordem |
| `Questao`, `Alternativa`, `Conceito` no banco | Não criados | Ficam para depois da entrega (veja [Limitações](#limitações-e-próximos-passos)) |

## Contratos e serviços

```dart
abstract interface class RepositorioDeJogadores {
  Future<Jogador?> obterAtual();
  Future<Jogador> salvar(Jogador jogador);   // cria ou troca o apelido; nunca mexe nos pontos
  Future<void> apagarTudo();
}

abstract interface class RepositorioDePartidas {
  Future<bool> salvar(Partida partida);      // false = já estava gravada, nada muda
  Future<List<Partida>> listarPorJogador(int jogadorId, {int? limite});
  Future<Map<String, int>> recordesPorModo(int jogadorId);
}

abstract interface class RepositorioDeProgresso {
  Future<List<ProgressoTopico>> listarPorJogador(int jogadorId);
}
```

No UML, `RepositorioDeProgresso` também tem `salvar(progresso)`. Aqui o progresso é gravado por `RepositorioDePartidas.salvar`, dentro da mesma transação da partida. Assim nunca existe progresso contado sem a partida correspondente, nem o contrário.

`ServicoDePerfil` e `ServicoDeProgresso` são os serviços do diagrama 7. `DadosLocais` junta os dois e é o que o app usa:

```dart
final dados = dadosLocais;                       // SQLite no Android
final jogador = await dados.perfil.obterJogadorAtual();
await dados.perfil.alterarApelido('Ana');        // lança ApelidoInvalido se recusado
final historico = await dados.progresso.historico(jogador.id);
final recordes = await dados.progresso.recordes(jogador.id);
final progresso = await dados.progresso.consultarProgresso(jogador.id);
```

## Como os outros módulos usam

### Quizzes (Breno)

Nada muda. A tela de resultado continua chamando `repository.save(result)` com o `QuizResult` do `PartidaController`. Quem atende esse contrato agora é `DadosLocais`.

### Conta Rápida (Eduardo)

Ao terminar a partida, monte uma `Partida` e registre:

```dart
final jogador = await dadosLocais.perfil.obterJogadorAtual();
await dadosLocais.progresso.registrarPartida(
  Partida(
    id: idDaPartida,                 // gere uma vez por partida e reutilize ao tentar de novo
    jogadorId: jogador.id,
    modo: 'Conta Rápida',
    dificuldade: 'Fácil',
    tempoPorQuestao: 10,
    operacoes: ['SOMA', 'MULTIPLICACAO'],
    iniciadaEm: inicio,
    finalizadaEm: DateTime.now().toUtc(),
    respostas: [
      RespostaPartida(
        ordem: 0,                    // 0, 1, 2... na ordem das perguntas
        topico: 'Multiplicação',
        enunciado: '7 × 8',          // o "enunciadoGerado" do UML
        respostaDada: '56',          // vazio se o tempo acabou
        respostaCorreta: '56',
        correta: true,
        tempoGastoMs: 3200,
        pontos: 140,                 // 0 se errou ou se o tempo acabou
      ),
    ],
  ),
);
```

Também é possível reaproveitar a `QuizResultScreen`, entregando um `QuizResult` com o modo "Conta Rápida".

### Telas (Leonardo e Lucas)

- `TuringclidesApp(dados: ...)` e `HomeScreen(dados: ...)` recebem os dados. Sem parâmetro, usam o banco do aparelho.
- `PlayerScreen(section: PlayerSection.profile | history | progress, dados: ...)` abre Perfil, Histórico ou Progresso.
- Nos testes de tela, use `DadosLocais.emMemoria()`. Não precisa de banco.

## Regras de integridade

| Regra | Como é garantida |
| --- | --- |
| Uma partida só aparece como salva depois da confirmação do repositório | `save` só termina depois do fim da transação. A tela de resultado mostra erro e permite tentar de novo |
| A mesma partida nunca soma pontos duas vezes | O id da partida é chave primária e é conferido dentro da transação. Repetir, mesmo ao mesmo tempo ou depois de reabrir o app, devolve `false` sem mudar nada |
| Nada fica gravado pela metade | Partida, respostas, progresso e pontos vão na mesma transação. Qualquer erro desfaz tudo |
| Pontos e progresso batem com o histórico | Teste automático compara os valores gravados com o recálculo a partir das partidas |
| Dados impossíveis não entram | `Partida.validar()` recusa pontos negativos, resposta errada com pontos, id fora do formato, partida sem respostas e textos longos demais. O banco repete as regras principais com `CHECK` e chaves estrangeiras |
| Primeiro uso funciona | O perfil "Jogador" é criado sozinho na primeira leitura ou na primeira partida |
| Atualização sem perda | Abrir a versão 2 sobre um banco da versão 1 migra as partidas antigas em uma transação. Registros corrompidos são descartados |

## Testes

Rodar tudo:

```powershell
flutter test
```

| Arquivo | O que verifica |
| --- | --- |
| `test/data/dados_sqlite_test.dart` | Todo o contrato no SQLite real (via `sqflite_common_ffi`); falha simulada no meio da gravação sem registro parcial; migração da versão 1 com registro corrompido; chaves estrangeiras e `secure_delete` ligados |
| `test/data/dados_memoria_test.dart` | O mesmo contrato em memória e com persistência em texto (como o localStorage); conteúdo corrompido; falha ao gravar desfaz a alteração |
| `test/data/contrato_dados.dart` | Primeiro uso; mesma partida duas vezes (simultâneas e após reabrir); pontos e progresso iguais ao recálculo; ida e volta do `QuizResult`; apelido válido e inválido; apagar dados; partida impossível; textos com aspas e comandos SQL |
| `test/domain/dados_modelos_test.dart` | Regras do apelido, conversão e validação da partida, cálculo do progresso e dos recordes |
| `test/widgets/player_screen_test.dart` | Edição de apelido com erro e sucesso, recorde, apagar dados com confirmação, progresso por modo e histórico |

## Roteiro para demonstrar (cerca de 1 minuto)

1. Abra o app e toque no ícone de pessoa: o Perfil mostra "Jogador" com 0 pontos.
2. Toque no lápis, tente "A" (aparece "Use pelo menos 2 caracteres.") e depois salve um apelido válido.
3. Jogue um quiz até o fim e espere "Partida salva no histórico.".
4. Abra Perfil (pontos e recorde), Histórico (expanda a partida) e Progresso (barra por assunto).
5. Feche o app pelo gerenciador de tarefas, abra de novo e mostre que tudo continua igual.
6. Explique que o id da partida e a transação impedem pontos duplicados ou gravações pela metade. Os testes automáticos provam isso.

## Limitações e próximos passos

- **Questões e conceitos no SQLite**: o UML prevê `RepositorioDeQuestoes` e `RepositorioDeConceitos`. Hoje as questões estão no código de Breno. Para mover, crie as tabelas `questao`, `alternativa` e `conceito` em uma migração v3, carregue o conteúdo inicial sem duplicar e faça o `SorteadorDeQuestoes` ler pelo contrato.
- **Conta Rápida**: o modelo já aceita `operacoes` e `tempoPorQuestao`. Falta Eduardo enviar as partidas.
- **Vários perfis no mesmo aparelho**: o modelo usa `jogador_id` em todas as tabelas. Trocar o id fixo por uma escolha de perfil não exige mudar o esquema.
- **Ranking online**: exigiria servidor e validação da pontuação no servidor (veja [Segurança](SEGURANCA.md)).
