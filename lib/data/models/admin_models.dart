class AppRegistrationSettings {
  const AppRegistrationSettings({
    required this.allowPublicRegistration,
    required this.registrationMessage,
  });

  final bool allowPublicRegistration;
  final String registrationMessage;

  factory AppRegistrationSettings.fromJson(Map<String, dynamic> json) {
    return AppRegistrationSettings(
      allowPublicRegistration:
          json['allow_public_registration'] as bool? ?? false,
      registrationMessage: json['registration_message'] as String? ??
          'Los registros publicos estan cerrados. Contacta al administrador.',
    );
  }

  static const fallbackOpen = AppRegistrationSettings(
    allowPublicRegistration: true,
    registrationMessage: '',
  );
}

class TenantAdminModel {
  const TenantAdminModel({
    required this.id,
    required this.nombre,
    required this.emailAdmin,
    required this.estado,
    required this.createdAt,
    this.planNombre,
    this.trialEndsAt,
    this.usuariosCount = 0,
    this.pacientesCount = 0,
  });

  final String id;
  final String nombre;
  final String emailAdmin;
  final String estado;
  final String? planNombre;
  final DateTime? trialEndsAt;
  final DateTime createdAt;
  final int usuariosCount;
  final int pacientesCount;

  factory TenantAdminModel.fromJson(Map<String, dynamic> json) {
    return TenantAdminModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String? ?? '',
      emailAdmin: json['email_admin'] as String? ?? '',
      estado: json['estado'] as String? ?? 'trial',
      planNombre: json['plan_nombre'] as String?,
      trialEndsAt: _parseDate(json['trial_ends_at']),
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      usuariosCount: (json['usuarios_count'] as num?)?.toInt() ?? 0,
      pacientesCount: (json['pacientes_count'] as num?)?.toInt() ?? 0,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
