$ErrorActionPreference = "Stop"

Write-Host "== Iniciando Supabase local =="
npx supabase start

Write-Host ""
Write-Host "Copia del output anterior:"
Write-Host "- API URL -> SUPABASE_URL"
Write-Host "- anon key -> SUPABASE_ANON_KEY"
Write-Host ""
Write-Host "Luego ejecuta:"
Write-Host "npx supabase db reset"
Write-Host 'powershell -ExecutionPolicy Bypass -File scripts\check_setup.ps1'
