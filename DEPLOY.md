# Despliegue de FonoClinic

## Requisitos

1. Instalar Flutter SDK y agregarlo al `PATH`.
2. Instalar Vercel CLI:

```powershell
npm install -g vercel
vercel login
```

3. Tener a mano las variables publicas necesarias para compilar Flutter Web:

```env
SUPABASE_URL=https://TU_PROYECTO.supabase.co
SUPABASE_ANON_KEY=TU_ANON_KEY
CLOUDINARY_CLOUD_NAME=TU_CLOUD_NAME
CLOUDINARY_UPLOAD_PRESET=fonoclinic_preset
```

No incluyas secretos de servidor en el cliente web. El `anon key` de Supabase y un preset unsigned de Cloudinary son publicos por naturaleza, pero el preset debe tener restricciones de carpeta, tamano y formato.

## Verificacion local

Antes del primer login, aplica la migracion de Supabase:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\supabase_link_and_push.ps1 -ProjectRef TU_PROJECT_REF -AccessToken TU_ACCESS_TOKEN
```

```powershell
cd "E:\programacion\Hisotoria clinica\fonoclinic"
flutter pub get
flutter analyze
flutter run -d chrome
```

## Build web

```powershell
flutter build web --release `
  --dart-define=SUPABASE_URL=https://TU_PROYECTO.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=TU_ANON_KEY `
  --dart-define=CLOUDINARY_CLOUD_NAME=TU_CLOUD_NAME `
  --dart-define=CLOUDINARY_UPLOAD_PRESET=fonoclinic_preset
Copy-Item vercel.json build/web/vercel.json -Force
```

Nota Windows: si Flutter esta instalado en una ruta con espacios y el build falla con `"SDK" no se reconoce`, usa el alias sin espacios:

```powershell
New-Item -ItemType Junction -Path "E:\programacion\SDK_FLUTTER" -Target "E:\programacion\SDK FLUTTER"
E:\programacion\SDK_FLUTTER\flutter\bin\flutter.bat build web --release --no-wasm-dry-run `
  --dart-define=SUPABASE_URL=https://TU_PROYECTO.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=TU_ANON_KEY `
  --dart-define=CLOUDINARY_CLOUD_NAME=TU_CLOUD_NAME `
  --dart-define=CLOUDINARY_UPLOAD_PRESET=fonoclinic_preset
```

## Preview en Vercel

Desde la raiz del proyecto Flutter:

```powershell
vercel --cwd build/web
```

## Produccion

```powershell
vercel --cwd build/web --prod
```

## Variables en Vercel

Si haces build local y luego `vercel --cwd build/web`, los valores pasados con `--dart-define` quedan compilados en Flutter. Agrega las mismas variables en Vercel solo si luego configuras CI/CD o builds desde la nube:

```powershell
vercel env add SUPABASE_URL production
vercel env add SUPABASE_ANON_KEY production
vercel env add CLOUDINARY_CLOUD_NAME production
vercel env add CLOUDINARY_UPLOAD_PRESET production
```

Luego vuelve a compilar y desplegar:

```powershell
E:\programacion\SDK_FLUTTER\flutter\bin\flutter.bat build web --release --no-wasm-dry-run `
  --dart-define=SUPABASE_URL=https://TU_PROYECTO.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=TU_ANON_KEY `
  --dart-define=CLOUDINARY_CLOUD_NAME=TU_CLOUD_NAME `
  --dart-define=CLOUDINARY_UPLOAD_PRESET=fonoclinic_preset
Copy-Item vercel.json build/web/vercel.json -Force
vercel --cwd build/web --prod
```
