# --- CONFIGURAÇÃO DE AMBIENTE VS 2022 ---
$vsPath = "C:\Program Files\Microsoft Visual Studio\2022\Community"
$devShellDll = "$vsPath\Common7\Tools\Microsoft.VisualStudio.DevShell.dll"

Write-Host "--- Iniciando Automação ArmorPaint (v2) ---" -ForegroundColor Cyan

if (Test-Path $devShellDll) {
    Import-Module $devShellDll
    # Removemos o -DevShellIndex para evitar o erro de parâmetro
    Enter-VsDevShell -VsInstallPath $vsPath -SkipAutomaticLocation
    Write-Host "Ambiente de Compilação VS 2022 carregado com sucesso." -ForegroundColor Green
} else {
    Write-Host "ERRO: Visual Studio 2022 não encontrado em $vsPath" -ForegroundColor Red
    exit
}

# --- DEFINIÇÃO DE CAMINHOS ---
# Ajustado para a estrutura que vimos nas suas imagens
$solutionFile = ".\paint\build\ArmorPaint.slnx"
$sourceExe = ".\paint\build\x64\Release\ArmorPaint.exe"
$dataFolder = ".\paint\build\out\data" 
$destFolder = [System.IO.Path]::Combine($env:USERPROFILE, "Desktop\ArmorPaint_Pro")

# --- VERIFICAÇÃO DO MSBUILD ---
if (!(Get-Command msbuild -ErrorAction SilentlyContinue)) {
    Write-Host "ERRO: MSBuild ainda não foi reconhecido no PATH." -ForegroundColor Red
    exit
}

# --- EXECUÇÃO DO BUILD ---
Write-Host "Compilando em modo Release (x64) com Clang..." -ForegroundColor Yellow
# Usamos o comando direto para garantir a limpeza do build
msbuild $solutionFile /p:Configuration=Release /p:Platform=x64 /t:Rebuild

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERRO: A compilação falhou. Verifique as mensagens de erro acima." -ForegroundColor Red
    exit
}

# --- DEPLOY NO DESKTOP ---
Write-Host "Organizando arquivos no Desktop..." -ForegroundColor Cyan
if (!(Test-Path $destFolder)) { New-Item -ItemType Directory -Path $destFolder | Out-Null }

Copy-Item -Path $sourceExe -Destination $destFolder -Force

if (Test-Path $dataFolder) {
    Copy-Item -Path $dataFolder -Destination $destFolder -Recurse -Force
    Write-Host "Pasta Data sincronizada com sucesso!" -ForegroundColor Green
}

Write-Host "--- SUCESSO! ArmorPaint atualizado no Desktop ---" -ForegroundColor Magenta