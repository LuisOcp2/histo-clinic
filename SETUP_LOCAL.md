# Puesta en marcha local

## 1. Instalar Flutter en Windows

Winget no lista el SDK oficial de Flutter en esta maquina. Usa una de estas opciones:

### Opcion recomendada: instalacion oficial

1. Descarga Flutter SDK para Windows desde:
   https://docs.flutter.dev/get-started/install/windows
2. Descomprime, por ejemplo en:

```text
C:\src\flutter
```

3. Agrega al PATH:

```text
C:\src\flutter\bin
```

4. Cierra y abre PowerShell.

5. Verifica:

```powershell
flutter doctor
dart --version
```

Si tu SDK esta en una carpeta con espacios, por ejemplo `E:\programacion\SDK FLUTTER`, crea un alias sin espacios:

```powershell
New-Item -ItemType Junction -Path "E:\programacion\SDK_FLUTTER" -Target "E:\programacion\SDK FLUTTER"
```

Y usa este Flutter para builds:

```powershell
E:\programacion\SDK_FLUTTER\flutter\bin\flutter.bat build web --release --no-wasm-dry-run
```

## 2. Configurar credenciales locales

Para desarrollo local puedes crear `.env` en la raiz de `fonoclinic`:

```env
SUPABASE_URL=https://TU_PROYECTO.supabase.co
SUPABASE_ANON_KEY=TU_ANON_KEY
CLOUDINARY_CLOUD_NAME=TU_CLOUD_NAME
CLOUDINARY_UPLOAD_PRESET=fonoclinic_preset
```

No agregues secretos de servidor en `.env`: Flutter Web corre en el navegador. Para builds de produccion usa `--dart-define`.

## 3. Preparar Supabase

Con Supabase CLI tienes dos caminos:

### Proyecto remoto

1. Copia el `project-ref` desde Supabase Dashboard. Es el id corto de la URL del proyecto.
2. Ejecuta:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\supabase_link_and_push.ps1 -ProjectRef TU_PROJECT_REF -AccessToken TU_ACCESS_TOKEN
```

El token se crea en:

```text
https://supabase.com/dashboard/account/tokens
```

3. Copia `SUPABASE_URL` y `SUPABASE_ANON_KEY` desde:

```text
Supabase Dashboard > Project Settings > API
```

4. Pégalos en `.env`.

### Supabase local

Requiere Docker Desktop activo.

```powershell
powershell -ExecutionPolicy Bypass -File scripts\supabase_local_start.ps1
npx supabase db reset
```

Copia `API URL` y `anon key` al `.env`.

En ambos casos, en Authentication habilita Email/Password.

## 4. Instalar dependencias y probar

```powershell
cd "E:\programacion\Hisotoria clinica\fonoclinic"
flutter pub get
flutter analyze
flutter run -d chrome
```

Tambien puedes ejecutar sin `.env` usando variables compiladas:

```powershell
flutter run -d chrome `
  --dart-define=SUPABASE_URL=https://TU_PROYECTO.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=TU_ANON_KEY `
  --dart-define=CLOUDINARY_CLOUD_NAME=TU_CLOUD_NAME `
  --dart-define=CLOUDINARY_UPLOAD_PRESET=fonoclinic_preset
```

## 5. Desplegar

Vercel CLI ya fue instalado en esta maquina. Si abres una nueva terminal y no aparece, ejecuta:

```powershell
npm install -g vercel
```

Luego:

```powershell
vercel login
E:\programacion\SDK_FLUTTER\flutter\bin\flutter.bat build web --release --no-wasm-dry-run `
  --dart-define=SUPABASE_URL=https://TU_PROYECTO.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=TU_ANON_KEY `
  --dart-define=CLOUDINARY_CLOUD_NAME=TU_CLOUD_NAME `
  --dart-define=CLOUDINARY_UPLOAD_PRESET=fonoclinic_preset
Copy-Item vercel.json build/web/vercel.json -Force
vercel --cwd build/web
vercel --cwd build/web --prod
```
