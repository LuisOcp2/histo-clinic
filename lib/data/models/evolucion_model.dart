class EvolucionModel {
  const EvolucionModel({
    required this.id,
    required this.pacienteId,
    required this.tenantId,
    required this.profesionalId,
    required this.fechaAtencion,
    required this.numSesion,
    required this.modalidad,
    required this.motivoConsulta,
    required this.hallazgos,
    required this.intervencion,
    required this.respuestaPaciente,
    required this.plan,
    required this.createdAt,
    this.datosArea = const {},
    this.anexos = const [],
    this.proximaCita,
  });

  final String id;
  final String pacienteId;
  final String tenantId;
  final String profesionalId;
  final DateTime fechaAtencion;
  final int numSesion;
  final String modalidad;
  final String motivoConsulta;
  final String hallazgos;
  final String intervencion;
  final String respuestaPaciente;
  final String plan;
  final Map<String, dynamic> datosArea;
  final List<EvolucionAnexoModel> anexos;
  final DateTime? proximaCita;
  final DateTime createdAt;

  factory EvolucionModel.fromJson(Map<String, dynamic> json) {
    return EvolucionModel(
      id: json['id'] as String,
      pacienteId: json['paciente_id'] as String,
      tenantId: json['tenant_id'] as String? ?? '',
      profesionalId: json['profesional_id'] as String? ?? '',
      fechaAtencion: DateTime.parse(json['fecha_atencion'] as String),
      numSesion: json['num_sesion'] as int? ?? 0,
      modalidad: json['modalidad'] as String? ?? 'Presencial',
      motivoConsulta: json['motivo_consulta'] as String? ?? '',
      hallazgos: json['hallazgos'] as String? ?? '',
      intervencion: json['intervencion'] as String? ?? '',
      respuestaPaciente: json['respuesta_paciente'] as String? ?? '',
      plan: json['plan'] as String? ?? '',
      datosArea: Map<String, dynamic>.from(json['datos_area'] as Map? ?? {}),
      anexos: (json['evolucion_anexos'] as List<dynamic>? ?? const [])
          .map((item) =>
              EvolucionAnexoModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      proximaCita: json['proxima_cita'] == null
          ? null
          : DateTime.parse(json['proxima_cita'] as String),
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

class EvolucionAnexoModel {
  const EvolucionAnexoModel({
    required this.id,
    required this.evolucionId,
    required this.tipo,
    required this.contenido,
    required this.createdAt,
    required this.profesionalId,
  });

  final String id;
  final String evolucionId;
  final String tipo;
  final String contenido;
  final DateTime createdAt;
  final String profesionalId;

  String get titulo => tipo == 'enmienda' ? 'Enmienda' : 'Nota aclaratoria';

  factory EvolucionAnexoModel.fromJson(Map<String, dynamic> json) {
    return EvolucionAnexoModel(
      id: json['id'] as String,
      evolucionId: json['evolucion_id'] as String? ?? '',
      tipo: json['tipo'] as String? ?? 'nota_aclaratoria',
      contenido: json['contenido'] as String? ?? '',
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      profesionalId: json['profesional_id'] as String? ?? '',
    );
  }
}
