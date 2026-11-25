# Gera o APK de release do Turingclides com o código Dart ofuscado.
# Uso (na raiz do projeto):  .\tool\gerar_apk_release.ps1
# Com o Flutter fora do PATH: .\tool\gerar_apk_release.ps1 -Flutter "$env:USERPROFILE\flutter\bin\flutter.bat"
param([string]$Flutter = "flutter")

$ErrorActionPreference = "Stop"
Set-Location (Split-Path $PSScriptRoot -Parent)

function Invoke-Passo([string]$Titulo, [string[]]$Argumentos) {
    Write-Host "`n== $Titulo" -ForegroundColor Cyan
    & $Flutter @Argumentos
    if ($LASTEXITCODE -ne 0) { throw "Falhou: $Titulo" }
}

if (-not (Test-Path "android\key.properties")) {
    Write-Warning "android\key.properties nao encontrado: o APK sera assinado com a chave de DEBUG (serve para demonstracao, nao para publicar)."
}

Invoke-Passo "Dependencias" @("pub", "get")
Invoke-Passo "Analise estatica" @("analyze")
Invoke-Passo "Testes" @("test")
# --obfuscate troca nomes de classes e funcoes no binario; os simbolos ficam
# em build\simbolos-debug (fora do Git) para ler relatorios de erro.
Invoke-Passo "APK de release" @("build", "apk", "--release", "--obfuscate", "--split-debug-info=build/simbolos-debug")

Write-Host "`nAPK pronto: build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Green
