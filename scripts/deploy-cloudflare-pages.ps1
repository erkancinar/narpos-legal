param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path,
    [string]$KeystoreRoot = 'C:\Projects\ai-workspace\private-keystore'
)

$ErrorActionPreference = 'Stop'

function Read-EnvFile {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path $Path)) {
        throw "Env file not found: $Path"
    }

    $values = @{}
    Get-Content $Path | ForEach-Object {
        if ($_ -match '^\s*([^#][A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)$') {
            $name = $Matches[1]
            $value = $Matches[2].Trim().Trim('"').Trim("'")
            $values[$name] = $value
        }
    }

    return ,$values
}

$cloudflare = Read-EnvFile (Join-Path $KeystoreRoot 'services\cloudflare-narpos.env')
$pages = Read-EnvFile (Join-Path $KeystoreRoot 'services\narpos-legal-pages.env')

$project = $pages['CF_PAGES_PROJECT']
$accountId = $pages['CF_PAGES_ACCOUNT_ID']
$email = $cloudflare['CF_EMAIL']
$apiKey = $cloudflare['CF_API_TOKEN']

if (-not $project) { throw 'CF_PAGES_PROJECT is missing.' }
if (-not $accountId) { throw 'CF_PAGES_ACCOUNT_ID is missing.' }
if (-not $email) { throw 'CF_EMAIL is missing.' }
if (-not $apiKey) { throw 'CF_API_TOKEN is missing.' }

$commit = (git -C $RepoRoot rev-parse HEAD).Trim()
$message = (git -C $RepoRoot log -1 --pretty=%s).Trim()
$tempDir = Join-Path $env:TEMP ("narpos-legal-pages-" + [guid]::NewGuid().ToString('N'))

try {
    New-Item -ItemType Directory -Path $tempDir | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $tempDir 'assets') | Out-Null

    Copy-Item -Path (Join-Path $RepoRoot '*.html') -Destination $tempDir
    Copy-Item -LiteralPath (Join-Path $RepoRoot 'favicon.ico') -Destination $tempDir
    Copy-Item -Path (Join-Path $RepoRoot 'assets\*') -Destination (Join-Path $tempDir 'assets')

    $env:CLOUDFLARE_EMAIL = $email
    $env:CLOUDFLARE_API_KEY = $apiKey
    $env:CLOUDFLARE_ACCOUNT_ID = $accountId

    Write-Host "Deploying Cloudflare Pages project '$project' from clean temp dir."
    Write-Host "Commit: $commit"

    npx.cmd wrangler pages deploy $tempDir `
        --project-name $project `
        --branch main `
        --commit-hash $commit `
        --commit-message $message
}
finally {
    if (Test-Path $tempDir) {
        Remove-Item -Recurse -Force -LiteralPath $tempDir
    }
}
