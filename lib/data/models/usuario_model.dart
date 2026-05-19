class UsuarioModel {
  const UsuarioModel({
    required this.id,
    required this.tenantId,
    required this.email,
    required this.nombre,
    required this.rol,
    this.consultorio,
    this.tarjetaProfesional,
  });

  final String id;
  final String tenantId;
  final String email;
  final String nombre;
  final String rol;
  final String? consultorio;
  final String? tarjetaProfesional;

  factory UsuarioModel.fromJson(Map<String, dynamic> json) => UsuarioModel(
        id: json['id'] as String,
        tenantId: json['tenant_id'] as String? ?? '',
        email: json['email'] as String? ?? '',
        nombre: json['nombre'] as String? ?? '',
        rol: json['rol'] as String? ?? 'admin',
        consultorio: json['consultorio'] as String?,
        tarjetaProfesional: json['tarjeta_profesional'] as String?,
      );
}
