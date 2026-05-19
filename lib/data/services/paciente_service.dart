import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/supabase_constants.dart';
import '../../core/errors/app_exception.dart';
import '../models/paciente_model.dart';
import 'auth_service.dart';
import 'supabase_access.dart';

class PacienteService {
  PacienteService({AuthService? authService})
      : _authService = authService ?? AuthService();

  final AuthService _authService;
  SupabaseClient? get _client => supabaseOrNull();

  Future<List<PacienteModel>> listarPacientes({String query = ''}) async {
    final client = _client;
    final tenantId = _authService.currentTenantId;
    if (client == null || tenantId == null) return [];

    var request = client
        .from(SupabaseConstants.pacientes)
        .select('*, datos_clinicos_area(datos)')
        .eq('tenant_id', tenantId)
        .eq('activo', true);

    final rows = await request.order('created_at', ascending: false);
    final pacientes = rows.map(PacienteModel.fromJson).toList();
    final text = query.trim().toLowerCase();
    if (text.isEmpty) return pacientes;
    return pacientes
        .where((p) =>
            p.nombreCompleto.toLowerCase().contains(text) ||
            p.numDoc.contains(text))
        .toList();
  }

  Future<PacienteModel?> obtenerPaciente(String id) async {
    final client = _client;
    final tenantId = _authService.currentTenantId;
    if (client == null || tenantId == null) return null;
    final json = await client
        .from(SupabaseConstants.pacientes)
        .select('*, datos_clinicos_area(datos)')
        .eq('id', id)
        .eq('tenant_id', tenantId)
        .maybeSingle();
    return json == null ? null : PacienteModel.fromJson(json);
  }

  Future<PacienteModel> crearPaciente({
    required Map<String, dynamic> datosPaciente,
    required Map<String, dynamic> datosClinicosArea,
  }) async {
    final client = _client;
    final tenantId = _authService.currentTenantId;
    if (client == null || tenantId == null) {
      throw const BusinessRuleException(
          'Configura Supabase e inicia sesion antes de crear pacientes.');
    }

    _validarAcudienteSiMenor(datosPaciente);

    try {
      final codigo = await client.rpc(
        SupabaseConstants.generarCodigoPacienteRpc,
        params: {'p_tenant_id': tenantId},
      ) as String;

      final insert = {
        ...datosPaciente,
        'tenant_id': tenantId,
        'codigo': codigo,
        'activo': true,
      };
      final pacienteJson = await client
          .from(SupabaseConstants.pacientes)
          .insert(insert)
          .select()
          .single();

      await client.from(SupabaseConstants.datosClinicosArea).insert({
        'tenant_id': tenantId,
        'paciente_id': pacienteJson['id'],
        'area': pacienteJson['area_atencion'],
        'datos': datosClinicosArea,
      });

      return PacienteModel.fromJson({
        ...pacienteJson,
        'datos_clinicos_area': [
          {'datos': datosClinicosArea}
        ],
      });
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw const BusinessRuleException(
          'Ya existe un paciente con ese tipo y numero de documento.',
          code: 'RN-01',
        );
      }
      throw BusinessRuleException(e.message, code: e.code);
    }
  }

  Future<void> actualizarPaciente({
    required String id,
    required Map<String, dynamic> datosPaciente,
    required Map<String, dynamic> datosClinicosArea,
  }) async {
    final client = _client;
    final tenantId = _authService.currentTenantId;
    if (client == null || tenantId == null) return;
    _validarAcudienteSiMenor(datosPaciente);
    await client
        .from(SupabaseConstants.pacientes)
        .update(datosPaciente)
        .eq('id', id)
        .eq('tenant_id', tenantId);
    await client
        .from(SupabaseConstants.datosClinicosArea)
        .update({'datos': datosClinicosArea})
        .eq('paciente_id', id)
        .eq('tenant_id', tenantId);
  }

  Future<void> desactivarPaciente(String id) async {
    final client = _client;
    final tenantId = _authService.currentTenantId;
    if (client == null || tenantId == null) return;
    await client
        .from(SupabaseConstants.pacientes)
        .update({'activo': false})
        .eq('id', id)
        .eq('tenant_id', tenantId);
  }

  void _validarAcudienteSiMenor(Map<String, dynamic> datosPaciente) {
    final rawDate = datosPaciente['fecha_nacimiento'];
    final fecha = rawDate is DateTime ? rawDate : DateTime.tryParse('$rawDate');
    if (fecha == null) return;
    final now = DateTime.now();
    var edad = now.year - fecha.year;
    if (DateTime(now.year, fecha.month, fecha.day).isAfter(now)) edad--;
    if (edad >= 18) return;
    final nombre = '${datosPaciente['acudiente_nombre'] ?? ''}'.trim();
    final telefono = '${datosPaciente['acudiente_tel'] ?? ''}'.trim();
    if (nombre.isEmpty || telefono.isEmpty) {
      throw const BusinessRuleException(
        'Los pacientes menores de edad requieren nombre y telefono de acudiente.',
        code: 'RN-07',
      );
    }
  }
}
