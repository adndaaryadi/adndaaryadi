param(
  [string]$Owner = "adndaaryadi",
  [string]$Repo = "adndaaryadi",
  [switch]$DryRun
)

$description = "GitHub profile repo dan portfolio statis Adinda Salsa Aryadi dengan Pages, CI, release, dan dokumentasi visual."
$homepage = "https://adndaaryadi.github.io/"
$topics = @("github-profile", "portfolio", "static-site", "github-pages", "personal-brand", "frontend")

$token = if ($env:GITHUB_TOKEN) { $env:GITHUB_TOKEN } else { $null }
if (-not $token -and -not $DryRun) {
  throw "Set env GITHUB_TOKEN dulu sebelum eksekusi tanpa -DryRun."
}

function Get-StatusCode {
  param([System.Management.Automation.ErrorRecord]$ErrorRecord)

  $statusCode = $null

  if ($ErrorRecord.Exception -and $ErrorRecord.Exception.Response -and $ErrorRecord.Exception.Response.StatusCode) {
    $statusCode = $ErrorRecord.Exception.Response.StatusCode
  }

  if ($null -eq $statusCode) {
    return $null
  }

  return [int]$statusCode
}

$headers = @{
  Accept = "application/vnd.github+json"
  "X-GitHub-Api-Version" = "2022-11-28"
}

if ($token) {
  $headers.Authorization = "Bearer $token"
}

$payload = @{
  name = $Repo
  description = $description
  homepage = $homepage
  has_wiki = $false
  has_projects = $true
  has_issues = $true
} | ConvertTo-Json

$createPayload = @{
  name = $Repo
  description = $description
  homepage = $homepage
  private = $false
  has_wiki = $false
  has_projects = $true
  has_issues = $true
  auto_init = $false
} | ConvertTo-Json

$topicsPayload = @{ names = $topics } | ConvertTo-Json
$baseUrl = "https://api.github.com/repos/$Owner/$Repo"
$createUrl = "https://api.github.com/user/repos"

if ($DryRun) {
  Write-Output "GET $baseUrl"
  Write-Output "POST $createUrl (kalau status 404)"
  Write-Output $createPayload
  Write-Output "PATCH $baseUrl"
  Write-Output $payload
  Write-Output "PUT $baseUrl/topics"
  Write-Output $topicsPayload
  exit 0
}

$created = $false

try {
  Invoke-RestMethod -Method Get -Uri $baseUrl -Headers $headers | Out-Null
}
catch {
  $statusCode = Get-StatusCode $_
  if ($statusCode -ne 404) {
    throw
  }

  Invoke-RestMethod -Method Post -Uri $createUrl -Headers $headers -Body $createPayload -ContentType "application/json" | Out-Null
  $created = $true
}

Invoke-RestMethod -Method Patch -Uri $baseUrl -Headers $headers -Body $payload -ContentType "application/json" | Out-Null
Invoke-RestMethod -Method Put -Uri "$baseUrl/topics" -Headers $headers -Body $topicsPayload -ContentType "application/json" | Out-Null

if ($created) {
  Write-Output "Repo $Owner/$Repo berhasil dibuat lalu metadatanya diupdate."
}
else {
  Write-Output "Metadata repo $Owner/$Repo berhasil diupdate."
}
