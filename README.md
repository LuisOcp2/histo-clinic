# FonoClinic

FonoClinic es una aplicacion web en Flutter para la gestion de historias clinicas, pacientes, agenda, evoluciones y reportes de fonoaudiologia independiente en Colombia.

## Stack

- Flutter Web
- Riverpod
- GoRouter
- Supabase
- Cloudinary
- Vercel

## Requisitos locales

- Flutter SDK 3.4 o superior
- Dart
- Supabase CLI, si vas a aplicar migraciones
- Vercel CLI, si vas a desplegar desde terminal

## Configuracion

Duplica `.env.example` como `.env` y completa los valores:

```env
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu-anon-key
CLOUDINARY_CLOUD_NAME=tu-cloud-name
CLOUDINARY_UPLOAD_PRESET=fonoclinic_preset
```

> No subas `.env` al repositorio. Las llaves usadas por Flutter Web quedan expuestas en el cliente, asi que usa solo llaves publicas, como el anon key de Supabase y un preset unsigned de Cloudinary con restricciones.

## Desarrollo local

```powershell
flutter pub get
flutter analyze
flutter run -d chrome
```

## Base de datos

El esquema inicial esta en `supabase/migrations/20260519000100_initial_schema.sql`.
Los controles de administracion, bloqueo de registros y suscripciones estan en `supabase/migrations/20260519000200_admin_controls.sql`.

Para enlazar y aplicar la migracion a un proyecto Supabase:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\supabase_link_and_push.ps1 -ProjectRef TU_PROJECT_REF -AccessToken TU_ACCESS_TOKEN
```

## Admin de plataforma

El panel `/admin` permite abrir o cerrar registros publicos y cambiar tenants entre `trial`, `activo`, `suspendido` y `cancelado`.

La migracion `20260519000200_admin_controls.sql` crea la tabla `app_admins`. Para dar acceso a otro correo, agrega una fila:

```sql
insert into app_admins (email, nombre)
values ('admin@tudominio.com', 'Admin')
on conflict (email) do update set activo = true;
```

Los tenants suspendidos, cancelados o con trial vencido no pueden consultar ni modificar datos clinicos por RLS.

## Build web

```powershell
flutter build web --release `
  --dart-define=SUPABASE_URL=https://tu-proyecto.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=tu-anon-key `
  --dart-define=CLOUDINARY_CLOUD_NAME=tu-cloud-name `
  --dart-define=CLOUDINARY_UPLOAD_PRESET=fonoclinic_preset
```

## Despliegue en Vercel

Este repositorio incluye `vercel.json` y `scripts/vercel_build.sh`. En Vercel:

1. Importa el repositorio `LuisOcp2/histo-clinic`.
2. Usa la raiz del proyecto como root directory.
3. Agrega estas variables de entorno en Production, Preview y Development:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
   - `CLOUDINARY_CLOUD_NAME`
   - `CLOUDINARY_UPLOAD_PRESET`
4. Despliega. Vercel ejecutara `bash scripts/vercel_build.sh` y publicara `build/web`.

Tambien puedes desplegar desde terminal:

```powershell
vercel --prod
```
