class PacienteModel {
  const PacienteModel({
    required this.id,
    required this.tenantId,
    required this.codigo,
    required this.nombres,
    required this.apellidos,
    required this.tipoDoc,
    required this.numDoc,
    required this.fechaNacimiento,
    required this.sexo,
    required this.areaAtencion,
    required this.diagnosticoCie10,
    required this.activo,
    required this.consentimientoFirmado,
    required this.createdAt,
    this.telefono,
    this.email,
    this.direccion,
    this.eps,
    this.acudienteNombre,
    this.acudienteTel,
    this.datosClinicosArea = const {},
  });

  final String id;
  final String tenantId;
  final String codigo;
  final String nombres;
  final String apellidos;
  final String tipoDoc;
  final String numDoc;
  final DateTime fechaNacimiento;
  final String sexo;
  final String? telefono;
  final String? email;
  final String? direccion;
  final String? eps;
  final String? acudienteNombre;
  final String? acudienteTel;
  final String areaAtencion;
  final String diagnosticoCie10;
  final bool activo;
  final bool consentimientoFirmado;
  final DateTime createdAt;
  final Map<String, dynamic> datosClinicosArea;

  String get nombreCompleto => '$nombres $apellidos'.trim();

  int get edad {
    final now = DateTime.now();
    var years = now.year - fechaNacimiento.year;
    if (DateTime(now.year, fechaNacimiento.month, fechaNacimiento.day).isAfter(now)) {
      years--;
    }
    return years;
  }

  factory PacienteModel.fromJson(Map<String, dynamic> json) {
    final datos = json['datos_clinicos_area'];
    Map<String, dynamic> datosArea = {};
    if (datos is List && datos.isNotEmpty && datos.first is Map) {
      datosArea = Map<String, dynamic>.from((datos.first as Map)['datos'] as Map? ?? {});
    } else if (datos is Map) {
      datosArea = Map<String, dynamic>.from(datos['datos'] as Map? ?? {});
    }

    return PacienteModel(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String? ?? '',
      codigo: json['codigo'] as String? ?? '',
      nombres: json['nombres'] as String? ?? '',
      apellidos: json['apellidos'] as String? ?? '',
      tipoDoc: json['tipo_doc'] as String? ?? 'CC',
      numDoc: json['num_doc'] as String? ?? '',
      fechaNacimiento: DateTime.parse(json['fecha_nacimiento'] as String),
      sexo: json['sexo'] as String? ?? 'F',
      telefono: json['telefono'] as String?,
      email: json['email'] as String?,
      direccion: json['direccion'] as String?,
      eps: json['eps'] as String?,
      acudienteNombre: json['acudiente_nombre'] as String?,
      acudienteTel: json['acudiente_tel'] as String?,
      areaAtencion: json['area_atencion'] as String? ?? 'AOS',
      diagnosticoCie10: json['diagnostico_cie10'] as String? ?? '',
      activo: json['activo'] as bool? ?? true,
      consentimientoFirmado: json['consentimiento_firmado'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
      datosClinicosArea: datosArea,
    );
  }

  Map<String, dynamic> toInsertJson({required String codigo, required String tenantId}) => {
        'tenant_id': tenantId,
        'codigo': codigo,
        'nombres': nombres,
        'apellidos': apellidos,
        'tipo_doc': tipoDoc,
        'num_doc': numDoc,
        'fecha_nacimiento': fechaNacimiento.toIso8601String().split('T').first,
        'sexo': sexo,
        'telefono': telefono,
        'email': email,
        'direccion': direccion,
        'eps': eps,
        'acudiente_nombre': acudienteNombre,
        'acudiente_tel': acudienteTel,
        'area_atencion': areaAtencion,
        'diagnostico_cie10': diagnosticoCie10,
        'consentimiento_firmado': consentimientoFirmado,
        'activo': activo,
      };
}
