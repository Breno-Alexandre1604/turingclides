# Turingclides: visão geral do projeto

Situação em 25/11/2026, data da entrega oficial. Este documento explica o que é o app, quem faz cada parte, o que o jogador vê em cada tela e como as peças se conectam por dentro.

Documentos relacionados:

- [Dados e progresso](DADOS_E_PROGRESSO.md): a frente de Renan (SQLite, perfil, histórico, recordes e progresso).
- [Segurança do APK](SEGURANCA.md): regras de segurança, como gerar e instalar o APK e o que pode melhorar.
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
| Conta Rápida | Eduardo | Gerador de contas por dificuldade, cronômetro de 10 s, pontuação, combo e feedback | **Ainda não está no repositório.** Na Home, o cartão aparece desativado com o texto "Aguardando integração das operações com cronômetro." |
| Quiz de Matemática e Quiz de Lógica | Breno | Banco de questões, alternativas, dica, pontuação compartilhada, explicação e teste de mesa | Pronto em `integracao/quizzes-offline`: 10 questões por quiz em 3 níveis, com testes automatizados |
| Dados e progresso | Renan | SQLite, perfil local, histórico, recordes e progresso por assunto | Branch `feat/dados-progresso`, criada a partir de `integracao/quizzes-offline`. Substitui a versão mínima do histórico que Breno tinha feito para a demonstração |

### Branches

| Branch | Conteúdo |
| --- | --- |
| `main` | Projeto Flutter inicial |
| `chore/estrutura-pastas` | Branch padrão do GitHub: estrutura de pastas e guia `ESTRUTURA_TURINGCLIDES.md` |
| `feat/quizzes-breno` | Primeira rodada dos quizzes |
| `integracao/quizzes-offline` | Versão integrada mais recente: Home, configuração, os dois quizzes e histórico |
| `feat/dados-progresso` | Esta entrega: `integracao/quizzes-offline` mais a frente Dados e progresso e as regras de segurança do APK |

## O que o jogador vê, tela a tela

O app tem um único tipo de usuário: o jogador (estudante). Não existe área de professor nem de administrador.

### 1. Home

- Título **Aprenda jogando!** e o texto "Escolha uma atividade para começar."
- Três cartões: Conta Rápida (desativado), Quiz de Matemática e Quiz de Lógica.
- Botões **Ver histórico** e **Ver progresso**.
- Ícone de pessoa no canto superior, que abre o **Perfil**.

### 2. Configurar atividade

- Nome do quiz escolhido.
- **Dificuldade**: Fácil, Médio ou Difícil. Só aparecem os níveis que têm questões.
- **Quantidade de perguntas**: de 1 até o total disponível no nível.
- Botão **Começar**.

### 3. Pergunta (os dois quizzes)

- Cabeçalho "Questão X de N · nível" e os pontos acumulados na rodada.
- Enunciado. No Quiz de Lógica, aparece também o trecho de código Dart com as linhas numeradas.
- Quatro alternativas (A a D).
- **Mostrar dica (−30 no acerto)**: a dica desconta pontos uma única vez.
- **Confirmar resposta**: trava a escolha, para que não dê para trocar depois de ver o gabarito.
- Feedback "Resposta correta!" ou "Resposta incorreta.", com a resposta escolhida, o gabarito e a explicação passo a passo.
- Só no Quiz de Lógica: **Ver execução** abre o **Teste de mesa**. Ele mostra, passo a passo, a linha executada, o valor das variáveis e a saída, com os botões Anterior e Próximo.
- **Próxima questão** ou, na última, **Ver resultado**.

### 4. Resultado

- **Atividade concluída!**, com o modo, o nível, os acertos e a pontuação.
- O estado da gravação: "Salvando partida…", "Partida salva no histórico." ou, se falhar, "Não foi possível confirmar o salvamento da partida." com o botão **Tentar salvar novamente**. Tentar de novo nunca duplica pontos.
- **Voltar ao início**.

### 5. Perfil (novo, frente de Renan)

- Apelido do jogador, com o botão de lápis para editar. No primeiro uso, o apelido é "Jogador".
- Pontos totais e quantidade de partidas.
- Total de respostas certas e a porcentagem de acerto geral.
- **Recordes por modo**: a maior pontuação de uma partida em cada jogo.
- Aviso de que os dados ficam só no aparelho e de que não é preciso usar o nome real.
- **Apagar meus dados**: pede confirmação e apaga apelido, partidas, recordes e progresso.

### 6. Histórico

- Um cartão por partida, da mais recente para a mais antiga, com modo, pontos, nível, data, hora e acertos (por exemplo, "3/5 acertos").
- Ao tocar no cartão, aparece cada resposta: ícone de certo ou errado, enunciado, resposta dada, gabarito, se usou dica e os pontos ganhos.

### 7. Progresso

- Agrupado por jogo (Quiz de Matemática, Quiz de Lógica).
- Para cada assunto (Porcentagem, Laços de repetição...), uma barra de acerto, o texto "X de Y respostas corretas" e a porcentagem.

## Regras de pontuação dos quizzes

| Situação | Pontos |
| --- | --- |
| Acerto | 100 |
| Bônus de tempo | até +50, perdendo 1 ponto por segundo |
| Combo (acertos seguidos) | +10 por acerto seguido a partir do segundo, até +50 |
| Dica | −30, se acertar |
| Erro | 0, e o combo zera |

A Conta Rápida usa as mesmas faixas no guia UML (sem dica), mas a implementação depende de Eduardo.

## Como funciona por dentro

O app segue as camadas do guia UML. Cada camada só conversa com a de baixo, e só por meio de contratos:

```
Telas (lib/presentation)          o que o jogador vê e toca
   │
Controle (lib/application)        PartidaController, ServicoDePerfil, ServicoDeProgresso
   │
Jogo (lib/domain/games)           QuizStrategy: banco de questões + pontuação + feedback
   │
Contratos (lib/domain/contracts)  RepositorioDeJogadores, RepositorioDePartidas, RepositorioDeProgresso
   │
Banco local (lib/data)            SQLite no Android, localStorage no navegador
```

O padrão Strategy aparece nos quizzes: `QuizStrategy` reúne o banco de questões, a regra de pontos e o feedback de cada modo. A tela e o controlador são os mesmos para Matemática e Lógica. Só mudam as peças.

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

1. **Conta Rápida (Eduardo)**: integrar o jogo e gravar o resultado com `dadosLocais.progresso.registrarPartida(...)`. O exemplo de código está em [Dados e progresso](DADOS_E_PROGRESSO.md#conta-rápida-eduardo).
2. **Integrar as branches**: revisar e juntar `feat/dados-progresso` em `integracao/quizzes-offline` e depois em `main`. Marcar a versão `v1.0.0`.
3. **APK no aparelho da demonstração**: gerar o APK, instalar, jogar, fechar e reabrir, e conferir histórico e pontos.
4. **README**: completar instalação, funcionalidades e divisão da equipe (critério do plano).
5. **Questões e conceitos no banco**: no UML, as questões e os cartões de conceito também ficam no SQLite (`RepositorioDeQuestoes` e `RepositorioDeConceitos`). Hoje as questões estão no código Dart de Breno, o que funciona offline. Mover para o banco fica para depois da entrega.
