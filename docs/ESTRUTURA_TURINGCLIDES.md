# Organização do Turingclides

Aplicativo Flutter e Dart desenvolvido no Android Studio. Abra a pasta que contém pubspec.yaml. O ponto de entrada do aplicativo é lib/main.dart.

| Pasta | O que colocar aqui |
| --- | --- |
| `lib/app/` | Inicialização do app, tema e rotas. Leonardo e Lucas conectam a Home aos três modos. |
| `lib/presentation/home/` | Tela inicial e seleção do modo de jogo. |
| `lib/presentation/widgets/` | Componentes visuais utilizados por mais de uma tela, como o painel de pontos. |
| `lib/application/` | Coordenação das partidas. O controlador recebe respostas e chama as regras do jogo e os repositórios. |
| `lib/domain/contracts/` | Interfaces para a fonte de perguntas, regra de pontuação, estratégia de feedback e repositórios. |
| `lib/domain/models/` | Modelos usados em mais de um módulo, como Jogador, Partida e Resultado. |
| `lib/domain/games/conta_rapida/` | Eduardo mantém o gerador de operações e as regras específicas de Conta Rápida. |
| `lib/domain/games/quiz_compartilhado/` | Breno mantém aqui a seleção de alternativas, o uso de dicas e a pontuação comum aos dois quizzes. |
| `lib/domain/games/quiz_matematica/` | Breno implementa as regras e explicações específicas de Matemática. |
| `lib/domain/games/quiz_logica/` | Breno implementa a interpretação das questões de código e o teste de mesa. |
| `lib/presentation/conta_rapida/` | Configuração, entrada numérica e cronômetro da Conta Rápida. |
| `lib/presentation/quizzes/` | Tela compartilhada dos quizzes e componentes próprios de Matemática e Lógica. |
| `lib/data/sqlite/` | Renan mantém o esquema local, a abertura do banco e a implementação dos repositórios em SQLite. |
| `lib/presentation/progresso/` | Perfil, histórico, recordes e progresso por assunto. |
| `assets/data/` | Questões e conceitos que acompanham o aplicativo. Ao incluir os arquivos reais, declare os assets no pubspec.yaml. |
| `test/domain/` | Testes de regras dos jogos, como pontuação, combo e desconto por dica. |
| `test/data/` | Testes de persistência, recuperação de partidas e integridade dos pontos. |
| `test/widgets/` | Testes de interação com as telas Flutter. |

## Exemplo para os quizzes

Uma questão sobre porcentagem entra em assets/data. A regra que desconta pontos ao usar uma dica fica em lib/domain/games/quiz_compartilhado. A tela que mostra as alternativas fica em lib/presentation/quizzes. A gravação do resultado passa pelo contrato de repositório e pela implementação em lib/data/sqlite.

Os arquivos .gitkeep permitem que o Git registre as pastas enquanto estão vazias. Podem ser removidos quando a pasta receber seu primeiro arquivo.
