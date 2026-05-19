import 'package:supabase_flutter/supabase_flutter.dart' as s;

import '../../core/constants/supabase_constants.dart';
import '../../core/errors/app_exception.dart';
import '../models/admin_models.dart';
import 'supabase_access.dart';

class AdminService {
  s.SupabaseClient? get _client => supabaseOrNull();

  Future<AppRegistrationSettings> fetchPublicRegistrationSettings() async {
    final client = _client;
    if (client == null) return AppRegistrationSettings.fallbackOpen;
    try {
      final response =
          await client.rpc(SupabaseConstants.getPublicAppSettingsRpc);
      return _settingsFromRpc(response);
    } catch (_) {
      return AppRegistrationSettings.fallbackOpen;
    }
  }

  Future<bool> isPlatformAdmin() async {
    final client = _client;
    if (client == null || client.auth.currentUser == null) return false;
    try {
      return await client.rpc(SupabaseConstants.isPlatformAdminRpc) as bool? ??
          false;
    } catch (_) {
      return false;
    }
  }

  Future<AppRegistrationSettings> fetchAdminSettings() async {
    final client = _requireClient();
    try {
      final response = await client.rpc(SupabaseConstants.adminGetSettingsRpc);
      return _settingsFromRpc(response);
    } catch (e) {
      throw UnknownAppException('No se pudo cargar la configuracion: $e');
    }
  }

  Future<void> updateRegistrationSettings({
    required bool allowPublicRegistration,
    required String registrationMessage,
  }) async {
    final client = _requireClient();
    try {
      await client.rpc(
        SupabaseConstants.adminUpdateSettingsRpc,
        params: {
          'p_allow_public_registration': allowPublicRegistration,
          'p_registration_message': registrationMessage,
        },
      );
    } catch (e) {
      throw UnknownAppException('No se pudo actualizar registros: $e');
    }
  }

  Future<List<TenantAdminModel>> fetchTenants() async {
    final client = _requireClient();
    try {
      final response = await client.rpc(SupabaseConstants.adminListTenantsRpc);
      final rows = response as List<dynamic>? ?? const [];
      return rows
          .map((row) => TenantAdminModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw UnknownAppException('No se pudieron cargar los tenants: $e');
    }
  }

  Future<void> updateTenantStatus({
    required String tenantId,
    required String estado,
    DateTime? trialEndsAt,
  }) async {
    final client = _requireClient();
    try {
      await client.rpc(
        SupabaseConstants.adminUpdateTenantRpc,
        params: {
          'p_tenant_id': tenantId,
          'p_estado': estado,
          'p_trial_ends_at': trialEndsAt?.toUtc().toIso8601String(),
        },
      );
    } catch (e) {
      throw UnknownAppException('No se pudo actualizar la suscripcion: $e');
    }
  }

  s.SupabaseClient _requireClient() {
    final client = _client;
    if (client == null) {
      throw const AuthException('Configura Supabase para administrar.');
    }
    return client;
  }

  AppRegistrationSettings _settingsFromRpc(dynamic response) {
    if (response is List && response.isNotEmpty) {
      return AppRegistrationSettings.fromJson(
        response.first as Map<String, dynamic>,
      );
    }
    if (response is Map<String, dynamic>) {
      return AppRegistrationSettings.fromJson(response);
    }
    return AppRegistrationSettings.fallbackOpen;
  }
}
