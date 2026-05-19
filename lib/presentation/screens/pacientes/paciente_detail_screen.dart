import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/pdf_generator.dart';
import '../../providers/evolucion_provider.dart';
import '../../providers/paciente_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/evoluciones/evolucion_card.dart';

class PacienteDetailScreen extends ConsumerWidget {
  const PacienteDetailScreen({required this.pacienteId, super.key});

  final String pacienteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paciente = ref.watch(pacienteDetailProvider(pacienteId));
    final evoluciones = ref.watch(evolucionesPacienteProvider(pacienteId));
    return paciente.when(
      loading: () => const Scaffold(body: Center(child: Text('Cargando...'))),
      error: (e, _) => Scaffold(body: EmptyState(icon: Icons.warning_amber, title: 'Error', subtitle: '$e')),
      data: (p) {
        if (p == null) return const Scaffold(body: EmptyState(icon: Icons.person_off_outlined, title: 'Paciente no encontrado', subtitle: 'Verifica la ruta.'));
        return Scaffold(
          appBar: AppBar(title: Text(p.nombreCompleto)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.codigo, style: Theme.of(context).textTheme.titleLarge),
                      Text('${p.tipoDoc} ${p.numDoc} - ${p.edad} anos - ${p.areaAtencion}'),
                      Text('Consentimiento: ${p.consentimientoFirmado ? 'Firmado' : 'Pendiente'}'),
                      const SizedBox(height: 16),
                      Wrap(spacing: 10, runSpacing: 10, children: [
                        AppButton(label: 'Nueva evolucion', icon: Icons.note_add_outlined, onPressed: () => context.go('/pacientes/${p.id}/evolucion')),
                        AppButton(label: 'Consentimiento PDF', icon: Icons.picture_as_pdf_outlined, onPressed: () => PdfGenerator.compartirConsentimiento(p)),
                        AppButton(
                          label: 'Historia PDF',
                          icon: Icons.description_outlined,
                          onPressed: () async => PdfGenerator.compartirHistoriaClinica(
                            paciente: p,
                            evoluciones: await ref.read(evolucionesPacienteProvider(p.id).future),
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Evoluciones', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              evoluciones.when(
                loading: () => const Text('Cargando evoluciones...'),
                error: (e, _) => Text('$e'),
                data: (items) => items.isEmpty
                    ? const EmptyState(icon: Icons.assignment_outlined, title: 'Sin evoluciones', subtitle: 'Registra la primera sesion cuando el consentimiento este firmado.')
                    : Column(children: items.map((e) => EvolucionCard(evolucion: e)).toList()),
              ),
            ],
          ),
        );
      },
    );
  }
}
