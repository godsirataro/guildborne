$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$toolRoot = Join-Path $projectRoot '.tools'
New-Item -ItemType Directory -Path $toolRoot -Force | Out-Null

function Get-VerifiedFile {
    param([string]$Url, [string]$Path, [string]$Sha256)
    if (-not (Test-Path -LiteralPath $Path)) {
        Invoke-WebRequest -Uri $Url -OutFile $Path
    }
    $actual = (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
    if ($actual -ne $Sha256) { throw "Checksum mismatch: $Path. The file has not been executed." }
}

$archives = @(
    @{ Name = 'rojo'; Url = 'https://github.com/rojo-rbx/rojo/releases/download/v7.7.0/rojo-7.7.0-windows-x86_64.zip'; Hash = '2179C44862A10ECBD725BDFEB4ABC64E16DC4AAD9B6C8F3E1A7C46A87280B949' },
    @{ Name = 'luau'; Url = 'https://github.com/luau-lang/luau/releases/download/0.740/luau-windows.zip'; Hash = 'BE676D9A1092B3D5EE36BE5F5F11E2AF1976911C32F5644A052548DC7C66BB9C' },
    @{ Name = 'luau-lsp'; Url = 'https://github.com/JohnnyMorganz/luau-lsp/releases/download/1.70.0/luau-lsp-win64.zip'; Hash = '26E6D32069CB5DD74F06BBDC2F3033D3BA66DA76D3DBDFC3DCC2B085DDAA274A' }
)
foreach ($archive in $archives) {
    $zipPath = Join-Path $toolRoot ($archive.Name + '.zip')
    $destination = Join-Path $toolRoot $archive.Name
    Get-VerifiedFile -Url $archive.Url -Path $zipPath -Sha256 $archive.Hash
    New-Item -ItemType Directory -Path $destination -Force | Out-Null
    Expand-Archive -LiteralPath $zipPath -DestinationPath $destination -Force
    Write-Output "Ready: $($archive.Name)"
}
Get-VerifiedFile -Url 'https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/1.70.0/scripts/globalTypes.d.luau' -Path (Join-Path $toolRoot 'luau-lsp\globalTypes.d.luau') -Sha256 '2B0DF788DC3FD1B572E71EE7FE9E1C55CC23882AFBD5024AECDEC30D9BD7520F'
Write-Output 'Pinned development tools ready. PATH and Studio plugins were not changed.'
