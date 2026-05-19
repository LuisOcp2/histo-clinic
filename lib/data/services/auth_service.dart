import 'package:supabase_flutter/supabase_flutter.dart' as s;

import '../../core/constants/supabase_constants.dart';
import '../../core/errors/app_exception.dart';
import '../models/usuario_model.dart';
import 'supabase_access.dart';

class AuthService {
  s.SupabaseClient? get _client => supabaseOrNull();

  Stream<s.AuthState> get authStateChanges =>
      _client?.auth.onAuthStateChange ?? const Stream.empty();

  s.User? get currentUser => _client?.auth.currentUser;

  String? get currentTenantId {
    final user = currentUser;
    return user?.userMetadata?['tenant_id'] as String?;
  }

  Future<void> login({required String email, required String password}) async {
    final client = _client;
    if (client == null)
      throw const AuthException('Configura Supabase para iniciar sesion.');
    try {
      await client.auth.signInWithPassword(email: email, password: password);
    } on s.AuthException catch (e) {
      throw AuthException(e.message, code: e.statusCode);
    }
  }

  Future<void> register({
    required String nombre,
    required String consultorio,
    required String tarjetaProfesional,
    required String email,
    required String password,
  }) async {
    final client = _client;
    if (client == null)
      throw const AuthException('Configura Supabase para crear cuentas.');
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {
          'nombre': nombre,
          'consultorio': consultorio,
          'tarjeta_profesional': tarjetaProfesional,
        },
      );
      final userId = response.user?.id;
      if (userId == null) return;
      final tenantId = await client.rpc(
        SupabaseConstants.registrarTenantRpc,
        params: {
          'p_user_id': userId,
          'p_nombre': nombre,
          'p_email': email,
          'p_consultorio': consultorio,
          'p_tarjeta_profesional': tarjetaProfesional,
        },
      ) as String;
      if (client.auth.currentSession != null) {
        await client.auth.updateUser(
          s.UserAttributes(
            data: {
              'tenant_id': tenantId,
              'nombre': nombre,
              'consultorio': consultorio,
              'tarjeta_profesional': tarjetaProfesional,
            },
          ),
        );
      }
    } on s.AuthException catch (e) {
      throw AuthException(e.message, code: e.statusCode);
    } catch (e) {
      throw UnknownAppException('No se pudo completar el registro: $e');
    }
  }

  Future<void> sendPasswordReset(String email) async {
    final client = _client;
    if (client == null)
      throw const AuthException(
          'Configura Supabase para recuperar contrasenas.');
    try {
      await client.auth.resetPasswordForEmail(email);
    } on s.AuthException catch (e) {
      throw AuthException(e.message, code: e.statusCode);
    } catch (e) {
      throw UnknownAppException(
          'No se pudo enviar el correo de recuperacion: $e');
    }
  }

  Future<void> logout() async => _client?.auth.signOut();

  Future<UsuarioModel?> fetchCurrentProfile() async {
    final client = _client;
    final user = currentUser;
    if (client == null || user == null) return null;
    final json = await client
        .from(SupabaseConstants.usuarios)
        .select()
        .eq('id', user.id)
        .maybeSingle();
    return json == null ? null : UsuarioModel.fromJson(json);
  }
}
