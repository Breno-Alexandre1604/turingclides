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
