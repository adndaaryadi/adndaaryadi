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

$headers = @{
  Accept = "application/vnd.github+json"
  "X-GitHub-Api-Version" = "2022-11-28"
}

if ($token) {
  $headers.Authorization = "Bearer $token"
}

$payload = @{
  description = $description
  homepage = $homepage
  has_wiki = $false
  has_projects = $true
  has_issues = $true
} | ConvertTo-Json

$topicsPayload = @{ names = $topics } | ConvertTo-Json
$baseUrl = "https://api.github.com/repos/$Owner/$Repo"

if ($DryRun) {
  Write-Output "PATCH $baseUrl"
  Write-Output $payload
  Write-Output "PUT $baseUrl/topics"
  Write-Output $topicsPayload
  exit 0
}

Invoke-RestMethod -Method Patch -Uri $baseUrl -Headers $headers -Body $payload -ContentType "application/json" | Out-Null
Invoke-RestMethod -Method Put -Uri "$baseUrl/topics" -Headers $headers -Body $topicsPayload -ContentType "application/json" | Out-Null
Write-Output "Metadata repo $Owner/$Repo berhasil diupdate."
