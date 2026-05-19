$ErrorActionPreference = "Continue"

Write-Host "== FonoClinic setup check =="

function Check-Command($name) {
  $cmd = Get-Command $name -ErrorAction SilentlyContinue
  if ($null -eq $cmd) {
    Write-Host "[FALTA] $name no esta en PATH" -ForegroundColor Red
    return $false
  }
  Write-Host "[OK] $name -> $($cmd.Source)" -ForegroundColor Green
  return $true
}

$hasFlutter = Check-Command "flutter"
$hasDart = Check-Command "dart"
$hasNode = Check-Command "node"
$hasVercel = Check-Command "vercel"

Write-Host ""
Write-Host "== Variables .env =="
$envPath = Join-Path $PSScriptRoot "..\.env"
if (Test-Path $envPath) {
  Get-Content $envPath | ForEach-Object {
    if ($_ -match "^([^=]+)=(.*)$") {
      $key = $Matches[1]
      $value = $Matches[2]
      if ([string]::IsNullOrWhiteSpace($value)) {
        Write-Host "[FALTA] $key" -ForegroundColor Red
      } else {
        Write-Host "[OK] $key" -ForegroundColor Green
      }
    }
  }
} else {
  Write-Host "[FALTA] .env" -ForegroundColor Red
}

if ($hasFlutter) {
  Write-Host ""
  Write-Host "== Flutter doctor =="
  flutter doctor
}

if ($hasFlutter) {
  Write-Host ""
  Write-Host "Siguiente paso sugerido:"
  Write-Host "flutter pub get; flutter analyze; flutter run -d chrome"
}
