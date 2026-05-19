import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../providers/auth_provider.dart';

class PerfilScreen extends ConsumerWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          profile.when(
            loading: () => const Card(child: ListTile(title: Text('Cargando perfil...'))),
            error: (e, _) => Card(child: ListTile(title: const Text('Perfil local'), subtitle: Text('$e'))),
            data: (u) => Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                title: Text(u?.nombre.isNotEmpty == true ? u!.nombre : 'Fonoaudiologa'),
                subtitle: Text('${u?.consultorio ?? 'Consultorio'} - TP ${u?.tarjetaProfesional ?? '-'}'),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.workspace_premium_outlined),
              title: const Text('Plan y limites'),
              subtitle: const Text('Ver suscripcion actual'),
              onTap: () => context.go('/settings/suscripcion'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesion'),
              onTap: () async {
                await ref.read(authServiceProvider).logout();
                if (context.mounted) context.go(AppRoutes.login);
              },
            ),
          ),
        ],
      ),
    );
  }
}
