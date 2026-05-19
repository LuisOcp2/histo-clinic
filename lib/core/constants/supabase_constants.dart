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
  static const getPublicAppSettingsRpc = 'get_public_app_settings';
  static const isPlatformAdminRpc = 'is_platform_admin';
  static const adminGetSettingsRpc = 'admin_get_settings';
  static const adminUpdateSettingsRpc = 'admin_update_settings';
  static const adminListTenantsRpc = 'admin_list_tenants';
  static const adminUpdateTenantRpc = 'admin_update_tenant';
}
