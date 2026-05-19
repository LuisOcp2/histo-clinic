/// Nombres de tablas, RPC y variables usadas por Supabase.
abstract final class SupabaseConstants {
  static const urlEnv = 'SUPABASE_URL';
  static const anonKeyEnv = 'SUPABASE_ANON_KEY';

  static const tenants = 'tenants';
  static const usuarios = 'usuarios';
  static const pacientes = 'pacientes';
  static const datosClinicosArea = 'datos_clinicos_area';
  static const evoluciones = 'evoluciones';
  static const citas = 'citas';
  static const imagenesClinicas = 'imagenes_clinicas';
  static const planesSuscripcion = 'planes_suscripcion';

  static const registrarTenantRpc = 'registrar_tenant';
  static const generarCodigoPacienteRpc = 'generar_codigo_paciente';
}
