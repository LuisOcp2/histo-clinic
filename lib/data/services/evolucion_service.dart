import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/supabase_constants.dart';
import '../../core/errors/app_exception.dart';
import '../models/evolucion_model.dart';
import 'auth_service.dart';
import 'supabase_access.dart';

class EvolucionService {
  EvolucionService({AuthService? authService}) : _authService = authService ?? AuthService();

  final AuthService _authService;
  SupabaseClient? get _client => supabaseOrNull();

  Future<List<EvolucionModel>> listarPorPaciente(String pacienteId) async {
    final client = _client;
    if (client == null) return [];
    final rows = await client
        .from(SupabaseConstants.evoluciones)
        .select()
        .eq('paciente_id', pacienteId)
        .order('num_sesion');
    return rows.map(EvolucionModel.fromJson).toList();
  }

  Future<EvolucionModel> crearEvolucion({
    required String pacienteId,
    required Map<String, dynamic> datos,
    required Map<String, dynamic> datosArea,
  }) async {
    final client = _client;
    final tenantId = _authService.currentTenantId;
    final profesionalId = _authService.currentUser?.id;
    if (client == null || tenantId == null || profesionalId == null) {
      throw const BusinessRuleException('Inicia sesion antes de registrar evoluciones.');
    }

    final paciente = await client
        .from(SupabaseConstants.pacientes)
        .select('consentimiento_firmado')
        .eq('id', pacienteId)
        .single();
    if (paciente['consentimiento_firmado'] != true) {
      throw const BusinessRuleException(
        'No se puede guardar la evolucion sin consentimiento firmado.',
        code: 'RN-09',
      );
    }

    final json = await client
        .from(SupabaseConstants.evoluciones)
        .insert({
          ...datos,
          'tenant_id': tenantId,
          'paciente_id': pacienteId,
          'profesional_id': profesionalId,
          'datos_area': datosArea,
        })
        .select()
        .single();
    return EvolucionModel.fromJson(json);
  }
}
