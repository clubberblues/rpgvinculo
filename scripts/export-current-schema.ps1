[CmdletBinding()]
param(
    [string]$BackupRoot = ""
)

$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

if ([string]::IsNullOrWhiteSpace($BackupRoot)) {
    $parent = Split-Path -Parent $repoRoot
    $BackupRoot = Join-Path $parent "rpgvinculo-local-backups"
}

if (-not (Get-Command supabase -ErrorAction SilentlyContinue)) {
    throw "Supabase CLI não encontrado. Instale/ative a CLI já usada para este projeto."
}
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw "Docker não encontrado. O comando supabase db dump executa pg_dump em um container; instale/inicie Docker Desktop."
}

$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$targetDir = Join-Path $BackupRoot $stamp
New-Item -ItemType Directory -Force -Path $targetDir | Out-Null

Push-Location $repoRoot
try {
    $version = (& supabase --version 2>&1 | Out-String).Trim()
    if ($LASTEXITCODE -ne 0) {
        throw "Não foi possível executar supabase --version."
    }

    & docker info *> $null
    if ($LASTEXITCODE -ne 0) {
        throw "Docker Desktop não está iniciado. Inicie-o e execute novamente."
    }

    # Requires this repository to be linked with supabase link.
    # This is a schema-only snapshot of the CURRENT remote schema, not a
    # pre-migration bootstrap and not a full backup of Auth/Storage objects.
    $schemaFile = Join-Path $targetDir "current-schema.sql"
    & supabase db dump -f $schemaFile
    if ($LASTEXITCODE -ne 0) {
        throw "Falha no dump de schema. Verifique o link do projeto e a senha do banco no CLI."
    }

    if (-not (Test-Path $schemaFile) -or (Get-Item $schemaFile).Length -eq 0) {
        throw "O dump foi gerado vazio ou não foi encontrado."
    }

    $hash = Get-FileHash -Algorithm SHA256 -Path $schemaFile
    $manifest = @(
        "Project ref: grrgwxcagvvafdmzsmro"
        "Generated at: $(Get-Date -Format o)"
        "Supabase CLI: $version"
        "Artifact: current-schema.sql"
        "Size bytes: $((Get-Item $schemaFile).Length)"
        "SHA256: $($hash.Hash)"
        "Scope: schema snapshot only; managed Auth/Storage schemas and Storage object files are not included."
        "Important: this is the current schema after applied migrations, not the original pre-ledger bootstrap."
    )
    Set-Content -Encoding UTF8 -Path (Join-Path $targetDir "manifest.txt") -Value $manifest

    Write-Host ""
    Write-Host "Schema snapshot created:"
    Write-Host $targetDir
    Write-Host "SHA256: $($hash.Hash)"
    Write-Host "This file was saved outside the Git repository and was not uploaded."
}
finally {
    Pop-Location
}
