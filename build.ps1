$ErrorActionPreference = 'Stop'

Set-Location $PSScriptRoot

$buildScripts = Get-ChildItem -LiteralPath $PSScriptRoot -Directory |
    Where-Object { $_.Name -like 'exe_*' } |
    Sort-Object Name

foreach ($folder in $buildScripts) {
    $buildPath = Join-Path $folder.FullName 'build.bat'
    if (-not (Test-Path -LiteralPath $buildPath)) {
        Write-Warning "Ignorando $($folder.Name): build.bat nao encontrado."
        continue
    }

    Write-Host "Compilando $($folder.Name)..."
    & $buildPath
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}

exit 0
