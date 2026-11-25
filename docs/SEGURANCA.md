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
| 14 | **Uma única tela exposta**: só a `MainActivity` é exportada, porque é ela que o ícone do app abre. O único outro componente exportado é o receptor do AndroidX que otimiza a inicialização, protegido pela permissão `DUMP` (só o sistema e o `adb` podem chamá-lo) | Manifesto | Outros apps não conseguem abrir partes internas do Turingclides |
| 15 | **Identificador próprio do app**: `br.edu.unipe.turingclides` (antes era `com.example.turingclides`, que a Play Store recusa) | `android/app/build.gradle.kts`, `MainActivity.kt` | Identifica o app de forma única e permite publicar |
| 16 | **CI no GitHub Actions**: análise, testes e APK ofuscado a cada push e pull request, com permissão só de leitura (`contents: read`) e sem guardar a credencial do checkout | `.github/workflows/ci.yml` | Nada quebrado chega à `main` sem ser visto; o workflow não consegue alterar o repositório |
| 17 | **Dependabot** semanal para pacotes do Dart/Flutter e para as ações do CI | `.github/dependabot.yml` | Correções de segurança das dependências chegam como pull request |
| 18 | **Armazenamento bloqueado no navegador não derruba o app**: a versão web passa a funcionar só em memória | `lib/data/plataforma/dados_web.dart` | Robustez em janela anônima ou página embutida |

## Como gerar e instalar o APK

### O que precisa na máquina

| Ferramenta | Situação nesta máquina (25/11) |
| --- | --- |
| Flutter SDK 3.50 ou mais novo | Instalado em `%USERPROFILE%\flutter` (fora do PATH) |
| JDK 21 | Instalado em `%USERPROFILE%\jdk-21` |
| Android SDK (platform-tools, Android 36, build-tools 36) | Instalado em `%LOCALAPPDATA%\Android\Sdk`, sem o Android Studio |
| Celular Android com depuração USB, ou um emulador | Necessário para instalar e testar |

Em outra máquina, o caminho mais simples é instalar o Android Studio e, no SDK Manager, o Android SDK e as Command-line Tools. Depois confira o ambiente:

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

A chave da equipe já foi criada na máquina de Renan, em `%USERPROFILE%\.turingclides\turingclides-release.jks` (RSA 3072, validade de 10 000 dias), com uma senha aleatória guardada em `android\key.properties` e numa cópia em `%USERPROFILE%\.turingclides\key.properties`. Nenhum desses arquivos vai para o Git. Guarde a pasta `.turingclides` num gerenciador de senhas ou em um backup cifrado: sem ela não dá para publicar atualizações com a mesma assinatura.

Para criar uma chave em outra máquina:

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

- Permissões: `aapt2 dump permissions build\app\outputs\flutter-apk\app-release.apk` (o `aapt2` fica em `%LOCALAPPDATA%\Android\Sdk\build-tools\36.0.0`) não deve listar `android.permission.INTERNET`. No APK gerado em 25/11, a única permissão é a interna `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`, criada pelo AndroidX e restrita ao próprio app.
- Manifesto: `aapt2 dump xmltree --file AndroidManifest.xml <apk>` mostra `allowBackup=false`, `usesCleartextTraffic=false`, `networkSecurityConfig` e `dataExtractionRules`.
- Assinatura: `apksigner verify --print-certs <apk>` (mesma pasta do `aapt2`) mostra `CN=Turingclides, OU=Desenvolvimento Mobile, O=Equipe Turingclides, C=BR` no APK assinado pela equipe.
- Backup: em um aparelho de teste, `adb shell bmgr backupnow br.edu.unipe.turingclides` não deve gerar backup do app.
- Código: `flutter test` cobre a validação, a injeção de SQL, a gravação atômica e a migração.

## Melhorias: o que já foi feito e o que falta

| Melhoria | Situação |
| --- | --- |
| Identificador próprio do app (`br.edu.unipe.turingclides`) | Feito (regra 15). O roteiro de demonstração de Breno já usa o pacote novo |
| Chave de assinatura da equipe fora do repositório | Feito: chave criada e `key.properties` ignorado pelo Git |
| CI rodando análise e testes em cada push e pull request | Feito (regra 16) |
| Dependabot | Feito (regra 17) |
| Proteger a branch `main` (pull request com revisão e CI passando) | **Pendente**: só o dono do repositório (Breno) pode ligar, em Settings → Rules → Rulesets |
| Trocar a branch padrão do GitHub para `main` | **Pendente**: hoje é `chore/estrutura-pastas`; também em Settings, pelo dono |
| Play App Signing | Só quando o app for publicado na Play Store |
| Validação da pontuação no servidor | Só se houver ranking online. A pontuação calculada no celular não é confiável, porque um aparelho com root pode editar o banco |
| Criptografar o banco (SQLCipher) | Não recomendado agora: só há apelido e pontuação, e a chave teria de ficar no próprio aparelho |
| Bloquear captura de tela (`FLAG_SECURE`) | Não recomendado: em um app de estudo, o aluno deve poder tirar print da explicação |
