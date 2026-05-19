import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/paciente_provider.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_list.dart';

class EvolucionesScreen extends ConsumerWidget {
  const EvolucionesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pacientes = ref.watch(pacientesProvider);
    return pacientes.when(
      loading: () => const LoadingList(),
      error: (e, _) => EmptyState(icon: Icons.warning_amber, title: 'Error', subtitle: '$e'),
      data: (items) => items.isEmpty
          ? const EmptyState(icon: Icons.assignment_outlined, title: 'Sin pacientes', subtitle: 'Crea un paciente antes de registrar evoluciones.')
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) {
                final p = items[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.assignment_outlined),
                    title: Text(p.nombreCompleto),
                    subtitle: Text('${p.codigo} - ${p.areaAtencion}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('/pacientes/${p.id}'),
                  ),
                );
              },
            ),
    );
  }
}
