import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/paciente_provider.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_list.dart';
import '../../widgets/pacientes/paciente_card.dart';

class PacientesListScreen extends ConsumerWidget {
  const PacientesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pacientes = ref.watch(pacientesProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/pacientes/nuevo'),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), labelText: 'Buscar por nombre o documento'),
              onChanged: (value) => ref.read(pacienteSearchProvider.notifier).state = value,
            ),
          ),
          Expanded(
            child: pacientes.when(
              loading: () => const LoadingList(),
              error: (e, _) => EmptyState(icon: Icons.warning_amber, title: 'No se pudieron cargar pacientes', subtitle: '$e'),
              data: (items) => items.isEmpty
                  ? EmptyState(
                      icon: Icons.group_outlined,
                      title: 'Sin pacientes registrados',
                      subtitle: 'Agrega tu primer paciente para comenzar.',
                      actionLabel: 'Nuevo paciente',
                      onAction: () => context.go('/pacientes/nuevo'),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(pacientesProvider);
                        await ref.read(pacientesProvider.future);
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, index) => PacienteCard(
                          paciente: items[index],
                          onTap: () => context.go('/pacientes/${items[index].id}'),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
