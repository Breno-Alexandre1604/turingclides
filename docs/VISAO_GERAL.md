# Turingclides: visão geral do projeto

Situação em 25/11/2026, data da entrega oficial, na branch `release/v1.0.0`. Este documento explica o que é o app, quem faz cada parte, o que o jogador vê em cada tela e como as peças se conectam por dentro.

Documentos relacionados:

- [Dados e progresso](DADOS_E_PROGRESSO.md): a frente de Renan (SQLite, perfil, histórico, recordes e progresso).
- [Segurança do APK](SEGURANCA.md): regras de segurança, como gerar e instalar o APK e o que pode melhorar.
- [Apresentação](APRESENTACAO.md): roteiro de hoje, checklist e onde está cada coisa.
- [Demonstração dos quizzes](DEMONSTRACAO_QUIZZES.md): roteiro de apresentação escrito por Breno.
- [Estrutura de pastas](ESTRUTURA_TURINGCLIDES.md): onde cada arquivo deve ficar.

## O que é

O Turingclides é um aplicativo educacional para Android, feito em Flutter e Dart para a disciplina de Desenvolvimento Mobile (UNIPÊ). O projeto também aplica o conteúdo de Análise e Projeto de Sistemas II: diagramas UML, o padrão Strategy e os princípios SOLID.

O app tem três mini-jogos que seguem o mesmo ciclo (pergunta, resposta, pontos e explicação):

| Mini-jogo | Ideia |
| --- | --- |
| Conta Rápida | Contas de cabeça geradas na hora, com 10 segundos por conta. |
| Quiz de Matemática | Questões de 4 alternativas até o nível ENEM, com dica e explicação passo a passo. |
| Quiz de Lógica | Trechos de código Dart com a pergunta "qual é a saída?" e explicação por teste de mesa. |

O app funciona offline. Não tem login, servidor nem internet. Cada aparelho tem um perfil local, e partidas, recordes e progresso ficam guardados em SQLite no próprio celular. Ranking online, comunidade, chat e IA ficaram para uma versão futura.

## Quem faz o quê

Esta divisão segue o plano da equipe (cartões do Trello). A coluna da direita mostra o que existe no GitHub hoje.

| Frente | Responsável | O que entrega | Estado no GitHub |
| --- | --- | --- | --- |
| Estrutura e integração | Leonardo (tema, Home, componentes visuais) e Lucas (projeto, navegação, integração) | Projeto Flutter, tema, Home, configuração da atividade, componentes reutilizáveis e ligação dos módulos | O protótipo dos dois (Home, cartões dos modos, botão principal, tela de configuração e rotas) foi integrado por Breno na branch `integracao/quizzes-offline` |
| Conta Rápida | Eduardo | Gerador de contas por dificuldade, cronômetro de 10 s, pontuação, combo e feedback | O código de Eduardo não chegou ao repositório. Para fechar a entrega, a Conta Rápida foi implementada na `release/v1.0.0` seguindo o guia UML e as regras do cartão C1 (`lib/domain/games/conta_rapida/`). Eduardo pode revisar e trocar pela versão dele |
| Quiz de Matemática e Quiz de Lógica | Breno | Banco de questões, alternativas, dica, pontuação compartilhada, explicação e teste de mesa | Pronto em `integracao/quizzes-offline`: 10 questões por quiz em 3 níveis, com testes automatizados |
| Dados e progresso | Renan | SQLite, perfil local, histórico, recordes e progresso por assunto | Branch `feat/dados-progresso`, depois incorporada à `release/v1.0.0`. Substitui a versão mínima do histórico que Breno tinha feito para a demonstração. Renan também fez a segurança do APK, o CI e a documentação |

### Branches

| Branch | Conteúdo |
| --- | --- |
| `main` | Projeto Flutter inicial |
| `chore/estrutura-pastas` | Branch padrão do GitHub: estrutura de pastas e guia `ESTRUTURA_TURINGCLIDES.md` |
| `feat/quizzes-breno` | Primeira rodada dos quizzes |
| `integracao/quizzes-offline` | Versão integrada mais recente: Home, configuração, os dois quizzes e histórico |
| `feat/dados-progresso` | `integracao/quizzes-offline` mais a frente Dados e progresso e as regras de segurança do APK |
| `release/v1.0.0` | **Versão de entrega**: tudo acima, mais a Conta Rápida, as melhorias de segurança, o CI e o Dependabot |

## O que o jogador vê, tela a tela

O app tem um único tipo de usuário: o jogador (estudante). Não existe área de professor nem de administrador.

### 1. Home

- Título **Aprenda jogando!** e o texto "Escolha uma atividade para começar."
- Três cartões: Conta Rápida, Quiz de Matemática e Quiz de Lógica.
- Botões **Ver histórico** e **Ver progresso**.
- Ícone de pessoa no canto superior, que abre o **Perfil**.

### 2. Conta Rápida

- **Configurar Conta Rápida**: marque as operações (soma, subtração, multiplicação, divisão; pelo menos uma fica marcada), o nível e a quantidade de contas (5, 10 ou 15).
- **Partida**: "Conta X de N · nível", pontos, barra do cronômetro de 10 segundos, a conta em letras grandes e o campo numérico. Responder com Enter ou com o botão. Resposta vazia não é enviada.
- Feedback curto: "Acertou!" (com os pontos), "Errou." ou "Tempo esgotado!", sempre com o resultado certo. Depois de responder, o tempo acabar não conta de novo.
- **Resultado**: acertos, pontuação, a lista de contas com o tempo de cada uma e o estado da gravação, com "Jogar de novo" e "Voltar ao início".

### 3. Configurar atividade (quizzes)

- Nome do quiz escolhido.
- **Dificuldade**: Fácil, Médio ou Difícil. Só aparecem os níveis que têm questões.
- **Quantidade de perguntas**: de 1 até o total disponível no nível.
- Botão **Começar**.

### 4. Pergunta (os dois quizzes)

- Cabeçalho "Questão X de N · nível" e os pontos acumulados na rodada.
- Enunciado. No Quiz de Lógica, aparece também o trecho de código Dart com as linhas numeradas.
- Quatro alternativas (A a D).
- **Mostrar dica (−30 no acerto)**: a dica desconta pontos uma única vez.
- **Confirmar resposta**: trava a escolha, para que não dê para trocar depois de ver o gabarito.
- Feedback "Resposta correta!" ou "Resposta incorreta.", com a resposta escolhida, o gabarito e a explicação passo a passo.
- Só no Quiz de Lógica: **Ver execução** abre o **Teste de mesa**. Ele mostra, passo a passo, a linha executada, o valor das variáveis e a saída, com os botões Anterior e Próximo.
- **Próxima questão** ou, na última, **Ver resultado**.

### 5. Resultado dos quizzes

- **Atividade concluída!**, com o modo, o nível, os acertos e a pontuação.
- O estado da gravação: "Salvando partida…", "Partida salva no histórico." ou, se falhar, "Não foi possível confirmar o salvamento da partida." com o botão **Tentar salvar novamente**. Tentar de novo nunca duplica pontos.
- **Voltar ao início**.

### 6. Perfil (frente de Renan)

- Apelido do jogador, com o botão de lápis para editar. No primeiro uso, o apelido é "Jogador".
- Pontos totais e quantidade de partidas.
- Total de respostas certas e a porcentagem de acerto geral.
- **Recordes por modo**: a maior pontuação de uma partida em cada jogo.
- Aviso de que os dados ficam só no aparelho e de que não é preciso usar o nome real.
- **Apagar meus dados**: pede confirmação e apaga apelido, partidas, recordes e progresso.

### 7. Histórico

- Um cartão por partida, da mais recente para a mais antiga, com modo, pontos, nível, data, hora e acertos (por exemplo, "3/5 acertos").
- Ao tocar no cartão, aparece cada resposta: ícone de certo ou errado, enunciado, resposta dada, gabarito, se usou dica e os pontos ganhos.

### 8. Progresso

- Agrupado por jogo (Quiz de Matemática, Quiz de Lógica).
- Para cada assunto (Porcentagem, Laços de repetição...), uma barra de acerto, o texto "X de Y respostas corretas" e a porcentagem.

## Regras de pontuação

| Situação | Pontos |
| --- | --- |
| Acerto | 100 |
| Bônus de tempo | até +50, perdendo 1 ponto por segundo |
| Combo (acertos seguidos) | +10 por acerto seguido a partir do segundo, até +50 |
| Dica | −30, se acertar |
| Erro | 0, e o combo zera |

Na Conta Rápida não há dica, o bônus de tempo é proporcional ao tempo que sobrou dos 10 segundos (responder na hora vale +50, no último instante +0) e o tempo esgotado vale 0 e zera o combo.

| Nível da Conta Rápida | Soma e subtração | Multiplicação e divisão |
| --- | --- | --- |
| Fácil | parcelas de 1 a 10 | fatores de 1 a 10 |
| Médio | 10 a 99 | 2 a 15 |
| Difícil | 100 a 999 | 6 a 30 |

A subtração nunca dá negativo e a divisão é sempre exata.

## Como funciona por dentro

O app segue as camadas do guia UML. Cada camada só conversa com a de baixo, e só por meio de contratos:

```
Telas (lib/presentation)          o que o jogador vê e toca
   │
Controle (lib/application)        PartidaController, ServicoDePerfil, ServicoDeProgresso
   │
Jogo (lib/domain/games)           QuizStrategy e RodadaContaRapida: perguntas + pontuação + feedback
   │
Contratos (lib/domain/contracts)  RepositorioDeJogadores, RepositorioDePartidas, RepositorioDeProgresso
   │
Banco local (lib/data)            SQLite no Android, localStorage no navegador
```

O padrão Strategy aparece nos quizzes: `QuizStrategy` reúne o banco de questões, a regra de pontos e o feedback de cada modo. A tela e o controlador são os mesmos para Matemática e Lógica. Só mudam as peças. A Conta Rápida usa as peças do guia UML com os mesmos nomes: `GeradorDeContas`, `PontuacaoRapida` e `FeedbackRapido`, coordenadas pela `RodadaContaRapida`.

### Uma partida do começo ao fim

1. A Home abre a configuração com a estratégia do quiz escolhido.
2. O `PartidaController` sorteia as questões do nível, cronometra cada resposta, calcula os pontos e o combo e gera um id único para a partida.
3. No fim, o controlador entrega um `QuizResult` à tela de resultado.
4. A tela de resultado chama `save(result)`. Esse contrato agora é atendido por `DadosLocais`, a porta de entrada da frente Dados e progresso.
5. `DadosLocais` converte o resultado em `Partida` e, em uma única transação SQLite, grava a partida, as respostas, o progresso por assunto e os pontos do jogador. Se a mesma partida chegar de novo, nada muda.
6. Perfil, Histórico e Progresso leem esses dados pelos serviços.

## Como rodar

Na pasta que contém `pubspec.yaml`:

```powershell
flutter pub get
flutter analyze
flutter test
flutter run
```

Para gerar o APK, veja [Segurança do APK](SEGURANCA.md#como-gerar-e-instalar-o-apk).

## O que ainda falta para a entrega

1. **Juntar na `main` e marcar `v1.0.0`**: a `release/v1.0.0` já contém tudo e passa no CI. Falta a equipe aprovar o pull request para a `main` e criar a tag.
2. **APK no aparelho da demonstração**: instalar, jogar os três modos, fechar e reabrir e conferir histórico e pontos. Veja [Segurança do APK](SEGURANCA.md#como-gerar-e-instalar-o-apk).
3. **Proteção da `main`** (dono do repositório): exigir pull request com revisão e o CI passando antes de juntar.
4. **Depois da entrega**: questões e conceitos no SQLite (`RepositorioDeQuestoes` e `RepositorioDeConceitos` do UML). Hoje as questões estão no código Dart de Breno, o que funciona offline.
