param(
  [string]$BaseHref = "/pedidos-app/",
  [string]$TargetPath = "C:\httpd-2.4.46-win64-VS16\htdocs\pedidos-app"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$buildPath = Join-Path $repoRoot "build\web"

if (-not $BaseHref.StartsWith("/") -or -not $BaseHref.EndsWith("/")) {
  throw "BaseHref deve comecar e terminar com '/'. Exemplo: /pedidos-app/"
}

Write-Host "Compilando PWA com base-href $BaseHref..."
Push-Location $repoRoot
try {
  flutter build web --base-href $BaseHref
} finally {
  Pop-Location
}

if (-not (Test-Path -LiteralPath $buildPath)) {
  throw "Build web nao encontrado em $buildPath"
}

$resolvedTargetParent = Resolve-Path -LiteralPath (Split-Path -Parent $TargetPath)
$targetName = Split-Path -Leaf $TargetPath
if ($targetName -ne "pedidos-app") {
  throw "Por seguranca, este script so limpa uma pasta chamada pedidos-app."
}

if (-not (Test-Path -LiteralPath $TargetPath)) {
  New-Item -ItemType Directory -Path $TargetPath | Out-Null
}

$resolvedTarget = Resolve-Path -LiteralPath $TargetPath
if (-not $resolvedTarget.Path.StartsWith($resolvedTargetParent.Path)) {
  throw "Caminho alvo invalido: $($resolvedTarget.Path)"
}

Write-Host "Limpando $($resolvedTarget.Path)..."
Get-ChildItem -LiteralPath $resolvedTarget.Path -Force |
  Remove-Item -Recurse -Force

Write-Host "Copiando arquivos de $buildPath..."
Copy-Item -Path (Join-Path $buildPath "*") -Destination $resolvedTarget.Path -Recurse -Force

Write-Host "PWA publicado em $($resolvedTarget.Path)"
Write-Host "Abra: http://192.168.3.10$BaseHref"
