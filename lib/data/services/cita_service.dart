import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/supabase_constants.dart';
import '../../core/errors/app_exception.dart';
import '../models/cita_model.dart';
import 'auth_service.dart';
import 'supabase_access.dart';

class CitaService {
  CitaService({AuthService? authService})
      : _authService = authService ?? AuthService();

  final AuthService _authService;
  SupabaseClient? get _client => supabaseOrNull();

  Future<List<CitaModel>> listarPorRango(DateTime inicio, DateTime fin) async {
    final client = _client;
    final tenantId = _authService.currentTenantId;
    if (client == null || tenantId == null) return [];
    final rows = await client
        .from(SupabaseConstants.citas)
        .select('*, pacientes(nombres, apellidos)')
        .eq('tenant_id', tenantId)
        .gte('fecha_hora', inicio.toUtc().toIso8601String())
        .lte('fecha_hora', fin.toUtc().toIso8601String())
        .order('fecha_hora');
    return rows.map(CitaModel.fromJson).toList();
  }

  Future<List<CitaModel>> citasDeHoy() {
    final now = DateTime.now();
    return listarPorRango(DateTime(now.year, now.month, now.day),
        DateTime(now.year, now.month, now.day, 23, 59));
  }

  Future<CitaModel> crearCita(Map<String, dynamic> datos) async {
    final client = _client;
    final tenantId = _authService.currentTenantId;
    final profesionalId = _authService.currentUser?.id;
    if (client == null || tenantId == null || profesionalId == null) {
      throw const BusinessRuleException(
          'Inicia sesion antes de programar citas.');
    }

    final fecha = datos['fecha_hora'] as DateTime;
    final inicioVentana = fecha.subtract(const Duration(minutes: 15));
    final finVentana = fecha.add(const Duration(minutes: 15));
    final conflictos = await client
        .from(SupabaseConstants.citas)
        .select('id')
        .eq('tenant_id', tenantId)
        .eq('profesional_id', profesionalId)
        .neq('estado', 'Cancelada')
        .gte('fecha_hora', inicioVentana.toUtc().toIso8601String())
        .lte('fecha_hora', finVentana.toUtc().toIso8601String());

    if (conflictos.isNotEmpty) {
      throw const BusinessRuleException(
        'Ya existe una cita en una ventana de 15 minutos para ese horario.',
        code: 'RN-08',
      );
    }

    final json = await client
        .from(SupabaseConstants.citas)
        .insert({
          ...datos,
          'tenant_id': tenantId,
          'profesional_id': profesionalId,
          'fecha_hora': fecha.toUtc().toIso8601String(),
        })
        .select('*, pacientes(nombres, apellidos)')
        .single();
    return CitaModel.fromJson(json);
  }

  Future<void> cambiarEstado(
      {required String id, required String estado}) async {
    final client = _client;
    final tenantId = _authService.currentTenantId;
    if (client == null || tenantId == null) return;
    await client
        .from(SupabaseConstants.citas)
        .update({'estado': estado})
        .eq('id', id)
        .eq('tenant_id', tenantId);
  }
}
