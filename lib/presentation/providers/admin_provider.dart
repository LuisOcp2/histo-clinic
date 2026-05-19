import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/admin_models.dart';
import '../../data/services/admin_service.dart';
import 'auth_provider.dart';

final adminServiceProvider = Provider<AdminService>((ref) => AdminService());

final publicRegistrationSettingsProvider =
    FutureProvider<AppRegistrationSettings>((ref) {
  return ref.watch(adminServiceProvider).fetchPublicRegistrationSettings();
});

final isPlatformAdminProvider = FutureProvider<bool>((ref) {
  ref.watch(authChangesProvider);
  return ref.watch(adminServiceProvider).isPlatformAdmin();
});

final adminSettingsProvider = FutureProvider<AppRegistrationSettings>((ref) {
  ref.watch(authChangesProvider);
  return ref.watch(adminServiceProvider).fetchAdminSettings();
});

final adminTenantsProvider = FutureProvider<List<TenantAdminModel>>((ref) {
  ref.watch(authChangesProvider);
  return ref.watch(adminServiceProvider).fetchTenants();
});
