import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/pdf_generator.dart';
import '../../providers/evolucion_provider.dart';
import '../../providers/paciente_provider.dart';
import '../../widgets/common/empty_state.dart';

class ReporteScreen extends ConsumerWidget {
  const ReporteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pacientes = ref.watch(pacientesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes PDF')),
      body: pacientes.when(
        loading: () => const Center(child: Text('Cargando pacientes...')),
        error: (e, _) => EmptyState(icon: Icons.warning_amber, title: 'Error', subtitle: '$e'),
        data: (items) => items.isEmpty
            ? const EmptyState(icon: Icons.picture_as_pdf_outlined, title: 'Sin reportes', subtitle: 'Registra pacientes para generar documentos.')
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, index) {
                  final p = items[index];
                  return Card(
                    child: ListTile(
                      title: Text(p.nombreCompleto),
                      subtitle: Text(p.codigo),
                      trailing: Wrap(
                        spacing: 6,
                        children: [
                          IconButton(tooltip: 'Consentimiento', onPressed: () => PdfGenerator.compartirConsentimiento(p), icon: const Icon(Icons.assignment_turned_in_outlined)),
                          IconButton(
                            tooltip: 'Historia completa',
                            onPressed: () async => PdfGenerator.compartirHistoriaClinica(
                              paciente: p,
                              evoluciones: await ref.read(evolucionesPacienteProvider(p.id).future),
                            ),
                            icon: const Icon(Icons.picture_as_pdf_outlined),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
