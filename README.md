# Turingclides

Aplicativo educacional em Flutter. A tela inicial temporária permite demonstrar
uma questão do Quiz de Matemática e uma do Quiz de Lógica, com seleção,
confirmação, feedback e encerramento.

## Executar

Abra no VS Code a pasta que contém `pubspec.yaml` e rode no terminal:

```powershell
flutter pub get
flutter run -t lib/main.dart
```

Também é possível iniciar pelo VS Code com **F5**, selecionando um emulador ou
dispositivo. A suíte de testes pode ser executada com:

```powershell
flutter test
```

## Questões dos quizzes

As questões locais ficam em `lib/domain/games/quiz_matematica/` e
`lib/domain/games/quiz_logica/`. O fluxo compartilhado e a sessão que bloqueia
alterações depois da confirmação ficam em
`lib/domain/games/quiz_compartilhado/`; a tela comum está em
`lib/presentation/quizzes/`.

## Documentação

| Documento | Conteúdo |
| --- | --- |
| [Visão geral](docs/VISAO_GERAL.md) | O que é o app, quem faz cada parte, o que o jogador vê em cada tela e como as peças se conectam |
| [Dados e progresso](docs/DADOS_E_PROGRESSO.md) | SQLite, perfil local, histórico, recordes e progresso por assunto (Renan) |
| [Segurança do APK](docs/SEGURANCA.md) | Regras de segurança, como gerar e instalar o APK e próximas melhorias |
| [Demonstração dos quizzes](docs/DEMONSTRACAO_QUIZZES.md) | Roteiro de apresentação dos quizzes (Breno) |
| [Estrutura de pastas](docs/ESTRUTURA_TURINGCLIDES.md) | Onde cada arquivo deve ficar |

Para gerar o APK de release com análise, testes e ofuscação:

```powershell
.\tool\gerar_apk_release.ps1
```
