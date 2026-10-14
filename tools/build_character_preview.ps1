$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path -Parent $PSScriptRoot
$stagingRuntime = Join-Path $taskRoot 'src/server/Config/Runtime.luau'
$before = (Get-FileHash -LiteralPath $stagingRuntime -Algorithm SHA256).Hash
$project = Get-Content -Raw -LiteralPath (Join-Path $taskRoot 'default.project.json') | ConvertFrom-Json -AsHashtable
$project.name = 'Guildborne_CharacterPreview'
$project.Remove('servePlaceIds')
$server = $project.tree.ServerScriptService.Server
$server.Clear()
$server['$className'] = 'Folder'
foreach ($entry in Get-ChildItem -LiteralPath (Join-Path $taskRoot 'src/server')) {
    if ($entry.Name -eq 'Config') {
        $config = @{'$className'='Folder'}
        foreach ($module in Get-ChildItem -LiteralPath $entry.FullName -Filter '*.luau' -File) {
            $config[$module.BaseName] = @{'$path'=$module.FullName}
        }
        $config.Runtime = @{'$path'=(Join-Path $taskRoot 'offline/Runtime.luau')}
        $server.Config = $config
    } elseif ($entry.PSIsContainer) {
        $server[$entry.Name] = @{'$path'=$entry.FullName}
    } elseif ($entry.Extension -eq '.luau') {
        $name = $entry.BaseName -replace '\.(server|client)$',''
        $server[$name] = @{'$path'=$entry.FullName}
    }
}
function Resolve-ProjectPaths($node) {
    if ($node -is [System.Collections.IDictionary]) {
        if ($node.Contains('$path') -and -not [IO.Path]::IsPathRooted($node['$path'])) {
            $node['$path'] = Join-Path $taskRoot $node['$path']
        }
        foreach ($value in $node.Values) { Resolve-ProjectPaths $value }
    }
}
Resolve-ProjectPaths $project
$outputDir = Join-Path $taskRoot 'build'
New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
$projectPath = Join-Path $outputDir 'character-preview.project.json'
$project | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $projectPath -Encoding utf8NoBOM
$outputPath = Join-Path $outputDir 'Guildborne_CharacterPreview.rbxlx'
& (Join-Path $taskRoot '.tools/rojo/rojo.exe') build $projectPath --output $outputPath
if ($LASTEXITCODE -ne 0) { throw 'Character preview build failed' }
[xml]$built = Get-Content -Raw -LiteralPath $outputPath
$runtimeSources = @($built.SelectNodes("//Item/Properties[string[@name='Name']='Runtime']/*[@name='Source']"))
if ($runtimeSources.Count -ne 1 -or $runtimeSources[0].InnerText -notmatch 'StudioPersistence="Memory"' -or $runtimeSources[0].InnerText -notmatch 'AllowedDataStoreUniverses=\{\}') {
    throw 'Preview did not retain isolated Memory configuration'
}
if ((Get-FileHash -LiteralPath $stagingRuntime -Algorithm SHA256).Hash -ne $before) { throw 'Staging configuration changed' }
@{
    date='2026-10-11'; place=$outputPath; stagingRuntimeUnchanged=$true; studioPersistence='Memory';
    cloudAllowlistEmpty=$true; placeSha256=(Get-FileHash -LiteralPath $outputPath -Algorithm SHA256).Hash;
    acceptance='BUILD_ONLY_STUDIO_PLAYTEST_REQUIRED';
} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $outputDir 'character-preview-build.json') -Encoding utf8NoBOM
Write-Output "Character preview built: $outputPath (Memory only; Studio acceptance separate)"
