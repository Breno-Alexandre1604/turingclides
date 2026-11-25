# Segurança do APK

Este documento lista as regras de segurança do Turingclides para Android, mostra como gerar e instalar o APK e indica o que ainda pode melhorar.

## Contra o que estamos protegendo

O app é offline, não tem conta nem servidor. O único dado pessoal é o apelido. Os riscos reais são:

| Risco | Exemplo |
| --- | --- |
| Dados saindo do aparelho | Backup automático no Google Drive ou transferência para um celular novo levando o banco |
| Tráfego de rede inseguro | Uma biblioteca futura acessando a internet por HTTP |
| Entrada maliciosa ou corrompida | Apelido com comando SQL, partida com pontos negativos, conteúdo adulterado no navegador |
| Gravação inconsistente | App fechado no meio da gravação deixando pontos sem partida |
| Chave de assinatura vazada | `key.properties` ou `.jks` enviados ao GitHub público |
| Engenharia reversa | Leitura fácil do código a partir do APK |

## Regras implementadas

| # | Regra | Onde | Por quê |
| --- | --- | --- | --- |
| 1 | **Sem permissão de internet no release.** O manifesto principal não pede `INTERNET`. Só os manifestos de debug e profile pedem, porque o `flutter run` usa a rede para hot reload | `android/app/src/main/AndroidManifest.xml` | O app é offline. Sem a permissão, nenhum código (nem de biblioteca) consegue enviar dados |
| 2 | **Sem backup dos dados**: `allowBackup="false"` e `dataExtractionRules` excluindo tudo do backup na nuvem e da transferência entre aparelhos (Android 12+) | Manifesto e `res/xml/data_extraction_rules.xml` | O banco não vai para o Google Drive, para outro celular nem para `adb backup` |
| 3 | **Só HTTPS**: `usesCleartextTraffic="false"` e `network_security_config.xml` aceitando apenas certificados do sistema | Manifesto e `res/xml/network_security_config.xml` | Se um dia o app acessar a internet, HTTP em texto puro e certificados instalados pelo usuário já ficam bloqueados |
| 4 | **Banco na pasta privada do app**, com `PRAGMA foreign_keys = ON` e `PRAGMA secure_delete = ON` | `lib/data/sqlite/banco_local.dart` | Outros apps não leem o arquivo. Relações sempre válidas. O conteúdo apagado é sobrescrito no arquivo |
| 5 | **SQL sempre com parâmetros (`?`)**, nunca texto concatenado | `lib/data/sqlite/*.dart` | Impede injeção de SQL. Um teste grava `'; DROP TABLE partida; --` e lê de volta como texto comum |
| 6 | **Validação de entrada**: apelido com 2 a 20 caracteres, só letras, números, espaço e `_ . -`; partida recusada com pontos negativos ou acima de 1000 por resposta, resposta errada com pontos, id fora do formato ou textos longos demais | `lib/domain/models/apelido.dart` e `partida.dart` | Dados impossíveis não entram, venham da tela, de um bug ou de adulteração |
| 7 | **Defesa em profundidade no banco**: `CHECK`, chaves estrangeiras e `UNIQUE` repetem as regras principais | `criarEsquema` em `banco_local.dart` | Mesmo que alguém pule a validação do Dart, o SQLite recusa |
| 8 | **Gravação atômica e idempotente**: partida, respostas, progresso e pontos em uma transação; o id da partida impede contar duas vezes | `lib/data/sqlite/partidas_sqlite.dart` | Nada fica pela metade e tentar de novo é sempre seguro |
| 9 | **Dados do navegador conferidos ao carregar**: conteúdo corrompido ou adulterado no localStorage é descartado em vez de travar o app | `lib/data/memoria/armazem_em_memoria.dart` | Robustez na versão web de demonstração |
| 10 | **Erros sem detalhes técnicos na tela** e nenhum `print` de dados | Telas de resultado e de perfil; regra `avoid_print` do `flutter_lints` | Não expõe caminhos, SQL ou dados internos |
| 11 | **Privacidade (LGPD)**: só o apelido, aviso para não usar o nome real e botão **Apagar meus dados** com confirmação | `lib/presentation/progresso/player_screen.dart` | Mínimo de dados pessoais e direito de exclusão |
| 12 | **Chave de assinatura fora do Git**: o release usa `android/key.properties` se ele existir. `key.properties`, `*.jks`, `*.keystore` e `.env` estão no `.gitignore` da raiz e do `android/` | `android/app/build.gradle.kts`, `.gitignore` | O repositório é público |
| 13 | **Código ofuscado no release**: o Flutter já liga o R8 (minificação e remoção de recursos não usados) e o script de build adiciona `--obfuscate --split-debug-info` para o código Dart | `tool/gerar_apk_release.ps1` | Dificulta a engenharia reversa e reduz o tamanho do APK |
| 14 | **Uma única tela exposta**: só a `MainActivity` é exportada, porque é ela que o ícone do app abre | Manifesto | Outros apps não conseguem abrir partes internas do Turingclides |

## Como gerar e instalar o APK

### O que precisa na máquina

| Ferramenta | Situação nesta máquina (25/11) |
| --- | --- |
| Flutter SDK 3.50 ou mais novo | Instalado em `%USERPROFILE%\flutter` (fora do PATH) |
| Android Studio (Android SDK e JDK 17) | **Não instalado.** Necessário para gerar o APK |
| Celular Android com depuração USB, ou um emulador | Necessário para instalar e testar |

Depois de instalar o Android Studio, abra o SDK Manager e instale o Android SDK e as Command-line Tools. Depois confira o ambiente:

```powershell
& "$env:USERPROFILE\flutter\bin\flutter.bat" doctor --android-licenses
```

```powershell
& "$env:USERPROFILE\flutter\bin\flutter.bat" doctor
```

### Opção A: APK para a demonstração (sem chave própria)

Na raiz do projeto, rode o script. Ele executa `pub get`, `analyze`, os testes e o build com ofuscação:

```powershell
.\tool\gerar_apk_release.ps1 -Flutter "$env:USERPROFILE\flutter\bin\flutter.bat"
```

Sem `android\key.properties`, o APK sai assinado com a chave de debug e o script avisa. Isso serve para a apresentação, mas não para publicar na loja.

O APK fica em `build\app\outputs\flutter-apk\app-release.apk`.

### Opção B: APK assinado com a chave da equipe

1. Gere a chave uma vez e guarde o arquivo `.jks` fora do repositório, em um lugar com backup:

```powershell
keytool -genkey -v -keystore "$env:USERPROFILE\turingclides-release.jks" -keyalg RSA -keysize 2048 -validity 10000 -alias turingclides
```

2. Crie `android\key.properties`. Ele não vai para o Git:

```properties
storePassword=<senha do arquivo>
keyPassword=<senha da chave>
keyAlias=turingclides
storeFile=C:\\Users\\<voce>\\turingclides-release.jks
```

3. Rode o mesmo script da opção A.

Quem perder a chave não consegue mais publicar atualizações do app com o mesmo nome. Guarde o `.jks` e as senhas em um gerenciador de senhas.

### Instalar no celular

Com o celular conectado por USB e a depuração USB ligada:

```powershell
& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" install -r build\app\outputs\flutter-apk\app-release.apk
```

Sem cabo: envie o arquivo `app-release.apk` para o celular, abra e permita "instalar apps desconhecidos" para o app usado (Arquivos, Drive...).

O Android só atualiza um app instalado se o APK novo tiver a mesma assinatura. Ao trocar da chave de debug para a chave da equipe, desinstale a versão anterior. Isso apaga os dados locais dela.

### Conferir as regras no APK gerado

- Permissões: com o Android SDK instalado, `apkanalyzer manifest permissions build\app\outputs\flutter-apk\app-release.apk` não deve listar `android.permission.INTERNET`.
- Backup: em um aparelho de teste, `adb shell bmgr backupnow com.example.turingclides` não deve gerar backup do app.
- Código: `flutter test` cobre a validação, a injeção de SQL, a gravação atômica e a migração.

## O que pode melhorar

Em ordem de prioridade:

1. **Identificador próprio do app.** Hoje é `com.example.turingclides`, e a Play Store recusa `com.example`. Antes de publicar, troque `namespace` e `applicationId` (por exemplo, `br.edu.unipe.turingclides`), mova a `MainActivity.kt` para a pasta do novo pacote e atualize os comandos `adb` do roteiro de demonstração. Não foi feito agora para não quebrar a apresentação de hoje.
2. **Chave da equipe e Play App Signing.** Usar a opção B e, se publicar na Play Store, ativar o Play App Signing para que o Google guarde a chave de assinatura.
3. **CI no GitHub.** Rodar `flutter analyze` e `flutter test` em cada pull request (GitHub Actions) e proteger a branch `main` com revisão obrigatória.
4. **Dependências em dia.** Ativar o Dependabot para o ecossistema `pub` e revisar `flutter pub outdated` antes de cada versão.
5. **Ranking online, se vier.** A pontuação calculada no celular não é confiável, porque um aparelho com root pode editar o banco. Com ranking, o servidor precisa validar as partidas, exigir autenticação, usar só HTTPS (a regra 3 já ajuda) e, se possível, conferir o aparelho com a Play Integrity API.
6. **Criptografar o banco (SQLCipher)** só se o app passar a guardar dados sensíveis. Hoje são apenas apelido e pontuação, e a chave teria de ficar no próprio aparelho. O custo não compensa.
7. **Bloquear captura de tela (`FLAG_SECURE`)**: não recomendado. Em um app de estudo, o aluno deve poder tirar print da explicação.
