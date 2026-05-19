param(
  [Parameter(Mandatory = $true)]
  [string]$ProjectRef,

  [Parameter(Mandatory = $false)]
  [string]$AccessToken
)

$ErrorActionPreference = "Stop"

if (-not [string]::IsNullOrWhiteSpace($AccessToken)) {
  $env:SUPABASE_ACCESS_TOKEN = $AccessToken
  Write-Host "== Usando SUPABASE_ACCESS_TOKEN temporal =="
} elseif ([string]::IsNullOrWhiteSpace($env:SUPABASE_ACCESS_TOKEN)) {
  Write-Host "No hay SUPABASE_ACCESS_TOKEN."
  Write-Host "Crea uno en https://supabase.com/dashboard/account/tokens"
  Write-Host "Luego ejecuta este script con -AccessToken TU_TOKEN"
  exit 1
}

Write-Host "== Link proyecto remoto =="
npx supabase link --project-ref $ProjectRef

Write-Host "== Aplicando migraciones =="
npx supabase db push --yes

Write-Host ""
Write-Host "Listo. Ahora obtén SUPABASE_URL y SUPABASE_ANON_KEY desde:"
Write-Host "Supabase Dashboard > Project Settings > API"
Write-Host ""
Write-Host "Luego edita .env y ejecuta:"
Write-Host 'powershell -ExecutionPolicy Bypass -File scripts\check_setup.ps1'
