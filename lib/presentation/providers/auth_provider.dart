import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/usuario_model.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/supabase_access.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authChangesProvider = StreamProvider((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final currentUserProvider = Provider((ref) {
  ref.watch(authChangesProvider);
  return ref.watch(authServiceProvider).currentUser;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  if (!hasSupabaseConfig) return kDebugMode;
  return ref.watch(currentUserProvider) != null;
});

final currentProfileProvider = FutureProvider<UsuarioModel?>((ref) {
  ref.watch(authChangesProvider);
  return ref.watch(authServiceProvider).fetchCurrentProfile();
});
