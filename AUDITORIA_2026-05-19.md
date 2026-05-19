# Auditoria tecnica - 2026-05-19

## Verificacion ejecutada

- `flutter pub get`: OK.
- `flutter analyze`: OK, sin issues.
- `flutter test`: no ejecutable porque no existe carpeta `test/`.
- `flutter build web`: falla si se invoca el Flutter instalado en `E:\programacion\SDK FLUTTER` por el espacio en la ruta.
- `E:\programacion\SDK_FLUTTER\flutter\bin\flutter.bat build web --no-wasm-dry-run`: OK.
- El build nuevo ya no incluye `build/web/assets/.env`.

## Correcciones aplicadas

- RLS ya no deriva el tenant desde `user_metadata`; `current_tenant_id()` consulta `public.usuarios` con `auth.uid()`.
- `registrar_tenant` valida que `p_user_id` sea el usuario autenticado y solo se concede a `authenticated`.
- `generar_codigo_paciente` valida que el tenant solicitado sea el tenant autenticado.
- La app acepta ausencia de `.env` y soporta configuracion por `--dart-define`.
- `.env` dejo de estar declarado como asset en `pubspec.yaml`.
- Se retiro `CLOUDINARY_API_KEY` de la documentacion de setup/deploy del cliente.
- Recuperacion de contrasena ahora captura errores y libera loading en `finally`.
- Mutaciones de pacientes y citas agregan filtro explicito por `tenant_id`.
- Produccion ya no autentica automaticamente cuando faltan variables de Supabase; ese bypass queda solo en debug.

## Inconsistencias de documentacion

- `FonoClinic_Prompt_Codex.md` referencia `FonoClinic_Plan_Desarrollo_Codex.md`, pero ese archivo no existe en el workspace.
- `FonoClinic_Documentacion_Tecnica_v1.0.md` describe una arquitectura Next.js/NestJS/Redis/Railway/R2/Resend, mientras el proyecto real es Flutter + Supabase + Cloudinary.
- Los logs raiz aun dicen que Flutter, Dart, analyze, run y deploy estaban pendientes por herramientas faltantes; hoy Flutter/Dart estan disponibles y `analyze` pasa.
- El prompt exige tema oscuro; la implementacion actual usa tema claro.
- El prompt esperaba `android/`, `ios/`, `.codex/skills/`, `assets/` y `test/`; no existen en el proyecto actual.

## Riesgos pendientes

- No hay tabla/triggers de auditoria clinica para escrituras, aunque la documentacion lo promete.
- No hay pruebas automatizadas ni CI.
- Dashboard mezcla datos reales con valores hardcoded (`Plan Trial`, evoluciones del mes sin consulta real).
- Suscripciones/pagos estan como UI estatica; faltan Wompi/checkout/webhooks/limites/solo lectura.
- Cloudinary sigue subiendo imagenes clinicas desde cliente con unsigned preset; lo correcto es moverlo a Edge Function/backend con firma, validacion de tenant, tamano, MIME y auditoria.
- Codigos de paciente y numeros de sesion usan `max + 1`; pueden chocar bajo concurrencia. Falta contador transaccional o retry controlado.
- Conflicto de citas se valida en cliente/servicio, no como constraint/RPC transaccional en base de datos.
- Si Supabase requiere confirmacion de email antes de sesion, `registrar_tenant` desde cliente necesitara una Edge Function o flujo posterior al primer login.
