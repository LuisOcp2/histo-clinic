class CitaModel {
  const CitaModel({
    required this.id,
    required this.pacienteId,
    required this.tenantId,
    required this.profesionalId,
    required this.fechaHora,
    required this.duracionMin,
    required this.tipoCita,
    required this.modalidad,
    required this.estado,
    this.notas,
    this.linkVirtual,
    this.pacienteNombre,
  });

  final String id;
  final String pacienteId;
  final String tenantId;
  final String profesionalId;
  final DateTime fechaHora;
  final int duracionMin;
  final String tipoCita;
  final String modalidad;
  final String estado;
  final String? notas;
  final String? linkVirtual;
  final String? pacienteNombre;

  factory CitaModel.fromJson(Map<String, dynamic> json) {
    String? pacienteNombre;
    final paciente = json['pacientes'];
    if (paciente is Map) {
      pacienteNombre = '${paciente['nombres'] ?? ''} ${paciente['apellidos'] ?? ''}'.trim();
    }
    return CitaModel(
      id: json['id'] as String,
      pacienteId: json['paciente_id'] as String,
      tenantId: json['tenant_id'] as String? ?? '',
      profesionalId: json['profesional_id'] as String? ?? '',
      fechaHora: DateTime.parse(json['fecha_hora'] as String).toLocal(),
      duracionMin: json['duracion_min'] as int? ?? 45,
      tipoCita: json['tipo_cita'] as String? ?? 'Seguimiento',
      modalidad: json['modalidad'] as String? ?? 'Presencial',
      estado: json['estado'] as String? ?? 'Programada',
      notas: json['notas'] as String?,
      linkVirtual: json['link_virtual'] as String?,
      pacienteNombre: pacienteNombre,
    );
  }
}
