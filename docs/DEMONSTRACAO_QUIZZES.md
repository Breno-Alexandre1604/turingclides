# Demonstração dos quizzes do Turingclides

## Abrir a cópia de integração

No PowerShell, abra a pasta que contém `pubspec.yaml`. A branch local `integracao/quizzes-offline` parte de `77dc55c`. Na última consulta ao GitHub em 24/11, `main` continuava em `cd9e308`. O commit `84c8c2b` reúne a primeira integração da Home e identifica as contribuições do protótipo de Leonardo e Lucas.

```powershell
Set-Location "$env:USERPROFILE\dev\turingclides"
$flutter = "$env:USERPROFILE\flutter\bin\flutter.bat"
$dart = "$env:USERPROFILE\flutter\bin\dart.bat"
git branch --show-current
& $flutter pub get
& $flutter analyze
& $flutter test
& $dart test -p chrome test/data/quiz_history_web_test.dart
& $flutter run -d chrome --web-port=57341
```

Para o Android, encerre a execução do Chrome com `q`. Abra o Pixel 5 e aguarde a tela inicial do Android antes de executar no dispositivo. `flutter devices` mostra o identificador atribuído ao emulador.

```powershell
& $flutter emulators --launch Pixel_5
& $flutter devices
& $flutter run -d emulator-5554
```

Para repetir a verificação do SQLite, conclua uma rodada e espere a mensagem **Partida salva no histórico**. Em outro PowerShell, encerre e reabra o app no mesmo emulador. Em **Ver histórico**, confira o mesmo modo, os pontos e a quantidade de partidas.

```powershell
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
& $adb -s emulator-5554 shell am force-stop com.example.turingclides
& $adb -s emulator-5554 shell am start -n com.example.turingclides/.MainActivity
```

## Roteiro de dois minutos

| Tempo | O que mostrar |
| --- | --- |
| 0:00–0:35 | Na Home de Leonardo e Lucas, abra **Quiz de Matemática**, mantenha **Fácil** e **1 pergunta**. Peça a dica, escolha **R$ 68,00** e confirme. Explique que 10% de 80 são 8 e 5% são 4. A camiseta fica por 80 − 12 = 68. |
| 0:35–1:05 | Toque em **Ver resultado**, **Voltar ao início** e abra **Quiz de Lógica** com a configuração padrão. Na questão com `print(total)`, escolha **9**. O feedback preserva a escolha e apresenta o gabarito **10**. |
| 1:05–1:40 | Abra **Ver execução**. A cada iteração, a tela identifica a linha, o valor de `i` e o estado de `valor` e `total`. O total passa por **3, 7 e 10**. No último passo, `print(total)` exibe **10**. Use **Anterior** e volte à questão para mostrar a pontuação preservada. |
| 1:40–2:00 | Abra **Ver resultado**, volte à Home e mostre **Ver histórico**. Expanda a partida para exibir as respostas. No Android, o registro permanece disponível após fechar e abrir o aplicativo. |

A segunda questão de Lógica fácil tem o exemplo da soma de 1 a 4. Escolha **2 perguntas** e avance da primeira para a segunda. No teste de mesa, o acumulador começa em zero, chega a **1, 3, 6 e 10** após as iterações e termina com a saída **10**.

## A parte de Breno no código

| Responsabilidade | Arquivo |
| --- | --- |
| Perguntas com quatro opções, dicas, cálculos e explicações | [Banco de Matemática](../lib/domain/games/quiz_matematica/matematica_question.dart) |
| Trechos de Dart, gabaritos e estados de execução | [Banco de Lógica](../lib/domain/games/quiz_logica/logica_question.dart) |
| Seleção, dica e confirmação de uma única resposta | [QuizSession](../lib/domain/games/quiz_compartilhado/quiz_session.dart) |
| Banco, pontuação e feedback por modo | [QuizStrategy e QuizScoringRule](../lib/domain/games/quiz_compartilhado/quiz_strategy.dart) |
| Rodada, sequência de acertos e identificador estável do resultado | [PartidaController](../lib/application/partida_controller.dart) |
| Tela compartilhada e estudo depois da confirmação | [QuizScreen](../lib/presentation/quizzes/quiz_screen.dart) e [QuizExecutionScreen](../lib/presentation/quizzes/quiz_execution_screen.dart) |

A configuração entrega uma estratégia ao controlador. Ela seleciona questões do banco do modo na dificuldade escolhida. Ambas usam a mesma regra de pontos. A estratégia de Matemática devolve a explicação do cálculo. A de Lógica disponibiliza também os passos de execução. A tela de estudo recebe apenas a questão, por isso avançar ou voltar não registra outra resposta.

O guia UML define **100 pontos por acerto**, bônus de tempo de até **50**, combo de **10** e desconto de **30** ao pedir dica. Para os limites deixados em aberto, adotamos a perda de um ponto de bônus por segundo completo e um combo de **+10 a partir do segundo acerto seguido**, limitado a **+50**. Um erro rende zero e reinicia o combo.

## Validação da integração

- Flutter 3.50.1 e Dart 3.14.0. Na cópia fora do OneDrive, as árvores Git iniciais coincidiram. Os dois testes originais passaram antes e depois da integração da Home. A falha antiga em `build\flutter_assets` não reapareceu. Sua causa continua indeterminada.
- A suíte final passou com **12 testes na VM** e **1 teste de histórico no Chrome**. Ela cobre cartão e banco corretos, seleção de quantidade e dificuldade, bloqueio após confirmar, pontuação única, retry após falha, reabertura do SQLite e rastreio em tela de 320 × 568. Executamos separadamente os dez trechos do banco de Lógica no SDK Dart e conferimos suas saídas.
- No Chrome, completamos a rodada de porcentagem e erramos deliberadamente a questão de Dart. O histórico mostrou as duas partidas. As capturas da execução local estão em `build/evidencias/`.
- No emulador Android Pixel 5, o histórico começou vazio. A questão da camiseta rendeu 128 pontos e 1/1 acerto nessa execução. Após encerrar o processo do app e reabri-lo, o histórico mostrou uma partida e o SQLite conservou o mesmo ID e as mesmas respostas. A captura está em `build/evidencias/historico-android.png`.
- Na primeira compilação Android, `:app:compileDebugKotlin` não resolveu `FlutterActivity` em `MainActivity.kt`. A compilação da versão integrada, com o plugin SQLite e os componentes do SDK disponíveis, gerou o APK sem alterações em Gradle ou na atividade Android.

## Integrações pendentes da equipe

A Conta Rápida precisa do gerador, das telas e do cronômetro de Eduardo para validar operações e a resposta no limite de 10 segundos. As pastas destinadas ao módulo são `lib/domain/games/conta_rapida/` e `lib/presentation/conta_rapida/`.

O histórico atual cobre os quizzes de um jogador local. O adaptador grava a partida e as respostas em uma única inserção identificada pela chave da rodada. Perfil, recordes e progresso são calculados a partir das partidas salvas. O Android usa `turingclides_quizzes.db`. O Chrome usa o armazenamento local da origem e do perfil do navegador. Quando chegar o esquema de Renan em `lib/data/sqlite/`, o ponto para ligar seus repositórios é [QuizHistoryRepository](../lib/data/quiz_history_repository.dart).

O plano de equipe vigente adota o escopo offline. Login, Firebase, ranking online, chat e IA pertencem à proposta inicial. O plano da equipe registra o repositório público como exigência informada do professor. Não foi localizada exigência formal de login ou de serviços online. O diagnóstico `LEIA_PRIMEIRO.md` não foi localizado nas pastas de contexto examinadas.
