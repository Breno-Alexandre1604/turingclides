# Turingclides

Aplicativo educacional para Android, feito em Flutter e Dart, com três mini-jogos de matemática e lógica. Funciona offline: o perfil, as partidas, os recordes e o progresso ficam em SQLite no próprio celular.

Trabalho da disciplina de Desenvolvimento Mobile (UNIPÊ), com o projeto orientado a objetos de Análise e Projeto de Sistemas II (UML, Strategy e SOLID).

## Funcionalidades

| Mini-jogo | O que faz |
| --- | --- |
| **Conta Rápida** | Contas de cabeça geradas na hora (soma, subtração, multiplicação e divisão), 3 níveis, 10 segundos por conta, bônus de tempo e combo |
| **Quiz de Matemática** | 10 questões de 4 alternativas em 3 níveis, com dica (−30 pontos) e explicação passo a passo |
| **Quiz de Lógica** | 10 trechos de código Dart: "qual é a saída?", com teste de mesa linha a linha |

Também há **Perfil** (apelido, pontos, recordes por jogo, tema claro ou escuro, apagar meus dados), **Histórico** (cada partida e cada resposta) e **Progresso** (taxa de acerto por assunto), em abas que trocam deslizando o dedo. A Home mostra os pontos, o acerto e os recordes do jogador.

## Equipe

| Frente | Responsável |
| --- | --- |
| Estrutura, tema, Home, navegação e integração | Leonardo e Lucas |
| Conta Rápida | Eduardo |
| Quiz de Matemática e Quiz de Lógica | Breno |
| Dados e progresso (SQLite, perfil, histórico, recordes), segurança do APK e CI | Renan |

Detalhes de quem fez cada parte e do estado de cada uma: [docs/VISAO_GERAL.md](docs/VISAO_GERAL.md).

## Instalar e executar

Pré-requisitos: [Flutter](https://docs.flutter.dev/get-started/install) 3.50 ou mais novo (Dart 3.14) e, para Android, o Android Studio (Android SDK 36 e JDK 17 ou 21). Confira com `flutter doctor`.

Na pasta que contém `pubspec.yaml`:

```powershell
flutter pub get
flutter run
```

No VS Code, também dá para iniciar com **F5**, escolhendo um emulador ou celular. Para abrir no navegador: `flutter run -d chrome`.

### Testes e análise

```powershell
flutter analyze
flutter test
```

O GitHub Actions roda os dois a cada push e pull request e gera um APK de teste (aba **Actions**, artefato `turingclides-apk`).

### APK

```powershell
.\tool\gerar_apk_release.ps1
```

O script roda a análise e os testes e gera `build\app\outputs\flutter-apk\app-release.apk`, com o código ofuscado. Assinatura com a chave da equipe, instalação no celular e regras de segurança: [docs/SEGURANCA.md](docs/SEGURANCA.md).

## Organização do código

| Pasta | Conteúdo |
| --- | --- |
| `lib/presentation/` | Telas: Home, configuração, quizzes, Conta Rápida, perfil, histórico e progresso |
| `lib/application/` | Controlador da partida dos quizzes e serviços de perfil e de progresso |
| `lib/domain/games/` | Regras dos jogos: bancos de questões, pontuação, feedback e gerador de contas |
| `lib/domain/contracts/` | Contratos dos repositórios |
| `lib/domain/models/` | Jogador, Partida, respostas, progresso e resultado dos quizzes |
| `lib/data/` | SQLite (Android), memória e navegador |
| `test/` | Testes de regras, de dados e de telas |

As questões ficam em `lib/domain/games/quiz_matematica/` e `lib/domain/games/quiz_logica/`. O fluxo compartilhado dos quizzes e a sessão que trava a resposta depois da confirmação ficam em `lib/domain/games/quiz_compartilhado/`.

## Documentação

| Documento | Conteúdo |
| --- | --- |
| [Visão geral](docs/VISAO_GERAL.md) | O que é o app, quem faz cada parte, o que o jogador vê em cada tela e como as peças se conectam |
| [Apresentação](docs/APRESENTACAO.md) | Roteiro, checklist de entrega e perguntas prováveis |
| [Dados e progresso](docs/DADOS_E_PROGRESSO.md) | SQLite, perfil local, histórico, recordes e progresso por assunto |
| [Identidade visual](docs/IDENTIDADE_VISUAL.md) | Ícone, regras de espaço e cor, modo claro e escuro, rolagem |
| [Segurança do APK](docs/SEGURANCA.md) | Regras de segurança, como gerar e instalar o APK e próximas melhorias |
| [Demonstração dos quizzes](docs/DEMONSTRACAO_QUIZZES.md) | Roteiro de apresentação dos quizzes (Breno) |
| [Estrutura de pastas](docs/ESTRUTURA_TURINGCLIDES.md) | Onde cada arquivo deve ficar |
