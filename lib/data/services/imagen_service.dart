import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../core/config/env_config.dart';
import '../../core/constants/supabase_constants.dart';
import '../../core/errors/app_exception.dart';
import 'auth_service.dart';
import 'supabase_access.dart';

class ImagenService {
  ImagenService({AuthService? authService})
      : _authService = authService ?? AuthService();

  final AuthService _authService;

  Future<String> subirImagenClinica({
    required String pacienteId,
    required Uint8List bytes,
    required String filename,
    String? descripcion,
  }) async {
    final cloudName = EnvConfig.cloudinaryCloudName;
    final preset = EnvConfig.cloudinaryUploadPreset;
    final client = supabaseOrNull();
    final tenantId = _authService.currentTenantId;
    if (cloudName.isEmpty ||
        preset.isEmpty ||
        client == null ||
        tenantId == null) {
      throw const BusinessRuleException(
          'Configura Cloudinary y Supabase antes de subir imagenes.');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload'),
    )
      ..fields['upload_preset'] = preset
      ..fields['folder'] = 'fonoclinic/$tenantId/$pacienteId'
      ..files
          .add(http.MultipartFile.fromBytes('file', bytes, filename: filename));

    final response = await request.send();
    final body = await response.stream.bytesToString();
    if (response.statusCode >= 400) {
      throw BusinessRuleException('Cloudinary rechazo la imagen: $body');
    }

    final json = jsonDecode(body) as Map<String, dynamic>;
    final secureUrl = json['secure_url'] as String;
    await client.from(SupabaseConstants.imagenesClinicas).insert({
      'tenant_id': tenantId,
      'paciente_id': pacienteId,
      'url': secureUrl,
      'descripcion': descripcion,
    });
    return secureUrl;
  }
}
