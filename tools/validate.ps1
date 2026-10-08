$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
Push-Location -LiteralPath $projectRoot
try {
    function Invoke-Check {
        param([string]$Executable, [string[]]$Arguments)
        & $Executable @Arguments
        if ($LASTEXITCODE -ne 0) { throw "Validation failed ($LASTEXITCODE): $Executable" }
    }
    $rojo = Join-Path $projectRoot '.tools\rojo\rojo.exe'
    $luau = Join-Path $projectRoot '.tools\luau\luau.exe'
    $compiler = Join-Path $projectRoot '.tools\luau\luau-compile.exe'
    $analyzer = Join-Path $projectRoot '.tools\luau-lsp\luau-lsp.exe'
    $definitions = Join-Path $projectRoot '.tools\luau-lsp\globalTypes.d.luau'
    foreach ($path in @($rojo, $luau, $compiler, $analyzer, $definitions)) {
        if (-not (Test-Path -LiteralPath $path)) { throw 'Missing tools. Run .\tools\setup_tools.ps1 first.' }
    }
    New-Item -ItemType Directory -Path 'build' -Force | Out-Null
    Invoke-Check $luau @('tests/run.luau')
    Invoke-Check $rojo @('build', 'default.project.json', '--output', 'build/Guildborne.rbxlx')
    Invoke-Check $rojo @('sourcemap', 'default.project.json', '--output', 'build/sourcemap.json')
    Invoke-Check $analyzer @('analyze', '--platform=roblox', '--sourcemap=build/sourcemap.json', "--definitions=$definitions", 'src', 'tests')
    $sources = @(Get-ChildItem -Path 'src','tests' -Filter '*.luau' -Recurse | Sort-Object FullName | ForEach-Object FullName)
    # Keep each Windows process command line below its length limit as sources grow.
    for ($offset = 0; $offset -lt $sources.Count; $offset += 80) {
        $last = [Math]::Min($offset + 79, $sources.Count - 1)
        Invoke-Check $compiler (@('--null') + $sources[$offset..$last])
    }
    Invoke-Check 'python' @('tools/validate_repository.py', '--place', 'build/Guildborne.rbxlx', '--sourcemap', 'build/sourcemap.json')
    Invoke-Check 'git' @('diff', '--check')
    Write-Output 'PASS: all automated checks. Studio/staging acceptance is separate.'
} finally {
    Pop-Location
}
