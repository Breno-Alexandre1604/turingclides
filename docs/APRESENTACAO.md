# Apresentação de 25/11/2026

Roteiro, checklist de entrega e respostas para as perguntas mais prováveis. Versão apresentada: branch `release/v1.0.0`.

## Onde está cada coisa

| O quê | Onde |
| --- | --- |
| Código final | Branch `release/v1.0.0` no GitHub |
| APK de teste | GitHub → Actions → execução mais recente do **CI** na `release/v1.0.0` → artefato `turingclides-apk` (assinado com a chave de debug) |
| APK assinado pela equipe | Gerado com `.\tool\gerar_apk_release.ps1` na máquina que tem `android\key.properties` (veja [Segurança](SEGURANCA.md)) |
| Visão geral, telas e equipe | [VISAO_GERAL.md](VISAO_GERAL.md) |
| Dados e progresso | [DADOS_E_PROGRESSO.md](DADOS_E_PROGRESSO.md) |
| Ícone, cores, modo escuro e rolagem | [IDENTIDADE_VISUAL.md](IDENTIDADE_VISUAL.md) |
| Segurança e instalação do APK | [SEGURANCA.md](SEGURANCA.md) |
| Roteiro detalhado dos quizzes | [DEMONSTRACAO_QUIZZES.md](DEMONSTRACAO_QUIZZES.md) |

## Checklist do plano (critérios de 23/11)

| Critério | Situação | Como foi verificado |
| --- | --- | --- |
| Os três jogos iniciam, recebem respostas, dão feedback e concluem a partida | Feito | Testes de tela: `widget_test.dart` (quizzes) e `conta_rapida_screen_test.dart` |
| Conta Rápida trata erro, tempo esgotado e resposta duplicada | Feito | `conta_rapida_test.dart` e `conta_rapida_screen_test.dart` |
| Quizzes mostram alternativas, dicas e explicações corretas | Feito | Testes de Breno |
| Lógica mostra código legível e teste de mesa coerente | Feito | `quiz_execution_test.dart` |
| Perfil, partidas e progresso continuam após reiniciar | Feito | `dados_sqlite_test.dart` fecha e reabre o banco. **Conferir também no celular** |
| Salvar de novo a mesma partida não duplica pontos | Feito | Contrato dos dados (simultâneo e após reabrir) |
| Navegação, teclado e cronômetros funcionam ao sair e voltar | Feito | Teste "sair no meio da conta cancela o cronômetro" e foco do campo |
| `flutter analyze` e testes executados | Feito | 0 problemas, 61 testes; o CI repete a cada push |
| README com instalação, execução, funcionalidades e equipe | Feito | `README.md` |
| APK conferido no aparelho da demonstração | **Pendente** | Instalar, jogar os três modos, fechar e reabrir |
| Versão final identificada no GitHub | **Pendente** | Aprovar o pull request da `release/v1.0.0` para a `main` e criar a tag `v1.0.0` |

## Roteiro sugerido (cerca de 5 minutos)

| Tempo | Quem | O que mostrar |
| --- | --- | --- |
| 0:00 a 0:30 | Leonardo e Lucas | Home com os três modos, tema e navegação. As camadas do app (telas, controle, jogo, contratos, banco) |
| 0:30 a 1:30 | Eduardo | Conta Rápida: marque soma e multiplicação, nível Fácil. Acerte uma conta e deixe outra estourar os 10 s. Mostre o resultado com o tempo de cada conta |
| 1:30 a 3:00 | Breno | Quiz de Matemática com dica e explicação. Quiz de Lógica com o teste de mesa ([roteiro dele](DEMONSTRACAO_QUIZZES.md)) |
| 3:00 a 4:15 | Renan | "Partida salva no histórico" e a Home já com pontos e recorde. Perfil: tente o apelido "A" (recusado) e salve um válido; troque para o modo Escuro. Deslize para Histórico e Progresso. Feche o app pelo gerenciador de tarefas, abra de novo e mostre que tudo continua, tema incluído |
| 4:15 a 5:00 | Renan | Segurança: sem internet, sem backup, chave fora do Git, CI com testes a cada push |

## Se algo der errado

- **O APK não instala por cima da versão antiga**: a assinatura mudou. Desinstale o app antigo e instale de novo.
- **Sem celular ou sem cabo**: rode `flutter run -d chrome` no notebook. O app web usa os mesmos contratos de dados.
- **"Não foi possível confirmar o salvamento"**: toque em "Tentar salvar novamente". Não duplica pontos.
- **Histórico vazio depois de reinstalar**: é esperado. Desinstalar apaga os dados do app, e o backup está desligado de propósito.

## Perguntas prováveis e respostas curtas

**Onde está o padrão Strategy?**
Nas peças que variam por jogo. Nos quizzes, `QuizStrategy` reúne banco de questões, pontuação e feedback. Na Conta Rápida, `GeradorDeContas`, `PontuacaoRapida` e `FeedbackRapido`. A tela e o fluxo não mudam; só as peças.

**Onde aparecem os princípios SOLID?**
- Responsabilidade única: o controlador coordena, o serviço cuida do progresso, o repositório grava.
- Aberto/fechado: um jogo novo entra com classes novas.
- Liskov e segregação de interfaces: contratos pequenos em vez de herança forçada.
- Inversão de dependência: jogos e serviços conhecem `RepositorioDePartidas`, nunca o SQLite. Por isso os testes rodam com dados em memória.

**Como vocês garantem que os pontos não duplicam?**
Cada partida tem um id gerado no celular. A gravação acontece em uma transação que confere o id antes de inserir. Se o id já existe, nada muda. Se algo falha no meio, a transação desfaz tudo.

**E se o app fechar no meio da gravação?**
O SQLite desfaz a transação incompleta. A partida ou entra inteira (respostas, progresso e pontos), ou não entra.

**Por que não tem login?**
O escopo do MVP é offline, com um perfil local por aparelho. O único dado pessoal é o apelido, e o app avisa para não usar o nome real.

**Por que as questões não estão no banco?**
Para a entrega, as 20 questões ficam no código Dart e o app funciona offline. Movê-las para o SQLite (como no diagrama 6A) é o próximo passo.

**O que impede alguém de trapacear na pontuação?**
Sem ranking online não há o que proteger entre jogadores. A validação recusa dados impossíveis. Se um dia houver ranking, a pontuação precisa ser validada no servidor.
